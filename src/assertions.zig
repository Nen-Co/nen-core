// Nen Core - Assertion Helpers
// Data-Oriented Design assertion patterns consolidated from all Nen projects
// Provides compile-time and runtime safety checks

const std = @import("std");
const constants = @import("constants.zig");

/// DOD-optimized assertion helpers
/// Consolidated from nen-db, nen-ml, nen-inference, nen-cache
pub const Assertions = struct {
    /// Paired assertion helpers for DOD validation
    pub fn assertPositive(condition: bool, comptime msg: []const u8, args: anytype) void {
        if (!condition) {
            std.debug.panic("Assertion failed: " ++ msg, args);
        }
    }

    pub fn assertNegative(condition: bool, comptime msg: []const u8, args: anytype) void {
        if (condition) {
            std.debug.panic("Assertion failed: " ++ msg, args);
        }
    }

    /// Dimension assertions for tensor operations
    pub fn assertDim(actual: usize, expected: usize, comptime context: []const u8) void {
        if (actual != expected) {
            std.debug.panic("Dimension mismatch in {s}: expected {}, got {}", .{ context, expected, actual });
        }
    }

    /// Ring buffer assertions
    pub fn assertRing(condition: bool, comptime context: []const u8) void {
        if (!condition) {
            std.debug.panic("Ring buffer assertion failed in {s}", .{context});
        }
    }

    /// Memory alignment assertions
    pub fn assertAlign(ptr: *const anyopaque, alignment: usize, comptime context: []const u8) void {
        const addr = @intFromPtr(ptr);
        if (addr % alignment != 0) {
            std.debug.panic("Alignment assertion failed in {s}: pointer {} not aligned to {}", .{ context, addr, alignment });
        }
    }

    /// Bounds checking assertions
    pub fn assertBounds(index: usize, max: usize, comptime context: []const u8) void {
        if (index >= max) {
            std.debug.panic("Bounds assertion failed in {s}: index {} >= max {}", .{ context, index, max });
        }
    }

    /// Memory pool assertions
    pub fn assertPool(condition: bool, comptime context: []const u8) void {
        if (!condition) {
            std.debug.panic("Memory pool assertion failed in {s}", .{context});
        }
    }

    /// SIMD batch assertions
    pub fn assertBatch(batch_size: usize, max_batch: usize, comptime context: []const u8) void {
        if (batch_size > max_batch) {
            std.debug.panic("SIMD batch assertion failed in {s}: batch size {} > max {}", .{ context, batch_size, max_batch });
        }
    }

    /// Numerical precision assertions
    pub fn assertPrecision(actual: f32, expected: f32, tolerance: f32, comptime context: []const u8) void {
        const diff = @abs(actual - expected);
        if (diff > tolerance) {
            std.debug.panic("Precision assertion failed in {s}: |{} - {}| = {} > {}", .{ context, actual, expected, diff, tolerance });
        }
    }

    /// Compile-time assertions for DOD correctness
    pub fn assertComptime(comptime condition: bool, comptime msg: []const u8) void {
        if (!condition) {
            @compileError("Compile-time assertion failed: " ++ msg);
        }
    }

    /// Runtime assertions with custom error handling
    pub fn assertOrError(condition: bool, error_type: anytype) error_type!void {
        if (!condition) {
            return error_type;
        }
    }
};

/// DOD-specific assertion macros
pub const DODAssertions = struct {
    /// Assert tensor dimensions match expected layout
    pub fn assertTensorDims(actual_dims: []const usize, expected_dims: []const usize, comptime context: []const u8) void {
        if (actual_dims.len != expected_dims.len) {
            std.debug.panic("Tensor dimension count mismatch in {s}: expected {} dims, got {}", .{ context, expected_dims.len, actual_dims.len });
        }
        
        for (actual_dims, expected_dims, 0..) |actual, expected, i| {
            if (actual != expected) {
                std.debug.panic("Tensor dimension {} mismatch in {s}: expected {}, got {}", .{ i, context, expected, actual });
            }
        }
    }

    /// Assert memory layout is cache-friendly
    pub fn assertCacheFriendly(ptr: *const anyopaque, size: usize, comptime context: []const u8) void {
        const addr = @intFromPtr(ptr);
        const cache_line_size = constants.DODConstants.CACHE_LINE_SIZE;
        
        // Check that the memory region doesn't cross too many cache lines
        const start_line = addr / cache_line_size;
        const end_line = (addr + size - 1) / cache_line_size;
        const lines_used = end_line - start_line + 1;
        
        if (lines_used > 4) { // Allow up to 4 cache lines for efficiency
            std.debug.panic("Memory layout not cache-friendly in {s}: {} bytes span {} cache lines", .{ context, size, lines_used });
        }
    }

    /// Assert SIMD alignment
    pub fn assertSIMDAlign(ptr: *const anyopaque, simd_width: usize, comptime context: []const u8) void {
        const addr = @intFromPtr(ptr);
        const alignment = simd_width * @sizeOf(f32);
        
        if (addr % alignment != 0) {
            std.debug.panic("SIMD alignment assertion failed in {s}: pointer {} not aligned to {} for SIMD width {}", .{ context, addr, alignment, simd_width });
        }
    }

    /// Assert batch size is optimal for SIMD
    pub fn assertOptimalBatch(batch_size: usize, simd_width: usize, comptime context: []const u8) void {
        if (batch_size % simd_width != 0) {
            std.debug.panic("Batch size not optimal for SIMD in {s}: {} not divisible by SIMD width {}", .{ context, batch_size, simd_width });
        }
    }

    /// Assert memory pool utilization is reasonable
    pub fn assertPoolUtilization(used: usize, total: usize, max_utilization: f32, comptime context: []const u8) void {
        const utilization = @as(f32, @floatFromInt(used)) / @as(f32, @floatFromInt(total));
        if (utilization > max_utilization) {
            std.debug.panic("Memory pool utilization too high in {s}: {:.2}% > {:.2}%", .{ context, utilization * 100.0, max_utilization * 100.0 });
        }
    }
};

