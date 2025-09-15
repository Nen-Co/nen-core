// Nen Core - Constants and Configuration
// Data-Oriented Design constants consolidated from all Nen projects
// Optimized for cache-friendly memory layouts and SIMD operations

const std = @import("std");

/// Data-Oriented Design Constants
/// Consolidated from nen-db, nen-cache, nen-io, nen, nen-ml, nen-inference
pub const DODConstants = struct {
    // Memory and Cache Constants
    pub const CACHE_LINE_SIZE = 64;
    pub const PAGE_SIZE = 4096;
    pub const SECTOR_SIZE = 512;

    // SIMD Constants
    pub const SIMD_ALIGNMENT = 32; // SIMD alignment requirement
    pub const SIMD_WIDTH_F32 = 8; // 8 f32 values per SIMD operation
    pub const SIMD_WIDTH_F64 = 4; // 4 f64 values per SIMD operation
    pub const SIMD_WIDTH_I32 = 8; // 8 i32 values per SIMD operation
    pub const SIMD_WIDTH_I64 = 4; // 4 i64 values per SIMD operation

    // Batch Processing Constants
    pub const SIMD_KEY_BATCH = 8;
    pub const SIMD_NODE_BATCH = 16;
    pub const SIMD_STATS_BATCH = 32;
    pub const SIMD_MATH_BATCH = 64;

    // Memory Pool Constants
    pub const MAX_NODES = 1_000_000;
    pub const MAX_EDGES = 10_000_000;
    pub const MAX_EMBEDDINGS = 100_000;
    pub const MAX_SEQUENCE_LENGTH = 4096;
    pub const MAX_EMBEDDING_DIM = 4096;

    // Numerical Constants
    pub const F32_EPSILON = 1.0e-6;
    pub const F64_EPSILON = 1.0e-12;
    pub const PI = 3.14159265358979323846;
    pub const E = 2.71828182845904523536;
    pub const LN_2 = 0.69314718055994530942;
    pub const LN_10 = 2.30258509299404568402;

    // Neural Network Constants
    pub const MAX_LAYERS = 128;
    pub const MAX_HEADS = 64;
    pub const MAX_VOCAB_SIZE = 100_000;
    pub const MAX_CONTEXT_LENGTH = 8192;

    // Performance Constants
    pub const PREFETCH_DISTANCE = 16;
    pub const HASH_TABLE_LOAD_FACTOR = 0.75;
    pub const BLOOM_FILTER_BITS = 8;
    pub const COMPRESSION_LEVEL = 1;

    // Alignment Constants (for DOD layouts)
    pub const ALIGN_8 = 8;
    pub const ALIGN_16 = 16;
    pub const ALIGN_32 = 32;
    pub const ALIGN_64 = 64;
    pub const ALIGN_CACHE_LINE = CACHE_LINE_SIZE;
    pub const ALIGN_PAGE = PAGE_SIZE;
};

/// Numerical precision constants
pub const Precision = struct {
    pub const F32_PRECISION = 1.0e-6;
    pub const F64_PRECISION = 1.0e-12;
    pub const F16_PRECISION = 1.0e-3;
    pub const BF16_PRECISION = 1.0e-3;
};

/// SIMD vector sizes for different data types
pub const SIMDSizes = struct {
    pub const F32_VEC_SIZE = DODConstants.SIMD_WIDTH_F32;
    pub const F64_VEC_SIZE = DODConstants.SIMD_WIDTH_F64;
    pub const I32_VEC_SIZE = DODConstants.SIMD_WIDTH_I32;
    pub const I64_VEC_SIZE = DODConstants.SIMD_WIDTH_I64;
    pub const U8_VEC_SIZE = 32; // 32 u8 values per SIMD operation
    pub const U16_VEC_SIZE = 16; // 16 u16 values per SIMD operation
};

/// Memory layout constants for DOD
pub const MemoryLayout = struct {
    pub const NODE_ALIGNMENT = DODConstants.ALIGN_64;
    pub const EDGE_ALIGNMENT = DODConstants.ALIGN_32;
    pub const TENSOR_ALIGNMENT = DODConstants.ALIGN_CACHE_LINE;
    pub const BATCH_ALIGNMENT = DODConstants.ALIGN_32;
};

/// Mathematical constants for fast approximations
pub const MathConstants = struct {
    // Fast approximation constants
    pub const EXP_APPROX_COEFFS = [4]f32{ 1.0, 1.0, 0.5, 0.16666666666666666 };
    pub const LN_APPROX_COEFFS = [4]f32{ 0.0, 1.0, -0.5, 0.3333333333333333 };
    pub const SQRT_APPROX_COEFFS = [3]f32{ 1.0, 0.5, -0.125 };

    // Trigonometric constants
    pub const SIN_APPROX_COEFFS = [5]f32{ 0.0, 1.0, -0.16666666666666666, 0.008333333333333333, -0.00019841269841269841 };
    pub const COS_APPROX_COEFFS = [5]f32{ 1.0, -0.5, 0.041666666666666664, -0.001388888888888889, 0.000024801587301587302 };
};

/// Feature flags for conditional compilation
pub const Features = struct {
    pub const ENABLE_SIMD = true;
    pub const ENABLE_AVX2 = @hasDecl(std.Target.x86, "avx2");
    pub const ENABLE_NEON = @hasDecl(std.Target.aarch64, "neon");
    pub const ENABLE_FMA = @hasDecl(std.Target.x86, "fma");
    pub const ENABLE_ASSERTIONS = true;
    pub const ENABLE_METRICS = true;
    pub const ENABLE_DEBUG_LOGGING = std.builtin.mode == .Debug;
    pub const ENABLE_BOUNDS_CHECKING = std.builtin.mode == .Debug;
};

// Compile-time assertions for DOD correctness
comptime {
    // Ensure power-of-2 alignments
    std.debug.assert(DODConstants.CACHE_LINE_SIZE & (DODConstants.CACHE_LINE_SIZE - 1) == 0);
    std.debug.assert(DODConstants.PAGE_SIZE & (DODConstants.PAGE_SIZE - 1) == 0);
    std.debug.assert(DODConstants.SECTOR_SIZE & (DODConstants.SECTOR_SIZE - 1) == 0);

    // Ensure SIMD widths are reasonable
    std.debug.assert(DODConstants.SIMD_WIDTH_F32 > 0);
    std.debug.assert(DODConstants.SIMD_WIDTH_F64 > 0);
    std.debug.assert(DODConstants.SIMD_WIDTH_I32 > 0);
    std.debug.assert(DODConstants.SIMD_WIDTH_I64 > 0);

    // Ensure batch sizes are reasonable
    std.debug.assert(DODConstants.SIMD_KEY_BATCH > 0);
    std.debug.assert(DODConstants.SIMD_NODE_BATCH > 0);
    std.debug.assert(DODConstants.SIMD_STATS_BATCH > 0);
    std.debug.assert(DODConstants.SIMD_MATH_BATCH > 0);

    // Ensure memory limits are reasonable
    std.debug.assert(DODConstants.MAX_NODES > 0);
    std.debug.assert(DODConstants.MAX_EDGES > 0);
    std.debug.assert(DODConstants.MAX_EMBEDDINGS > 0);
    std.debug.assert(DODConstants.MAX_SEQUENCE_LENGTH > 0);

    // Ensure numerical constants are valid
    std.debug.assert(DODConstants.F32_EPSILON > 0.0);
    std.debug.assert(DODConstants.F64_EPSILON > 0.0);
    std.debug.assert(DODConstants.PI > 0.0);
    std.debug.assert(DODConstants.E > 0.0);
}
