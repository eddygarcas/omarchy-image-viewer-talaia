const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib_mod.addIncludePath(b.path("vendor/stb"));
    lib_mod.addCSourceFile(.{
        .file = b.path("src/stb_impl.c"),
        .flags = &.{
            "-DSTB_IMAGE_IMPLEMENTATION",
            "-DSTB_IMAGE_WRITE_IMPLEMENTATION",
            "-DSTB_IMAGE_RESIZE_IMPLEMENTATION",
        },
    });

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "imgbackend",
        .root_module = lib_mod,
    });
    b.installArtifact(lib);
    b.installFile("include/imgbackend.h", "include/imgbackend.h");

    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_mod.addIncludePath(b.path("vendor/stb"));
    test_mod.addCSourceFile(.{
        .file = b.path("src/stb_impl.c"),
        .flags = &.{
            "-DSTB_IMAGE_IMPLEMENTATION",
            "-DSTB_IMAGE_WRITE_IMPLEMENTATION",
            "-DSTB_IMAGE_RESIZE_IMPLEMENTATION",
        },
    });
    const tests = b.addTest(.{ .root_module = test_mod, .use_lld = true, .use_llvm = true });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run backend unit tests");
    test_step.dependOn(&run_tests.step);
}
