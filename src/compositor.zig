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
    const surface = output.createSurface(.output, .{
        .size = (output.info() catch |e| @panic(@errorName(e))).size.res,
    }) catch |e| @panic(@errorName(e));
    defer {
        surface.destroy() catch {};
        surface.deinit();
    }

    const scene = surface.createScene(@enumFromInt(@intFromEnum(sceneBackendType))) catch |e| @panic(@errorName(e));

    const format = phantom.painting.image.formats.zigimg.create(alloc) catch |e| @panic(@errorName(e));
    defer format.deinit();

    const image = format.readBuffer(@embedFile("example.gif")) catch |e| @panic(@errorName(e));
    defer image.deinit();

    const fb = scene.createNode(.NodeFrameBuffer, .{
        .source = image.buffer(0) catch |e| @panic(@errorName(e)),
    }) catch |e| @panic(@errorName(e));

    const stderr = if (builtin.os.tag == .uefi) SimpleTextOutputWriter{
        .context = std.os.uefi.system_table.std_err.?,
    } else std.io.getStdErr().writer();

    var prevTime = std.time.milliTimestamp();
    while (true) {
        const currTime = std.time.milliTimestamp();
        const deltaTime = currTime - prevTime;
        _ = stderr.print("FPS: {} (Delta time: {}, Prev: {}, Curr: {})\n", .{
            60 / @max(deltaTime, 1),
            deltaTime,
            prevTime,
            currTime,
        }) catch {};

        _ = scene.frame(fb) catch |e| @panic(@errorName(e));

        fb.setProperties(.{
            .source = image.buffer(scene.seq % image.info().seqCount) catch |e| @panic(@errorName(e)),
        }) catch |e| @panic(@errorName(e));

        prevTime = currTime;
    }
}
