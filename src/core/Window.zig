const Window = @import("impl.zig").Window;

pub const CreateWindowOptions = struct {
    title: []const u8,
    width: usize,
    height: usize,
    resizable: bool = false,
};

pub const init = Window.init;
pub const deinit = Window.deinit;
