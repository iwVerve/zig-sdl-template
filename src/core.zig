const core = @import("core/sdl.zig");

pub const Texture = core.Texture;
pub const Window = core.Window;
pub const Camera = core.Camera;

pub const getTimer = core.getTimer;
pub const getTimerFrequency = core.getTimerFrequency;

pub const CreateWindowOptions = struct {
    title: []const u8,
    width: usize,
    height: usize,
    resizable: bool = false,
};
