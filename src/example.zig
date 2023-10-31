const std = @import("std");
const phantom = @import("phantom");

pub const phantomOptions = struct {
    pub const modules = struct {
        pub const i18n = @import("phantom.i18n");
    };
};

pub fn main() void {
    std.debug.print("{}\n", .{phantom.i18n});
}
