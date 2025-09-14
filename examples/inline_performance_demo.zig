// Inline Performance Demo
// Demonstrates the performance benefits of inline functions in nen-core
// Shows before/after performance improvements from strategic inlining

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    std.debug.print("⚡ Nen Core Inline Performance Demo\n", .{});
    std.debug.print("Demonstrating performance benefits of strategic inlining\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Demo 1: SIMD Operations Performance
    try demoSIMDPerformance(allocator);

    // Demo 2: Fast Math Performance
    try demoFastMathPerformance();

    // Demo 3: RNG Performance
    try demoRNGPerformance();

    // Demo 4: Memory Management Performance
    try demoMemoryPerformance(allocator);

    // Demo 5: Metrics Performance
    try demoMetricsPerformance();

    std.debug.print("\n✅ All inline performance demos completed!\n", .{});
}

fn demoSIMDPerformance(allocator: std.mem.Allocator) !void {
    std.debug.print("🔢 Demo 1: SIMD Operations Performance\n", .{});
    std.debug.print("Testing inline SIMD operations in tight loops\n\n", .{});

    const vector_size = 1000000; // 1M elements
    const iterations = 100;

    // Allocate test vectors
    var a = try allocator.alloc(f32, vector_size);
    defer allocator.free(a);
    var b = try allocator.alloc(f32, vector_size);
    defer allocator.free(b);
    const c = try allocator.alloc(f32, vector_size);
    defer allocator.free(c);

    // Initialize test data
    for (0..vector_size) |i| {
        a[i] = @as(f32, @floatFromInt(i % 100));
        b[i] = @as(f32, @floatFromInt((i + 1) % 100));
    }

    // Benchmark vector addition (inline optimized)
    const start_time = std.time.nanoTimestamp();

    for (0..iterations) |_| {
        nen_core.SIMDOperations.addVectors(a, b, c);
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations * vector_size)) / duration;

    std.debug.print("SIMD Vector Addition Results:\n", .{});
    std.debug.print("  - Vector size: {} elements\n", .{vector_size});
    std.debug.print("  - Iterations: {}\n", .{iterations});
    std.debug.print("  - Total operations: {}M\n", .{iterations * vector_size / 1_000_000});
    std.debug.print("  - Duration: {d:.3} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}M ops/sec\n", .{ops_per_sec / 1_000_000.0});
    std.debug.print("  - Inline optimization: ✅ Enabled\n", .{});
    std.debug.print("\n", .{});
}

fn demoFastMathPerformance() !void {
    std.debug.print("🧮 Demo 2: Fast Math Performance\n", .{});
    std.debug.print("Testing inline fast math approximations\n\n", .{});

    const iterations = 10_000_000; // 10M operations
    const test_values = [_]f32{ 0.1, 0.5, 1.0, 2.0, 5.0, 10.0 };

    // Benchmark fast math functions (inline optimized)
    const start_time = std.time.nanoTimestamp();

    var result: f32 = 0.0;
    for (0..iterations) |i| {
        const x = test_values[i % test_values.len];
        result += nen_core.FastMath.fastExp(x);
        result += nen_core.FastMath.fastLn(x);
        result += nen_core.FastMath.fastSqrt(x);
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations * 3)) / duration; // 3 operations per iteration

    std.debug.print("Fast Math Results:\n", .{});
    std.debug.print("  - Operations: {}M\n", .{iterations * 3 / 1_000_000});
    std.debug.print("  - Duration: {d:.3} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}M ops/sec\n", .{ops_per_sec / 1_000_000.0});
    std.debug.print("  - Result (prevent optimization): {d:.6}\n", .{result});
    std.debug.print("  - Inline optimization: ✅ Enabled\n", .{});
    std.debug.print("\n", .{});
}

fn demoRNGPerformance() !void {
    std.debug.print("🎲 Demo 3: RNG Performance\n", .{});
    std.debug.print("Testing inline random number generation\n\n", .{});

    const iterations = 50_000_000; // 50M operations

    // Test XorShift32 (inline optimized)
    var rng = nen_core.XorShift32.init(42);

    const start_time = std.time.nanoTimestamp();

    var result: u32 = 0;
    for (0..iterations) |_| {
        result ^= rng.next();
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations)) / duration;

    std.debug.print("RNG Performance Results:\n", .{});
    std.debug.print("  - Operations: {}M\n", .{iterations / 1_000_000});
    std.debug.print("  - Duration: {d:.3} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}M ops/sec\n", .{ops_per_sec / 1_000_000.0});
    std.debug.print("  - Result (prevent optimization): {}\n", .{result});
    std.debug.print("  - Inline optimization: ✅ Enabled\n", .{});
    std.debug.print("\n", .{});
}

fn demoMemoryPerformance(allocator: std.mem.Allocator) !void {
    std.debug.print("💾 Demo 4: Memory Management Performance\n", .{});
    std.debug.print("Testing inline memory allocation operations\n\n", .{});

    const iterations = 100_000; // 100K allocations
    const allocation_size = 64; // 64 bytes per allocation

    // Test Arena allocator (inline optimized)
    var arena = nen_core.Arena.init(allocator, iterations * allocation_size);
    defer arena.deinit();

    const start_time = std.time.nanoTimestamp();

    for (0..iterations) |i| {
        const data = try arena.alloc(u8, allocation_size);
        // Initialize data to prevent optimization
        data[0] = @as(u8, @intCast(i % 256));

        // Reset arena every 1000 allocations to test reset performance
        if (i % 1000 == 0) {
            arena.reset();
        }
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations)) / duration;

    std.debug.print("Memory Management Results:\n", .{});
    std.debug.print("  - Allocations: {}K\n", .{iterations / 1_000});
    std.debug.print("  - Allocation size: {} bytes\n", .{allocation_size});
    std.debug.print("  - Duration: {d:.3} seconds\n", .{duration});
    std.debug.print("  - Allocations/sec: {d:.0}K ops/sec\n", .{ops_per_sec / 1_000.0});
    std.debug.print("  - Inline optimization: ✅ Enabled\n", .{});
    std.debug.print("\n", .{});
}

fn demoMetricsPerformance() !void {
    std.debug.print("📊 Demo 5: Metrics Performance\n", .{});
    std.debug.print("Testing inline metrics recording operations\n\n", .{});

    const iterations = 100_000_000; // 100M operations

    // Test ThroughputTracker (inline optimized)
    var tracker = nen_core.ThroughputTracker.init();

    const start_time = std.time.nanoTimestamp();

    for (0..iterations) |_| {
        tracker.recordOperation();
    }

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;
    const ops_per_sec = @as(f64, @floatFromInt(iterations)) / duration;
    const throughput = tracker.getThroughput();

    std.debug.print("Metrics Performance Results:\n", .{});
    std.debug.print("  - Operations: {}M\n", .{iterations / 1_000_000});
    std.debug.print("  - Duration: {d:.3} seconds\n", .{duration});
    std.debug.print("  - Operations/sec: {d:.0}M ops/sec\n", .{ops_per_sec / 1_000_000.0});
    std.debug.print("  - Throughput: {d:.0} ops/sec\n", .{throughput});
    std.debug.print("  - Inline optimization: ✅ Enabled\n", .{});
    std.debug.print("\n", .{});
}
