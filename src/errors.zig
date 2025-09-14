// Nen Core - Error Types
// Consolidated error handling from all Nen projects
// Provides consistent error types across the ecosystem

const std = @import("std");

/// Core error types for the Nen ecosystem
/// Consolidated from nen-db, nen-cache, nen-io, nen-json, nen-net, nen-inference
pub const NenError = error{
    // Memory errors
    OutOfMemory,
    PoolExhausted,
    InvalidAlignment,
    BufferOverflow,
    BufferUnderflow,
    MemoryLeak,
    
    // I/O errors
    IOError,
    FileNotFound,
    PermissionDenied,
    DiskFull,
    NetworkError,
    ConnectionFailed,
    Timeout,
    
    // Data errors
    InvalidData,
    CorruptedData,
    InvalidFormat,
    InvalidSize,
    InvalidType,
    InvalidRange,
    InvalidIndex,
    InvalidKey,
    InvalidValue,
    
    // Numerical errors
    DivisionByZero,
    Overflow,
    Underflow,
    InvalidOperation,
    PrecisionError,
    ConvergenceError,
    
    // Configuration errors
    InvalidConfiguration,
    MissingConfiguration,
    InvalidParameter,
    FeatureNotEnabled,
    VersionMismatch,
    
    // System errors
    SystemError,
    ResourceExhausted,
    NotSupported,
    InvalidState,
    OperationFailed,
    InternalError,
    
    // Security errors
    AuthenticationFailed,
    AuthorizationFailed,
    SecurityViolation,
    InvalidToken,
    AccessDenied,
    
    // Network errors
    RequestTimeout,
    InvalidMessage,
    ProtocolError,
    ConnectionLost,
    ServerError,
    ClientError,
    
    // Database errors
    DatabaseError,
    QueryError,
    TransactionError,
    ConstraintViolation,
    Deadlock,
    
    // Cache errors
    CacheError,
    CacheMiss,
    CacheFull,
    CacheCorrupted,
    
    // Inference errors
    ModelError,
    InferenceError,
    TokenizationError,
    DetokenizationError,
    GenerationError,
    
    // ML errors
    TrainingError,
    ValidationError,
    PredictionError,
    ModelNotFound,
    InvalidModel,
    
    // Format errors
    FormatError,
    SerializationError,
    DeserializationError,
    InvalidSchema,
    VersionError,
};

/// Error context for better debugging
pub const ErrorContext = struct {
    message: []const u8,
    file: []const u8,
    line: u32,
    function: []const u8,
    
    pub fn init(message: []const u8, file: []const u8, line: u32, function: []const u8) ErrorContext {
        return ErrorContext{
            .message = message,
            .file = file,
            .line = line,
            .function = function,
        };
    }
    
    pub fn format(self: ErrorContext, comptime fmt: []const u8, args: anytype) []const u8 {
        _ = fmt;
        _ = args;
        return self.message;
    }
};

/// Error handling utilities
pub const ErrorHandler = struct {
    /// Convert std errors to Nen errors
    pub fn fromStdError(err: anytype) NenError {
        return switch (err) {
            error.OutOfMemory => NenError.OutOfMemory,
            error.InvalidArgument => NenError.InvalidParameter,
            error.UnexpectedEndOfStream => NenError.IOError,
            error.WouldBlock => NenError.Timeout,
            error.ConnectionResetByPeer => NenError.ConnectionLost,
            error.BrokenPipe => NenError.ConnectionLost,
            error.NetworkUnreachable => NenError.NetworkError,
            error.HostUnreachable => NenError.NetworkError,
            error.ConnectionRefused => NenError.ConnectionFailed,
            error.NotConnected => NenError.ConnectionFailed,
            error.AddressInUse => NenError.SystemError,
            error.AddressNotAvailable => NenError.SystemError,
            error.PermissionDenied => NenError.PermissionDenied,
            error.FileNotFound => NenError.FileNotFound,
            error.AccessDenied => NenError.AccessDenied,
            error.NoSpaceLeft => NenError.DiskFull,
            error.FileTooBig => NenError.InvalidSize,
            error.InvalidUtf8 => NenError.InvalidData,
            error.InvalidCharacter => NenError.InvalidData,
            error.IncompleteUtf8 => NenError.InvalidData,
            error.Overflow => NenError.Overflow,
            error.Underflow => NenError.Underflow,
            error.DivisionByZero => NenError.DivisionByZero,
            else => NenError.InternalError,
        };
    }
    
    /// Check if error is recoverable
    pub fn isRecoverable(err: NenError) bool {
        return switch (err) {
            .Timeout,
            .ConnectionLost,
            .NetworkError,
            .RequestTimeout,
            .ConnectionFailed,
            .ServerError,
            .CacheMiss,
            .ResourceExhausted => true,
            else => false,
        };
    }
    
    /// Check if error is fatal
    pub fn isFatal(err: NenError) bool {
        return switch (err) {
            .OutOfMemory,
            .SystemError,
            .InternalError,
            .CorruptedData,
            .SecurityViolation,
            .InvalidState => true,
            else => false,
        };
    }
    
    /// Get error severity level
    pub fn getSeverity(err: NenError) ErrorSeverity {
        return switch (err) {
            .OutOfMemory,
            .SystemError,
            .InternalError,
            .CorruptedData,
            .SecurityViolation => .Critical,
            
            .PoolExhausted,
            .IOError,
            .DatabaseError,
            .ModelError,
            .InferenceError => .High,
            
            .InvalidData,
            .InvalidFormat,
            .InvalidConfiguration,
            .CacheError => .Medium,
            
            .CacheMiss,
            .Timeout,
            .ConnectionLost => .Low,
            
            else => .Medium,
        };
    }
};

