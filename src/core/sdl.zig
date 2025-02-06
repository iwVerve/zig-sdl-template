const c = @import("c");

pub const Texture = @import("sdl/Texture.zig");
pub const Window = @import("sdl/Window.zig");
pub const Camera = @import("sdl/Camera.zig");
pub const Font = @import("sdl/Font.zig");
pub const Sound = @import("sdl/Sound.zig");
const event = @import("sdl/event.zig");
pub const Event = event.Event;

pub fn getTimer() u64 {
    return c.SDL_GetPerformanceCounter();
}

pub fn getTimerFrequency() u64 {
    return c.SDL_GetPerformanceFrequency();
}
