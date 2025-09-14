// Nen Core - Numerical Computing Demo
// Demonstrates Data-Oriented Design numerical operations
// Shows SIMD-optimized math operations and DOD layouts

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("=== Nen Core Numerical Computing Demo ===\n\n", .{});

    // Demonstrate SIMD-optimized vector operations
    demoVectorOperations();

    // Demonstrate DOD-optimized matrix operations
    demoMatrixOperations();

    // Demonstrate fast mathematical approximations
    demoFastMath();

    // Demonstrate DOD layouts
    try demoDODLayouts(allocator);

    // Demonstrate performance metrics
    demoPerformanceMetrics();

    std.debug.print("\n=== Demo Complete ===\n", .{});
}

fn demoVectorOperations() void {
    std.debug.print("--- Vector Operations (SIMD-Optimized) ---\n", .{});

    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0 };
    const b = [_]f32{ 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0 };
    var c = [_]f32{ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

    // SIMD-optimized vector addition
    nen_core.SIMDMath.addVectors(&a, &b, &c);
    std.debug.print("Vector Addition: {any} + {any} = {any}\n", .{ a, b, c });

    // SIMD-optimized dot product
    const dot = nen_core.SIMDMath.dotProduct(&a, &b);
    std.debug.print("Dot Product: {any} · {any} = {d}\n", .{ a, b, dot });

    // SIMD-optimized vector sum
    const sum = nen_core.SIMDMath.sum(&a);
    std.debug.print("Vector Sum: sum({any}) = {d}\n", .{ a, sum });

    // SIMD-optimized vector maximum
    const max = nen_core.SIMDMath.max(&a);
    std.debug.print("Vector Max: max({any}) = {d}\n", .{ a, max });

    std.debug.print("\n", .{});
}

fn demoMatrixOperations() void {
    std.debug.print("--- Matrix Operations (DOD-Optimized) ---\n", .{});

    // 2x2 matrix multiplication
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0 }; // 2x2 matrix
    const b = [_]f32{ 5.0, 6.0, 7.0, 8.0 }; // 2x2 matrix
    var c = [_]f32{ 0.0, 0.0, 0.0, 0.0 }; // 2x2 result

    nen_core.LinearAlgebra.matrixMultiply(&a, &b, &c, 2, 2, 2);
    std.debug.print("Matrix Multiplication:\n", .{});
    std.debug.print("A = [[{d}, {d}], [{d}, {d}]]\n", .{ a[0], a[1], a[2], a[3] });
    std.debug.print("B = [[{d}, {d}], [{d}, {d}]]\n", .{ b[0], b[1], b[2], b[3] });
    std.debug.print("C = A × B = [[{d}, {d}], [{d}, {d}]]\n", .{ c[0], c[1], c[2], c[3] });

    // Vector norm
    const norm = nen_core.LinearAlgebra.norm(&a);
    std.debug.print("Vector Norm: ||{any}|| = {d}\n", .{ a, norm });

    std.debug.print("\n", .{});
}

