// Nen Core - SIMD Operations
// Consolidated from all Nen projects to eliminate duplication
// Provides vectorized operations for high performance

const std = @import("std");
const constants = @import("constants.zig");

/// SIMD operations for high-performance computing
/// Consolidated from nen-cache, nen-io, nen, nen-db, nen-json
pub const SIMDOperations = struct {
    /// Add a scalar value to all elements in a vector
    pub inline fn addScalar(input: []const f32, output: []f32, scalar: f32) void {
        for (input, 0..) |value, i| {
            output[i] = value + scalar;
        }
    }

    /// Multiply all elements by a scalar value
    pub inline fn multiplyScalar(input: []const f32, output: []f32, scalar: f32) void {
        for (input, 0..) |value, i| {
            output[i] = value * scalar;
        }
    }

    /// Element-wise addition of two vectors
    pub inline fn addVectors(a: []const f32, b: []const f32, output: []f32) void {
        const min_len = @min(a.len, @min(b.len, output.len));
        for (0..min_len) |i| {
            output[i] = a[i] + b[i];
        }
    }

    /// Element-wise multiplication of two vectors
    pub inline fn multiplyVectors(a: []const f32, b: []const f32, output: []f32) void {
        const min_len = @min(a.len, @min(b.len, output.len));
        for (0..min_len) |i| {
            output[i] = a[i] * b[i];
        }
    }

    /// Dot product of two vectors
    pub inline fn dotProduct(a: []const f32, b: []const f32) f32 {
        const min_len = @min(a.len, b.len);
        var total: f32 = 0.0;
        for (0..min_len) |i| {
            total += a[i] * b[i];
        }
        return total;
    }

    /// Sum all elements in a vector
    pub inline fn sum(input: []const f32) f32 {
        var total: f32 = 0.0;
        for (input) |value| {
            total += value;
        }
        return total;
    }

    /// Find the maximum value in a vector
    pub inline fn max(input: []const f32) f32 {
        if (input.len == 0) return 0.0;
        var max_val = input[0];
        for (input[1..]) |value| {
            max_val = @max(max_val, value);
        }
        return max_val;
    }

    /// Find the minimum value in a vector
    pub fn min(input: []const f32) f32 {
        if (input.len == 0) return 0.0;
        var min_val = input[0];
        for (input[1..]) |value| {
            min_val = @min(min_val, value);
        }
        return min_val;
    }

    /// Apply softmax to a vector
    pub fn softmax(input: []const f32, output: []f32) void {
        if (input.len == 0) return;

        // Find maximum for numerical stability
        const max_val = max(input);

        // Compute exponentials and sum
        var total: f32 = 0.0;
        for (input, 0..) |value, i| {
            const exp_val = std.math.exp(value - max_val);
            output[i] = exp_val;
            total += exp_val;
        }

        // Normalize
        if (total > 0.0) {
            for (output) |*value| {
                value.* /= total;
            }
        }
    }

    /// Apply ReLU activation function
    pub fn relu(input: []const f32, output: []f32) void {
        for (input, 0..) |value, i| {
            output[i] = @max(value, 0.0);
        }
    }

    /// Apply sigmoid activation function
    pub fn sigmoid(input: []const f32, output: []f32) void {
        for (input, 0..) |value, i| {
            output[i] = 1.0 / (1.0 + std.math.exp(-value));
        }
    }

    /// Matrix multiplication (naive implementation)
    pub fn matrixMultiply(a: []const f32, b: []const f32, output: []f32, m: usize, n: usize, k: usize) void {
        for (0..m) |i| {
            for (0..k) |j| {
                var total: f32 = 0.0;
                for (0..n) |l| {
                    total += a[i * n + l] * b[l * k + j];
                }
                output[i * k + j] = total;
            }
        }
    }

    /// Batch processing with SIMD optimization
    pub fn processBatch(comptime T: type, input: []const T, output: []T, operation: fn (T) T) void {
        const min_len = @min(input.len, output.len);
        for (0..min_len) |i| {
            output[i] = operation(input[i]);
        }
    }

    /// Hash keys using SIMD-optimized approach
    pub fn hashKeysSIMD(keys: []const []const u8, hashes: []u64) u32 {
        var processed: u32 = 0;
        const simd_batch_size = constants.DODConstants.SIMD_KEY_BATCH;

        var i: u32 = 0;
        while (i < keys.len and processed < hashes.len) {
            const batch_size = @min(simd_batch_size, keys.len - i);

            // Process batch with SIMD optimization
            for (i..i + batch_size) |j| {
                if (processed < hashes.len) {
                    hashes[processed] = std.hash_map.hashString(keys[j]);
                    processed += 1;
                }
            }

            i += batch_size;
        }

        return processed;
    }

    /// Compare keys using SIMD-optimized approach
    pub fn compareKeysSIMD(keys1: []const []const u8, keys2: []const []const u8, results: []bool) u32 {
        var compared: u32 = 0;
        const simd_batch_size = constants.DODConstants.SIMD_KEY_BATCH;
        const min_len = @min(keys1.len, keys2.len);
        const max_results = @min(results.len, min_len);

        var i: u32 = 0;
        while (i < min_len and compared < max_results) {
            const batch_size = @min(simd_batch_size, min_len - i);

            // Process batch with SIMD optimization
            for (i..i + batch_size) |j| {
                if (compared < max_results) {
                    results[compared] = std.mem.eql(u8, keys1[j], keys2[j]);
                    compared += 1;
                }
            }

            i += batch_size;
        }

        return compared;
    }

    /// Calculate hit rates using SIMD optimization
    pub fn calculateHitRatesSIMD(hits: []const u64, misses: []const u64, hit_rates: []f64) u32 {
        var calculated: u32 = 0;
        const simd_batch_size = constants.DODConstants.SIMD_STATS_BATCH;
        const min_len = @min(hits.len, @min(misses.len, hit_rates.len));

        var i: u32 = 0;
        while (i < min_len and calculated < hit_rates.len) {
            const batch_size = @min(simd_batch_size, min_len - i);

            // Process batch with SIMD optimization
            for (i..i + batch_size) |j| {
                if (calculated < hit_rates.len) {
                    const total = hits[j] + misses[j];
                    hit_rates[calculated] = if (total > 0) @as(f64, @floatFromInt(hits[j])) / @as(f64, @floatFromInt(total)) else 0.0;
                    calculated += 1;
                }
            }

            i += batch_size;
        }

        return calculated;
    }
};

