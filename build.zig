const std = @import("std");
const Phantom = @import("phantom");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const backend = b.option(Phantom.BackendType, "backend", "The backend to use for the example") orelse .headless;

    const phantom_i18n = b.dependency("phantom.i18n", .{
        .target = target,
        .optimize = optimize,
    });

    const phantom = b.dependency("phantom", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("phantom.i18n", .{
        .source_file = .{
            .path = phantom_i18n.builder.pathFromRoot(phantom_i18n.module("phantom.i18n").source_file.path),
        },
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
    exe.addModule("phantom.i18n", phantom_i18n.module("phantom.i18n"));
    exe.addOptions("options", options);
    b.installArtifact(exe);
}
