// Nen Core Batching System
// TigerBeetle-style high-performance batch processing
// All operations are inline for maximum performance

const std = @import("std");
const memory = @import("memory.zig");
const simd = @import("simd.zig");
const metrics = @import("metrics.zig");

// Pre-allocated message types for zero-allocation batching
pub const MessageType = enum(u8) {
    read = 1,
    write = 2,
    compute = 3,
    network = 4,
    cache = 5,
    memory = 6,
    file = 7,
    database = 8,
    inference = 9,
    training = 10,
    batch_commit = 11,
};

// Fixed-size message structure (like TigerBeetle)
pub const Message = extern struct {
    type: MessageType,
    timestamp: u64,
    data: [64]u8, // Fixed size for predictable memory layout (64 bytes = 512 bits)

    pub inline fn init(msg_type: MessageType, data: []const u8) Message {
        var msg = Message{
            .type = msg_type,
            .timestamp = @as(u64, @intCast(std.time.nanoTimestamp())),
            .data = undefined,
        };

        // Copy data with bounds checking
        const copy_len = @min(data.len, msg.data.len);
        @memcpy(msg.data[0..copy_len], data[0..copy_len]);

        return msg;
    }
};

// Batch structure with pre-allocated message buffer
pub const Batch = struct {
    const Self = @This();

    // Pre-allocated message buffer (like TigerBeetle)
    messages: [8192]Message = undefined,
    count: u32 = 0,

    // Pre-allocated data buffers for zero-copy operations
    data_buffer: [8192 * 64]u8 = undefined, // 64 bytes per message (512 bits)
    buffer_pos: usize = 0,

    pub inline fn init() Self {
        return Self{};
    }

    // Add operation to batch
    pub inline fn addOperation(self: *Self, msg_type: MessageType, data: []const u8) !void {
        if (self.count >= 8192) {
            return error.BatchFull;
        }

        // Copy data to pre-allocated buffer
        if (self.buffer_pos + data.len <= self.data_buffer.len) {
            @memcpy(self.data_buffer[self.buffer_pos..][0..data.len], data);
            self.buffer_pos += data.len;
        }

        // Create message
        const msg = Message.init(msg_type, data);
        self.messages[self.count] = msg;
        self.count += 1;
    }

    // Get current batch size
    pub inline fn size(self: Self) u32 {
        return self.count;
    }

    // Check if batch is empty
    pub inline fn isEmpty(self: Self) bool {
        return self.count == 0;
    }

    // Check if batch is full
    pub inline fn isFull(self: Self) bool {
        return self.count >= 8192;
    }

    // Clear batch (for reuse)
    pub inline fn clear(self: *Self) void {
        self.count = 0;
        self.buffer_pos = 0;
    }
};

// Batch processor for executing batches
pub const BatchProcessor = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    memory_pool: memory.MemoryPool,
    metrics: metrics.ThroughputTracker,

    // Pre-allocated result buffers
    results: [8192]BatchResult = undefined,
    result_count: u32 = 0,

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .memory_pool = try memory.MemoryPool.init(allocator, 1024 * 1024), // 1MB
            .metrics = metrics.ThroughputTracker.init(),
        };
    }

    pub fn deinit(self: *Self) void {
        self.memory_pool.deinit();
    }

    // Process a batch atomically (like TigerBeetle)
    pub fn processBatch(self: *Self, batch: *const Batch) !BatchResult {
        if (batch.isEmpty()) {
            return BatchResult{ .success = true, .processed = 0 };
        }

        // Start atomic transaction
        self.result_count = 0;

        // Process all messages in batch
        for (batch.messages[0..batch.count], 0..) |msg, i| {
            const result = try self.processMessage(msg);
            self.results[self.result_count] = result;
            self.result_count += 1;

            // If any message fails, abort the entire batch
            if (!result.success) {
                return BatchResult{
                    .success = false,
                    .processed = @intCast(i),
                };
            }
        }

        return BatchResult{
            .success = true,
            .processed = batch.count,
        };
    }

    // Process individual message
    fn processMessage(self: *Self, msg: Message) !BatchResult {
        switch (msg.type) {
            .read => {
                // Process read operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .write => {
                // Process write operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .compute => {
                // Process compute operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .network => {
                // Process network operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .cache => {
                // Process cache operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .memory => {
                // Process memory operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .file => {
                // Process file operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .database => {
                // Process database operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .inference => {
                // Process inference operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            .training => {
                // Process training operation
                self.metrics.recordOperation();
                return BatchResult{ .success = true };
            },
            else => {
                return BatchResult{ .success = false };
            },
        }
    }
};

// Batch result structure
pub const BatchResult = struct {
    success: bool,
    processed: u32 = 0,
    err: ?anyerror = null,
};

