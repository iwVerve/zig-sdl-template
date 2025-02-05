const Impl = @import("impl.zig").Window;

const Window = @This();

pub const CreateWindowOptions = struct {
    title: []const u8,
    width: usize,
    height: usize,
    resizable: bool = false,
};

pub const init = Impl.init;
pub const deinit = Impl.deinit;
