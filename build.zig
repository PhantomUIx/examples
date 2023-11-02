const std = @import("std");
const Phantom = @import("phantom");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const backend = b.option(Phantom.BackendType, "backend", "The backend to use for the example") orelse .headless;

    const phantom = b.dependency("phantom", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("phantom", .{
        .source_file = .{
            .path = phantom.builder.pathFromRoot(phantom.module("phantom").source_file.path),
        },
    });

    const options = b.addOptions();
    options.addOption(Phantom.BackendType, "backend", backend);

    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{
            .path = b.pathFromRoot("src/example.zig"),
        },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("phantom", phantom.module("phantom"));
    exe.addOptions("options", options);
    b.installArtifact(exe);
}
