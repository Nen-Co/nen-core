// Unified Constants - Consolidates constants across all Nen projects
// Provides canonical constants for tensor names, metadata keys, and configuration

const std = @import("std");

// Tensor name constants - canonical names used across all projects
pub const TENSOR_NAMES = struct {
    // Model architecture tensors
    pub const TOK_EMBED = "model.embed_tokens.weight";
    pub const FINAL_RMS = "model.norm.weight";
    pub const FINAL_NORM = "model.norm.weight";
    pub const OUTPUT_WEIGHT = "lm_head.weight";
    pub const OUTPUT_BIAS = "lm_head.bias";

    // Attention tensors
    pub const ATTN_Q = "model.layers.{d}.self_attn.q_proj.weight";
    pub const ATTN_K = "model.layers.{d}.self_attn.k_proj.weight";
    pub const ATTN_V = "model.layers.{d}.self_attn.v_proj.weight";
    pub const ATTN_OUT = "model.layers.{d}.self_attn.o_proj.weight";

    // Feed-forward tensors
    pub const FFN_GATE = "model.layers.{d}.mlp.gate_proj.weight";
    pub const FFN_UP = "model.layers.{d}.mlp.up_proj.weight";
    pub const FFN_DOWN = "model.layers.{d}.mlp.down_proj.weight";

    // Layer normalization tensors
    pub const LAYER_NORM = "model.layers.{d}.input_layernorm.weight";
    pub const POST_ATTN_NORM = "model.layers.{d}.post_attention_layernorm.weight";

    // Rope tensors
    pub const ROPE_FREQ = "model.layers.{d}.self_attn.rotary_emb.inv_freq";

    // Cache tensors
    pub const KEY_CACHE = "cache.k.{d}";
    pub const VALUE_CACHE = "cache.v.{d}";

    // Utility functions
    pub fn getLayerTensor(template: []const u8, layer: u32) []const u8 {
        return std.fmt.allocPrint(std.heap.page_allocator, template, .{layer}) catch template;
    }

    pub fn isAttentionTensor(name: []const u8) bool {
        return std.mem.indexOf(u8, name, "self_attn") != null;
    }

    pub fn isFFNTensor(name: []const u8) bool {
        return std.mem.indexOf(u8, name, "mlp") != null;
    }

    pub fn isLayerNormTensor(name: []const u8) bool {
        return std.mem.indexOf(u8, name, "layernorm") != null or std.mem.indexOf(u8, name, "norm") != null;
    }

    pub fn getLayerNumber(name: []const u8) ?u32 {
        const layers_start = std.mem.indexOf(u8, name, "layers.") orelse return null;
        const layer_start = layers_start + 7; // "layers.".len
        const layer_end = std.mem.indexOf(u8, name[layer_start..], ".") orelse return null;
        return std.fmt.parseInt(u32, name[layer_start .. layer_start + layer_end], 10) catch null;
    }
};

