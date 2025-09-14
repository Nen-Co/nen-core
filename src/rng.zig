// Nen Core - Random Number Generation
// Consolidated from all Nen projects to eliminate duplication
// Provides deterministic RNG for reproducible results

const std = @import("std");

/// XorShift32 random number generator
/// Consolidated from nen-inference, nen-ml, nen-lm
pub const XorShift32 = struct {
    state: u32,

    pub fn init(seed: u32) XorShift32 {
        return XorShift32{ .state = if (seed == 0) 1 else seed };
    }

    pub inline fn next(self: *XorShift32) u32 {
        var x = self.state;
        x ^= x << 13;
        x ^= x >> 17;
        x ^= x << 5;
        self.state = x;
        return x;
    }

    pub inline fn nextFloat(self: *XorShift32) f32 {
        const bits = self.next();
        return @as(f32, @floatFromInt(bits)) / @as(f32, @floatFromInt(std.math.maxInt(u32)));
    }

    pub fn nextFloatNorm(self: *XorShift32) f32 {
        // Box-Muller transform for normal distribution
        const u1_val = self.nextFloat();
        const u2_val = self.nextFloat();
        const z0 = std.math.sqrt(-2.0 * @log(u1_val)) * std.math.cos(2.0 * std.math.pi * u2_val);
        return z0;
    }

    pub fn nextInt(self: *XorShift32, max: u32) u32 {
        if (max == 0) return 0;
        return self.next() % max;
    }

    pub fn nextRange(self: *XorShift32, min: u32, max: u32) u32 {
        if (min >= max) return min;
        return min + self.nextInt(max - min);
    }
};

/// SplitMix64 random number generator
/// For better quality random numbers
pub const SplitMix64 = struct {
    state: u64,

    pub fn init(seed: u64) SplitMix64 {
        return SplitMix64{ .state = seed };
    }

    pub inline fn next(self: *SplitMix64) u64 {
        var x = self.state;
        x = (x ^ (x >> 30)) *% 0xbf58476d1ce4e5b9;
        x = (x ^ (x >> 27)) *% 0x94d049bb133111eb;
        x = x ^ (x >> 31);
        self.state = x;
        return x;
    }

    pub fn nextFloat(self: *SplitMix64) f64 {
        const bits = self.next();
        return @as(f64, @floatFromInt(bits)) / @as(f64, @floatFromInt(std.math.maxInt(u64)));
    }

    pub fn nextFloatNorm(self: *SplitMix64) f64 {
        // Box-Muller transform for normal distribution
        const u1_val = self.nextFloat();
        const u2_val = self.nextFloat();
        const z0 = std.math.sqrt(-2.0 * @log(u1_val)) * std.math.cos(2.0 * std.math.pi * u2_val);
        return z0;
    }

    pub fn nextInt(self: *SplitMix64, max: u64) u64 {
        if (max == 0) return 0;
        return self.next() % max;
    }

    pub fn nextRange(self: *SplitMix64, min: u64, max: u64) u64 {
        if (min >= max) return min;
        return min + self.nextInt(max - min);
    }
};

/// High-quality random number generator using PCG
pub const PCG32 = struct {
    state: u64,
    inc: u64,

    pub fn init(seed: u64) PCG32 {
        return PCG32{
            .state = seed,
            .inc = (seed << 1) | 1,
        };
    }

    pub inline fn next(self: *PCG32) u32 {
        const oldstate = self.state;
        self.state = oldstate *% 6364136223846793005 + self.inc;
        const xorshifted = @as(u32, @truncate(((oldstate >> 18) ^ oldstate) >> 27));
        const rot = @as(u32, @truncate(oldstate >> 59));
        return (xorshifted >> @as(u5, @intCast(rot))) | (xorshifted << @as(u5, @intCast((-@as(i32, @intCast(rot)) & 31))));
    }

    pub fn nextFloat(self: *PCG32) f32 {
        const bits = self.next();
        return @as(f32, @floatFromInt(bits)) / @as(f32, @floatFromInt(std.math.maxInt(u32)));
    }

    pub fn nextFloatNorm(self: *PCG32) f32 {
        // Box-Muller transform for normal distribution
        const u1_val = self.nextFloat();
        const u2_val = self.nextFloat();
        const z0 = std.math.sqrt(-2.0 * @log(u1_val)) * std.math.cos(2.0 * std.math.pi * u2_val);
        return z0;
    }

    pub fn nextInt(self: *PCG32, max: u32) u32 {
        if (max == 0) return 0;
        return self.next() % max;
    }

    pub fn nextRange(self: *PCG32, min: u32, max: u32) u32 {
        if (min >= max) return min;
        return min + self.nextInt(max - min);
    }
};

