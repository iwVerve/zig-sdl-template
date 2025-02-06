const std = @import("std");
const c = @import("c");

const Assets = @import("../Assets.zig");
const Fox = @import("FoxState/Fox.zig");
const Game = @import("../Game.zig");
const MenuState = @import("MenuState.zig");
const core = @import("../core.zig");
const Window = core.Window;

const FoxState = @This();

fox: Fox,

pub fn init(game: Game, starting_angle: f32) FoxState {
    _ = game;
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

pub fn draw(self: FoxState, window: *Window, assets: Assets, interpolation: f32) void {
    window.setDrawColor(.{ .r = 127, .g = 255, .b = 255 });
    window.clear();

    self.fox.draw(window, assets, interpolation);
}
