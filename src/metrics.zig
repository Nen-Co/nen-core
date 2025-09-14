// Nen Core - Metrics and Performance Monitoring
// Data-Oriented Design metrics collection for performance analysis
// Provides zero-allocation metrics tracking for production systems

const std = @import("std");
const constants = @import("constants.zig");

/// DOD-optimized metrics collector
/// Uses Struct of Arrays layout for cache-friendly performance
pub const MetricsCollector = struct {
    // Metrics data arrays (Struct of Arrays)
    metric_names: [][:0]const u8,
    metric_values: []f64,
    metric_types: []MetricType,
    metric_timestamps: []u64,
    metric_active: []bool,

    // Metadata
    metric_count: usize,
    max_metrics: usize,
    start_time: u64,

    pub fn init(allocator: std.mem.Allocator, max_metrics: usize) !MetricsCollector {
        const metric_names = try allocator.alloc([:0]const u8, max_metrics);
        const metric_values = try allocator.alloc(f64, max_metrics);
        const metric_types = try allocator.alloc(MetricType, max_metrics);
        const metric_timestamps = try allocator.alloc(u64, max_metrics);
        const metric_active = try allocator.alloc(bool, max_metrics);

        return MetricsCollector{
            .metric_names = metric_names,
            .metric_values = metric_values,
            .metric_types = metric_types,
            .metric_timestamps = metric_timestamps,
            .metric_active = metric_active,
            .metric_count = 0,
            .max_metrics = max_metrics,
            .start_time = std.time.nanoTimestamp(),
        };
    }

    pub fn deinit(self: *MetricsCollector, allocator: std.mem.Allocator) void {
        allocator.free(self.metric_names);
        allocator.free(self.metric_values);
        allocator.free(self.metric_types);
        allocator.free(self.metric_timestamps);
        allocator.free(self.metric_active);
    }

    pub fn addMetric(self: *MetricsCollector, name: [:0]const u8, value: f64, @"type": MetricType) bool {
        if (self.metric_count >= self.max_metrics) return false;

        const index = self.metric_count;
        self.metric_names[index] = name;
        self.metric_values[index] = value;
        self.metric_types[index] = @"type";
        self.metric_timestamps[index] = @as(u64, @intCast(std.time.nanoTimestamp()));
        self.metric_active[index] = true;

        self.metric_count += 1;
        return true;
    }

    pub fn updateMetric(self: *MetricsCollector, name: [:0]const u8, value: f64) bool {
        for (0..self.metric_count) |i| {
            if (self.metric_active[i] and std.mem.eql(u8, self.metric_names[i], name)) {
                self.metric_values[i] = value;
                self.metric_timestamps[i] = @as(u64, @intCast(std.time.nanoTimestamp()));
                return true;
            }
        }
        return false;
    }

    pub fn getMetric(self: *const MetricsCollector, name: [:0]const u8) ?f64 {
        for (0..self.metric_count) |i| {
            if (self.metric_active[i] and std.mem.eql(u8, self.metric_names[i], name)) {
                return self.metric_values[i];
            }
        }
        return null;
    }

    pub fn getActiveCount(self: *const MetricsCollector) usize {
        var count: usize = 0;
        for (self.metric_active) |active| {
            if (active) count += 1;
        }
        return count;
    }
};

/// Metric types for different kinds of measurements
pub const MetricType = enum {
    Counter, // Monotonically increasing value
    Gauge, // Current value that can go up or down
    Histogram, // Distribution of values
    Timer, // Duration measurements
};

/// Performance timer for measuring execution time
pub const PerformanceTimer = struct {
    start_time: u64,
    end_time: u64,
    is_running: bool,

    pub fn init() PerformanceTimer {
        return PerformanceTimer{
            .start_time = 0,
            .end_time = 0,
            .is_running = false,
        };
    }

    pub fn start(self: *PerformanceTimer) void {
        self.start_time = @as(u64, @intCast(std.time.nanoTimestamp()));
        self.is_running = true;
    }

    pub fn stop(self: *PerformanceTimer) u64 {
        if (!self.is_running) return 0;

        self.end_time = @as(u64, @intCast(std.time.nanoTimestamp()));
        self.is_running = false;
        return self.end_time - self.start_time;
    }

    pub fn elapsed(self: *const PerformanceTimer) u64 {
        if (self.is_running) {
            return @as(u64, @intCast(std.time.nanoTimestamp())) - self.start_time;
        }
        return self.end_time - self.start_time;
    }

    pub fn elapsedMs(self: *const PerformanceTimer) f64 {
        return @as(f64, @floatFromInt(elapsed(self))) / 1_000_000.0;
    }

    pub fn elapsedUs(self: *const PerformanceTimer) f64 {
        return @as(f64, @floatFromInt(elapsed(self))) / 1_000.0;
    }
};

