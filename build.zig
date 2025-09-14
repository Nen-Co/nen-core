const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Module for other projects to depend on
    const nen_core_module = b.addModule("nen-core", .{
        .root_source_file = b.path("src/lib.zig"),
    });

    // Tests
    const tests = b.addTest(.{
        .name = "nen-core-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const test_run = b.addRunArtifact(tests);
    test_run.has_side_effects = true;

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&test_run.step);

    // Examples
    const numerical_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/numerical_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    numerical_demo_mod.addImport("nen-core", nen_core_module);

    const numerical_demo = b.addExecutable(.{
        .name = "numerical-demo",
        .root_module = numerical_demo_mod,
    });

    const memory_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/memory_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    memory_demo_mod.addImport("nen-core", nen_core_module);

    const memory_demo = b.addExecutable(.{
        .name = "memory-demo",
        .root_module = memory_demo_mod,
    });

    const unified_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/unified_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    unified_demo_mod.addImport("nen-core", nen_core_module);

    const unified_demo = b.addExecutable(.{
        .name = "unified-demo",
        .root_module = unified_demo_mod,
    });

    const batching_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/batching_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    batching_demo_mod.addImport("nen-core", nen_core_module);

    const batching_demo = b.addExecutable(.{
        .name = "batching-demo",
        .root_module = batching_demo_mod,
    });

    const inline_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/inline_performance_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    inline_demo_mod.addImport("nen-core", nen_core_module);

    const inline_demo = b.addExecutable(.{
        .name = "inline-demo",
        .root_module = inline_demo_mod,
    });

    const release_demo_mod = b.createModule(.{
        .root_source_file = b.path("examples/release_performance_demo.zig"),
        .target = target,
        .optimize = optimize,
    });
    release_demo_mod.addImport("nen-core", nen_core_module);

    const release_demo = b.addExecutable(.{
        .name = "release-demo",
        .root_module = release_demo_mod,
    });

    // Run steps
    const run_numerical = b.addRunArtifact(numerical_demo);
    const run_memory = b.addRunArtifact(memory_demo);
    const run_unified = b.addRunArtifact(unified_demo);
    const run_batching = b.addRunArtifact(batching_demo);
    const run_inline = b.addRunArtifact(inline_demo);
    const run_release = b.addRunArtifact(release_demo);

    const run_numerical_step = b.step("run-numerical", "Run numerical demo");
    run_numerical_step.dependOn(&run_numerical.step);

    const run_memory_step = b.step("run-memory", "Run memory demo");
    run_memory_step.dependOn(&run_memory.step);

    const run_unified_step = b.step("run-unified", "Run unified demo");
    run_unified_step.dependOn(&run_unified.step);

    const run_batching_step = b.step("run-batching", "Run batching demo");
    run_batching_step.dependOn(&run_batching.step);

    const run_inline_step = b.step("run-inline", "Run inline performance demo");
    run_inline_step.dependOn(&run_inline.step);

    const run_release_step = b.step("run-release", "Run release performance demo");
    run_release_step.dependOn(&run_release.step);
}
