// TigerBeetle-Style Batching Demo
// Demonstrates high-performance batch processing inspired by TigerBeetle
// Shows client-side batching, atomic commits, and zero-allocation operations

const std = @import("std");
const nen_core = @import("nen-core");

pub fn main() !void {
    std.debug.print("🐯 Nen Core TigerBeetle-Style Batching Demo\n", .{});
    std.debug.print("High-performance batch processing with zero-allocation operations\n\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Demonstrate basic TigerBeetle-style batching
    try demoBasicBatching(allocator);

    // Demonstrate client-side automatic batching
    try demoClientSideBatching(allocator);

    // Demonstrate performance comparison
    try demoPerformanceComparison(allocator);

    std.debug.print("\n✅ All TigerBeetle-style batching demos completed!\n", .{});
}

fn demoBasicBatching(allocator: std.mem.Allocator) !void {
    std.debug.print("📦 Demo 1: Basic TigerBeetle-Style Batch Processing\n", .{});
    std.debug.print("Pre-allocated buffers with atomic batch commits\n\n", .{});

    // Create batch API
    var batch_api = try nen_core.batching.BatchAPI.init(allocator);
    defer batch_api.deinit();

    // Create a batch with operations
    var batch = nen_core.batching.Batch.init();

    // Add operations to batch
    try batch.addOperation(.compute, "Compute operation 1");
    try batch.addOperation(.compute, "Compute operation 2");
    try batch.addOperation(.compute, "Compute operation 3");
    try batch.addOperation(.write, "Write operation 1");
    try batch.addOperation(.read, "Read operation 1");

    std.debug.print("Created batch with {} operations\n", .{batch.size()});

    // Execute batch atomically
    const result = try batch_api.executeBatch(&batch);

    if (result.success) {
        std.debug.print("✅ Batch executed successfully: {} operations processed\n", .{result.processed});
    } else {
        std.debug.print("❌ Batch failed: {?}\n", .{result.err});
    }

    // Get statistics
    const stats = batch_api.getStats();
    std.debug.print("Batch statistics:\n", .{});
    std.debug.print("  - Batches processed: {}\n", .{stats.batches_processed});
    std.debug.print("  - Messages processed: {}\n", .{stats.messages_processed});
    std.debug.print("  - Average batch size: {d:.1}\n", .{stats.getAverageBatchSize()});
    std.debug.print("  - Average processing time: {d:.3} ms\n", .{@as(f64, @floatFromInt(stats.getAverageProcessingTime())) / 1_000_000.0});
    std.debug.print("\n", .{});
}

fn demoClientSideBatching(allocator: std.mem.Allocator) !void {
    std.debug.print("🔄 Demo 2: Client-Side Automatic Batching\n", .{});
    std.debug.print("Automatically groups operations to reduce overhead\n\n", .{});

    // Initialize client batcher with TigerBeetle-style configuration
    const config = nen_core.batching.ClientBatcher.ClientBatchConfig{
        .max_batch_size = 8192,
        .max_batch_wait_ms = 10,
        .auto_flush_threshold = 100,
        .enable_homogeneous_batching = true,
        .enable_adaptive_batching = true,
    };

    var client_batcher = try nen_core.batching.ClientBatcher.init(allocator, config);

    // Simulate client operations being added over time
    const start_time = std.time.nanoTimestamp();

    // Add operations that will be automatically batched
    for (0..1000) |i| {
        const data = std.fmt.allocPrint(allocator, "Operation {}", .{i}) catch "Operation";
        defer allocator.free(data);

        try client_batcher.addOperation(.compute, data);

        // Simulate some delay
        if (i % 50 == 0) {
            std.Thread.sleep(1_000_000); // 1ms delay
        }
    }

    // Force final flush
    try client_batcher.flush();

    const end_time = std.time.nanoTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000_000.0;

    // Get client-side statistics
    const stats = client_batcher.getStats();

    std.debug.print("Client-Side Batching Results:\n", .{});
    std.debug.print("  - Operations queued: {}\n", .{stats.operations_queued});
    std.debug.print("  - Operations flushed: {}\n", .{stats.operations_flushed});
    std.debug.print("  - Flushes performed: {}\n", .{stats.flushes_performed});
    std.debug.print("  - Average batch size: {d:.1}\n", .{stats.getAverageBatchSize()});
    std.debug.print("  - Average flush time: {d:.3} ms\n", .{@as(f64, @floatFromInt(stats.getAverageFlushTime())) / 1_000_000.0});
    std.debug.print("  - Queue utilization: {d:.1}%\n", .{stats.getQueueUtilization() * 100.0});
    std.debug.print("  - Total duration: {d:.3} seconds\n", .{duration});
    std.debug.print("\n", .{});
}

fn demoPerformanceComparison(allocator: std.mem.Allocator) !void {
    std.debug.print("🏁 Demo 3: Performance Comparison\n", .{});
    std.debug.print("Comparing individual operations vs TigerBeetle-style batching\n\n", .{});

    const num_operations = 10000;

    // Test 1: Individual operations (baseline)
    const individual_start = std.time.nanoTimestamp();
    var individual_api = try nen_core.batching.BatchAPI.init(allocator);
    defer individual_api.deinit();

    for (0..num_operations) |i| {
        var single_batch = nen_core.batching.Batch.init();
        const data = std.fmt.allocPrint(allocator, "Individual {}", .{i}) catch "Individual";
        defer allocator.free(data);

        try single_batch.addOperation(.compute, data);
        _ = try individual_api.executeBatch(&single_batch);
    }

    const individual_end = std.time.nanoTimestamp();
    const individual_duration = @as(f64, @floatFromInt(individual_end - individual_start)) / 1_000_000_000.0;

    // Test 2: TigerBeetle-style batching
    const batch_start = std.time.nanoTimestamp();
    var batch_api = try nen_core.batching.BatchAPI.init(allocator);
    defer batch_api.deinit();

    var batch_count: u32 = 0;
    while (batch_count < num_operations / 1000) : (batch_count += 1) {
        var batch = nen_core.batching.Batch.init();

        for (0..1000) |i| {
            const data = std.fmt.allocPrint(allocator, "Batch {} {}", .{ batch_count, i }) catch "Batch";
            defer allocator.free(data);

            try batch.addOperation(.compute, data);

            if (batch.isFull()) break;
        }

        _ = try batch_api.executeBatch(&batch);
    }

    const batch_end = std.time.nanoTimestamp();
    const batch_duration = @as(f64, @floatFromInt(batch_end - batch_start)) / 1_000_000_000.0;

    // Test 3: Client-side automatic batching
    const client_config = nen_core.batching.ClientBatcher.ClientBatchConfig{
        .max_batch_size = 8192,
        .max_batch_wait_ms = 1,
        .auto_flush_threshold = 1000,
        .enable_homogeneous_batching = true,
        .enable_adaptive_batching = true,
    };

    var client_batcher = try nen_core.batching.ClientBatcher.init(allocator, client_config);

    const client_start = std.time.nanoTimestamp();
    for (0..num_operations) |i| {
        const data = std.fmt.allocPrint(allocator, "Client {}", .{i}) catch "Client";
        defer allocator.free(data);

        try client_batcher.addOperation(.compute, data);
    }
    try client_batcher.flush();

    const client_end = std.time.nanoTimestamp();
    const client_duration = @as(f64, @floatFromInt(client_end - client_start)) / 1_000_000_000.0;

    // Calculate performance metrics
    const individual_ops_per_sec = @as(f64, @floatFromInt(num_operations)) / individual_duration;
    const batch_ops_per_sec = @as(f64, @floatFromInt(num_operations)) / batch_duration;
    const client_ops_per_sec = @as(f64, @floatFromInt(num_operations)) / client_duration;

    std.debug.print("Performance Comparison Results ({} operations):\n", .{num_operations});
    std.debug.print("  - Individual operations: {d:.0} ops/sec ({d:.3}s)\n", .{ individual_ops_per_sec, individual_duration });
    std.debug.print("  - Manual batching: {d:.0} ops/sec ({d:.3}s) - {d:.1}x faster\n", .{ batch_ops_per_sec, batch_duration, batch_ops_per_sec / individual_ops_per_sec });
    std.debug.print("  - Client-side batching: {d:.0} ops/sec ({d:.3}s) - {d:.1}x faster\n", .{ client_ops_per_sec, client_duration, client_ops_per_sec / individual_ops_per_sec });

    const client_stats = client_batcher.getStats();
    const batch_stats = batch_api.getStats();

    std.debug.print("\nTigerBeetle-Style Optimizations:\n", .{});
    std.debug.print("  - Client-side avg batch size: {d:.1}\n", .{client_stats.getAverageBatchSize()});
    std.debug.print("  - Client-side avg flush time: {d:.3} ms\n", .{@as(f64, @floatFromInt(client_stats.getAverageFlushTime())) / 1_000_000.0});
    std.debug.print("  - Batch API avg processing time: {d:.3} ms\n", .{@as(f64, @floatFromInt(batch_stats.getAverageProcessingTime())) / 1_000_000.0});
    std.debug.print("\n", .{});
}