fn demoFastMath() void {
    std.debug.print("--- Fast Mathematical Approximations ---\n", .{});

    const x = 2.0;

    // Fast approximations
    const fast_exp = nen_core.FastMath.fastExp(x);
    const fast_ln = nen_core.FastMath.fastLn(x);
    const fast_sqrt = nen_core.FastMath.fastSqrt(x);
    const fast_sin = nen_core.FastMath.fastSin(x);
    const fast_cos = nen_core.FastMath.fastCos(x);
    const fast_pow = nen_core.FastMath.fastPow(x, 3.0);

    // Standard functions for comparison
    const std_exp = std.math.exp(x);
    const std_ln = @log(x);
    const std_sqrt = std.math.sqrt(x);
    const std_sin = std.math.sin(x);
    const std_cos = std.math.cos(x);
    const std_pow = std.math.pow(f32, x, 3.0);

    std.debug.print("Fast vs Standard Math (x = {d}):\n", .{x});
    std.debug.print("exp:  fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_exp, std_exp, @abs(fast_exp - std_exp) });
    std.debug.print("ln:   fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_ln, std_ln, @abs(fast_ln - std_ln) });
    std.debug.print("sqrt: fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_sqrt, std_sqrt, @abs(fast_sqrt - std_sqrt) });
    std.debug.print("sin:  fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_sin, std_sin, @abs(fast_sin - std_sin) });
    std.debug.print("cos:  fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_cos, std_cos, @abs(fast_cos - std_cos) });
    std.debug.print("pow:  fast={d:.6}, std={d:.6}, error={d:.6}\n", .{ fast_pow, std_pow, @abs(fast_pow - std_pow) });

    std.debug.print("\n", .{});
}

fn demoDODLayouts(allocator: std.mem.Allocator) !void {
    std.debug.print("--- DOD Layouts (Data-Oriented Design) ---\n", .{});

    // DOD I/O Layout
    var io_layout = nen_core.DODIOLayout.init();
    _ = io_layout.addOperation(1, 100, 0, 1);
    _ = io_layout.addOperation(2, 200, 100, 2);
    std.debug.print("DOD I/O Layout: {} active operations\n", .{io_layout.getActiveCount()});

    // DOD Node Layout
    var node_layout = try nen_core.DODNodeLayout.init(allocator, 10, 4);
    defer node_layout.deinit(allocator);

    const embedding1 = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const embedding2 = [_]f32{ 5.0, 6.0, 7.0, 8.0 };

    _ = node_layout.addNode(1, 2, 0.5, &embedding1);
    _ = node_layout.addNode(2, 3, 0.8, &embedding2);
    std.debug.print("DOD Node Layout: {} nodes added\n", .{node_layout.node_count});

    // DOD Tensor Layout
    var tensor_layout = try nen_core.DODTensorLayout.init(allocator, 5, 1000);
    defer tensor_layout.deinit(allocator);

    const shape = [_]u32{ 2, 3, 4, 1 };
    const data = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };

    _ = tensor_layout.addTensor(&shape, &data, 1);
    std.debug.print("DOD Tensor Layout: {} tensors added\n", .{tensor_layout.tensor_count});

    std.debug.print("\n", .{});
}

fn demoPerformanceMetrics() void {
    std.debug.print("--- Performance Metrics ---\n", .{});

    // Performance Timer
    var timer = nen_core.PerformanceTimer.init();
    timer.start();
    std.Thread.sleep(1000 * 1000); // 1 microsecond
    const elapsed = timer.stop();
    std.debug.print("Timer: {d}ns ({d:.2}μs)\n", .{ elapsed, @as(f64, @floatFromInt(elapsed)) / 1000.0 });

    // Memory Tracker
    var memory_tracker = nen_core.MemoryTracker.init();
    memory_tracker.recordAllocation(1000);
    memory_tracker.recordAllocation(2000);
    memory_tracker.recordDeallocation(500);
    std.debug.print("Memory: {} bytes allocated, {} bytes freed, {} bytes current\n", .{ memory_tracker.allocated_bytes, memory_tracker.freed_bytes, memory_tracker.current_usage });

    // Cache Tracker
    var cache_tracker = nen_core.CacheTracker.init();
    cache_tracker.recordHit();
    cache_tracker.recordHit();
    cache_tracker.recordMiss();
    std.debug.print("Cache: {d:.2}% hit rate, {d:.2}% miss rate\n", .{ cache_tracker.getHitRate() * 100.0, cache_tracker.getMissRate() * 100.0 });

    // Throughput Tracker
    var throughput_tracker = nen_core.ThroughputTracker.init();
    throughput_tracker.recordOperation();
    throughput_tracker.recordOperation();
    throughput_tracker.recordOperation();
    std.debug.print("Throughput: {d:.2} ops/sec\n", .{throughput_tracker.getThroughput()});

    std.debug.print("\n", .{});
}
