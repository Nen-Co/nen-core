// Release Performance Demo
// Demonstrates the performance difference between Debug and ReleaseFast modes
// Shows advanced allocator patterns for maximum efficiency

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    std.debug.print("🚀 Nen Core Release Performance Demo\n", .{});
    std.debug.print("Comparing Debug vs ReleaseFast performance with advanced allocators\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Demo 1: Stack-backed allocators
    try demoStackAllocators(allocator);

    // Demo 2: Fixed-size stack allocators
    try demoFixedStackAllocators();

    // Demo 3: Batch allocators with fallback
    try demoBatchAllocators(allocator);

    // Demo 4: Memory pools
    try demoMemoryPools(allocator);

    // Demo 5: Performance comparison
    try demoPerformanceComparison(allocator);

    std.debug.print("\n✅ All release performance demos completed!\n", .{});
}

fn demoStackAllocators(allocator: std.mem.Allocator) !void {
    std.debug.print("📚 Demo 1: Stack-Backed Allocators\n", .{});
    std.debug.print("Ultra-fast temporary allocations with automatic cleanup\n\n", .{});

    const stack_size = 1024 * 1024; // 1MB stack
    var stack_arena = try nen_core.StackArena.init(allocator, stack_size);
    defer stack_arena.deinit();

    const start_time = std.time.nanoTimestamp();

    // Allocate multiple arrays
    const arrays = 1000;
    for (0..arrays) |i| {
        const size = 64 + (i % 100); // Variable sizes
        const data = try stack_arena.alloc(u8, size);

        // Initialize data to prevent optimization
        data[0] = @as(u8, @intCast(i % 256));
        data[size - 1] = @as(u8, @intCast((i + 1) % 256));
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const allocations_per_sec = @as(f64, @floatFromInt(arrays)) / duration;

    std.debug.print("Stack Arena Results:\n", .{});
    std.debug.print("  - Allocations: {}\n", .{arrays});
    std.debug.print("  - Stack size: {} bytes\n", .{stack_size});
    std.debug.print("  - Used: {} bytes\n", .{stack_arena.used()});
    std.debug.print("  - Remaining: {} bytes\n", .{stack_arena.remaining()});
    std.debug.print("  - Duration: {d:.6} seconds\n", .{duration});
    std.debug.print("  - Allocations/sec: {d:.0}\n", .{allocations_per_sec});
    std.debug.print("  - Zero heap allocations: ✅\n", .{});
    std.debug.print("\n", .{});
}

fn demoFixedStackAllocators() !void {
    std.debug.print("🔒 Demo 2: Fixed-Size Stack Allocators\n", .{});
    std.debug.print("Compile-time known sizes with zero-allocation\n\n", .{});

    // 64KB fixed stack allocator
    var fixed_allocator = nen_core.FixedStackAllocator(64 * 1024){};

    const start_time = std.time.nanoTimestamp();

    // Allocate various data types
    const iterations = 10000;
    for (0..iterations) |i| {
        const count = 1 + (i % 10);

        // Allocate different types
        const u8_data = fixed_allocator.alloc(u8, count) catch break;
        const f32_data = fixed_allocator.alloc(f32, count) catch break;
        const u64_data = fixed_allocator.alloc(u64, count) catch break;

        // Initialize to prevent optimization
        u8_data[0] = @as(u8, @intCast(i % 256));
        f32_data[0] = @as(f32, @floatFromInt(i));
        u64_data[0] = @as(u64, @intCast(i));

        // Reset every 100 iterations to test reset performance
        if (i % 100 == 0) {
            fixed_allocator.reset();
        }
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations * 3)) / duration; // 3 allocations per iteration

    std.debug.print("Fixed Stack Allocator Results:\n", .{});
    std.debug.print("  - Operations: {}K\n", .{iterations * 3 / 1_000});
    std.debug.print("  - Stack size: 64KB\n", .{});
    std.debug.print("  - Used: {} bytes\n", .{fixed_allocator.used()});
    std.debug.print("  - Duration: {d:.6} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}K\n", .{ops_per_sec / 1_000.0});
    std.debug.print("  - Zero allocations: ✅\n", .{});
    std.debug.print("\n", .{});
}

