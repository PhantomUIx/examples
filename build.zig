const std = @import("std");
const Phantom = @import("phantom");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const display_backend = b.option(Phantom.DisplayBackendType, "display-backend", "The display backend to use for the example") orelse .headless;
    const scene_backend = b.option(Phantom.SceneBackendType, "scene-backend", "The scene backend to use for the example") orelse .headless;

    const phantom = b.dependency("phantom", .{
        .target = target,
        .optimize = optimize,
    });

    const vizops = b.dependency("vizops", .{
        .target = target,
        .optimize = optimize,
    });

    const zigimg = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize,
    });

    const options = b.addOptions();
    options.addOption(Phantom.DisplayBackendType, "display_backend", display_backend);
    options.addOption(Phantom.SceneBackendType, "scene_backend", scene_backend);

    const exe_compositor = b.addExecutable(.{
        .name = "compositor",
        .root_source_file = .{
            .path = b.pathFromRoot("src/compositor.zig"),
        },
        .target = target,
        .optimize = optimize,
    });

    exe_compositor.addModule("phantom", phantom.module("phantom"));
    exe_compositor.addModule("vizops", vizops.module("vizops"));
    exe_compositor.addModule("zigimg", zigimg.module("zigimg"));
    exe_compositor.addOptions("options", options);
    b.installArtifact(exe_compositor);
}
