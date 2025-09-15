// Nen Core - Shared Primitives and Utilities
// Foundation layer for the entire Nen ecosystem
// Eliminates code duplication across all Nen projects
// Data-Oriented Design for maximum performance

const std = @import("std");

// Core modules - consolidated from all Nen projects
pub const memory = @import("memory.zig");
pub const rng = @import("rng.zig");
pub const simd = @import("simd.zig");
pub const assertions = @import("assertions.zig");
pub const constants = @import("constants.zig");
pub const errors = @import("errors.zig");
pub const layouts = @import("layouts.zig");
pub const math = @import("math.zig");
pub const metrics = @import("metrics.zig");
pub const numerical = @import("numerical.zig");

// Unified modules - consolidating duplicate code across projects
pub const data_types = @import("data_types.zig");
pub const version_management = @import("version.zig");
pub const unified_errors = @import("unified_errors.zig");
pub const unified_constants = @import("unified_constants.zig");
pub const batching = @import("batching.zig");
pub const advanced_allocators = @import("advanced_allocators.zig");

// Re-export commonly used types
pub const MemoryPool = memory.MemoryPool;
pub const StaticMemoryPool = memory.StaticMemoryPool;
pub const Arena = memory.Arena;
pub const RingBuffer = memory.RingBuffer;
pub const XorShift32 = rng.XorShift32;
pub const SplitMix64 = rng.SplitMix64;
pub const PCG32 = rng.PCG32;
pub const SIMDOperations = simd.SIMDOperations;
pub const DODConstants = constants.DODConstants;
pub const NenError = errors.NenError;
pub const NumericalCore = numerical.NumericalCore;
pub const FastMath = math.FastMath;
pub const SIMDMath = math.SIMDMath;
pub const Statistics = math.Statistics;
pub const LinearAlgebra = math.LinearAlgebra;
pub const DODIOLayout = layouts.DODIOLayout;
pub const DODNodeLayout = layouts.DODNodeLayout;
pub const DODTensorLayout = layouts.DODTensorLayout;
pub const PerformanceTimer = metrics.PerformanceTimer;
pub const MemoryTracker = metrics.MemoryTracker;
pub const CacheTracker = metrics.CacheTracker;
pub const ThroughputTracker = metrics.ThroughputTracker;

// Re-export unified types
pub const DataType = data_types.DataType;
pub const Shape = data_types.Shape;
pub const Backend = data_types.Backend;
pub const MemoryLayout = data_types.MemoryLayout;
pub const QuantizationType = data_types.QuantizationType;
pub const TensorMetadata = data_types.TensorMetadata;
pub const Version = data_types.Version;
pub const Config = data_types.Config;
pub const TENSOR_NAMES = unified_constants.TENSOR_NAMES;
pub const METADATA_KEYS = unified_constants.METADATA_KEYS;
pub const CONFIG = unified_constants.CONFIG;
pub const FILE_EXTENSIONS = unified_constants.FILE_EXTENSIONS;
pub const MAGIC_NUMBERS = unified_constants.MAGIC_NUMBERS;
pub const ERROR_CODES = unified_constants.ERROR_CODES;
pub const STATUS_CODES = unified_constants.STATUS_CODES;

// Re-export batching types
pub const BatchProcessor = batching.BatchProcessor;
pub const BatchItem = batching.BatchItem;
pub const BatchConfig = batching.BatchConfig;
pub const MessageType = batching.MessageType;
pub const BatchResult = batching.BatchResult;
pub const BatchPriority = batching.BatchPriority;
pub const BatchStats = batching.BatchStats;
pub const ClientBatcher = batching.ClientBatcher;
pub const FileBatchProcessor = batching.FileBatchProcessor;
pub const NetworkBatchProcessor = batching.NetworkBatchProcessor;

// Re-export advanced allocator types
pub const StackArena = advanced_allocators.StackArena;
pub const FixedStackAllocator = advanced_allocators.FixedStackAllocator;
pub const BatchAllocator = advanced_allocators.BatchAllocator;
pub const StackMemoryPool = advanced_allocators.StackMemoryPool;
pub const StringAllocator = advanced_allocators.StringAllocator;
pub const ProfiledAllocator = advanced_allocators.ProfiledAllocator;

// Version information
pub const version = std.SemanticVersion{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

// Feature flags
pub const features = struct {
    pub const enable_simd = true;
    pub const enable_assertions = true;
    pub const enable_metrics = true;
    pub const enable_debug_logging = std.builtin.mode == .Debug;
};

// Test the library
test "nen-core basic functionality" {
    // Test memory management
    var arena = Arena.init(std.testing.allocator, 1024);
    defer arena.deinit();

    const data = try arena.alloc(u8, 100);
    try std.testing.expect(data.len == 100);

    // Test RNG
    var rng_state = XorShift32.init(42);
    const random_value = rng_state.next();
    try std.testing.expect(random_value > 0);

    // Test constants
    try std.testing.expect(DODConstants.MAX_NODES > 0);
    try std.testing.expect(DODConstants.CACHE_LINE_SIZE == 64);

    // Test assertions
    // assertions.assertPositive(true, "This should not fail", .{});

    // Test SIMD (if available)
    if (features.enable_simd) {
        const values = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
        var results = [_]f32{ 0.0, 0.0, 0.0, 0.0 };
        SIMDOperations.addScalar(&values, &results, 1.0);
        try std.testing.expectEqual(@as(f32, 2.0), results[0]);
    }
}