// Metadata key constants
pub const METADATA_KEYS = struct {
    // Model metadata
    pub const MODEL_TYPE = "model_type";
    pub const ARCHITECTURE = "architecture";
    pub const VERSION = "version";
    pub const DESCRIPTION = "description";
    pub const AUTHOR = "author";
    pub const LICENSE = "license";
    pub const CREATED_AT = "created_at";
    pub const UPDATED_AT = "updated_at";

    // Model configuration
    pub const VOCAB_SIZE = "vocab_size";
    pub const HIDDEN_SIZE = "hidden_size";
    pub const INTERMEDIATE_SIZE = "intermediate_size";
    pub const NUM_LAYERS = "num_layers";
    pub const NUM_HEADS = "num_heads";
    pub const NUM_KEY_VALUE_HEADS = "num_key_value_heads";
    pub const HEAD_DIM = "head_dim";
    pub const HIDDEN_ACT = "hidden_act";
    pub const MAX_POSITION_EMBEDDINGS = "max_position_embeddings";
    pub const ROPE_THETA = "rope_theta";
    pub const ROPE_SCALING = "rope_scaling";
    pub const ATTENTION_BIAS = "attention_bias";
    pub const ATTENTION_DROPOUT = "attention_dropout";
    pub const HIDDEN_DROPOUT = "hidden_dropout";
    pub const CLASSIFIER_DROPOUT = "classifier_dropout";
    pub const INITIALIZER_RANGE = "initializer_range";
    pub const LAYER_NORM_EPS = "layer_norm_eps";
    pub const USE_CACHE = "use_cache";
    pub const TORCH_DTYPE = "torch_dtype";

    // Training metadata
    pub const TRAINING_STEPS = "training_steps";
    pub const TRAINING_EPOCHS = "training_epochs";
    pub const LEARNING_RATE = "learning_rate";
    pub const BATCH_SIZE = "batch_size";
    pub const GRADIENT_ACCUMULATION_STEPS = "gradient_accumulation_steps";
    pub const WEIGHT_DECAY = "weight_decay";
    pub const WARMUP_STEPS = "warmup_steps";
    pub const MAX_GRAD_NORM = "max_grad_norm";
    pub const OPTIMIZER = "optimizer";
    pub const SCHEDULER = "scheduler";

    // Performance metadata
    pub const INFERENCE_TIME_MS = "inference_time_ms";
    pub const MEMORY_USAGE_MB = "memory_usage_mb";
    pub const THROUGHPUT_TOKENS_S = "throughput_tokens_s";
    pub const LATENCY_P50_MS = "latency_p50_ms";
    pub const LATENCY_P95_MS = "latency_p95_ms";
    pub const LATENCY_P99_MS = "latency_p99_ms";

    // Hardware metadata
    pub const DEVICE = "device";
    pub const DEVICE_TYPE = "device_type";
    pub const DEVICE_MEMORY_GB = "device_memory_gb";
    pub const CUDA_VERSION = "cuda_version";
    pub const PYTORCH_VERSION = "pytorch_version";
    pub const TRANSFORMERS_VERSION = "transformers_version";

    // Quantization metadata
    pub const QUANTIZATION_TYPE = "quantization_type";
    pub const QUANTIZATION_BITS = "quantization_bits";
    pub const QUANTIZATION_GROUP_SIZE = "quantization_group_size";
    pub const QUANTIZATION_ZERO_POINT = "quantization_zero_point";
    pub const QUANTIZATION_SCALE = "quantization_scale";

    // Tokenizer metadata
    pub const TOKENIZER_TYPE = "tokenizer_type";
    pub const TOKENIZER_MODEL = "tokenizer_model";
    pub const SPECIAL_TOKENS = "special_tokens";
    pub const PAD_TOKEN = "pad_token";
    pub const EOS_TOKEN = "eos_token";
    pub const BOS_TOKEN = "bos_token";
    pub const UNK_TOKEN = "unk_token";
    pub const MASK_TOKEN = "mask_token";
    pub const SEP_TOKEN = "sep_token";
    pub const CLS_TOKEN = "cls_token";
};

