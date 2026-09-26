const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addModule("crestz", .{
        .root_source_file = b.path("crestz.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_tests = b.addRunAtifact(tests);
    const tests_step = b.step("test", "Run tests");
    tests_step.dependOn(&run_tests.step);

    _ = b.addStaticLibrary(.{
        .name = "crestz",
        .root_source_file = b.path("src/crestz.zig"),
        .target = target,
        .optimize = optimize,
    });
}