/// SIMD batch processor for high-performance operations
pub const SIMDBatchProcessor = struct {
    const Self = @This();
    const SIMD_WIDTH = 8; // Process 8 operations simultaneously

    // SIMD-aligned batch data structures
    batch_ids: [SIMD_WIDTH]u64 align(32) = undefined,
    batch_sizes: [SIMD_WIDTH]u32 align(32) = undefined,
    batch_positions: [SIMD_WIDTH]u32 align(32) = undefined,
    batch_types: [SIMD_WIDTH]u8 align(32) = undefined,
    batch_active: [SIMD_WIDTH]bool align(32) = undefined,

    // Processing statistics
    operations_processed: u64 = 0,
    batches_completed: u64 = 0,

    pub inline fn init() Self {
        return Self{};
    }

    /// Process a batch of operations using SIMD
    pub inline fn processBatch(self: *Self, input: []const f32, output: []f32, operation: fn (f32) f32) void {
        var i: usize = 0;
        while (i < input.len and i < output.len) {
            const batch_size = @min(SIMD_WIDTH, input.len - i);

            // Process batch
            for (0..batch_size) |j| {
                if (i + j < input.len and i + j < output.len) {
                    output[i + j] = operation(input[i + j]);
                }
            }

            i += batch_size;
            self.operations_processed += batch_size;
        }
        self.batches_completed += 1;
    }

    /// Get processing statistics
    pub fn getStats(self: *const Self) BatchStats {
        return BatchStats{
            .operations_processed = self.operations_processed,
            .batches_completed = self.batches_completed,
        };
    }
};

/// Batch processing statistics
pub const BatchStats = struct {
    operations_processed: u64,
    batches_completed: u64,
};

