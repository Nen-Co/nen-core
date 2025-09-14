// Version Management - Unified version handling across all Nen projects
// Consolidates duplicate version constants and utilities

const std = @import("std");
const data_types = @import("data_types.zig");

// Core Nen ecosystem version
pub const NEN_CORE_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

// Individual project versions
pub const NEN_DB_VERSION = data_types.Version{
    .major = 0,
    .minor = 2,
    .patch = 0,
    .prerelease = "beta",
};

pub const NEN_FORMAT_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_IO_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_JSON_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_NET_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_ML_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_INFERENCE_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_GPU_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

pub const NEN_CACHE_VERSION = data_types.Version{
    .major = 0,
    .minor = 1,
    .patch = 0,
};

// Version string generators
pub fn getVersionString(version: data_types.Version, project_name: []const u8) []const u8 {
    return std.fmt.allocPrint(std.heap.page_allocator, "{s} v{d}.{d}.{d}", .{
        project_name,
        version.major,
        version.minor,
        version.patch,
    }) catch "Unknown Version";
}

pub fn getFullVersionString(version: data_types.Version, project_name: []const u8) []const u8 {
    var result = std.ArrayList(u8).init(std.heap.page_allocator);
    defer result.deinit();

    result.writer().print("{s} v{d}.{d}.{d}", .{
        project_name,
        version.major,
        version.minor,
        version.patch,
    }) catch return "Unknown Version";

    if (version.prerelease) |prerelease| {
        result.writer().print("-{s}", .{prerelease}) catch return "Unknown Version";
    }

    if (version.build) |build| {
        result.writer().print("+{s}", .{build}) catch return "Unknown Version";
    }

    return result.toOwnedSlice() catch "Unknown Version";
}

// Compatibility checking
pub fn isCompatible(version1: data_types.Version, version2: data_types.Version) bool {
    return version1.major == version2.major and version1.minor >= version2.minor;
}

pub fn isNewer(version1: data_types.Version, version2: data_types.Version) bool {
    if (version1.major > version2.major) return true;
    if (version1.major < version2.major) return false;
    if (version1.minor > version2.minor) return true;
    if (version1.minor < version2.minor) return false;
    return version1.patch > version2.patch;
}

// Project-specific version getters
pub fn getNenDBVersion() []const u8 {
    return getVersionString(NEN_DB_VERSION, "NenDB");
}

pub fn getNenFormatVersion() []const u8 {
    return getVersionString(NEN_FORMAT_VERSION, "Nen Format");
}

pub fn getNenIOVersion() []const u8 {
    return getVersionString(NEN_IO_VERSION, "Nen IO");
}

pub fn getNenJSONVersion() []const u8 {
    return getVersionString(NEN_JSON_VERSION, "Nen JSON");
}

pub fn getNenNetVersion() []const u8 {
    return getVersionString(NEN_NET_VERSION, "Nen Net");
}

pub fn getNenMLVersion() []const u8 {
    return getVersionString(NEN_ML_VERSION, "Nen ML");
}

pub fn getNenInferenceVersion() []const u8 {
    return getVersionString(NEN_INFERENCE_VERSION, "Nen Inference");
}

pub fn getNenGPUVersion() []const u8 {
    return getVersionString(NEN_GPU_VERSION, "Nen GPU");
}

pub fn getNenCacheVersion() []const u8 {
    return getVersionString(NEN_CACHE_VERSION, "Nen Cache");
}

// Ecosystem version info
pub const ECOSYSTEM_VERSION = struct {
    core: data_types.Version = NEN_CORE_VERSION,
    projects: []const data_types.Version = &[_]data_types.Version{
        NEN_DB_VERSION,
        NEN_FORMAT_VERSION,
        NEN_IO_VERSION,
        NEN_JSON_VERSION,
        NEN_NET_VERSION,
        NEN_ML_VERSION,
        NEN_INFERENCE_VERSION,
        NEN_GPU_VERSION,
        NEN_CACHE_VERSION,
    },

    pub fn getEcosystemVersionString() []const u8 {
        return std.fmt.allocPrint(std.heap.page_allocator, "Nen Ecosystem v{d}.{d}.{d}", .{
            NEN_CORE_VERSION.major,
            NEN_CORE_VERSION.minor,
            NEN_CORE_VERSION.patch,
        }) catch "Unknown Ecosystem Version";
    }

    pub fn getAllProjectVersions() []const []const u8 {
        return &[_][]const u8{
            getNenDBVersion(),
            getNenFormatVersion(),
            getNenIOVersion(),
            getNenJSONVersion(),
            getNenNetVersion(),
            getNenMLVersion(),
            getNenInferenceVersion(),
            getNenGPUVersion(),
            getNenCacheVersion(),
        };
    }
};
