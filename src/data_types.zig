// Data Types - Unified definitions across all Nen projects
// Consolidates duplicate DataType, Shape, and other common types

const std = @import("std");

// Unified DataType enum used across all Nen projects
pub const DataType = enum(u32) {
    // Float types
    f32 = 0,
    f16 = 1,
    f64 = 2,

    // Integer types
    i8 = 3,
    i16 = 4,
    i32 = 5,
    i64 = 6,
    u8 = 7,
    u16 = 8,
    u32 = 9,
    u64 = 10,

    // Boolean
    bool = 11,

    // Quantized types (for ML models)
    q4_0 = 12,
    q4_1 = 13,
    q5_0 = 14,
    q5_1 = 15,
    q8_0 = 16,
    q8_1 = 17,
    q2_k = 18,
    q3_k_s = 19,
    q3_k_m = 20,
    q3_k_l = 21,
    q4_k_s = 22,
    q4_k_m = 23,
    q5_k_s = 24,
    q5_k_m = 25,
    q6_k = 26,
    q8_k = 27,
    iq2_xxs = 28,
    iq2_xs = 29,
    iq3_xxs = 30,
    iq1_s = 31,
    iq4_nl = 32,
    iq3_s = 33,
    iq8_0 = 34,
    iq2_s = 35,
    iq4_xs = 36,

    pub inline fn size(self: DataType) usize {
        return switch (self) {
            .f32 => 4,
            .f16 => 2,
            .f64 => 8,
            .i8 => 1,
            .i16 => 2,
            .i32 => 4,
            .i64 => 8,
            .u8 => 1,
            .u16 => 2,
            .u32 => 4,
            .u64 => 8,
            .bool => 1,
            .q4_0, .q4_1 => 4,
            .q5_0, .q5_1 => 5,
            .q8_0, .q8_1 => 8,
            .q2_k => 2,
            .q3_k_s, .q3_k_m, .q3_k_l => 3,
            .q4_k_s, .q4_k_m => 4,
            .q5_k_s, .q5_k_m => 5,
            .q6_k => 6,
            .q8_k => 8,
            .iq2_xxs, .iq2_xs, .iq2_s => 2,
            .iq3_xxs, .iq3_s => 3,
            .iq1_s => 1,
            .iq4_nl, .iq4_xs => 4,
            .iq8_0 => 8,
        };
    }

    pub inline fn isFloat(self: DataType) bool {
        return switch (self) {
            .f32, .f16, .f64 => true,
            else => false,
        };
    }

    pub inline fn isInteger(self: DataType) bool {
        return switch (self) {
            .i8, .i16, .i32, .i64, .u8, .u16, .u32, .u64 => true,
            else => false,
        };
    }

    pub inline fn isQuantized(self: DataType) bool {
        return switch (self) {
            .q4_0, .q4_1, .q5_0, .q5_1, .q8_0, .q8_1, .q2_k, .q3_k_s, .q3_k_m, .q3_k_l, .q4_k_s, .q4_k_m, .q5_k_s, .q5_k_m, .q6_k, .q8_k, .iq2_xxs, .iq2_xs, .iq3_xxs, .iq1_s, .iq4_nl, .iq3_s, .iq8_0, .iq2_s, .iq4_xs => true,
            else => false,
        };
    }

    pub inline fn isSigned(self: DataType) bool {
        return switch (self) {
            .i8, .i16, .i32, .i64, .f32, .f16, .f64 => true,
            else => false,
        };
    }
};

// Unified Shape structure for tensors
pub const Shape = struct {
    dims: [8]usize, // Max 8 dimensions
    rank: u8,

    pub inline fn init(dims: []const usize) Shape {
        var shape = Shape{ .dims = undefined, .rank = 0 };
        const rank = @min(dims.len, 8);
        shape.rank = @intCast(rank);
        for (0..rank) |i| {
            shape.dims[i] = dims[i];
        }
        return shape;
    }

    pub inline fn getRank(self: Shape) u8 {
        return self.rank;
    }

    pub inline fn totalElements(self: Shape) usize {
        var total: usize = 1;
        for (0..self.rank) |i| {
            total *= self.dims[i];
        }
        return total;
    }

    pub inline fn getDim(self: Shape, index: u8) usize {
        if (index < self.rank) {
            return self.dims[index];
        }
        return 0;
    }

    pub inline fn isCompatible(self: Shape, other: Shape) bool {
        if (self.rank != other.rank) return false;
        for (0..self.rank) |i| {
            if (self.dims[i] != other.dims[i]) return false;
        }
        return true;
    }

    pub inline fn isScalar(self: Shape) bool {
        return self.rank == 0 or (self.rank == 1 and self.dims[0] == 1);
    }

    pub inline fn isVector(self: Shape) bool {
        return self.rank == 1;
    }

    pub inline fn isMatrix(self: Shape) bool {
        return self.rank == 2;
    }

    pub inline fn isTensor(self: Shape) bool {
        return self.rank > 2;
    }
};

