// Nen Core - Memory Management
// Consolidated from all Nen projects to eliminate duplication
// Provides static memory allocation patterns for zero-allocation design

const std = @import("std");
const constants = @import("constants.zig");

/// Static memory pool for efficient allocation
/// Consolidated from nen-cache, nen-format, nen-db, nen-ml, nen-inference
pub const StaticMemoryPool = struct {
    entries: []StaticPoolEntry,
    data_buffer: []u8,
    free_list_head: ?usize,
    used_count: usize,
    max_entries: usize,
    entry_size: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, entry_size: usize, max_entries: usize) !StaticMemoryPool {
        // Allocate the data buffer
        const total_data_size = entry_size * max_entries;
        const data_buffer = try allocator.alloc(u8, total_data_size);

        // Allocate entry metadata
        const entries = try allocator.alloc(StaticPoolEntry, max_entries);

        // Initialize entries and free list
        for (0..max_entries) |i| {
            const data_start = i * entry_size;
            const data_end = data_start + entry_size;
            entries[i] = StaticPoolEntry.init(data_buffer[data_start..data_end]);

            if (i < max_entries - 1) {
                entries[i].next_free = i + 1;
            } else {
                entries[i].next_free = null;
            }
        }

        return StaticMemoryPool{
            .entries = entries,
            .data_buffer = data_buffer,
            .free_list_head = 0, // Start with first entry as free
            .used_count = 0,
            .max_entries = max_entries,
            .entry_size = entry_size,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *StaticMemoryPool) void {
        self.allocator.free(self.entries);
        self.allocator.free(self.data_buffer);
    }

    /// Allocate an entry from the pool (ZERO allocation)
    pub fn allocate(self: *StaticMemoryPool) ?*StaticPoolEntry {
        if (self.free_list_head) |free_index| {
            const entry = &self.entries[free_index];
            self.free_list_head = entry.next_free;
            entry.is_used = true;
            self.used_count += 1;
            return entry;
        }
        return null; // Pool is full
    }

    /// Free an entry back to the pool
    pub fn free(self: *StaticMemoryPool, entry: *StaticPoolEntry) void {
        if (entry.is_used) {
            entry.is_used = false;
            entry.next_free = self.free_list_head;
            self.free_list_head = self.getEntryIndex(entry);
            self.used_count -= 1;
        }
    }

    /// Get the index of an entry
    fn getEntryIndex(self: *const StaticMemoryPool, entry: *const StaticPoolEntry) ?usize {
        const entry_ptr = @intFromPtr(entry);
        const entries_ptr = @intFromPtr(self.entries.ptr);
        if (entry_ptr >= entries_ptr and entry_ptr < entries_ptr + (@sizeOf(StaticPoolEntry) * self.entries.len)) {
            return (entry_ptr - entries_ptr) / @sizeOf(StaticPoolEntry);
        }
        return null;
    }

    /// Get pool statistics
    pub fn getStats(self: *const StaticMemoryPool) PoolStats {
        return PoolStats{
            .total_entries = self.max_entries,
            .used_entries = self.used_count,
            .free_entries = self.max_entries - self.used_count,
            .utilization = @as(f32, @floatFromInt(self.used_count)) / @as(f32, @floatFromInt(self.max_entries)),
        };
    }
};

/// Static pool entry
pub const StaticPoolEntry = struct {
    data: []u8,
    is_used: bool = false,
    next_free: ?usize = null,

    pub fn init(data: []u8) StaticPoolEntry {
        return StaticPoolEntry{
            .data = data,
            .is_used = false,
            .next_free = null,
        };
    }
};

/// Pool statistics
pub const PoolStats = struct {
    total_entries: usize,
    used_entries: usize,
    free_entries: usize,
    utilization: f32,
};

/// Memory pool for efficient allocation
/// Consolidated from nen-format
pub const MemoryPool = struct {
    allocator: std.mem.Allocator,
    buffer: []u8,
    offset: usize,

    pub fn init(allocator: std.mem.Allocator, size: usize) !MemoryPool {
        const buffer = try allocator.alloc(u8, size);
        return MemoryPool{
            .allocator = allocator,
            .buffer = buffer,
            .offset = 0,
        };
    }

    pub fn deinit(self: *MemoryPool) void {
        self.allocator.free(self.buffer);
    }

    pub fn allocate(self: *MemoryPool, size: usize, alignment: usize) ![]u8 {
        const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);

        if (aligned_offset + size > self.buffer.len) {
            return error.OutOfMemory;
        }

        const result = self.buffer[aligned_offset .. aligned_offset + size];
        self.offset = aligned_offset + size;
        return result;
    }

    pub fn reset(self: *MemoryPool) void {
        self.offset = 0;
    }
};

