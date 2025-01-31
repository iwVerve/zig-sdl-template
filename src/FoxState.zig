const std = @import("std");
const c = @import("c");

const Assets = @import("Assets.zig");
const Fox = @import("FoxState/Fox.zig");
const Game = @import("Game.zig");
const MenuState = @import("MenuState.zig");

const FoxState = @This();

fox: Fox,

pub fn init(starting_angle: f32) FoxState {
    return .{
        .fox = Fox.init(starting_angle),
    };
}

pub fn update(game: *Game, delta_time: f32) !void {
    const self = &game.state.fox;

    if (game.input.exit.pressed) {
        game.state.change(.{ .menu = try MenuState.init(game.*) });
        return;
    }

    self.fox.update(delta_time, game);
}

pub fn draw(self: FoxState, renderer: *c.SDL_Renderer, assets: Assets, interpolation: f32) void {
    _ = c.SDL_SetRenderDrawColor(renderer, 127, 255, 255, 255);
    _ = c.SDL_RenderClear(renderer);

    self.fox.draw(renderer, assets, interpolation);
}
