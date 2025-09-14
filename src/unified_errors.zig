// Unified Error Handling - Consolidates error types across all Nen projects
// Provides consistent error handling patterns and error codes

const std = @import("std");

// Core Nen error types - unified across all projects
pub const NenError = error{
    // Memory errors
    OutOfMemory,
    InvalidAlignment,
    BufferOverflow,
    BufferUnderflow,
    InvalidPointer,
    MemoryCorruption,

    // I/O errors
    FileNotFound,
    PermissionDenied,
    DiskFull,
    InvalidPath,
    ReadError,
    WriteError,
    SeekError,
    CloseError,
    OpenError,

    // Network errors
    ConnectionFailed,
    ConnectionTimeout,
    ConnectionRefused,
    NetworkUnreachable,
    HostUnreachable,
    InvalidAddress,
    ProtocolError,
    SocketError,

    // Data format errors
    InvalidFormat,
    InvalidJson,
    InvalidXml,
    InvalidYaml,
    InvalidCsv,
    InvalidBinary,
    CorruptedData,
    UnexpectedEndOfData,
    InvalidEncoding,

    // Validation errors
    ValidationFailed,
    InvalidInput,
    InvalidParameter,
    InvalidRange,
    InvalidType,
    InvalidValue,
    MissingRequired,
    DuplicateKey,
    InvalidKey,
    InvalidIndex,

    // Parsing errors
    ParseError,
    SyntaxError,
    UnexpectedToken,
    UnexpectedCharacter,
    UnexpectedEndOfInput,
    InvalidEscapeSequence,
    InvalidNumber,
    InvalidString,
    InvalidBoolean,
    InvalidNull,

    // Serialization errors
    SerializationError,
    DeserializationError,
    EncodingError,
    DecodingError,
    CompressionError,
    DecompressionError,

    // Database errors
    DatabaseError,
    TransactionError,
    ConstraintViolation,
    DuplicateEntry,
    NotFound,
    AlreadyExists,
    LockTimeout,
    Deadlock,
    InvalidQuery,
    InvalidSchema,

    // ML/AI errors
    ModelError,
    InferenceError,
    TrainingError,
    InvalidModel,
    InvalidTensor,
    DimensionMismatch,
    ShapeMismatch,
    TypeMismatch,
    InvalidOperation,
    UnsupportedOperation,

    // GPU errors
    GPUError,
    DeviceNotFound,
    DeviceError,
    OutOfMemoryGPU,
    InvalidShader,
    CompilationError,
    ExecutionError,
    SynchronizationError,

    // Cache errors
    CacheError,
    CacheMiss,
    CacheFull,
    InvalidCacheKey,
    CacheCorruption,
    EvictionError,

    // Configuration errors
    ConfigError,
    InvalidConfig,
    MissingConfig,
    InvalidOption,

    // System errors
    SystemError,
    NotSupported,
    NotImplemented,
    InternalError,
    UnknownError,
    Timeout,
    Cancelled,
    Interrupted,
    ResourceExhausted,
    ResourceUnavailable,
};

// Error severity levels
pub const ErrorSeverity = enum {
    info,
    warning,
    error_level,
    critical,
    fatal,
};

// Error context information
pub const ErrorContext = struct {
    file: ?[]const u8 = null,
    line: ?u32 = null,
    function: ?[]const u8 = null,
    message: []const u8,
    severity: ErrorSeverity = .error_level,
    code: ?u32 = null,
    details: ?[]const u8 = null,

    pub fn format(self: ErrorContext, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("[{s}] {s}", .{ @tagName(self.severity), self.message });

        if (self.file) |file| {
            try writer.print(" at {s}", .{file});
            if (self.line) |line| {
                try writer.print(":{d}", .{line});
            }
        }

        if (self.function) |func| {
            try writer.print(" in {s}()", .{func});
        }

        if (self.code) |code| {
            try writer.print(" (code: {d})", .{code});
        }

        if (self.details) |details| {
            try writer.print(" - {s}", .{details});
        }
    }
};

// Error handler interface
pub const ErrorHandler = struct {
    handleError: *const fn (ErrorContext) void,
    handleWarning: *const fn (ErrorContext) void,
    handleInfo: *const fn (ErrorContext) void,

    pub fn default() ErrorHandler {
        return ErrorHandler{
            .handleError = defaultErrorHandler,
            .handleWarning = defaultWarningHandler,
            .handleInfo = defaultInfoHandler,
        };
    }

    fn defaultErrorHandler(ctx: ErrorContext) void {
        std.debug.print("ERROR: {any}\n", .{ctx});
    }

    fn defaultWarningHandler(ctx: ErrorContext) void {
        std.debug.print("WARNING: {any}\n", .{ctx});
    }

    fn defaultInfoHandler(ctx: ErrorContext) void {
        std.debug.print("INFO: {any}\n", .{ctx});
    }
};