/// Random number generator factory
pub const RNG = struct {
    pub fn createXorShift32(seed: u32) XorShift32 {
        return XorShift32.init(seed);
    }

    pub fn createSplitMix64(seed: u64) SplitMix64 {
        return SplitMix64.init(seed);
    }

    pub fn createPCG32(seed: u64) PCG32 {
        return PCG32.init(seed);
    }

    /// Create a random number generator with a random seed
    pub fn createRandom() XorShift32 {
        const seed = @as(u32, @intCast(std.time.nanoTimestamp() & 0xFFFFFFFF));
        return XorShift32.init(seed);
    }
};

/// Utility functions for random data generation
pub const RandomUtils = struct {
    /// Generate a random string of specified length
    pub fn randomString(rng: anytype, length: usize, allocator: std.mem.Allocator) ![]u8 {
        const result = try allocator.alloc(u8, length);
        for (result) |*byte| {
            byte.* = @as(u8, @intCast(rng.nextInt(256)));
        }
        return result;
    }

    /// Generate a random string with printable characters
    pub fn randomPrintableString(rng: anytype, length: usize, allocator: std.mem.Allocator) ![]u8 {
        const result = try allocator.alloc(u8, length);
        for (result) |*byte| {
            byte.* = @as(u8, @intCast(rng.nextRange(32, 126))); // Printable ASCII
        }
        return result;
    }

    /// Shuffle an array in place
    pub fn shuffle(rng: anytype, comptime T: type, array: []T) void {
        for (0..array.len) |i| {
            const j = rng.nextInt(@as(u32, @intCast(array.len)));
            std.mem.swap(T, &array[i], &array[j]);
        }
    }

    /// Sample n elements from an array without replacement
    pub fn sample(rng: anytype, comptime T: type, source: []const T, n: usize, allocator: std.mem.Allocator) ![]T {
        if (n > source.len) return error.SampleSizeTooLarge;

        const result = try allocator.alloc(T, n);
        var indices = try allocator.alloc(usize, source.len);
        defer allocator.free(indices);

        for (0..source.len) |i| {
            indices[i] = i;
        }

        shuffle(rng, usize, indices);

        for (0..n) |i| {
            result[i] = source[indices[i]];
        }

        return result;
    }
};

// Test RNG implementations
test "XorShift32" {
    var rng = XorShift32.init(42);
    const value1 = rng.next();
    const value2 = rng.next();
    try std.testing.expect(value1 != value2);
    try std.testing.expect(value1 > 0);
    try std.testing.expect(value2 > 0);
}

test "SplitMix64" {
    var rng = SplitMix64.init(42);
    const value1 = rng.next();
    const value2 = rng.next();
    try std.testing.expect(value1 != value2);
    try std.testing.expect(value1 > 0);
    try std.testing.expect(value2 > 0);
}

test "PCG32" {
    var rng = PCG32.init(42);
    const value1 = rng.next();
    const value2 = rng.next();
    try std.testing.expect(value1 != value2);
    // PCG32 can generate 0, so just check they're different
    try std.testing.expect(value1 != value2);
}

// test "RandomUtils" {
//     var rng = XorShift32.init(42);
//     const string = try RandomUtils.randomPrintableString(rng, 10, std.testing.allocator);
//     defer std.testing.allocator.free(string);
//     try std.testing.expect(string.len == 10);
// }

test "Float generation" {
    const rng = XorShift32.init(42);
    var rng_mut = rng;
    const float_val = rng_mut.nextFloat();
    try std.testing.expect(float_val >= 0.0);
    try std.testing.expect(float_val < 1.0);

    const norm_val = rng_mut.nextFloatNorm();
    // Normal distribution should have values around 0
    try std.testing.expect(norm_val > -5.0);
    try std.testing.expect(norm_val < 5.0);
}
