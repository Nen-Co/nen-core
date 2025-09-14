// Nen Core - Advanced Allocator Patterns
// Stack-backed allocators and high-performance memory management
// Optimized for ReleaseFast builds with maximum efficiency

const std = @import("std");

/// Stack-backed arena allocator for ultra-fast temporary allocations
/// Perfect for batch processing and temporary data structures
pub const StackArena = struct {
    const Self = @This();

    buffer: []u8,
    offset: usize = 0,
    parent_allocator: std.mem.Allocator,

    pub fn init(parent_allocator: std.mem.Allocator, size: usize) !Self {
        return Self{
            .buffer = try parent_allocator.alloc(u8, size),
            .parent_allocator = parent_allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.parent_allocator.free(self.buffer);
    }

    /// Allocate memory from stack-backed buffer
    pub inline fn alloc(self: *Self, comptime T: type, count: usize) ![]T {
        const size = @sizeOf(T) * count;
        const alignment = @alignOf(T);

        // Align offset for proper alignment
        const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);

        if (aligned_offset + size > self.buffer.len) {
            return error.OutOfMemory;
        }

        const result = self.buffer[aligned_offset .. aligned_offset + size];
        self.offset = aligned_offset + size;

        return @as([*]T, @ptrCast(@alignCast(result.ptr)))[0..count];
    }

    /// Reset the arena for reuse (ultra-fast)
    pub inline fn reset(self: *Self) void {
        self.offset = 0;
    }

    /// Get current memory usage
    pub inline fn used(self: Self) usize {
        return self.offset;
    }

    /// Get remaining capacity
    pub inline fn remaining(self: Self) usize {
        return self.buffer.len - self.offset;
    }
};

/// Fixed-size stack allocator for compile-time known sizes
/// Zero-allocation for maximum performance
pub fn FixedStackAllocator(comptime size: usize) type {
    return struct {
        const Self = @This();

        buffer: [size]u8 = undefined,
        offset: usize = 0,

        pub inline fn alloc(self: *Self, comptime T: type, count: usize) ![]T {
            const alloc_size = @sizeOf(T) * count;
            const alignment = @alignOf(T);

            const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);

            if (aligned_offset + alloc_size > size) {
                return error.OutOfMemory;
            }

            const result = self.buffer[aligned_offset .. aligned_offset + alloc_size];
            self.offset = aligned_offset + alloc_size;

            return @as([*]T, @ptrCast(@alignCast(result.ptr)))[0..count];
        }

        pub inline fn reset(self: *Self) void {
            self.offset = 0;
        }

        pub inline fn used(self: Self) usize {
            return self.offset;
        }
    };
}