/// Memory usage tracker
pub const MemoryTracker = struct {
    allocated_bytes: usize,
    freed_bytes: usize,
    peak_usage: usize,
    current_usage: usize,

    pub fn init() MemoryTracker {
        return MemoryTracker{
            .allocated_bytes = 0,
            .freed_bytes = 0,
            .peak_usage = 0,
            .current_usage = 0,
        };
    }

    pub fn recordAllocation(self: *MemoryTracker, size: usize) void {
        self.allocated_bytes += size;
        self.current_usage += size;
        self.peak_usage = @max(self.peak_usage, self.current_usage);
    }

    pub fn recordDeallocation(self: *MemoryTracker, size: usize) void {
        self.freed_bytes += size;
        self.current_usage = if (self.current_usage >= size) self.current_usage - size else 0;
    }

    pub fn getUtilization(self: *const MemoryTracker) f64 {
        if (self.allocated_bytes == 0) return 0.0;
        return @as(f64, @floatFromInt(self.freed_bytes)) / @as(f64, @floatFromInt(self.allocated_bytes));
    }

    pub fn getLeakCount(self: *const MemoryTracker) usize {
        return if (self.current_usage > 0) 1 else 0;
    }
};

/// Cache performance tracker
pub const CacheTracker = struct {
    hits: u64,
    misses: u64,
    evictions: u64,
    total_requests: u64,

    pub fn init() CacheTracker {
        return CacheTracker{
            .hits = 0,
            .misses = 0,
            .evictions = 0,
            .total_requests = 0,
        };
    }

    pub fn recordHit(self: *CacheTracker) void {
        self.hits += 1;
        self.total_requests += 1;
    }

    pub fn recordMiss(self: *CacheTracker) void {
        self.misses += 1;
        self.total_requests += 1;
    }

    pub fn recordEviction(self: *CacheTracker) void {
        self.evictions += 1;
    }

    pub fn getHitRate(self: *const CacheTracker) f64 {
        if (self.total_requests == 0) return 0.0;
        return @as(f64, @floatFromInt(self.hits)) / @as(f64, @floatFromInt(self.total_requests));
    }

    pub fn getMissRate(self: *const CacheTracker) f64 {
        if (self.total_requests == 0) return 0.0;
        return @as(f64, @floatFromInt(self.misses)) / @as(f64, @floatFromInt(self.total_requests));
    }

    pub fn getEvictionRate(self: *const CacheTracker) f64 {
        if (self.total_requests == 0) return 0.0;
        return @as(f64, @floatFromInt(self.evictions)) / @as(f64, @floatFromInt(self.total_requests));
    }
};

/// Throughput tracker for operations per second
pub const ThroughputTracker = struct {
    operations: u64,
    start_time: u64,
    last_reset: u64,

    pub fn init() ThroughputTracker {
        const now = @as(u64, @intCast(std.time.nanoTimestamp()));
        return ThroughputTracker{
            .operations = 0,
            .start_time = now,
            .last_reset = now,
        };
    }

    pub inline fn recordOperation(self: *ThroughputTracker) void {
        self.operations += 1;
    }

    pub inline fn getThroughput(self: *const ThroughputTracker) f64 {
        const elapsed = @as(u64, @intCast(std.time.nanoTimestamp())) - self.start_time;
        if (elapsed == 0) return 0.0;
        return @as(f64, @floatFromInt(self.operations)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0);
    }

    pub fn getThroughputSinceReset(self: *const ThroughputTracker) f64 {
        const elapsed = @as(u64, @intCast(std.time.nanoTimestamp())) - self.last_reset;
        if (elapsed == 0) return 0.0;
        return @as(f64, @floatFromInt(self.operations)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0);
    }

    pub fn reset(self: *ThroughputTracker) void {
        self.operations = 0;
        self.last_reset = @as(u64, @intCast(std.time.nanoTimestamp()));
    }
};

/// Latency tracker for measuring response times
pub const LatencyTracker = struct {
    latencies: []u64,
    count: usize,
    max_latencies: usize,

    pub fn init(allocator: std.mem.Allocator, max_latencies: usize) !LatencyTracker {
        const latencies = try allocator.alloc(u64, max_latencies);
        return LatencyTracker{
            .latencies = latencies,
            .count = 0,
            .max_latencies = max_latencies,
        };
    }

    pub fn deinit(self: *LatencyTracker, allocator: std.mem.Allocator) void {
        allocator.free(self.latencies);
    }

    pub fn recordLatency(self: *LatencyTracker, latency_ns: u64) void {
        if (self.count < self.max_latencies) {
            self.latencies[self.count] = latency_ns;
            self.count += 1;
        }
    }

    pub fn getAverageLatency(self: *const LatencyTracker) f64 {
        if (self.count == 0) return 0.0;

        var sum: u64 = 0;
        for (self.latencies[0..self.count]) |latency| {
            sum += latency;
        }

        return @as(f64, @floatFromInt(sum)) / @as(f64, @floatFromInt(self.count));
    }

    pub fn getPercentileLatency(self: *const LatencyTracker, percentile: f64) f64 {
        if (self.count == 0) return 0.0;

        // Simple implementation - would use more sophisticated algorithm in production
        const index = @as(usize, @intFromFloat(percentile * @as(f64, @floatFromInt(self.count - 1))));
        return @as(f64, @floatFromInt(self.latencies[index]));
    }

    pub fn getMinLatency(self: *const LatencyTracker) u64 {
        if (self.count == 0) return 0;

        var min_latency = self.latencies[0];
        for (self.latencies[1..self.count]) |latency| {
            min_latency = @min(min_latency, latency);
        }
        return min_latency;
    }

    pub fn getMaxLatency(self: *const LatencyTracker) u64 {
        if (self.count == 0) return 0;

        var max_latency = self.latencies[0];
        for (self.latencies[1..self.count]) |latency| {
            max_latency = @max(max_latency, latency);
        }
        return max_latency;
    }
};

