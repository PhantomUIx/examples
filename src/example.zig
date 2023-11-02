const std = @import("std");
const phantom = @import("phantom");

pub fn main() void {
    std.debug.print("{}\n", .{phantom.i18n});
}