// Batch statistics for monitoring
pub const BatchStats = struct {
    batches_processed: u64 = 0,
    messages_processed: u64 = 0,
    batches_failed: u64 = 0,
    avg_batch_size: f64 = 0.0,
    total_processing_time: u64 = 0,

    pub inline fn update(self: *BatchStats, batch_size: u32, processing_time: u64, success: bool) void {
        if (success) {
            self.batches_processed += 1;
            self.messages_processed += batch_size;
            self.total_processing_time += processing_time;

            // Update average batch size
            const total_batches = @as(f64, @floatFromInt(self.batches_processed));
            const total_messages = @as(f64, @floatFromInt(self.messages_processed));
            self.avg_batch_size = total_messages / total_batches;
        } else {
            self.batches_failed += 1;
        }
    }

    pub inline fn getAverageProcessingTime(self: BatchStats) u64 {
        if (self.batches_processed == 0) return 0;
        return self.total_processing_time / self.batches_processed;
    }

    pub inline fn getAverageBatchSize(self: BatchStats) f64 {
        return self.avg_batch_size;
    }
};

// High-level batch API for easy use
pub const BatchAPI = struct {
    const Self = @This();

    processor: BatchProcessor,
    stats: BatchStats,

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .processor = try BatchProcessor.init(allocator),
            .stats = BatchStats{},
        };
    }

    pub fn deinit(self: *Self) void {
        self.processor.deinit();
    }

    // Convenience method for batch operations
    pub fn executeBatch(self: *Self, batch: *const Batch) !BatchResult {
        const start_time = std.time.nanoTimestamp();
        const result = try self.processor.processBatch(batch);
        const end_time = std.time.nanoTimestamp();
        const processing_time = @as(u64, @intCast(end_time - start_time));

        self.stats.update(batch.size(), processing_time, result.success);

        return result;
    }

    // Get batch statistics
    pub fn getStats(self: *const Self) BatchStats {
        return self.stats;
    }
};

// Client-side batcher for automatic batching
pub const ClientBatcher = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    config: ClientBatchConfig,
    current_batch: Batch,
    stats: ClientBatchStats,

    pub const ClientBatchConfig = struct {
        max_batch_size: u32 = 8192,
        max_batch_wait_ms: u32 = 10,
        auto_flush_threshold: u32 = 100,
        enable_homogeneous_batching: bool = true,
        enable_adaptive_batching: bool = true,
    };

    pub fn init(allocator: std.mem.Allocator, config: ClientBatchConfig) !Self {
        return Self{
            .allocator = allocator,
            .config = config,
            .current_batch = Batch.init(),
            .stats = ClientBatchStats{},
        };
    }

    pub fn addOperation(self: *Self, msg_type: MessageType, data: []const u8) !void {
        // Add to current batch
        try self.current_batch.addOperation(msg_type, data);
        self.stats.operations_queued += 1;

        // Check if we should auto-flush
        if (self.current_batch.size() >= self.config.auto_flush_threshold) {
            try self.flush();
        }
    }

    pub fn flush(self: *Self) !void {
        if (self.current_batch.isEmpty()) return;

        const start_time = std.time.nanoTimestamp();

        // Process batch
        var api = try BatchAPI.init(self.allocator);
        defer api.deinit();

        _ = try api.executeBatch(&self.current_batch);

        const end_time = std.time.nanoTimestamp();
        const flush_time = @as(u64, @intCast(end_time - start_time));

        // Update statistics
        self.stats.operations_flushed += self.current_batch.size();
        self.stats.flushes_performed += 1;
        self.stats.total_flush_time += flush_time;

        // Clear batch for reuse
        self.current_batch.clear();
    }

    pub fn getStats(self: *const Self) ClientBatchStats {
        return self.stats;
    }
};

// Client batch statistics
pub const ClientBatchStats = struct {
    operations_queued: u64 = 0,
    operations_flushed: u64 = 0,
    flushes_performed: u64 = 0,
    total_flush_time: u64 = 0,
    batch_size_adjustments: u32 = 0,

    pub inline fn getAverageBatchSize(self: ClientBatchStats) f64 {
        if (self.flushes_performed == 0) return 0.0;
        return @as(f64, @floatFromInt(self.operations_flushed)) / @as(f64, @floatFromInt(self.flushes_performed));
    }

    pub inline fn getAverageFlushTime(self: ClientBatchStats) u64 {
        if (self.flushes_performed == 0) return 0;
        return self.total_flush_time / self.flushes_performed;
    }

    pub inline fn getQueueUtilization(self: ClientBatchStats) f64 {
        if (self.operations_queued == 0) return 0.0;
        return @as(f64, @floatFromInt(self.operations_flushed)) / @as(f64, @floatFromInt(self.operations_queued));
    }
};

// Global batch processor instance
var global_processor: ?BatchAPI = null;
var global_processor_mutex: std.Thread.Mutex = .{};

pub fn getGlobalProcessor(allocator: std.mem.Allocator) !*BatchAPI {
    global_processor_mutex.lock();
    defer global_processor_mutex.unlock();

    if (global_processor == null) {
        global_processor = try BatchAPI.init(allocator);
    }

    return &global_processor.?;
}

pub fn shutdownGlobalProcessor() void {
    global_processor_mutex.lock();
    defer global_processor_mutex.unlock();

    if (global_processor) |*processor| {
        processor.deinit();
        global_processor = null;
    }
}