/// High-performance batch allocator for processing large datasets
/// Uses stack-backed allocation with automatic fallback
pub const BatchAllocator = struct {
    const Self = @This();

    stack_arena: StackArena,
    fallback_allocator: std.mem.Allocator,
    use_stack: bool = true,

    pub fn init(stack_size: usize, fallback_allocator: std.mem.Allocator) !Self {
        return Self{
            .stack_arena = try StackArena.init(fallback_allocator, stack_size),
            .fallback_allocator = fallback_allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stack_arena.deinit();
    }

    /// Allocate with automatic fallback to heap if stack is full
    pub fn alloc(self: *Self, comptime T: type, count: usize) ![]T {
        if (self.use_stack) {
            return self.stack_arena.alloc(T, count) catch |err| switch (err) {
                error.OutOfMemory => {
                    // Fallback to heap allocation
                    self.use_stack = false;
                    return self.fallback_allocator.alloc(T, count);
                },
                else => return err,
            };
        } else {
            return self.fallback_allocator.alloc(T, count);
        }
    }

    /// Free memory (only needed for heap allocations)
    pub fn free(self: *Self, memory: []u8) void {
        if (!self.use_stack) {
            self.fallback_allocator.free(memory);
        }
    }

    /// Reset for reuse
    pub inline fn reset(self: *Self) void {
        self.stack_arena.reset();
        self.use_stack = true;
    }
};

/// Memory pool with stack-backed allocation for high-frequency operations
pub const StackMemoryPool = struct {
    const Self = @This();

    buffer: []u8,
    free_blocks: []usize,
    free_count: usize,
    block_size: usize,
    parent_allocator: std.mem.Allocator,

    pub fn init(parent_allocator: std.mem.Allocator, block_size: usize, block_count: usize) !Self {
        const total_size = block_size * block_count;
        const free_blocks = try parent_allocator.alloc(usize, block_count);

        // Initialize free list
        for (0..block_count) |i| {
            free_blocks[i] = i * block_size;
        }

        return Self{
            .buffer = try parent_allocator.alloc(u8, total_size),
            .free_blocks = free_blocks,
            .free_count = block_count,
            .block_size = block_size,
            .parent_allocator = parent_allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.parent_allocator.free(self.free_blocks);
        self.parent_allocator.free(self.buffer);
    }

    /// Allocate a block from the pool
    pub inline fn allocBlock(self: *Self) ![]u8 {
        if (self.free_count == 0) {
            return error.OutOfMemory;
        }

        self.free_count -= 1;
        const offset = self.free_blocks[self.free_count];
        return self.buffer[offset .. offset + self.block_size];
    }

    /// Free a block back to the pool
    pub inline fn freeBlock(self: *Self, block: []u8) void {
        const offset = @intFromPtr(block.ptr) - @intFromPtr(self.buffer.ptr);
        self.free_blocks[self.free_count] = offset;
        self.free_count += 1;
    }

    /// Get pool statistics
    pub inline fn getStats(self: Self) struct { total: usize, free: usize, used: usize } {
        return .{
            .total = self.buffer.len / self.block_size,
            .free = self.free_count,
            .used = (self.buffer.len / self.block_size) - self.free_count,
        };
    }
};

/// Zero-copy string allocator for temporary strings
pub const StringAllocator = struct {
    const Self = @This();

    arena: StackArena,

    pub fn init(parent_allocator: std.mem.Allocator, size: usize) !Self {
        return Self{
            .arena = try StackArena.init(parent_allocator, size),
        };
    }

    pub fn deinit(self: *Self) void {
        self.arena.deinit();
    }

    /// Allocate a string with automatic null termination
    pub inline fn allocString(self: *Self, data: []const u8) ![]u8 {
        const result = try self.arena.alloc(u8, data.len + 1);
        @memcpy(result[0..data.len], data);
        result[data.len] = 0;
        return result[0..data.len];
    }

    /// Format a string with automatic allocation
    pub fn formatString(self: *Self, comptime fmt: []const u8, args: anytype) ![]u8 {
        const formatted = try std.fmt.allocPrint(self.arena.parent_allocator, fmt, args);
        defer self.arena.parent_allocator.free(formatted);
        return self.allocString(formatted);
    }

    /// Reset for reuse
    pub inline fn reset(self: *Self) void {
        self.arena.reset();
    }
};

/// High-performance allocator wrapper with statistics
pub const ProfiledAllocator = struct {
    const Self = @This();

    parent_allocator: std.mem.Allocator,
    allocations: u64 = 0,
    deallocations: u64 = 0,
    bytes_allocated: u64 = 0,
    bytes_freed: u64 = 0,
    peak_usage: u64 = 0,
    current_usage: u64 = 0,

    pub fn init(parent_allocator: std.mem.Allocator) Self {
        return Self{
            .parent_allocator = parent_allocator,
        };
    }

    /// Create a proper allocator interface
    pub fn allocator(self: *Self) std.mem.Allocator {
        return std.mem.Allocator{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free,
            },
        };
    }

    fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[]u8 {
        const self: *Self = @ptrCast(@alignCast(ctx));
        const result = self.parent_allocator.rawAlloc(len, ptr_align, ret_addr);
        if (result) |slice| {
            self.allocations += 1;
            self.bytes_allocated += slice.len;
            self.current_usage += slice.len;
            self.peak_usage = @max(self.peak_usage, self.current_usage);
        }
        return result;
    }

    fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) ?usize {
        const self: *Self = @ptrCast(@alignCast(ctx));
        const result = self.parent_allocator.rawResize(buf, buf_align, new_len, ret_addr);
        if (result) |new_size| {
            const old_size = buf.len;
            if (new_size > old_size) {
                self.bytes_allocated += new_size - old_size;
                self.current_usage += new_size - old_size;
                self.peak_usage = @max(self.peak_usage, self.current_usage);
            } else {
                self.bytes_freed += old_size - new_size;
                self.current_usage -= old_size - new_size;
            }
        }
        return result;
    }

    fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
        const self: *Self = @ptrCast(@alignCast(ctx));
        self.parent_allocator.rawFree(buf, buf_align, ret_addr);
        self.deallocations += 1;
        self.bytes_freed += buf.len;
        self.current_usage -= buf.len;
    }

    /// Get allocation statistics
    pub fn getStats(self: Self) struct {
        allocations: u64,
        deallocations: u64,
        bytes_allocated: u64,
        bytes_freed: u64,
        peak_usage: u64,
        current_usage: u64,
        net_allocations: u64,
        net_bytes: u64,
    } {
        return .{
            .allocations = self.allocations,
            .deallocations = self.deallocations,
            .bytes_allocated = self.bytes_allocated,
            .bytes_freed = self.bytes_freed,
            .peak_usage = self.peak_usage,
            .current_usage = self.current_usage,
            .net_allocations = self.allocations - self.deallocations,
            .net_bytes = self.bytes_allocated - self.bytes_freed,
        };
    }
};
