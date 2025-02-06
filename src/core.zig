const core = @import("core/sdl.zig");

pub const Texture = core.Texture;
pub const Window = core.Window;
pub const Camera = core.Camera;
pub const Sound = core.Sound;
pub const Font = core.Font;
pub const Event = core.Event;

pub const getTimer = core.getTimer;
pub const getTimerFrequency = core.getTimerFrequency;

pub const CreateWindowOptions = struct {
    title: []const u8,
    width: usize,
    height: usize,
    resizable: bool = false,
};
