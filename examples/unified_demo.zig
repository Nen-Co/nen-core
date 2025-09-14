// Unified Demo - Demonstrates consolidated types and constants
// Shows how nen-core eliminates duplication across all Nen projects

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    std.debug.print("=== Nen Core Unified Demo ===\n", .{});

    // Demonstrate unified data types
    try demoDataTypes();

    // Demonstrate unified constants
    try demoConstants();

    // Demonstrate unified version management
    try demoVersionManagement();

    // Demonstrate unified error handling
    try demoErrorHandling();

    std.debug.print("\n=== Demo Complete ===\n", .{});
}

fn demoDataTypes() !void {
    std.debug.print("\n--- Unified Data Types ---\n", .{});

    // DataType enum with all supported types
    const float_type = nen_core.DataType.f32;
    const int_type = nen_core.DataType.i32;
    const quantized_type = nen_core.DataType.q4_0;

    std.debug.print("Float type: {s}, size: {} bytes\n", .{ @tagName(float_type), float_type.size() });
    std.debug.print("Integer type: {s}, size: {} bytes\n", .{ @tagName(int_type), int_type.size() });
    std.debug.print("Quantized type: {s}, size: {} bytes\n", .{ @tagName(quantized_type), quantized_type.size() });
    std.debug.print("Is float: {}, Is integer: {}, Is quantized: {}\n", .{
        float_type.isFloat(),
        int_type.isInteger(),
        quantized_type.isQuantized(),
    });

    // Shape structure
    const shape = nen_core.Shape.init(&[_]usize{ 2, 3, 4 });
    std.debug.print("Shape: rank={}, elements={}\n", .{ shape.getRank(), shape.totalElements() });
    std.debug.print("Is scalar: {}, Is vector: {}, Is matrix: {}, Is tensor: {}\n", .{
        shape.isScalar(),
        shape.isVector(),
        shape.isMatrix(),
        shape.isTensor(),
    });

    // Backend types
    const backend = nen_core.Backend.cpu_simd;
    std.debug.print("Backend: {s}\n", .{@tagName(backend)});

    // Memory layout
    const layout = nen_core.MemoryLayout.row_major;
    std.debug.print("Memory layout: {s}\n", .{@tagName(layout)});

    // Tensor metadata
    const metadata = nen_core.TensorMetadata{
        .name = "test_tensor",
        .data_type = float_type,
        .shape = shape,
        .backend = backend,
        .layout = layout,
        .quantization = nen_core.QuantizationType.none,
        .offset = 0,
        .size = shape.totalElements() * float_type.size(),
        .stride = [_]usize{ 12, 4, 1 } ++ [_]usize{0} ** 5,
        .is_contiguous = true,
        .requires_grad = false,
    };

    std.debug.print("Tensor metadata: name='{s}', size={} bytes, contiguous={}\n", .{
        metadata.name,
        metadata.size,
        metadata.is_contiguous,
    });
}

