const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});

    const mod = b.addModule("dot-builder", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });

    var main_tests = b.addTest(.{
        .root_module = mod,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
