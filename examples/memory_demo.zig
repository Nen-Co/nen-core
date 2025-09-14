// Nen Core - Memory Management Demo
// Demonstrates Data-Oriented Design memory management
// Shows static allocation patterns and zero-allocation design

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("=== Nen Core Memory Management Demo ===\n\n", .{});

    // Demonstrate static memory pools
    try demoStaticMemoryPools(allocator);

    // Demonstrate arena allocators
    try demoArenaAllocators(allocator);

    // Demonstrate ring buffers
    try demoRingBuffers(allocator);

    // Demonstrate memory pool statistics
    try demoMemoryStatistics(allocator);

    std.debug.print("\n=== Demo Complete ===\n", .{});
}

fn demoStaticMemoryPools(allocator: std.mem.Allocator) !void {
    std.debug.print("--- Static Memory Pools ---\n", .{});

    // Create a static memory pool
    var pool = try nen_core.StaticMemoryPool.init(allocator, 64, 10);
    defer pool.deinit();

    std.debug.print("Created pool with {} entries of {} bytes each\n", .{ pool.max_entries, pool.entry_size });

    // Allocate entries
    const entry1 = pool.allocate();
    const entry2 = pool.allocate();
    const entry3 = pool.allocate();

    std.debug.print("Allocated 3 entries\n", .{});

    if (entry1) |e1| {
        std.debug.print("Entry 1: {} bytes, used: {}\n", .{ e1.data.len, e1.is_used });
    }

    if (entry2) |e2| {
        std.debug.print("Entry 2: {} bytes, used: {}\n", .{ e2.data.len, e2.is_used });
    }

    if (entry3) |e3| {
        std.debug.print("Entry 3: {} bytes, used: {}\n", .{ e3.data.len, e3.is_used });
    }

    // Get pool statistics
    const stats = pool.getStats();
    std.debug.print("Pool Stats: {} total, {} used, {} free, {d:.2}% utilization\n", .{ stats.total_entries, stats.used_entries, stats.free_entries, stats.utilization * 100.0 });

    // Free entries
    if (entry1) |e1| pool.free(e1);
    if (entry2) |e2| pool.free(e2);
    if (entry3) |e3| pool.free(e3);

    std.debug.print("Freed all entries\n", .{});

    const stats_after = pool.getStats();
    std.debug.print("Pool Stats After Free: {} total, {} used, {} free, {d:.2}% utilization\n", .{ stats_after.total_entries, stats_after.used_entries, stats_after.free_entries, stats_after.utilization * 100.0 });

    std.debug.print("\n", .{});
}

fn demoArenaAllocators(allocator: std.mem.Allocator) !void {
    std.debug.print("--- Arena Allocators ---\n", .{});

    // Create an arena
    var arena = nen_core.Arena.init(allocator, 1024);
    defer arena.deinit();

    std.debug.print("Created arena with {} byte capacity\n", .{arena.max_size});

    // Allocate some data
    const data1 = try arena.alloc(u8, 100);
    const data2 = try arena.alloc(f32, 50);
    const data3 = try arena.alloc(u64, 25);

    std.debug.print("Allocated: {} u8, {} f32, {} u64\n", .{ data1.len, data2.len, data3.len });

    // Use the data
    for (data1, 0..) |*byte, i| {
        byte.* = @as(u8, @intCast(i % 256));
    }

    for (data2, 0..) |*val, i| {
        val.* = @as(f32, @floatFromInt(i));
    }

    for (data3, 0..) |*val, i| {
        val.* = @as(u64, @intCast(i * i));
    }

    std.debug.print("Initialized data arrays\n", .{});

    // Reset arena
    arena.reset();
    std.debug.print("Reset arena\n", .{});

    // Allocate new data
    const data4 = try arena.alloc(u8, 200);
    std.debug.print("Allocated new data: {} u8\n", .{data4.len});

    std.debug.print("\n", .{});
}

fn demoRingBuffers(allocator: std.mem.Allocator) !void {
    std.debug.print("--- Ring Buffers ---\n", .{});

    // Create a ring buffer
    var ring = try nen_core.RingBuffer.init(allocator, 100);
    defer ring.deinit(allocator);

    std.debug.print("Created ring buffer with {} byte capacity\n", .{ring.capacity});

    // Push some data
    try ring.push("Hello");
    try ring.push("World");
    try ring.push("Test");

    std.debug.print("Pushed 3 items, size: {}\n", .{ring.size});

    // Pop data
    var output: [20]u8 = undefined;
    const popped1 = try ring.pop(&output);
    std.debug.print("Popped {} bytes: {s}\n", .{ popped1, output[0..popped1] });

    const popped2 = try ring.pop(&output);
    std.debug.print("Popped {} bytes: {s}\n", .{ popped2, output[0..popped2] });

    const popped3 = try ring.pop(&output);
    std.debug.print("Popped {} bytes: {s}\n", .{ popped3, output[0..popped3] });

    std.debug.print("Ring buffer empty: {}\n", .{ring.isEmpty()});

    std.debug.print("\n", .{});
}

fn demoMemoryStatistics(allocator: std.mem.Allocator) !void {
    std.debug.print("--- Memory Statistics ---\n", .{});

    // Create a memory pool
    var pool = try nen_core.MemoryPool.init(allocator, 1024);
    defer pool.deinit();

    std.debug.print("Created memory pool with {} byte capacity\n", .{pool.buffer.len});

    // Allocate some memory
    const data1 = try pool.allocate(100, 8);
    const data2 = try pool.allocate(200, 16);
    const data3 = try pool.allocate(300, 32);

    std.debug.print("Allocated: {} bytes (100 + 200 + 300)\n", .{data1.len + data2.len + data3.len});
    std.debug.print("Pool offset: {}\n", .{pool.offset});

    // Reset pool
    pool.reset();
    std.debug.print("Reset pool, offset: {}\n", .{pool.offset});

    // Allocate again
    const data4 = try pool.allocate(500, 8);
    std.debug.print("Allocated {} bytes after reset\n", .{data4.len});

    std.debug.print("\n", .{});
}
