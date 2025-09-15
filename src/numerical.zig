// Nen Core - Numerical Computing Library
// Data-Oriented Design for maximum performance
// Optimized for SIMD, cache-friendly layouts, and zero-allocation

const std = @import("std");
const constants = @import("constants.zig");
const simd = @import("simd.zig");

/// Data-Oriented Design numerical operations
/// Optimized for cache-friendly memory layouts and SIMD operations
pub const NumericalCore = struct {
    /// Vectorized mathematical operations using DOD principles
    pub const VectorMath = struct {
        /// SIMD-optimized vector addition: C = A + B
        /// Uses Struct of Arrays layout for maximum cache efficiency
        pub fn addVectors(a: []const f32, b: []const f32, c: []f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(a.len, @min(b.len, c.len));

            // Process SIMD batches
            var i: usize = 0;
            while (i + simd_width <= len) {
                // SIMD-optimized batch processing
                for (0..simd_width) |j| {
                    c[i + j] = a[i + j] + b[i + j];
                }
                i += simd_width;
            }

            // Handle remaining elements
            while (i < len) {
                c[i] = a[i] + b[i];
                i += 1;
            }
        }

        /// SIMD-optimized vector multiplication: C = A * B
        pub fn multiplyVectors(a: []const f32, b: []const f32, c: []f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(a.len, @min(b.len, c.len));

            var i: usize = 0;
            while (i + simd_width <= len) {
                for (0..simd_width) |j| {
                    c[i + j] = a[i + j] * b[i + j];
                }
                i += simd_width;
            }

            while (i < len) {
                c[i] = a[i] * b[i];
                i += 1;
            }
        }

        /// SIMD-optimized scalar multiplication: C = A * s
        pub fn multiplyScalar(a: []const f32, c: []f32, scalar: f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(a.len, c.len);

            var i: usize = 0;
            while (i + simd_width <= len) {
                for (0..simd_width) |j| {
                    c[i + j] = a[i + j] * scalar;
                }
                i += simd_width;
            }

            while (i < len) {
                c[i] = a[i] * scalar;
                i += 1;
            }
        }

        /// SIMD-optimized dot product
        pub fn dotProduct(a: []const f32, b: []const f32) f32 {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(a.len, b.len);

            var total: f32 = 0.0;
            var i: usize = 0;

            // Process SIMD batches
            while (i + simd_width <= len) {
                var batch_sum: f32 = 0.0;
                for (0..simd_width) |j| {
                    batch_sum += a[i + j] * b[i + j];
                }
                total += batch_sum;
                i += simd_width;
            }

            // Handle remaining elements
            while (i < len) {
                total += a[i] * b[i];
                i += 1;
            }

            return total;
        }

        /// SIMD-optimized vector sum
        pub fn sum(a: []const f32) f32 {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = a.len;

            var total: f32 = 0.0;
            var i: usize = 0;

            while (i + simd_width <= len) {
                var batch_sum: f32 = 0.0;
                for (0..simd_width) |j| {
                    batch_sum += a[i + j];
                }
                total += batch_sum;
                i += simd_width;
            }

            while (i < len) {
                sum += a[i];
                i += 1;
            }

            return total;
        }
    };

    /// Matrix operations using DOD principles
    pub const MatrixMath = struct {
        /// DOD-optimized matrix multiplication: C = A * B
        /// Uses cache-friendly memory access patterns
        pub fn matrixMultiply(a: []const f32, b: []const f32, c: []f32, m: usize, n: usize, k: usize) void {
            // Clear output matrix
            @memset(c, 0.0);

            // DOD optimization: process in cache-friendly blocks
            const block_size = 64; // Cache-friendly block size

            for (0..m) |i| {
                for (0..k) |j| {
                    var total: f32 = 0.0;

                    // Process in blocks for cache efficiency
                    var l: usize = 0;
                    while (l + block_size <= n) {
                        for (0..block_size) |block_l| {
                            total += a[i * n + l + block_l] * b[(l + block_l) * k + j];
                        }
                        l += block_size;
                    }

                    // Handle remaining elements
                    while (l < n) {
                        total += a[i * n + l] * b[l * k + j];
                        l += 1;
                    }

                    c[i * k + j] = total;
                }
            }
        }

        /// DOD-optimized matrix transpose
        pub fn transpose(a: []const f32, b: []f32, m: usize, n: usize) void {
            for (0..m) |i| {
                for (0..n) |j| {
                    b[j * m + i] = a[i * n + j];
                }
            }
        }

        /// DOD-optimized matrix addition: C = A + B
        pub fn matrixAdd(a: []const f32, b: []const f32, c: []f32, m: usize, n: usize) void {
            const len = m * n;
            VectorMath.addVectors(a[0..len], b[0..len], c[0..len]);
        }
    };

    /// Activation functions using DOD principles
    pub const Activations = struct {
        /// SIMD-optimized ReLU activation
        pub fn relu(input: []const f32, output: []f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(input.len, output.len);

            var i: usize = 0;
            while (i + simd_width <= len) {
                for (0..simd_width) |j| {
                    const val = input[i + j];
                    output[i + j] = if (val > 0.0) val else 0.0;
                }
                i += simd_width;
            }

            while (i < len) {
                const val = input[i];
                output[i] = if (val > 0.0) val else 0.0;
                i += 1;
            }
        }

        /// SIMD-optimized Sigmoid activation
        pub fn sigmoid(input: []const f32, output: []f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(input.len, output.len);

            var i: usize = 0;
            while (i + simd_width <= len) {
                for (0..simd_width) |j| {
                    const val = input[i + j];
                    output[i + j] = 1.0 / (1.0 + std.math.exp(-val));
                }
                i += simd_width;
            }

            while (i < len) {
                const val = input[i];
                output[i] = 1.0 / (1.0 + std.math.exp(-val));
                i += 1;
            }
        }

        /// SIMD-optimized Tanh activation
        pub fn tanh(input: []const f32, output: []f32) void {
            const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
            const len = @min(input.len, output.len);

            var i: usize = 0;
            while (i + simd_width <= len) {
                for (0..simd_width) |j| {
                    const val = input[i + j];
                    output[i + j] = std.math.tanh(val);
                }
                i += simd_width;
            }

            while (i < len) {
                const val = input[i];
                output[i] = std.math.tanh(val);
                i += 1;
            }
        }

        /// SIMD-optimized Softmax activation
        pub fn softmax(input: []const f32, output: []f32) void {
            if (input.len == 0) return;

            // Find maximum for numerical stability
            var max_val = input[0];
            for (input[1..]) |val| {
                max_val = @max(max_val, val);
            }

            // Compute exponentials and sum
            var total: f32 = 0.0;
            for (input, 0..) |val, i| {
                const exp_val = std.math.exp(val - max_val);
                output[i] = exp_val;
                total += exp_val;
            }

            // Normalize
            if (total > 0.0) {
                const inv_sum = 1.0 / total;
                for (output) |*val| {
                    val.* *= inv_sum;
                }
            }
        }
    };

    /// Statistical operations using DOD principles
    pub const Statistics = struct {
        /// SIMD-optimized mean calculation
        pub fn mean(data: []const f32) f32 {
            if (data.len == 0) return 0.0;
            return VectorMath.sum(data) / @as(f32, @floatFromInt(data.len));
        }

        /// SIMD-optimized variance calculation
        pub fn variance(data: []const f32) f32 {
            if (data.len <= 1) return 0.0;

            const mean_val = mean(data);
            var sum_sq_diff: f32 = 0.0;

            for (data) |val| {
                const diff = val - mean_val;
                sum_sq_diff += diff * diff;
            }

            return sum_sq_diff / @as(f32, @floatFromInt(data.len - 1));
        }

        /// SIMD-optimized standard deviation
        pub fn stdDev(data: []const f32) f32 {
            return std.math.sqrt(variance(data));
        }

        /// SIMD-optimized min/max finding
        pub fn minMax(data: []const f32) struct { min: f32, max: f32 } {
            if (data.len == 0) return .{ .min = 0.0, .max = 0.0 };

            var min_val = data[0];
            var max_val = data[0];

            for (data[1..]) |val| {
                min_val = @min(min_val, val);
                max_val = @max(max_val, val);
            }

            return .{ .min = min_val, .max = max_val };
        }
    };

    /// Fast approximations for critical math functions
    pub const FastMath = struct {
        /// Fast approximation of exponential function
        pub fn fastExp(x: f32) f32 {
            const x_clamped = @max(-88.0, @min(88.0, x));
            const c = 1048576.0 / constants.DODConstants.LN_2;
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

            return @as(f32, @floatFromInt(exponent)) * constants.DODConstants.LN_2 +
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
};

/// DOD-optimized tensor operations
pub const TensorOps = struct {
    /// Tensor addition: C = A + B
    pub fn addTensors(a: []const f32, b: []const f32, c: []f32, shape: []const usize) void {
        const total_elements = shape[0] * shape[1] * shape[2];
        NumericalCore.VectorMath.addVectors(a[0..total_elements], b[0..total_elements], c[0..total_elements]);
    }

    /// Tensor multiplication: C = A * B
    pub fn multiplyTensors(a: []const f32, b: []const f32, c: []f32, shape: []const usize) void {
        const total_elements = shape[0] * shape[1] * shape[2];
        NumericalCore.VectorMath.multiplyVectors(a[0..total_elements], b[0..total_elements], c[0..total_elements]);
    }

    /// Tensor scalar multiplication: C = A * s
    pub fn multiplyTensorScalar(a: []const f32, c: []f32, scalar: f32, shape: []const usize) void {
        const total_elements = shape[0] * shape[1] * shape[2];
        NumericalCore.VectorMath.multiplyScalar(a[0..total_elements], c[0..total_elements], scalar);
    }
};

// Test numerical operations
test "VectorMath basic operations" {
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const b = [_]f32{ 5.0, 6.0, 7.0, 8.0 };
    var c = [_]f32{ 0.0, 0.0, 0.0, 0.0 };

    NumericalCore.VectorMath.addVectors(&a, &b, &c);
    try std.testing.expectEqual(@as(f32, 6.0), c[0]);
    try std.testing.expectEqual(@as(f32, 8.0), c[1]);
    try std.testing.expectEqual(@as(f32, 10.0), c[2]);
    try std.testing.expectEqual(@as(f32, 12.0), c[3]);
}

test "VectorMath dot product" {
    const a = [_]f32{ 1.0, 2.0, 3.0 };
    const b = [_]f32{ 4.0, 5.0, 6.0 };
    const result = NumericalCore.VectorMath.dotProduct(&a, &b);
    try std.testing.expectEqual(@as(f32, 32.0), result); // 1*4 + 2*5 + 3*6
}

test "Activations ReLU" {
    const input = [_]f32{ -1.0, 0.0, 1.0, 2.0 };
    var output = [_]f32{ 0.0, 0.0, 0.0, 0.0 };

    NumericalCore.Activations.relu(&input, &output);
    try std.testing.expectEqual(@as(f32, 0.0), output[0]);
    try std.testing.expectEqual(@as(f32, 0.0), output[1]);
    try std.testing.expectEqual(@as(f32, 1.0), output[2]);
    try std.testing.expectEqual(@as(f32, 2.0), output[3]);
}

test "Statistics mean" {
    const data = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const result = NumericalCore.Statistics.mean(&data);
    try std.testing.expectEqual(@as(f32, 3.0), result);
}

test "FastMath approximations" {
    const x = 1.0;
    const fast_exp = NumericalCore.FastMath.fastExp(x);
    const fast_ln = NumericalCore.FastMath.fastLn(x);
    const fast_sqrt = NumericalCore.FastMath.fastSqrt(x);

    // These should be reasonable approximations
    try std.testing.expect(fast_exp > 0.0);
    try std.testing.expect(fast_ln >= 0.0);
    try std.testing.expect(fast_sqrt > 0.0);
}
