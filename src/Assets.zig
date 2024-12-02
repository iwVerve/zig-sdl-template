const std = @import("std");
const c = @import("c");

const config = @import("config.zig");

const Assets = @This();

const asset_data = .{
    .dir = config.data_dir ++ "/",
    .textures = .{
        .path = "sprites/",
        .entries = .{
            .{ "fox", "fox.png" },
        },
    },
};

fox: *c.SDL_Texture = undefined,

pub fn init(self: *Assets, renderer: *c.SDL_Renderer) !void {
    inline for (asset_data.textures.entries) |texture_entry| {
        const field = &@field(self, texture_entry[0]);
        const path = asset_data.dir ++ asset_data.textures.path ++ texture_entry[1];

        field.* = blk: {
            const surface = c.IMG_Load(path) orelse {
                std.debug.print("{s}\n", .{c.SDL_GetError()});
                return error.IMGLoad;
            };
            defer c.SDL_FreeSurface(surface);

            break :blk c.SDL_CreateTextureFromSurface(renderer, surface) orelse return error.CreateTexture;
        };
    }
}

pub fn deinit(self: *Assets) void {
    inline for (asset_data.textures.entries) |texture_entry| {
        const field = @field(self, texture_entry[0]);
        c.SDL_DestroyTexture(field);
    }
}
