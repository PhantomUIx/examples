const std = @import("std");
const builtin = @import("builtin");
const options = @import("options");
const phantom = @import("phantom");
const vizops = @import("vizops");
const zigimg = @import("zigimg");

const alloc = if (builtin.link_libc) std.heap.c_allocator else if (builtin.os.tag == .uefi) std.os.uefi.pool_allocator else std.heap.page_allocator;

const displayBackendType: phantom.display.BackendType = @enumFromInt(@intFromEnum(options.display_backend));
const displayBackend = phantom.display.Backend(displayBackendType);

const sceneBackendType: phantom.scene.BackendType = @enumFromInt(@intFromEnum(options.scene_backend));
const sceneBackend = phantom.scene.Backend(sceneBackendType);

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

    const format = phantom.painting.image.formats.gif.create(alloc) catch |e| @panic(@errorName(e));
    defer format.deinit();

    //const image = format.readBuffer(@embedFile("example.gif")) catch |e| @panic(@errorName(e));
    //defer image.deinit();

    const image = zigimg.Image.fromMemory(alloc, @embedFile("example.gif")) catch |e| @panic(@errorName(e));
    defer image.deinit();

    var buffers = std.ArrayList(*phantom.painting.fb.Base).initCapacity(alloc, image.animation.frames.items.len) catch |e| @panic(@errorName(e));
    defer buffers.deinit();

    for (0..image.animation.frames.items.len) |i| {
        buffers.appendAssumeCapacity(createFrameBuffer(image, i) catch |e| @panic(@errorName(e)));
    }

    const fb = scene.createNode(.NodeFrameBuffer, .{
        .source = buffers.items[0].dupe() catch |e| @panic(@errorName(e)),
    }) catch |e| @panic(@errorName(e));

    while (true) {
        _ = scene.frame(fb) catch |e| @panic(@errorName(e));

        fb.setProperties(.{
            .source = buffers.items[scene.seq % image.animation.frames.items.len],
        }) catch |e| @panic(@errorName(e));
    }
}

fn createFrameBuffer(image: zigimg.Image, frameIndex: usize) !*phantom.painting.fb.Base {
    const frame = &image.animation.frames.items[frameIndex];

    const fb = try phantom.painting.fb.AllocatedFrameBuffer.create(alloc, .{
        .res = .{ .value = .{ image.width, image.height } },
        .colorspace = .sRGB,
        .colorFormat = .{ .rgb = @splat(8) },
    });
    errdefer fb.deinit();

    var i: usize = 0;
    for (frame.pixels.indexed4.indices) |indic| {
        const pixel = frame.pixels.indexed4.palette[indic];
        try fb.write(i, &[_]u8{
            pixel.r,
            pixel.g,
            pixel.b,
        });
        i += 3;
    }
    return fb;
}
