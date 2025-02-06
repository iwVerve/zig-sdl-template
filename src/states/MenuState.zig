const std = @import("std");
const c = @import("c");

const Assets = @import("../Assets.zig");
const Game = @import("../Game.zig");
const FoxState = @import("FoxState.zig");
const util = @import("../util.zig");
const Rectangle = util.Rectangle;
const core = @import("../core.zig");
const Window = core.Window;
const Texture = core.Texture;

const MenuState = @This();

const text =
    \\Hello, world!
    \\
    \\Enter to start
    \\Escape to quit
    \\Space to speed up
;

text_texture: Texture = undefined,

pub fn init(game: Game) !MenuState {
    const surface = c.TTF_RenderUTF8_Blended_Wrapped(game.assets.menu.font, text, .{ .r = 255, .g = 255, .b = 255 }, 1024);
    defer c.SDL_FreeSurface(surface);

    const texture = c.SDL_CreateTextureFromSurface(game.window.renderer, surface) orelse return error.CreateTextureFromSurface;

    var width: c_int = undefined;
    var height: c_int = undefined;
    _ = c.SDL_QueryTexture(texture, null, null, &width, &height);

    return .{
        .text_texture = .{
            .texture = texture,
            .size = .{
                .x = @intCast(width),
                .y = @intCast(height),
            },
        },
    };
}

pub fn deinit(self: *MenuState) void {
    self.text_texture.deinit();
}

pub fn update(game: *Game, delta_time: f32) !void {
    const self = &game.state.menu;
    _ = self;
    _ = delta_time;

    if (game.input.exit.pressed) {
        game.running = false;
        return;
    }

    if (game.input.confirm.pressed) {
        game.state.change(.{ .fox = FoxState.init(game.*, 0) });
        return;
    }
}

pub fn draw(self: MenuState, window: *Window, assets: Assets, interpolation: f32) void {
    _ = interpolation;
    _ = assets;

    window.setDrawColor(.{});
    window.clear();

    const rect: Rectangle(u32) = .{
        .x = 32,
        .y = 32,
        .width = @intCast(self.text_texture.size.x),
        .height = @intCast(self.text_texture.size.y),
    };

    window.drawTexture(self.text_texture, null, rect);
}