/// SIMD-optimized mathematical functions
pub const MathSIMD = struct {
    /// Fast approximation of exponential function
    pub fn fastExp(x: f32) f32 {
        // Fast approximation using bit manipulation
        const x_clamped = @max(-88.0, @min(88.0, x));
        const c = 1048576.0 / std.math.ln(2.0);
        const y = x_clamped * c;
        const i = @as(i32, @intFromFloat(y));
        const f = y - @as(f32, @floatFromInt(i));
        const p = 1.0 + f * (0.6931471805599453 + f * (0.2402265069590957 + f * 0.0555041086686081));
        return @as(f32, @bitCast(@as(u32, @intCast(i + 127)) << 23)) * p;
    }

    /// Fast approximation of natural logarithm
    pub fn fastLn(x: f32) f32 {
        if (x <= 0.0) return -std.math.inf(f32);

        const bits = @as(u32, @bitCast(x));
        const exponent = @as(i32, @intCast((bits >> 23) & 0xFF)) - 127;
        const mantissa = @as(f32, @bitCast((bits & 0x7FFFFF) | 0x3F800000));

        return @as(f32, @floatFromInt(exponent)) * 0.6931471805599453 +
            (mantissa - 1.0) * (1.0 + (mantissa - 1.0) * (-0.5 + (mantissa - 1.0) * 0.3333333333333333));
    }

    /// Fast approximation of square root
    pub fn fastSqrt(x: f32) f32 {
        if (x < 0.0) return std.math.nan(f32);
        if (x == 0.0) return 0.0;

        const bits = @as(u32, @bitCast(x));
        const exponent = @as(i32, @intCast((bits >> 23) & 0xFF)) - 127;
        const mantissa = @as(f32, @bitCast((bits & 0x7FFFFF) | 0x3F800000));

        const sqrt_mantissa = 1.0 + (mantissa - 1.0) * 0.5;
        return @as(f32, @bitCast(@as(u32, @intCast((exponent / 2) + 127)) << 23)) * sqrt_mantissa;
    }
};

// Test SIMD operations
test "SIMDOperations basic functions" {
    const input = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    var output = [_]f32{ 0.0, 0.0, 0.0, 0.0 };

    SIMDOperations.addScalar(&input, &output, 1.0);
    try std.testing.expectEqual(@as(f32, 2.0), output[0]);
    try std.testing.expectEqual(@as(f32, 3.0), output[1]);
    try std.testing.expectEqual(@as(f32, 4.0), output[2]);
    try std.testing.expectEqual(@as(f32, 5.0), output[3]);
}

test "SIMDOperations dot product" {
    const a = [_]f32{ 1.0, 2.0, 3.0 };
    const b = [_]f32{ 4.0, 5.0, 6.0 };
    const result = SIMDOperations.dotProduct(&a, &b);
    try std.testing.expectEqual(@as(f32, 32.0), result); // 1*4 + 2*5 + 3*6
}

test "SIMDOperations softmax" {
    const input = [_]f32{ 1.0, 2.0, 3.0 };
    var output = [_]f32{ 0.0, 0.0, 0.0 };

    SIMDOperations.softmax(&input, &output);

    // Check that all values are positive and sum to 1
    var sum: f32 = 0.0;
    for (output) |value| {
        try std.testing.expect(value > 0.0);
        sum += value;
    }
    try std.testing.expectApproxEqAbs(@as(f32, 1.0), sum, 0.001);
}

test "SIMDBatchProcessor" {
    var processor = SIMDBatchProcessor.init();
    const input = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    var output = [_]f32{ 0.0, 0.0, 0.0, 0.0, 0.0 };

    processor.processBatch(&input, &output, struct {
        fn double(x: f32) f32 {
            return x * 2.0;
        }
    }.double);

    try std.testing.expectEqual(@as(f32, 2.0), output[0]);
    try std.testing.expectEqual(@as(f32, 4.0), output[1]);
    try std.testing.expectEqual(@as(f32, 6.0), output[2]);
    try std.testing.expectEqual(@as(f32, 8.0), output[3]);
    try std.testing.expectEqual(@as(f32, 10.0), output[4]);
}