/// Arena allocator for temporary allocations
/// Consolidated from nen-db, nen-ml, nen-inference
pub const Arena = struct {
    allocator: std.mem.Allocator,
    buffer: []u8,
    offset: usize,
    max_size: usize,

    pub fn init(allocator: std.mem.Allocator, max_size: usize) Arena {
        return Arena{
            .allocator = allocator,
            .buffer = &[_]u8{}, // Will be allocated on first use
            .offset = 0,
            .max_size = max_size,
        };
    }

    pub fn deinit(self: *Arena) void {
        if (self.buffer.len > 0) {
            self.allocator.free(self.buffer);
        }
    }

    pub inline fn alloc(self: *Arena, comptime T: type, count: usize) ![]T {
        const size = @sizeOf(T) * count;
        const alignment = @alignOf(T);

        // Allocate buffer if not already allocated
        if (self.buffer.len == 0) {
            self.buffer = try self.allocator.alloc(u8, self.max_size);
        }

        const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);

        if (aligned_offset + size > self.buffer.len) {
            return error.OutOfMemory;
        }

        const result = self.buffer[aligned_offset .. aligned_offset + size];
        self.offset = aligned_offset + size;

        return @as([*]T, @ptrCast(@alignCast(result.ptr)))[0..count];
    }

    pub inline fn reset(self: *Arena) void {
        self.offset = 0;
    }
};

/// Ring buffer for efficient circular data structures
/// Consolidated from nen-cache, nen-inference
pub const RingBuffer = struct {
    data: []u8,
    head: usize,
    tail: usize,
    size: usize,
    capacity: usize,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !RingBuffer {
        const data = try allocator.alloc(u8, capacity);
        return RingBuffer{
            .data = data,
            .head = 0,
            .tail = 0,
            .size = 0,
            .capacity = capacity,
        };
    }

    pub fn deinit(self: *RingBuffer, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn push(self: *RingBuffer, item: []const u8) !void {
        if (self.size >= self.capacity) {
            return error.BufferFull;
        }

        if (item.len > self.capacity) {
            return error.ItemTooLarge;
        }

        // Copy item to buffer
        const start = self.tail;
        const end = (self.tail + item.len) % self.capacity;

        if (end > start) {
            @memcpy(self.data[start..end], item);
        } else {
            // Wrap around
            const first_part = self.capacity - start;
            @memcpy(self.data[start..], item[0..first_part]);
            @memcpy(self.data[0..end], item[first_part..]);
        }

        self.tail = end;
        self.size += item.len;
    }

    pub fn pop(self: *RingBuffer, output: []u8) !usize {
        if (self.size == 0) {
            return 0;
        }

        const available = @min(output.len, self.size);
        const start = self.head;
        const end = (self.head + available) % self.capacity;

        if (end > start) {
            @memcpy(output[0..available], self.data[start..end]);
        } else {
            // Wrap around
            const first_part = self.capacity - start;
            @memcpy(output[0..first_part], self.data[start..]);
            @memcpy(output[first_part..available], self.data[0..end]);
        }

        self.head = end;
        self.size -= available;
        return available;
    }

    pub fn isFull(self: *const RingBuffer) bool {
        return self.size >= self.capacity;
    }

    pub fn isEmpty(self: *const RingBuffer) bool {
        return self.size == 0;
    }
};

// Test memory management
test "StaticMemoryPool" {
    var pool = try StaticMemoryPool.init(std.testing.allocator, 64, 10);
    defer pool.deinit();

    const entry = pool.allocate();
    try std.testing.expect(entry != null);
    try std.testing.expect(pool.used_count == 1);

    if (entry) |e| {
        pool.free(e);
        try std.testing.expect(pool.used_count == 0);
    }
}

test "MemoryPool" {
    var pool = try MemoryPool.init(std.testing.allocator, 1024);
    defer pool.deinit();

    const data = try pool.allocate(100, 8);
    try std.testing.expect(data.len == 100);
    try std.testing.expect(pool.offset == 100);
}

test "Arena" {
    var arena = Arena.init(std.testing.allocator, 1024);
    defer arena.deinit();

    const data = try arena.alloc(u8, 100);
    try std.testing.expect(data.len == 100);
}

test "RingBuffer" {
    var ring = try RingBuffer.init(std.testing.allocator, 100);
    defer ring.deinit(std.testing.allocator);

    try ring.push("hello");
    try std.testing.expect(ring.size == 5);

    var output: [10]u8 = undefined;
    const popped = try ring.pop(&output);
    try std.testing.expect(popped == 5);
    try std.testing.expectEqualStrings("hello", output[0..5]);
}
