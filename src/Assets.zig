const std = @import("std");

const config = @import("config.zig");
const core = @import("core.zig");
const Texture = core.Texture;
const Window = core.Window;
const Font = core.Font;
const Sound = core.Sound;

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
speedup: Sound = undefined,
menu: Font = undefined,

pub fn init(self: *Assets, window: Window) !void {
    inline for (asset_data.textures.entries) |texture_entry| {
        const field = &@field(self, texture_entry[0]);
        const path = asset_data.dir ++ asset_data.textures.path ++ texture_entry[1];

        field.* = try Texture.open(path, window);
    }

    inline for (asset_data.sounds.entries) |sound_entry| {
        const field = &@field(self, sound_entry[0]);
        const path = asset_data.dir ++ asset_data.sounds.path ++ sound_entry[1];

        field.* = try Sound.open(path);
    }

    inline for (asset_data.fonts.entries) |font_entry| {
        const field = &@field(self, font_entry[0]);
        const path = asset_data.dir ++ asset_data.fonts.path ++ font_entry[1];

        field.* = try Font.init(path, font_entry[2]);
    }
}

pub fn deinit(self: *Assets) void {
    inline for (asset_data.textures.entries) |texture_entry| {
        var texture = @field(self, texture_entry[0]);
        texture.deinit();
    }

    inline for (asset_data.sounds.entries) |sound_entry| {
        var sound = @field(self, sound_entry[0]);
        sound.deinit();
    }

    inline for (asset_data.fonts.entries) |font_entry| {
        var font = @field(self, font_entry[0]);
        font.deinit();
    }
}
