const std = @import("std");
const c = @import("c");

const Window = @import("Window.zig");
const util = @import("../../util.zig");
const Vector2 = util.Vector2;

const Texture = @This();

texture: *c.SDL_Texture,
size: Vector2(u32),

pub fn open(path: []const u8, window: Window) !Texture {
    const surface = c.IMG_Load(path.ptr) orelse {
        std.debug.print("{s}\n", .{c.SDL_GetError()});
        return error.IMGLoad;
    };
    defer c.SDL_FreeSurface(surface);

    const texture = c.SDL_CreateTextureFromSurface(window.renderer, surface) orelse {
        std.debug.print("{s}\n", .{c.SDL_GetError()});
        return error.CreateTextureFromSurface;
    };

    var width: c_int = undefined;
    var height: c_int = undefined;

    _ = c.SDL_QueryTexture(texture, null, null, &width, &height);

    return .{
        .texture = texture,
        .size = .{
            .x = @intCast(width),
            .y = @intCast(height),
        },
    };
}

pub fn deinit(self: *Texture) void {
    c.SDL_DestroyTexture(self.texture);
}
