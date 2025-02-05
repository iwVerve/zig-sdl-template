const Window = @import("Window.zig");

const Camera = @This();

window: *Window,

pub fn init(window: *Window) !Camera {
    return .{
        .window = window,
    };
}

pub fn deinit(self: *Camera) void {
    _ = self;
}
