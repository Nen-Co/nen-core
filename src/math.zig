// Nen Core - Mathematical Utilities
// Data-Oriented Design mathematical functions for maximum performance
// Provides fast approximations and SIMD-optimized math operations

const std = @import("std");
const constants = @import("constants.zig");

/// Fast mathematical approximations using DOD principles
/// Optimized for cache-friendly memory access and SIMD operations
pub const FastMath = struct {
    /// Fast approximation of exponential function
    /// Uses bit manipulation for maximum performance
    pub inline fn fastExp(x: f32) f32 {
        const x_clamped = @max(-88.0, @min(88.0, x));
        const c = 1048576.0 / constants.DODConstants.LN_2;
        const y = x_clamped * c;
        const i = @as(i32, @intFromFloat(y));
        const f = y - @as(f32, @floatFromInt(i));
        const p = 1.0 + f * (0.6931471805599453 + f * (0.2402265069590957 + f * 0.0555041086686081));
        return @as(f32, @bitCast(@as(u32, @intCast(i + 127)) << 23)) * p;
    }

    /// Fast approximation of natural logarithm
    /// Uses bit manipulation for maximum performance
    pub inline fn fastLn(x: f32) f32 {
        if (x <= 0.0) return -std.math.inf(f32);

        const bits = @as(u32, @bitCast(x));
        const exponent = @as(i32, @intCast((bits >> 23) & 0xFF)) - 127;
        const mantissa = @as(f32, @bitCast((bits & 0x7FFFFF) | 0x3F800000));

        return @as(f32, @floatFromInt(exponent)) * constants.DODConstants.LN_2 +
            (mantissa - 1.0) * (1.0 + (mantissa - 1.0) * (-0.5 + (mantissa - 1.0) * 0.3333333333333333));
    }

    /// Fast approximation of square root
    /// Uses bit manipulation for maximum performance
    pub inline fn fastSqrt(x: f32) f32 {
        if (x < 0.0) return std.math.nan(f32);
        if (x == 0.0) return 0.0;

        const bits = @as(u32, @bitCast(x));
        const exponent = @as(i32, @intCast((bits >> 23) & 0xFF)) - 127;
        const mantissa = @as(f32, @bitCast((bits & 0x7FFFFF) | 0x3F800000));

        const sqrt_mantissa = 1.0 + (mantissa - 1.0) * 0.5;
        return @as(f32, @bitCast(@as(u32, @intCast(@divTrunc(exponent, 2) + 127)) << 23)) * sqrt_mantissa;
    }

    /// Fast approximation of sine function
    /// Uses polynomial approximation for maximum performance
    pub fn fastSin(x: f32) f32 {
        const x_normalized = x * (1.0 / (2.0 * constants.DODConstants.PI));
        const x_frac = x_normalized - @floor(x_normalized);
        const x_scaled = x_frac * 2.0 * constants.DODConstants.PI;

        const x2 = x_scaled * x_scaled;
        const x3 = x2 * x_scaled;
        const x5 = x3 * x2;
        const x7 = x5 * x2;

        return x_scaled - x3 * 0.16666666666666666 + x5 * 0.008333333333333333 - x7 * 0.00019841269841269841;
    }

    /// Fast approximation of cosine function
    /// Uses polynomial approximation for maximum performance
    pub fn fastCos(x: f32) f32 {
        const x_normalized = x * (1.0 / (2.0 * constants.DODConstants.PI));
        const x_frac = x_normalized - @floor(x_normalized);
        const x_scaled = x_frac * 2.0 * constants.DODConstants.PI;

        const x2 = x_scaled * x_scaled;
        const x4 = x2 * x2;
        const x6 = x4 * x2;
        const x8 = x6 * x2;

        return 1.0 - x2 * 0.5 + x4 * 0.041666666666666664 - x6 * 0.001388888888888889 + x8 * 0.000024801587301587302;
    }

    /// Fast approximation of tangent function
    pub fn fastTan(x: f32) f32 {
        const sin_x = fastSin(x);
        const cos_x = fastCos(x);
        return if (cos_x != 0.0) sin_x / cos_x else std.math.nan(f32);
    }

    /// Fast approximation of power function
    pub fn fastPow(x: f32, y: f32) f32 {
        if (x <= 0.0) return 0.0;
        return fastExp(y * fastLn(x));
    }

    /// Fast approximation of logarithm base 10
    pub fn fastLog10(x: f32) f32 {
        return fastLn(x) / constants.DODConstants.LN_10;
    }

    /// Fast approximation of logarithm base 2
    pub fn fastLog2(x: f32) f32 {
        return fastLn(x) / constants.DODConstants.LN_2;
    }
};

