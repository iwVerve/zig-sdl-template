const c = @import("c");

pub const Texture = @import("sdl/Texture.zig");
pub const Window = @import("sdl/Window.zig");
pub const Camera = @import("sdl/Camera.zig");
pub const Font = @import("sdl/Font.zig");
pub const Sound = @import("sdl/Sound.zig");
pub const Event = @import("sdl/event.zig").Event;
pub const keyboard = @import("sdl/keyboard.zig");

pub fn getTimer() u64 {
    return c.SDL_GetPerformanceCounter();
}

pub fn getTimerFrequency() u64 {
    return c.SDL_GetPerformanceFrequency();
}
