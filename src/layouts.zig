// Nen Core - Data-Oriented Design Layouts
// Consolidated from all Nen projects for optimal memory layouts
// Provides cache-friendly data structures for maximum performance

const std = @import("std");
const constants = @import("constants.zig");

/// DOD-optimized I/O layout for batch processing
/// Consolidated from nen-cache, nen-io, nen, nen-db
pub const DODIOLayout = struct {
    // SIMD-aligned batch data structures
    batch_ids: [constants.DODConstants.SIMD_KEY_BATCH]u64 align(constants.DODConstants.ALIGN_64),
    batch_sizes: [constants.DODConstants.SIMD_KEY_BATCH]u32 align(constants.DODConstants.ALIGN_32),
    batch_positions: [constants.DODConstants.SIMD_KEY_BATCH]u32 align(constants.DODConstants.ALIGN_32),
    batch_types: [constants.DODConstants.SIMD_KEY_BATCH]u8 align(constants.DODConstants.ALIGN_8),
    batch_active: [constants.DODConstants.SIMD_KEY_BATCH]bool align(constants.DODConstants.ALIGN_8),

    // Processing statistics
    operations_processed: u64 = 0,
    batches_completed: u64 = 0,

    pub fn init() DODIOLayout {
        return DODIOLayout{
            .batch_ids = [_]u64{0} ** constants.DODConstants.SIMD_KEY_BATCH,
            .batch_sizes = [_]u32{0} ** constants.DODConstants.SIMD_KEY_BATCH,
            .batch_positions = [_]u32{0} ** constants.DODConstants.SIMD_KEY_BATCH,
            .batch_types = [_]u8{0} ** constants.DODConstants.SIMD_KEY_BATCH,
            .batch_active = [_]bool{false} ** constants.DODConstants.SIMD_KEY_BATCH,
        };
    }

    pub fn reset(self: *DODIOLayout) void {
        @memset(&self.batch_ids, 0);
        @memset(&self.batch_sizes, 0);
        @memset(&self.batch_positions, 0);
        @memset(&self.batch_types, 0);
        @memset(&self.batch_active, false);
        self.operations_processed = 0;
        self.batches_completed = 0;
    }

    pub fn addOperation(self: *DODIOLayout, id: u64, size: u32, position: u32, @"type": u8) bool {
        for (0..constants.DODConstants.SIMD_KEY_BATCH) |i| {
            if (!self.batch_active[i]) {
                self.batch_ids[i] = id;
                self.batch_sizes[i] = size;
                self.batch_positions[i] = position;
                self.batch_types[i] = @"type";
                self.batch_active[i] = true;
                return true;
            }
        }
        return false; // Batch is full
    }

    pub fn getActiveCount(self: *const DODIOLayout) usize {
        var count: usize = 0;
        for (self.batch_active) |active| {
            if (active) count += 1;
        }
        return count;
    }
};

/// DOD-optimized node layout for graph operations
/// Consolidated from nen, nen-db, nen-cache
pub const DODNodeLayout = struct {
    // Node data arrays (Struct of Arrays)
    node_ids: []u64,
    node_types: []u32,
    node_states: []u8,
    node_weights: []f32,
    node_embeddings: []f32,
    node_active: []bool,

    // Execution tracking
    node_execution_times: []u64,
    node_dependencies: []u32,
    node_children: []u32,

    // Metadata
    node_count: usize,
    max_nodes: usize,
    embedding_dim: usize,

    pub fn init(allocator: std.mem.Allocator, max_nodes: usize, embedding_dim: usize) !DODNodeLayout {
        const node_ids = try allocator.alloc(u64, max_nodes);
        const node_types = try allocator.alloc(u32, max_nodes);
        const node_states = try allocator.alloc(u8, max_nodes);
        const node_weights = try allocator.alloc(f32, max_nodes);
        const node_embeddings = try allocator.alloc(f32, max_nodes * embedding_dim);
        const node_active = try allocator.alloc(bool, max_nodes);
        const node_execution_times = try allocator.alloc(u64, max_nodes);
        const node_dependencies = try allocator.alloc(u32, max_nodes);
        const node_children = try allocator.alloc(u32, max_nodes);

        return DODNodeLayout{
            .node_ids = node_ids,
            .node_types = node_types,
            .node_states = node_states,
            .node_weights = node_weights,
            .node_embeddings = node_embeddings,
            .node_active = node_active,
            .node_execution_times = node_execution_times,
            .node_dependencies = node_dependencies,
            .node_children = node_children,
            .node_count = 0,
            .max_nodes = max_nodes,
            .embedding_dim = embedding_dim,
        };
    }

    pub fn deinit(self: *DODNodeLayout, allocator: std.mem.Allocator) void {
        allocator.free(self.node_ids);
        allocator.free(self.node_types);
        allocator.free(self.node_states);
        allocator.free(self.node_weights);
        allocator.free(self.node_embeddings);
        allocator.free(self.node_active);
        allocator.free(self.node_execution_times);
        allocator.free(self.node_dependencies);
        allocator.free(self.node_children);
    }

    pub fn addNode(self: *DODNodeLayout, id: u64, @"type": u32, weight: f32, embedding: []const f32) bool {
        if (self.node_count >= self.max_nodes) return false;

        const index = self.node_count;
        self.node_ids[index] = id;
        self.node_types[index] = @"type";
        self.node_states[index] = 0; // Inactive
        self.node_weights[index] = weight;
        self.node_active[index] = true;

        // Copy embedding
        const embedding_start = index * self.embedding_dim;
        const embedding_end = embedding_start + self.embedding_dim;
        @memcpy(self.node_embeddings[embedding_start..embedding_end], embedding);

        self.node_count += 1;
        return true;
    }

    pub fn getNodeEmbedding(self: *const DODNodeLayout, index: usize) []const f32 {
        const start = index * self.embedding_dim;
        const end = start + self.embedding_dim;
        return self.node_embeddings[start..end];
    }

    pub fn setNodeEmbedding(self: *DODNodeLayout, index: usize, embedding: []const f32) void {
        const start = index * self.embedding_dim;
        const end = start + self.embedding_dim;
        @memcpy(self.node_embeddings[start..end], embedding);
    }
};