// Global error handler
var global_error_handler: ErrorHandler = ErrorHandler.default();

pub fn setErrorHandler(handler: ErrorHandler) void {
    global_error_handler = handler;
}

pub fn getErrorHandler() ErrorHandler {
    return global_error_handler;
}

// Error reporting functions
pub fn reportError(ctx: ErrorContext) void {
    global_error_handler.handleError(ctx);
}

pub fn reportWarning(ctx: ErrorContext) void {
    global_error_handler.handleWarning(ctx);
}

pub fn reportInfo(ctx: ErrorContext) void {
    global_error_handler.handleInfo(ctx);
}

// Convenience macros for error reporting
pub fn errorCtx(message: []const u8, severity: ErrorSeverity) ErrorContext {
    return ErrorContext{
        .message = message,
        .severity = severity,
    };
}

pub fn errorCtxWithLocation(comptime message: []const u8, severity: ErrorSeverity, file: []const u8, line: u32) ErrorContext {
    return ErrorContext{
        .message = message,
        .severity = severity,
        .file = file,
        .line = line,
    };
}

// Error recovery utilities
pub fn tryRecover(comptime T: type, operation: anytype, fallback: T) T {
    return operation catch |err| {
        reportError(errorCtx(@errorName(err), .warning));
        return fallback;
    };
}

pub fn tryRecoverWithContext(comptime T: type, operation: anytype, fallback: T, ctx: ErrorContext) T {
    return operation catch |err| {
        var error_ctx = ctx;
        error_ctx.details = @errorName(err);
        reportError(error_ctx);
        return fallback;
    };
}

// Error assertion helpers
pub fn assertOrError(condition: bool, err: NenError, message: []const u8) !void {
    if (!condition) {
        reportError(errorCtx(message, .error_level));
        return err;
    }
}

pub fn assertOrErrorWithContext(condition: bool, err: NenError, ctx: ErrorContext) !void {
    if (!condition) {
        reportError(ctx);
        return err;
    }
}

// Error code mapping
pub const ErrorCode = struct {
    pub const SUCCESS: u32 = 0;
    pub const OUT_OF_MEMORY: u32 = 1;
    pub const INVALID_INPUT: u32 = 2;
    pub const FILE_NOT_FOUND: u32 = 3;
    pub const PERMISSION_DENIED: u32 = 4;
    pub const NETWORK_ERROR: u32 = 5;
    pub const PARSE_ERROR: u32 = 6;
    pub const VALIDATION_ERROR: u32 = 7;
    pub const DATABASE_ERROR: u32 = 8;
    pub const MODEL_ERROR: u32 = 9;
    pub const GPU_ERROR: u32 = 10;
    pub const CACHE_ERROR: u32 = 11;
    pub const CONFIG_ERROR: u32 = 12;
    pub const SYSTEM_ERROR: u32 = 13;
    pub const UNKNOWN_ERROR: u32 = 999;

    pub fn fromError(err: NenError) u32 {
        return switch (err) {
            NenError.OutOfMemory => OUT_OF_MEMORY,
            NenError.InvalidInput => INVALID_INPUT,
            NenError.FileNotFound => FILE_NOT_FOUND,
            NenError.PermissionDenied => PERMISSION_DENIED,
            NenError.ConnectionFailed, NenError.ConnectionTimeout, NenError.ConnectionRefused => NETWORK_ERROR,
            NenError.ParseError, NenError.SyntaxError => PARSE_ERROR,
            NenError.ValidationFailed => VALIDATION_ERROR,
            NenError.DatabaseError, NenError.TransactionError => DATABASE_ERROR,
            NenError.ModelError, NenError.InferenceError => MODEL_ERROR,
            NenError.GPUError, NenError.DeviceError => GPU_ERROR,
            NenError.CacheError, NenError.CacheMiss => CACHE_ERROR,
            NenError.ConfigError, NenError.InvalidConfig => CONFIG_ERROR,
            NenError.SystemError, NenError.InternalError => SYSTEM_ERROR,
            else => UNKNOWN_ERROR,
        };
    }
};
