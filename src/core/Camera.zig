const Impl = @import("impl.zig").Camera;

const Camera = @This();

pub const init = Impl.init;
pub const deinit = Impl.deinit;