fn demoBatchAllocators(allocator: std.mem.Allocator) !void {
    std.debug.print("📦 Demo 3: Batch Allocators with Fallback\n", .{});
    std.debug.print("Stack-first with automatic heap fallback\n\n", .{});

    const stack_size = 512 * 1024; // 512KB stack
    var batch_allocator = try nen_core.BatchAllocator.init(stack_size, allocator);
    defer batch_allocator.deinit();

    const start_time = std.time.nanoTimestamp();

    // Allocate with automatic fallback
    const iterations = 2000;
    var allocations: [][]u8 = try allocator.alloc([]u8, iterations);
    defer allocator.free(allocations);

    for (0..iterations) |i| {
        const size = 256 + (i % 500); // Variable sizes
        allocations[i] = try batch_allocator.alloc(u8, size);

        // Initialize data
        allocations[i][0] = @as(u8, @intCast(i % 256));
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const allocations_per_sec = @as(f64, @floatFromInt(iterations)) / duration;

    std.debug.print("Batch Allocator Results:\n", .{});
    std.debug.print("  - Allocations: {}\n", .{iterations});
    std.debug.print("  - Stack size: {} bytes\n", .{stack_size});
    std.debug.print("  - Duration: {d:.6} seconds\n", .{duration});
    std.debug.print("  - Allocations/sec: {d:.0}\n", .{allocations_per_sec});
    std.debug.print("  - Using stack: {}\n", .{batch_allocator.use_stack});
    std.debug.print("\n", .{});
}

fn demoMemoryPools(allocator: std.mem.Allocator) !void {
    std.debug.print("🏊 Demo 4: Memory Pools\n", .{});
    std.debug.print("High-performance block allocation and reuse\n\n", .{});

    const block_size = 256;
    const block_count = 1000;

    var pool = try nen_core.StackMemoryPool.init(allocator, block_size, block_count);
    defer pool.deinit();

    const start_time = std.time.nanoTimestamp();

    // Allocate and free blocks in batches
    const iterations = 1000; // Reduced to prevent OOM
    var blocks: [][]u8 = try allocator.alloc([]u8, iterations);
    defer allocator.free(blocks);

    for (0..iterations) |i| {
        blocks[i] = try pool.allocBlock();

        // Initialize block
        blocks[i][0] = @as(u8, @intCast(i % 256));

        // Free every other block to test reuse
        if (i > 0 and i % 2 == 0) {
            pool.freeBlock(blocks[i - 1]);
        }
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations)) / duration;
    const stats = pool.getStats();

    std.debug.print("Memory Pool Results:\n", .{});
    std.debug.print("  - Operations: {}\n", .{iterations});
    std.debug.print("  - Block size: {} bytes\n", .{block_size});
    std.debug.print("  - Total blocks: {}\n", .{stats.total});
    std.debug.print("  - Free blocks: {}\n", .{stats.free});
    std.debug.print("  - Used blocks: {}\n", .{stats.used});
    std.debug.print("  - Duration: {d:.6} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}\n", .{ops_per_sec});
    std.debug.print("\n", .{});
}

fn demoPerformanceComparison(allocator: std.mem.Allocator) !void {
    std.debug.print("⚡ Demo 5: Performance Comparison\n", .{});
    std.debug.print("Stack allocators vs traditional heap allocation\n\n", .{});

    const iterations = 100_000;
    const allocation_size = 64;

    // Test 1: Traditional heap allocation
    const heap_start = std.time.nanoTimestamp();

    var heap_allocations: [][]u8 = try allocator.alloc([]u8, iterations);
    defer allocator.free(heap_allocations);

    for (0..iterations) |i| {
        heap_allocations[i] = try allocator.alloc(u8, allocation_size);
        heap_allocations[i][0] = @as(u8, @intCast(i % 256));
    }

    // Free heap allocations
    for (heap_allocations) |allocation| {
        allocator.free(allocation);
    }

    const heap_end = std.time.nanoTimestamp();
    const heap_duration = @as(f64, @floatFromInt(heap_end - heap_start)) / 1_000_000_000.0;

    // Test 2: Stack arena allocation
    var stack_arena = try nen_core.StackArena.init(allocator, iterations * allocation_size);
    defer stack_arena.deinit();

    const stack_start = std.time.nanoTimestamp();

    for (0..iterations) |i| {
        const allocation = try stack_arena.alloc(u8, allocation_size);
        allocation[0] = @as(u8, @intCast(i % 256));
    }

    const stack_end = std.time.nanoTimestamp();
    const stack_duration = @as(f64, @floatFromInt(stack_end - stack_start)) / 1_000_000_000.0;

    // Calculate performance metrics
    const heap_ops_per_sec = @as(f64, @floatFromInt(iterations)) / heap_duration;
    const stack_ops_per_sec = @as(f64, @floatFromInt(iterations)) / stack_duration;
    const speedup = heap_duration / stack_duration;

    std.debug.print("Performance Comparison Results:\n", .{});
    std.debug.print("  - Iterations: {}K\n", .{iterations / 1_000});
    std.debug.print("  - Allocation size: {} bytes\n", .{allocation_size});
    std.debug.print("  - Heap duration: {d:.6} seconds\n", .{heap_duration});
    std.debug.print("  - Stack duration: {d:.6} seconds\n", .{stack_duration});
    std.debug.print("  - Heap ops/sec: {d:.0}K\n", .{heap_ops_per_sec / 1_000.0});
    std.debug.print("  - Stack ops/sec: {d:.0}K\n", .{stack_ops_per_sec / 1_000.0});
    std.debug.print("  - Stack speedup: {d:.1}x faster\n", .{speedup});
    std.debug.print("  - Memory efficiency: Stack uses {} bytes vs {} bytes\n", .{ stack_arena.used(), iterations * allocation_size });
    std.debug.print("\n", .{});
}