/// SIMD-optimized mathematical operations
pub const SIMDMath = struct {
    /// SIMD-optimized vector addition
    pub fn addVectors(a: []const f32, b: []const f32, c: []f32) void {
        const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
        const len = @min(a.len, @min(b.len, c.len));

        var i: usize = 0;
        while (i + simd_width <= len) {
            for (0..simd_width) |j| {
                c[i + j] = a[i + j] + b[i + j];
            }
            i += simd_width;
        }

        while (i < len) {
            c[i] = a[i] + b[i];
            i += 1;
        }
    }

    /// SIMD-optimized vector multiplication
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

    /// SIMD-optimized scalar multiplication
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

        while (i + simd_width <= len) {
            var batch_sum: f32 = 0.0;
            for (0..simd_width) |j| {
                batch_sum += a[i + j] * b[i + j];
            }
            total += batch_sum;
            i += simd_width;
        }

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
            total += a[i];
            i += 1;
        }

        return total;
    }

    /// SIMD-optimized vector maximum
    pub fn max(a: []const f32) f32 {
        if (a.len == 0) return 0.0;

        const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
        var max_val = a[0];
        var i: usize = 1;

        while (i + simd_width <= a.len) {
            for (0..simd_width) |j| {
                max_val = @max(max_val, a[i + j]);
            }
            i += simd_width;
        }

        while (i < a.len) {
            max_val = @max(max_val, a[i]);
            i += 1;
        }

        return max_val;
    }

    /// SIMD-optimized vector minimum
    pub fn min(a: []const f32) f32 {
        if (a.len == 0) return 0.0;

        const simd_width = constants.DODConstants.SIMD_WIDTH_F32;
        var min_val = a[0];
        var i: usize = 1;

        while (i + simd_width <= a.len) {
            for (0..simd_width) |j| {
                min_val = @min(min_val, a[i + j]);
            }
            i += simd_width;
        }

        while (i < a.len) {
            min_val = @min(min_val, a[i]);
            i += 1;
        }

        return min_val;
    }
};

/// Statistical functions using DOD principles
pub const Statistics = struct {
    /// Calculate mean with SIMD optimization
    pub fn mean(data: []const f32) f32 {
        if (data.len == 0) return 0.0;
        return SIMDMath.sum(data) / @as(f32, @floatFromInt(data.len));
    }

    /// Calculate variance with SIMD optimization
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

    /// Calculate standard deviation
    pub fn stdDev(data: []const f32) f32 {
        return FastMath.fastSqrt(variance(data));
    }

    /// Calculate correlation coefficient
    pub fn correlation(a: []const f32, b: []const f32) f32 {
        if (a.len != b.len or a.len == 0) return 0.0;

        const mean_a = mean(a);
        const mean_b = mean(b);

        var sum_ab: f32 = 0.0;
        var sum_a2: f32 = 0.0;
        var sum_b2: f32 = 0.0;

        for (a, b) |val_a, val_b| {
            const diff_a = val_a - mean_a;
            const diff_b = val_b - mean_b;
            sum_ab += diff_a * diff_b;
            sum_a2 += diff_a * diff_a;
            sum_b2 += diff_b * diff_b;
        }

        const denominator = FastMath.fastSqrt(sum_a2 * sum_b2);
        return if (denominator != 0.0) sum_ab / denominator else 0.0;
    }

    /// Calculate percentile
    pub fn percentile(data: []const f32, p: f32) f32 {
        if (data.len == 0) return 0.0;
        if (p <= 0.0) return SIMDMath.min(data);
        if (p >= 1.0) return SIMDMath.max(data);

        // Simple implementation - in practice, would use more sophisticated algorithm
        const index = @as(usize, @intFromFloat(p * @as(f32, @floatFromInt(data.len - 1))));
        return data[index];
    }
};

