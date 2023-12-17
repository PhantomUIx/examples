const std = @import("std");
const builtin = @import("builtin");
const options = @import("options");
const phantom = @import("phantom");
const vizops = @import("vizops");

const displayBackendType: phantom.display.BackendType = @enumFromInt(@intFromEnum(options.display_backend));
const displayBackend = phantom.display.Backend(displayBackendType);

const sceneBackendType: phantom.scene.BackendType = @enumFromInt(@intFromEnum(options.scene_backend));
const sceneBackend = phantom.scene.Backend(sceneBackendType);

pub fn main() void {
    const colors: []const [17]vizops.color.Any = &.{
        .{
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xf7, 0x76, 0x8e, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xff, 0x9e, 0x64, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xe0, 0xaf, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9e, 0xce, 0x6a, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x73, 0xda, 0xca, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xb4, 0xf9, 0xf8, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x2a, 0xc3, 0xde, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7d, 0xcf, 0xff, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7a, 0xa2, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xbb, 0x9a, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xc0, 0xca, 0xf5, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xa9, 0xb1, 0xd6, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9a, 0xa5, 0xce, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xcf, 0xc9, 0xc2, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x56, 0x5f, 0x89, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x41, 0x48, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x1a, 0x1b, 0x26, 0xff },
                    },
                },
            },
        },
        .{
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xf7, 0x76, 0x8e, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xff, 0x9e, 0x64, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xe0, 0xaf, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9e, 0xce, 0x6a, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x73, 0xda, 0xca, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xb4, 0xf9, 0xf8, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x2a, 0xc3, 0xde, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7d, 0xcf, 0xff, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7a, 0xa2, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xbb, 0x9a, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xc0, 0xca, 0xf5, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xa9, 0xb1, 0xd6, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9a, 0xa5, 0xce, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xcf, 0xc9, 0xc2, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x56, 0x5f, 0x89, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x41, 0x48, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x24, 0x28, 0x3b, 0xff },
                    },
                },
            },
        },
    };

    const alloc = if (builtin.link_libc) std.heap.c_allocator else if (builtin.os.tag == .uefi) std.os.uefi.pool_allocator else std.heap.page_allocator;

    var display = displayBackend.Display.init(alloc, .compositor);
    defer display.deinit();

    if (displayBackendType == .headless) {
        _ = display.addOutput(.{
            .enable = true,
            .size = .{
                .phys = vizops.vector.Float32Vector2.init([_]f32{ 306, 229.5 }),
                .res = vizops.vector.UsizeVector2.init([_]usize{ 1024, 768 }),
            },
            .scale = vizops.vector.Float32Vector2.init(1.0),
            .name = "display-0",
            .manufacturer = "PhantomUI",
            .colorFormat = vizops.color.fourcc.Value.decode(vizops.color.fourcc.formats.argb16161616) catch |e| @panic(@errorName(e)),
        }) catch |e| @panic(@errorName(e));
    }

    const outputs = @constCast(&display.display()).outputs() catch |e| @panic(@errorName(e));
    defer outputs.deinit();

    if (outputs.items.len == 0) {
        @panic("No outputs");
    }

    const output = outputs.items[0];
    const surface = output.createSurface(.output, .{
        .size = (output.info() catch |e| @panic(@errorName(e))).size.res,
    }) catch |e| @panic(@errorName(e));
    defer {
        surface.destroy() catch {};
        surface.deinit();
    }

    const scene = surface.createScene(@enumFromInt(@intFromEnum(sceneBackendType))) catch |e| @panic(@errorName(e));

    var children: [17]*phantom.scene.Node = undefined;

    for (&children, colors[0]) |*child, color| {
        child.* = scene.createNode(.NodeRect, .{
            .color = color,
            .size = vizops.vector.Float32Vector2.init([_]f32{ 100.0 / 17.0, 100.0 }),
        }) catch |e| @panic(@errorName(e));
    }

    const flex = scene.createNode(.NodeFlex, .{
        .direction = phantom.painting.Axis.horizontal,
        .children = children,
    }) catch |e| @panic(@errorName(e));
    defer flex.deinit();

    var i: usize = 0;
    while (i < 5) : (i += 1) {
        _ = scene.frame(flex) catch |e| @panic(@errorName(e));

        const currPalette = scene.seq % colors.len;
        for (children, colors[currPalette]) |child, color| {
            child.setProperties(.{ .color = color }) catch |e| @panic(@errorName(e));
        }
    }
}
