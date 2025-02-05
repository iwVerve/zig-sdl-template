const Impl = @import("impl.zig").Texture;

const Texture = @This();

pub const init = Impl.init;
pub const deinit = Impl.deinit;