/// Error severity levels
pub const ErrorSeverity = enum {
    Low,
    Medium,
    High,
    Critical,
};

/// Error reporting and logging
pub const ErrorReporter = struct {
    /// Report an error with context
    pub fn report(err: NenError, context: ErrorContext) void {
        const severity = ErrorHandler.getSeverity(err);
        const is_fatal = ErrorHandler.isFatal(err);
        
        if (is_fatal) {
            std.debug.panic("FATAL ERROR: {} in {}:{} ({}) - {}", .{ 
                @errorName(err), 
                context.file, 
                context.line, 
                context.function, 
                context.message 
            });
        } else {
            std.debug.print("ERROR [{}]: {} in {}:{} ({}) - {}\n", .{ 
                @tagName(severity),
                @errorName(err), 
                context.file, 
                context.line, 
                context.function, 
                context.message 
            });
        }
    }
    
    /// Report a warning
    pub fn warn(message: []const u8, context: ErrorContext) void {
        std.debug.print("WARNING: {} in {}:{} ({}) - {}\n", .{ 
            message, 
            context.file, 
            context.line, 
            context.function, 
            context.message 
        });
    }
    
    /// Report an info message
    pub fn info(message: []const u8, context: ErrorContext) void {
        std.debug.print("INFO: {} in {}:{} ({}) - {}\n", .{ 
            message, 
            context.file, 
            context.line, 
            context.function, 
            context.message 
        });
    }
};

/// Error recovery strategies
pub const ErrorRecovery = struct {
    /// Retry operation with exponential backoff
    pub fn retryWithBackoff(comptime T: type, operation: fn () T!void, max_retries: u32, base_delay_ms: u32) T!void {
        var retries: u32 = 0;
        var delay_ms = base_delay_ms;
        
        while (retries < max_retries) {
            const result = operation();
            if (result) |_| return;
            
            const err = result catch |e| e;
            if (!ErrorHandler.isRecoverable(err)) {
                return result;
            }
            
            std.time.sleep(delay_ms * 1_000_000); // Convert to nanoseconds
            delay_ms *= 2; // Exponential backoff
            retries += 1;
        }
        
        return operation();
    }
    
    /// Fallback to alternative operation
    pub fn fallback(comptime T: type, primary: fn () T!void, fallback_op: fn () T!void) T!void {
        const result = primary();
        if (result) |_| return;
        
        const err = result catch |e| e;
        if (ErrorHandler.isRecoverable(err)) {
            return fallback_op();
        }
        
        return result;
    }
    
    /// Graceful degradation
    pub fn degrade(comptime T: type, operation: fn () T!void, degraded_op: fn () T!void) T!void {
        const result = operation();
        if (result) |_| return;
        
        const err = result catch |e| e;
        if (ErrorHandler.isRecoverable(err)) {
            ErrorReporter.warn("Operation failed, using degraded mode", ErrorContext.init("", "", 0, ""));
            return degraded_op();
        }
        
        return result;
    }
};

// Test error handling
test "Error conversion" {
    const std_err = error.OutOfMemory;
    const nen_err = ErrorHandler.fromStdError(std_err);
    try std.testing.expectEqual(NenError.OutOfMemory, nen_err);
}

test "Error severity" {
    const severity = ErrorHandler.getSeverity(NenError.OutOfMemory);
    try std.testing.expectEqual(ErrorSeverity.Critical, severity);
}

// test "Error recovery" {
//     var attempt_count: u32 = 0;
//     
//     const operation = struct {
//         fn op() NenError!void {
//             attempt_count += 1;
//             if (attempt_count < 3) {
//                 return NenError.Timeout;
//             }
//             return;
//         }
//     }.op;
//     
//     try ErrorRecovery.retryWithBackoff(void, operation, 5, 1);
//     try std.testing.expectEqual(@as(u32, 3), attempt_count);
// }
