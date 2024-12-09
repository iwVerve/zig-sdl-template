const std = @import("std");
const c = @import("c");

const Assets = @import("Assets.zig");
const Game = @import("Game.zig");
const FoxState = @import("FoxState.zig");

const MenuState = @This();

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

    _ = self;
    _ = assets;
    _ = interpolation;
}
