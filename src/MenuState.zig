const std = @import("std");
const c = @import("c");

const Assets = @import("Assets.zig");
const Game = @import("Game.zig");
const FoxState = @import("FoxState.zig");

const MenuState = @This();

const text =
    \\Hello, world!
    \\
    \\Enter to start
    \\Escape to quit
    \\Space to speed up
;

pub fn init() MenuState {
    return .{};
}

pub fn update(game: *Game, delta_time: f32) !void {
    const self = &game.state.menu;

    if (game.input.exit.pressed) {
        game.running = false;
        return;
    }

    if (game.input.confirm.pressed) {
        game.state = .{ .fox = FoxState.init(0) };
    }

    _ = self;
    _ = delta_time;
}

pub fn draw(self: MenuState, renderer: *c.SDL_Renderer, assets: Assets, interpolation: f32) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    _ = c.SDL_RenderClear(renderer);

    const surface = c.TTF_RenderUTF8_Blended_Wrapped(assets.menu, text, .{ .r = 255, .g = 255, .b = 255 }, 1024);
    defer c.SDL_FreeSurface(surface);

    const texture = c.SDL_CreateTextureFromSurface(renderer, surface);
    defer c.SDL_DestroyTexture(texture);

    var width: c_int = undefined;
    var height: c_int = undefined;
    _ = c.SDL_QueryTexture(texture, null, null, &width, &height);

    const rect: c.SDL_Rect = .{
        .x = 32,
        .y = 32,
        .w = width,
        .h = height,
    };

    _ = c.SDL_RenderCopy(renderer, texture, null, &rect);

    _ = self;
    _ = interpolation;
}