// Backend types for computation
pub const Backend = enum {
    cpu_scalar,
    cpu_simd,
    cuda,
    metal,
    opencl,
    vulkan,
};

// Memory layout types
pub const MemoryLayout = enum {
    row_major,
    column_major,
    packed_layout,
    sparse,
};

// Quantization types
pub const QuantizationType = enum {
    none,
    symmetric,
    asymmetric,
    dynamic,
};

// Common tensor metadata
pub const TensorMetadata = struct {
    name: []const u8,
    data_type: DataType,
    shape: Shape,
    backend: Backend,
    layout: MemoryLayout,
    quantization: QuantizationType,
    offset: usize,
    size: usize,
    stride: [8]usize,
    is_contiguous: bool,
    requires_grad: bool,
};

// Version information structure
pub const Version = struct {
    major: u32,
    minor: u32,
    patch: u32,
    prerelease: ?[]const u8 = null,
    build: ?[]const u8 = null,

    pub fn format(self: Version, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d}.{d}.{d}", .{ self.major, self.minor, self.patch });
        if (self.prerelease) |prerelease| {
            try writer.print("-{s}", .{prerelease});
        }
        if (self.build) |build| {
            try writer.print("+{s}", .{build});
        }
    }

    pub fn toString(self: Version, allocator: std.mem.Allocator) ![]u8 {
        return std.fmt.allocPrint(allocator, "{d}.{d}.{d}", .{ self.major, self.minor, self.patch });
    }

    pub fn isCompatible(self: Version, other: Version) bool {
        return self.major == other.major and self.minor >= other.minor;
    }
};

// Common configuration structure
pub const Config = struct {
    version: Version,
    features: FeatureFlags,
    performance: PerformanceTargets,
    limits: Limits,

    pub const FeatureFlags = struct {
        static_memory: bool = true,
        zero_allocation: bool = true,
        simd_optimized: bool = true,
        cache_aligned: bool = true,
        inline_functions: bool = true,
        batch_processing: bool = true,
        data_oriented_design: bool = true,
    };

    pub const PerformanceTargets = struct {
        min_throughput_mb_s: f64 = 100.0,
        max_latency_ms: u64 = 10,
        memory_overhead_percent: f64 = 5.0,
        cache_hit_rate: f64 = 0.8,
    };

    pub const Limits = struct {
        max_tensor_rank: u8 = 8,
        max_tensor_elements: usize = 1_000_000_000,
        max_string_length: usize = 1024,
        max_object_keys: usize = 256,
        max_array_elements: usize = 1024,
        max_nesting_depth: u32 = 32,
    };
};

// Common constants
pub const CONSTANTS = struct {
    // Memory alignment
    pub const CACHE_LINE_SIZE: usize = 64;
    pub const PAGE_SIZE: usize = 4096;
    pub const MAX_ALIGNMENT: usize = 64;

    // SIMD
    pub const SIMD_WIDTH: usize = 32;
    pub const VECTOR_SIZE: usize = 8;

    // Tensor limits
    pub const MAX_TENSOR_RANK: u8 = 8;
    pub const MAX_TENSOR_DIMS: usize = 8;

    // String limits
    pub const MAX_STRING_LENGTH: usize = 1024;
    pub const MAX_NAME_LENGTH: usize = 256;

    // Performance targets
    pub const TARGET_THROUGHPUT_MB_S: f64 = 100.0;
    pub const TARGET_LATENCY_MS: u64 = 10;
    pub const TARGET_MEMORY_OVERHEAD_PERCENT: f64 = 5.0;
};