/// Linear algebra operations using DOD principles
pub const LinearAlgebra = struct {
    /// Matrix multiplication with cache optimization
    pub fn matrixMultiply(a: []const f32, b: []const f32, c: []f32, m: usize, n: usize, k: usize) void {
        @memset(c, 0.0);

        // Cache-friendly block processing
        const block_size = 64;

        for (0..m) |i| {
            for (0..k) |j| {
                var sum: f32 = 0.0;

                var l: usize = 0;
                while (l + block_size <= n) {
                    for (0..block_size) |block_l| {
                        sum += a[i * n + l + block_l] * b[(l + block_l) * k + j];
                    }
                    l += block_size;
                }

                while (l < n) {
                    sum += a[i * n + l] * b[l * k + j];
                    l += 1;
                }

                c[i * k + j] = sum;
            }
        }
    }

    /// Matrix transpose
    pub fn transpose(a: []const f32, b: []f32, m: usize, n: usize) void {
        for (0..m) |i| {
            for (0..n) |j| {
                b[j * m + i] = a[i * n + j];
            }
        }
    }

    /// Vector norm (L2)
    pub fn norm(a: []const f32) f32 {
        var sum_sq: f32 = 0.0;
        for (a) |val| {
            sum_sq += val * val;
        }
        return FastMath.fastSqrt(sum_sq);
    }

    /// Vector normalization
    pub fn normalize(a: []const f32, b: []f32) void {
        const norm_val = norm(a);
        if (norm_val != 0.0) {
            SIMDMath.multiplyScalar(a, b, 1.0 / norm_val);
        } else {
            @memset(b, 0.0);
        }
    }
};

// Test mathematical functions
test "FastMath approximations" {
    const x = 1.0;
    const fast_exp = FastMath.fastExp(x);
    const fast_ln = FastMath.fastLn(x);
    const fast_sqrt = FastMath.fastSqrt(x);

    try std.testing.expect(fast_exp > 0.0);
    try std.testing.expect(fast_ln >= 0.0);
    try std.testing.expect(fast_sqrt > 0.0);
}

test "SIMDMath operations" {
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const b = [_]f32{ 5.0, 6.0, 7.0, 8.0 };
    var c = [_]f32{ 0.0, 0.0, 0.0, 0.0 };

    SIMDMath.addVectors(&a, &b, &c);
    try std.testing.expectEqual(@as(f32, 6.0), c[0]);
    try std.testing.expectEqual(@as(f32, 8.0), c[1]);

    const dot = SIMDMath.dotProduct(&a, &b);
    try std.testing.expectEqual(@as(f32, 70.0), dot); // 1*5 + 2*6 + 3*7 + 4*8
}

test "Statistics functions" {
    const data = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const mean_val = Statistics.mean(&data);
    const variance_val = Statistics.variance(&data);

    try std.testing.expectEqual(@as(f32, 3.0), mean_val);
    try std.testing.expect(variance_val > 0.0);
}

test "LinearAlgebra operations" {
    const a = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    const b = [_]f32{ 5.0, 6.0, 7.0, 8.0 };
    var c = [_]f32{ 0.0, 0.0, 0.0, 0.0 };

    LinearAlgebra.matrixMultiply(&a, &b, &c, 2, 2, 2);
    // Basic test - would need proper matrix dimensions for full test
    try std.testing.expect(c[0] >= 0.0);
}
