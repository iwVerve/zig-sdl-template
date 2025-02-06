const c = @import("c");

const Texture = @import("Texture.zig");
const Window = @import("Window.zig");
const util = @import("../../util.zig");
const Color = util.Color;

const Font = @This();

font: *c.TTF_Font,

pub fn init(path: []const u8, size: u32) !Font {
    return .{
        .font = c.TTF_OpenFont(path.ptr, @intCast(size)) orelse return error.OpenFont,
    };
}

pub fn deinit(self: *Font) void {
    c.TTF_CloseFont(self.font);
}

pub fn drawText(self: Font, text: []const u8, window: Window, color: Color, wrap_length: ?u32) !Texture {
    const sdl_color: c.SDL_Color = .{ .r = color.r, .g = color.g, .b = color.b };

    const surface = c.TTF_RenderUTF8_Blended_Wrapped(self.font, text.ptr, sdl_color, wrap_length orelse 1024);
    defer c.SDL_FreeSurface(surface);

    const texture = c.SDL_CreateTextureFromSurface(window.renderer, surface) orelse return error.CreateTextureFromSurface;
    return Texture.fromSdlTexture(texture);
}
