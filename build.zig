const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOptions(.{});

    const lib = b.addStaticLibrary(.{
        .name = "crestz",
        .root_source_file = b.path("crestz.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    const tests = b.addTest(.{
        .root_source_file = b.path("crestz.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests_step = b.step("test", "Run tests");
    tests_step.dependOn(&tests.step);
}
