const std = @import("std");
const c = @import("c");

const config = @import("config.zig");
const Texture = @import("core.zig").Texture;

const Assets = @This();

const asset_data = .{
    .dir = config.data_dir ++ "/",
    .textures = .{
        .path = "sprites/",
        .entries = .{
            .{ "fox", "fox.png" },
        },
    },
    .sounds = .{
        .path = "sounds/",
        .entries = .{
            .{ "speedup", "speedup.wav" },
        },
    },
    .fonts = .{
        .path = "fonts/",
        .entries = .{
            .{ "menu", "BarlowCondensed-Regular.ttf", 24 },
        },
    },
};

fox: Texture = undefined,
speedup: [*c]c.Mix_Chunk = undefined,
menu: *c.TTF_Font = undefined,

pub fn init(self: *Assets, renderer: *c.SDL_Renderer) !void {
    inline for (asset_data.textures.entries) |texture_entry| {
        const field = &@field(self, texture_entry[0]);
        const path = asset_data.dir ++ asset_data.textures.path ++ texture_entry[1];

        field.* = try Texture.init(path, .{ .window = undefined, .renderer = renderer });
    }

    inline for (asset_data.sounds.entries) |sound_entry| {
        const field = &@field(self, sound_entry[0]);
        const path = asset_data.dir ++ asset_data.sounds.path ++ sound_entry[1];

        const sound = c.Mix_LoadWAV(path);
        if (sound == null) {
            return error.SoundLoad;
        }

        field.* = sound;
    }

    inline for (asset_data.fonts.entries) |font_entry| {
        const field = &@field(self, font_entry[0]);
        const path = asset_data.dir ++ asset_data.fonts.path ++ font_entry[1];

        const font = c.TTF_OpenFont(path, font_entry[2]) orelse return error.OpenFont;

        field.* = font;
    }
}

pub fn deinit(self: *Assets) void {
    inline for (asset_data.textures.entries) |texture_entry| {
        var field = @field(self, texture_entry[0]);
        Texture.deinit(&field);
    }

    inline for (asset_data.sounds.entries) |sound_entry| {
        const field = @field(self, sound_entry[0]);
        c.Mix_FreeChunk(field);
    }

    inline for (asset_data.fonts.entries) |font_entry| {
        const field = @field(self, font_entry[0]);
        c.TTF_CloseFont(field);
    }
}
