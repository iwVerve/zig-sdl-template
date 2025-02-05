const std = @import("std");
const c = @import("c");

const Window = @import("Window.zig");

const Texture = @This();

texture: *c.SDL_Texture,

pub fn init(path: []const u8, window: Window) !Texture {
    const surface = c.IMG_Load(path) orelse {
        std.debug.print("{s}\n", .{c.SDL_GetError()});
        return error.IMGLoad;
    };
    defer c.SDL_FreeSurface(surface);

    return .{
        .texture = c.SDL_CreateTextureFromSurface(window.renderer, surface),
    };
}

pub fn deinit(self: *Texture) void {
    c.SDL_DestroyTexture(self.texture);
}
