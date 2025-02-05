const std = @import("std");
const c = @import("c");

const Assets = @import("../Assets.zig");
const Game = @import("../Game.zig");
const FoxState = @import("FoxState.zig");

const MenuState = @This();

const text =
    \\Hello, world!
    \\
    \\Enter to start
    \\Escape to quit
    \\Space to speed up
;

text_texture: *c.SDL_Texture = undefined,

pub fn init(game: Game) !MenuState {
    const surface = c.TTF_RenderUTF8_Blended_Wrapped(game.assets.menu, text, .{ .r = 255, .g = 255, .b = 255 }, 1024);
    defer c.SDL_FreeSurface(surface);

    const texture = c.SDL_CreateTextureFromSurface(game.renderer, surface) orelse return error.CreateTextureFromSurface;

    return .{
        .text_texture = texture,
    };
}

pub fn deinit(self: *MenuState) void {
    c.SDL_DestroyTexture(self.text_texture);
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

pub fn draw(self: MenuState, renderer: *c.SDL_Renderer, assets: Assets, interpolation: f32) void {
    _ = interpolation;
    _ = assets;

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = c.SDL_RenderClear(renderer);

    var width: c_int = undefined;
    var height: c_int = undefined;
    _ = c.SDL_QueryTexture(self.text_texture, null, null, &width, &height);

    const rect: c.SDL_Rect = .{
        .x = 32,
        .y = 32,
        .w = width,
        .h = height,
    };

    _ = c.SDL_RenderCopy(renderer, self.text_texture, null, &rect);
}
