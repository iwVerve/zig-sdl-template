const c = @import("c");

pub const Texture = @import("sdl/Texture.zig");
pub const Window = @import("sdl/Window.zig");
pub const Camera = @import("sdl/Camera.zig");

pub fn getTimer() u64 {
    return c.SDL_GetPerformanceCounter();
}

pub fn getTimerFrequency() u64 {
    return c.SDL_GetPerformanceFrequency();
}