/// DOD-optimized edge layout for graph operations
/// Consolidated from nen, nen-db, nen-cache
pub const DODEdgeLayout = struct {
    // Edge data arrays (Struct of Arrays)
    edge_ids: []u64,
    edge_sources: []u32,
    edge_targets: []u32,
    edge_weights: []f32,
    edge_types: []u8,
    edge_active: []bool,

    // Metadata
    edge_count: usize,
    max_edges: usize,

    pub fn init(allocator: std.mem.Allocator, max_edges: usize) !DODEdgeLayout {
        const edge_ids = try allocator.alloc(u64, max_edges);
        const edge_sources = try allocator.alloc(u32, max_edges);
        const edge_targets = try allocator.alloc(u32, max_edges);
        const edge_weights = try allocator.alloc(f32, max_edges);
        const edge_types = try allocator.alloc(u8, max_edges);
        const edge_active = try allocator.alloc(bool, max_edges);

        return DODEdgeLayout{
            .edge_ids = edge_ids,
            .edge_sources = edge_sources,
            .edge_targets = edge_targets,
            .edge_weights = edge_weights,
            .edge_types = edge_types,
            .edge_active = edge_active,
            .edge_count = 0,
            .max_edges = max_edges,
        };
    }

    pub fn deinit(self: *DODEdgeLayout, allocator: std.mem.Allocator) void {
        allocator.free(self.edge_ids);
        allocator.free(self.edge_sources);
        allocator.free(self.edge_targets);
        allocator.free(self.edge_weights);
        allocator.free(self.edge_types);
        allocator.free(self.edge_active);
    }

    pub fn addEdge(self: *DODEdgeLayout, id: u64, source: u32, target: u32, weight: f32, @"type": u8) bool {
        if (self.edge_count >= self.max_edges) return false;

        const index = self.edge_count;
        self.edge_ids[index] = id;
        self.edge_sources[index] = source;
        self.edge_targets[index] = target;
        self.edge_weights[index] = weight;
        self.edge_types[index] = @"type";
        self.edge_active[index] = true;

        self.edge_count += 1;
        return true;
    }
};

/// DOD-optimized tensor layout for numerical operations
/// Consolidated from nen-ml, nen-inference, nen-cache
pub const DODTensorLayout = struct {
    // Tensor data arrays (Struct of Arrays)
    tensor_data: []f32,
    tensor_shapes: []u32,
    tensor_strides: []u32,
    tensor_types: []u8,
    tensor_active: []bool,

    // Metadata
    tensor_count: usize,
    max_tensors: usize,
    max_elements: usize,

    pub fn init(allocator: std.mem.Allocator, max_tensors: usize, max_elements: usize) !DODTensorLayout {
        const tensor_data = try allocator.alloc(f32, max_elements);
        const tensor_shapes = try allocator.alloc(u32, max_tensors * 4); // Max 4 dimensions
        const tensor_strides = try allocator.alloc(u32, max_tensors * 4);
        const tensor_types = try allocator.alloc(u8, max_tensors);
        const tensor_active = try allocator.alloc(bool, max_tensors);

        return DODTensorLayout{
            .tensor_data = tensor_data,
            .tensor_shapes = tensor_shapes,
            .tensor_strides = tensor_strides,
            .tensor_types = tensor_types,
            .tensor_active = tensor_active,
            .tensor_count = 0,
            .max_tensors = max_tensors,
            .max_elements = max_elements,
        };
    }

    pub fn deinit(self: *DODTensorLayout, allocator: std.mem.Allocator) void {
        allocator.free(self.tensor_data);
        allocator.free(self.tensor_shapes);
        allocator.free(self.tensor_strides);
        allocator.free(self.tensor_types);
        allocator.free(self.tensor_active);
    }

    pub fn addTensor(self: *DODTensorLayout, shape: []const u32, data: []const f32, @"type": u8) bool {
        if (self.tensor_count >= self.max_tensors) return false;
        if (data.len > self.max_elements) return false;

        const index = self.tensor_count;
        const shape_start = index * 4;
        const shape_end = shape_start + 4;

        // Copy shape
        @memset(self.tensor_shapes[shape_start..shape_end], 0);
        for (shape, 0..) |dim, i| {
            if (i < 4) {
                self.tensor_shapes[shape_start + i] = dim;
            }
        }

        // Copy data
        @memcpy(self.tensor_data[0..data.len], data);

        self.tensor_types[index] = @"type";
        self.tensor_active[index] = true;
        self.tensor_count += 1;

        return true;
    }

    pub fn getTensorData(self: *const DODTensorLayout, index: usize) []const f32 {
        const shape_start = index * 4;
        const shape = self.tensor_shapes[shape_start .. shape_start + 4];
        const elements = shape[0] * shape[1] * shape[2] * shape[3];
        return self.tensor_data[0..elements];
    }
};