fn demoConstants() !void {
    std.debug.print("\n--- Unified Constants ---\n", .{});

    // Tensor names
    std.debug.print("Token embedding tensor: '{s}'\n", .{nen_core.TENSOR_NAMES.TOK_EMBED});
    std.debug.print("Attention Q tensor: '{s}'\n", .{nen_core.TENSOR_NAMES.ATTN_Q});
    std.debug.print("FFN gate tensor: '{s}'\n", .{nen_core.TENSOR_NAMES.FFN_GATE});

    // Check if tensor is attention tensor
    const tensor_name = "model.layers.0.self_attn.q_proj.weight";
    std.debug.print("'{s}' is attention tensor: {}\n", .{
        tensor_name,
        nen_core.TENSOR_NAMES.isAttentionTensor(tensor_name),
    });

    // Metadata keys
    std.debug.print("Model type key: '{s}'\n", .{nen_core.METADATA_KEYS.MODEL_TYPE});
    std.debug.print("Vocab size key: '{s}'\n", .{nen_core.METADATA_KEYS.VOCAB_SIZE});
    std.debug.print("Hidden size key: '{s}'\n", .{nen_core.METADATA_KEYS.HIDDEN_SIZE});

    // Configuration constants
    std.debug.print("Default buffer size: {} bytes\n", .{nen_core.CONFIG.DEFAULT_BUFFER_SIZE});
    std.debug.print("Cache line size: {} bytes\n", .{nen_core.CONFIG.CACHE_LINE_SIZE});
    std.debug.print("Max tensor rank: {}\n", .{nen_core.CONFIG.MAX_TENSOR_RANK});
    std.debug.print("Target throughput: {} MB/s\n", .{nen_core.CONFIG.TARGET_THROUGHPUT_MB_S});

    // File extensions
    std.debug.print("Nen format extension: '{s}'\n", .{nen_core.FILE_EXTENSIONS.NEN_FORMAT});
    std.debug.print("Nen DB extension: '{s}'\n", .{nen_core.FILE_EXTENSIONS.NEN_DB});

    // Magic numbers
    std.debug.print("Nen format magic: 0x{X}\n", .{nen_core.MAGIC_NUMBERS.NEN_FORMAT});
    std.debug.print("Nen DB magic: 0x{X}\n", .{nen_core.MAGIC_NUMBERS.NEN_DB});

    // Error codes
    std.debug.print("Success code: {}\n", .{nen_core.ERROR_CODES.SUCCESS});
    std.debug.print("Out of memory code: {}\n", .{nen_core.ERROR_CODES.OUT_OF_MEMORY});

    // Status codes
    std.debug.print("OK status: {}\n", .{nen_core.STATUS_CODES.OK});
    std.debug.print("Not found status: {}\n", .{nen_core.STATUS_CODES.NOT_FOUND});
}

fn demoVersionManagement() !void {
    std.debug.print("\n--- Unified Version Management ---\n", .{});

    // Core version
    std.debug.print("Nen Core version: {any}\n", .{nen_core.version_management.NEN_CORE_VERSION});

    // Project versions
    std.debug.print("NenDB version: {any}\n", .{nen_core.version_management.NEN_DB_VERSION});
    std.debug.print("Nen Format version: {any}\n", .{nen_core.version_management.NEN_FORMAT_VERSION});
    std.debug.print("Nen IO version: {any}\n", .{nen_core.version_management.NEN_IO_VERSION});
    std.debug.print("Nen JSON version: {any}\n", .{nen_core.version_management.NEN_JSON_VERSION});

    // Version strings
    std.debug.print("NenDB version string: {s}\n", .{nen_core.version_management.getNenDBVersion()});
    std.debug.print("Nen Format version string: {s}\n", .{nen_core.version_management.getNenFormatVersion()});

    // Compatibility checking
    const version1 = nen_core.version_management.NEN_CORE_VERSION;
    const version2 = nen_core.version_management.NEN_DB_VERSION;
    std.debug.print("Core and DB versions compatible: {}\n", .{nen_core.version_management.isCompatible(version1, version2)});
    std.debug.print("Core newer than DB: {}\n", .{nen_core.version_management.isNewer(version1, version2)});

    // Ecosystem version
    std.debug.print("Ecosystem version: {s}\n", .{nen_core.version_management.ECOSYSTEM_VERSION.getEcosystemVersionString()});
}

fn demoErrorHandling() !void {
    std.debug.print("\n--- Unified Error Handling ---\n", .{});

    // Error context
    const error_ctx = nen_core.unified_errors.ErrorContext{
        .file = "demo.zig",
        .line = 42,
        .function = "demoErrorHandling",
        .message = "This is a demo error",
        .severity = nen_core.unified_errors.ErrorSeverity.warning,
        .code = nen_core.ERROR_CODES.INVALID_INPUT,
        .details = "Demo error details",
    };

    std.debug.print("Error context: {any}\n", .{error_ctx});

    // Error recovery
    const result = nen_core.unified_errors.tryRecover(u32, failingOperation(), 42);
    std.debug.print("Recovery result: {}\n", .{result});

    // Error assertion
    try nen_core.unified_errors.assertOrError(true, nen_core.unified_errors.NenError.InvalidInput, "This should not fail");

    // Error code mapping
    const error_code = nen_core.unified_errors.ErrorCode.fromError(nen_core.unified_errors.NenError.OutOfMemory);
    std.debug.print("OutOfMemory error code: {}\n", .{error_code});
}

fn failingOperation() !u32 {
    return nen_core.unified_errors.NenError.InvalidInput;
}