/// Metrics reporter for outputting metrics data
pub const MetricsReporter = struct {
    pub fn reportMetrics(collector: *const MetricsCollector) void {
        std.debug.print("=== Metrics Report ===\n");
        for (0..collector.metric_count) |i| {
            if (collector.metric_active[i]) {
                std.debug.print("{}: {} ({})\n", .{ collector.metric_names[i], collector.metric_values[i], @tagName(collector.metric_types[i]) });
            }
        }
        std.debug.print("=====================\n");
    }

    pub fn reportPerformance(timer: *const PerformanceTimer) void {
        std.debug.print("Performance Timer: {:.2}ms\n", .{timer.elapsedMs()});
    }

    pub fn reportMemory(tracker: *const MemoryTracker) void {
        std.debug.print("Memory Usage: {} bytes (Peak: {} bytes, Utilization: {:.2}%)\n", .{ tracker.current_usage, tracker.peak_usage, tracker.getUtilization() * 100.0 });
    }

    pub fn reportCache(tracker: *const CacheTracker) void {
        std.debug.print("Cache Performance: Hit Rate: {:.2}%, Miss Rate: {:.2}%, Eviction Rate: {:.2}%\n", .{ tracker.getHitRate() * 100.0, tracker.getMissRate() * 100.0, tracker.getEvictionRate() * 100.0 });
    }

    pub fn reportThroughput(tracker: *const ThroughputTracker) void {
        std.debug.print("Throughput: {:.2} ops/sec\n", .{tracker.getThroughput()});
    }

    pub fn reportLatency(tracker: *const LatencyTracker) void {
        std.debug.print("Latency: Avg: {:.2}ms, Min: {:.2}ms, Max: {:.2}ms, P95: {:.2}ms\n", .{ tracker.getAverageLatency() / 1_000_000.0, @as(f64, @floatFromInt(tracker.getMinLatency())) / 1_000_000.0, @as(f64, @floatFromInt(tracker.getMaxLatency())) / 1_000_000.0, tracker.getPercentileLatency(0.95) / 1_000_000.0 });
    }
};

// Test metrics functionality
test "MetricsCollector" {
    var collector = try MetricsCollector.init(std.testing.allocator, 10);
    defer collector.deinit(std.testing.allocator);

    try std.testing.expect(collector.addMetric("test_metric", 42.0, .Gauge));
    try std.testing.expectEqual(@as(f64, 42.0), collector.getMetric("test_metric").?);
    try std.testing.expect(collector.updateMetric("test_metric", 84.0));
    try std.testing.expectEqual(@as(f64, 84.0), collector.getMetric("test_metric").?);
}

test "PerformanceTimer" {
    var timer = PerformanceTimer.init();
    timer.start();
    std.time.sleep(1000); // 1 microsecond
    const elapsed = timer.stop();
    try std.testing.expect(elapsed > 0);
}

test "MemoryTracker" {
    var tracker = MemoryTracker.init();
    tracker.recordAllocation(1000);
    tracker.recordDeallocation(500);
    try std.testing.expectEqual(@as(usize, 500), tracker.current_usage);
}

test "CacheTracker" {
    var tracker = CacheTracker.init();
    tracker.recordHit();
    tracker.recordMiss();
    try std.testing.expectEqual(@as(f64, 0.5), tracker.getHitRate());
}

test "ThroughputTracker" {
    var tracker = ThroughputTracker.init();
    tracker.recordOperation();
    tracker.recordOperation();
    try std.testing.expect(tracker.getThroughput() >= 0.0);
}

test "LatencyTracker" {
    var tracker = try LatencyTracker.init(std.testing.allocator, 10);
    defer tracker.deinit(std.testing.allocator);

    tracker.recordLatency(1000);
    tracker.recordLatency(2000);
    try std.testing.expectEqual(@as(f64, 1500.0), tracker.getAverageLatency());
}