// Configuration constants
pub const CONFIG = struct {
    // Memory configuration
    pub const DEFAULT_BUFFER_SIZE: usize = 64 * 1024; // 64KB
    pub const LARGE_BUFFER_SIZE: usize = 1024 * 1024; // 1MB
    pub const HUGE_BUFFER_SIZE: usize = 16 * 1024 * 1024; // 16MB
    pub const MAX_BUFFER_SIZE: usize = 256 * 1024 * 1024; // 256MB

    // Cache configuration
    pub const CACHE_LINE_SIZE: usize = 64;
    pub const PAGE_SIZE: usize = 4096;
    pub const MAX_ALIGNMENT: usize = 64;

    // SIMD configuration
    pub const SIMD_WIDTH: usize = 32;
    pub const VECTOR_SIZE: usize = 8;
    pub const BATCH_SIZE: usize = 32;

    // Tensor configuration
    pub const MAX_TENSOR_RANK: u8 = 8;
    pub const MAX_TENSOR_DIMS: usize = 8;
    pub const MAX_TENSOR_ELEMENTS: usize = 1_000_000_000;

    // String configuration
    pub const MAX_STRING_LENGTH: usize = 1024;
    pub const MAX_NAME_LENGTH: usize = 256;
    pub const MAX_PATH_LENGTH: usize = 4096;

    // JSON configuration
    pub const MAX_JSON_TOKENS: usize = 8192;
    pub const MAX_JSON_STRING_LENGTH: usize = 1024;
    pub const MAX_JSON_OBJECT_KEYS: usize = 256;
    pub const MAX_JSON_ARRAY_ELEMENTS: usize = 1024;
    pub const MAX_JSON_NESTING_DEPTH: u32 = 32;

    // Network configuration
    pub const DEFAULT_TIMEOUT_MS: u32 = 30000; // 30 seconds
    pub const MAX_RETRIES: u32 = 3;
    pub const RETRY_DELAY_MS: u32 = 1000; // 1 second
    pub const MAX_CONNECTIONS: u32 = 100;
    pub const MAX_REQUEST_SIZE: usize = 16 * 1024 * 1024; // 16MB

    // Database configuration
    pub const DEFAULT_PAGE_SIZE: usize = 4096;
    pub const MAX_PAGE_SIZE: usize = 65536;
    pub const WAL_SIZE_MB: usize = 64;
    pub const CACHE_SIZE_MB: usize = 256;
    pub const MAX_CONNECTIONS_DB: u32 = 1000;

    // ML configuration
    pub const DEFAULT_BATCH_SIZE: usize = 32;
    pub const MAX_BATCH_SIZE: usize = 1024;
    pub const DEFAULT_SEQUENCE_LENGTH: usize = 512;
    pub const MAX_SEQUENCE_LENGTH: usize = 4096;
    pub const DEFAULT_EMBEDDING_DIM: usize = 768;
    pub const MAX_EMBEDDING_DIM: usize = 4096;

    // Performance targets
    pub const TARGET_THROUGHPUT_MB_S: f64 = 100.0;
    pub const TARGET_LATENCY_MS: u64 = 10;
    pub const TARGET_MEMORY_OVERHEAD_PERCENT: f64 = 5.0;
    pub const TARGET_CACHE_HIT_RATE: f64 = 0.8;
    pub const TARGET_BATCH_EFFICIENCY: f64 = 0.8;
};

// File extension constants
pub const FILE_EXTENSIONS = struct {
    pub const NEN_FORMAT = ".nenf";
    pub const NEN_DB = ".nendb";
    pub const NEN_CACHE = ".nencache";
    pub const NEN_MODEL = ".nenmodel";
    pub const NEN_CONFIG = ".nenconfig";
    pub const NEN_LOG = ".nenlog";

    pub const JSON = ".json";
    pub const YAML = ".yaml";
    pub const TOML = ".toml";
    pub const XML = ".xml";
    pub const CSV = ".csv";
    pub const TSV = ".tsv";

    pub const BINARY = ".bin";
    pub const TEXT = ".txt";
    pub const LOG = ".log";
    pub const CONFIG = ".config";
    pub const CONF = ".conf";
    pub const INI = ".ini";
};

// Magic number constants
pub const MAGIC_NUMBERS = struct {
    pub const NEN_FORMAT: u32 = 0x4E454E46; // "NENF"
    pub const NEN_DB: u32 = 0x4E454E44; // "NEND"
    pub const NEN_CACHE: u32 = 0x4E454E43; // "NENC"
    pub const NEN_MODEL: u32 = 0x4E454E4D; // "NENM"

    pub const JSON: u32 = 0x7B; // "{"
    pub const YAML: u32 = 0x2D2D2D2D; // "----"
    pub const XML: u32 = 0x3C3F786D; // "<?xm"
    pub const BINARY: u32 = 0xDEADBEEF;
};

// Error code constants
pub const ERROR_CODES = struct {
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
};

// Status code constants
pub const STATUS_CODES = struct {
    pub const OK: u16 = 200;
    pub const CREATED: u16 = 201;
    pub const ACCEPTED: u16 = 202;
    pub const NO_CONTENT: u16 = 204;
    pub const BAD_REQUEST: u16 = 400;
    pub const UNAUTHORIZED: u16 = 401;
    pub const FORBIDDEN: u16 = 403;
    pub const NOT_FOUND: u16 = 404;
    pub const METHOD_NOT_ALLOWED: u16 = 405;
    pub const CONFLICT: u16 = 409;
    pub const INTERNAL_SERVER_ERROR: u16 = 500;
    pub const NOT_IMPLEMENTED: u16 = 501;
    pub const BAD_GATEWAY: u16 = 502;
    pub const SERVICE_UNAVAILABLE: u16 = 503;
    pub const GATEWAY_TIMEOUT: u16 = 504;
};
