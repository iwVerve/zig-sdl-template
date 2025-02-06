const c = @import("c");

const Texture = @import("Texture.zig");

pub fn textureFromSdlTexture(texture: *c.SDL_Texture) Texture {
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
