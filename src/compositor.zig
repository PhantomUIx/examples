const std = @import("std");
const builtin = @import("builtin");
const options = @import("options");
const phantom = @import("phantom");
const vizops = @import("vizops");

const alloc = if (builtin.link_libc) std.heap.c_allocator else if (builtin.os.tag == .uefi) std.os.uefi.pool_allocator else std.heap.page_allocator;

const displayBackendType: phantom.display.BackendType = @enumFromInt(@intFromEnum(options.display_backend));
const displayBackend = phantom.display.Backend(displayBackendType);

const sceneBackendType: phantom.scene.BackendType = @enumFromInt(@intFromEnum(options.scene_backend));
const sceneBackend = phantom.scene.Backend(sceneBackendType);

fn simpleTextOutputWrite(sto: *std.os.uefi.protocol.SimpleTextOutput, buf: []const u8) !usize {
    const buf16 = try std.unicode.utf8ToUtf16LeWithNull(alloc, buf);
    defer alloc.free(buf16);
    try sto.outputString(buf16).err();
    return buf.len;
}

const SimpleTextOutputWriter = std.io.Writer(*std.os.uefi.protocol.SimpleTextOutput, std.os.uefi.Status.EfiError || std.mem.Allocator.Error || error{InvalidUtf8}, simpleTextOutputWrite);

pub fn main() void {
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
    const outputInfo = output.info() catch |e| @panic(@errorName(e));
    const surface = output.createSurface(.output, .{
        .size = outputInfo.size.res,
    }) catch |e| @panic(@errorName(e));
    defer {
        surface.destroy() catch {};
        surface.deinit();
    }

    const fontFormat = phantom.fonts.backends.bdf.create(alloc) catch |e| @panic(@errorName(e));
    defer fontFormat.deinit();

    const font = fontFormat.loadBuffer(@embedFile("example.bdf"), .{
        .colorspace = .sRGB,
        .colorFormat = .{ .rgba = @splat(8) },
        .foregroundColor = .{
            .uint8 = .{
                .sRGB = .{
                    .value = @splat(255),
                },
            },
        },
        .backgroundColor = .{
            .uint8 = .{
                .sRGB = .{
                    .value = @splat(0),
                },
            },
        },
    }) catch |e| @panic(@errorName(e));
    defer font.deinit();

    const scene = surface.createScene(@enumFromInt(@intFromEnum(sceneBackendType))) catch |e| @panic(@errorName(e));

    const text = scene.createNode(.NodeText, .{
        .font = font,
        .view = std.unicode.Utf8View.initComptime("Hellord"),
    }) catch |e| @panic(@errorName(e));

    while (true) {
        _ = scene.frame(text) catch |e| @panic(@errorName(e));
    }
}
