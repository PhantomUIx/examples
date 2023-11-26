const std = @import("std");
const options = @import("options");
const phantom = @import("phantom");
const vizops = @import("vizops");

pub fn main() !void {
    const alloc = std.heap.page_allocator;

    const displayBackendType = comptime std.meta.stringToEnum(phantom.display.BackendType, @tagName(options.display_backend)).?;
    const displayBackend = phantom.display.Backend(displayBackendType);

    const sceneBackendType = comptime std.meta.stringToEnum(phantom.scene.BackendType, @tagName(options.scene_backend)).?;

    var display = displayBackend.Display.init(alloc, .compositor);
    defer display.deinit();

    if (displayBackendType == .headless) {
        _ = try display.addOutput(.{
            .enable = true,
            .size = .{
                .phys = vizops.vector.Float32Vector2.init([_]f32{ 306, 229.5 }),
                .res = vizops.vector.UsizeVector2.init([_]usize{ 1024, 768 }),
            },
            .scale = vizops.vector.Float32Vector2.init(1.0),
            .name = "display-0",
            .manufacturer = "PhantomUI",
            .format = try vizops.color.fourcc.Value.decode(vizops.color.fourcc.formats.argb16161616),
        });
    }

    const outputs = try @constCast(&display.display()).outputs();
    defer outputs.deinit();

    if (outputs.items.len == 0) {
        return error.NoOutputs;
    }

    const output = outputs.items[0];
    const surface = try output.createSurface(.output, .{
        .size = (try output.info()).size.res,
    });
    defer {
        surface.destroy() catch {};
        surface.deinit();
    }

    const scene = try surface.createScene(sceneBackendType);
    _ = scene;
    // TODO: render something to the scene
}