/// DOD-optimized batch layout for processing
/// Consolidated from nen-cache, nen-io, nen-inference
pub const DODBatchLayout = struct {
    // Batch data arrays
    batch_data: []f32,
    batch_indices: []u32,
    batch_sizes: []u32,
    batch_types: []u8,
    batch_active: []bool,

    // Processing metadata
    batch_count: usize,
    max_batches: usize,
    max_elements: usize,

    pub fn init(allocator: std.mem.Allocator, max_batches: usize, max_elements: usize) !DODBatchLayout {
        const batch_data = try allocator.alloc(f32, max_elements);
        const batch_indices = try allocator.alloc(u32, max_batches);
        const batch_sizes = try allocator.alloc(u32, max_batches);
        const batch_types = try allocator.alloc(u8, max_batches);
        const batch_active = try allocator.alloc(bool, max_batches);

        return DODBatchLayout{
            .batch_data = batch_data,
            .batch_indices = batch_indices,
            .batch_sizes = batch_sizes,
            .batch_types = batch_types,
            .batch_active = batch_active,
            .batch_count = 0,
            .max_batches = max_batches,
            .max_elements = max_elements,
        };
    }

    pub fn deinit(self: *DODBatchLayout, allocator: std.mem.Allocator) void {
        allocator.free(self.batch_data);
        allocator.free(self.batch_indices);
        allocator.free(self.batch_sizes);
        allocator.free(self.batch_types);
        allocator.free(self.batch_active);
    }

    pub fn addBatch(self: *DODBatchLayout, data: []const f32, size: u32, @"type": u8) bool {
        if (self.batch_count >= self.max_batches) return false;
        if (data.len > self.max_elements) return false;

        const index = self.batch_count;
        self.batch_indices[index] = @as(u32, @intCast(data.len));
        self.batch_sizes[index] = size;
        self.batch_types[index] = @"type";
        self.batch_active[index] = true;

        // Copy data
        @memcpy(self.batch_data[0..data.len], data);

        self.batch_count += 1;
        return true;
    }
};

// Test DOD layouts
test "DODIOLayout" {
    var layout = DODIOLayout.init();
    try std.testing.expect(layout.addOperation(1, 100, 0, 1));
    try std.testing.expect(layout.getActiveCount() == 1);
    layout.reset();
    try std.testing.expect(layout.getActiveCount() == 0);
}

test "DODNodeLayout" {
    var layout = try DODNodeLayout.init(std.testing.allocator, 10, 4);
    defer layout.deinit(std.testing.allocator);

    const embedding = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    try std.testing.expect(layout.addNode(1, 2, 0.5, &embedding));
    try std.testing.expect(layout.node_count == 1);
}

test "DODEdgeLayout" {
    var layout = try DODEdgeLayout.init(std.testing.allocator, 10);
    defer layout.deinit(std.testing.allocator);

    try std.testing.expect(layout.addEdge(1, 0, 1, 0.8, 1));
    try std.testing.expect(layout.edge_count == 1);
}

test "DODTensorLayout" {
    var layout = try DODTensorLayout.init(std.testing.allocator, 10, 1000);
    defer layout.deinit(std.testing.allocator);

    const shape = [_]u32{ 2, 3, 4, 1 };
    const data = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0 };
    try std.testing.expect(layout.addTensor(&shape, &data, 1));
    try std.testing.expect(layout.tensor_count == 1);
}

test "DODBatchLayout" {
    var layout = try DODBatchLayout.init(std.testing.allocator, 10, 1000);
    defer layout.deinit(std.testing.allocator);

    const data = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    try std.testing.expect(layout.addBatch(&data, 4, 1));
    try std.testing.expect(layout.batch_count == 1);
}