/// Performance assertions for critical paths
pub const PerformanceAssertions = struct {
    /// Assert execution time is within bounds
    pub fn assertExecutionTime(actual_ns: u64, max_ns: u64, comptime context: []const u8) void {
        if (actual_ns > max_ns) {
            std.debug.panic("Execution time exceeded in {s}: {}ns > {}ns", .{ context, actual_ns, max_ns });
        }
    }

    /// Assert memory usage is within bounds
    pub fn assertMemoryUsage(actual_bytes: usize, max_bytes: usize, comptime context: []const u8) void {
        if (actual_bytes > max_bytes) {
            std.debug.panic("Memory usage exceeded in {s}: {} bytes > {} bytes", .{ context, actual_bytes, max_bytes });
        }
    }

    /// Assert cache hit rate is acceptable
    pub fn assertCacheHitRate(hits: u64, misses: u64, min_hit_rate: f32, comptime context: []const u8) void {
        const total = hits + misses;
        if (total == 0) return;
        
        const hit_rate = @as(f32, @floatFromInt(hits)) / @as(f32, @floatFromInt(total));
        if (hit_rate < min_hit_rate) {
            std.debug.panic("Cache hit rate too low in {s}: {:.2}% < {:.2}%", .{ context, hit_rate * 100.0, min_hit_rate * 100.0 });
        }
    }
};

/// Debug assertions (only enabled in debug builds)
pub const DebugAssertions = struct {
    /// Debug-only assertion for development
    pub fn debugAssert(condition: bool, comptime msg: []const u8, args: anytype) void {
        if (constants.Features.ENABLE_DEBUG_LOGGING and !condition) {
            std.debug.print("DEBUG ASSERTION FAILED: " ++ msg ++ "\n", args);
            std.debug.panic("Debug assertion failed", .{});
        }
    }

    /// Debug-only memory leak detection
    pub fn debugMemoryLeak(allocated: usize, freed: usize, comptime context: []const u8) void {
        if (constants.Features.ENABLE_DEBUG_LOGGING and allocated != freed) {
            std.debug.print("DEBUG MEMORY LEAK in {s}: allocated {}, freed {}\n", .{ context, allocated, freed });
        }
    }

    /// Debug-only performance profiling
    pub fn debugProfile(comptime context: []const u8, comptime block: anytype) void {
        if (constants.Features.ENABLE_DEBUG_LOGGING) {
            const start = std.time.nanoTimestamp();
            block();
            const end = std.time.nanoTimestamp();
            std.debug.print("DEBUG PROFILE {s}: {}ns\n", .{ context, end - start });
        } else {
            block();
        }
    }
};

// Test assertions
test "Basic assertions" {
    Assertions.assertPositive(true, "This should not fail", .{});
    Assertions.assertNegative(false, "This should not fail", .{});
    Assertions.assertDim(5, 5, "test");
    Assertions.assertBounds(3, 10, "test");
    Assertions.assertPrecision(1.0, 1.0, 0.001, "test");
}

test "DOD assertions" {
    const dims = [_]usize{ 2, 3, 4 };
    const expected = [_]usize{ 2, 3, 4 };
    DODAssertions.assertTensorDims(&dims, &expected, "test");
    
    const ptr = @as(*const anyopaque, @ptrCast(&dims));
    DODAssertions.assertCacheFriendly(ptr, @sizeOf(@TypeOf(dims)), "test");
}

test "Performance assertions" {
    PerformanceAssertions.assertExecutionTime(1000, 2000, "test");
    PerformanceAssertions.assertMemoryUsage(1024, 2048, "test");
    PerformanceAssertions.assertCacheHitRate(80, 20, 0.7, "test");
}
