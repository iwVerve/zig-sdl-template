const std = @import("std");

const Assets = @import("../Assets.zig");
const Fox = @import("FoxState/Fox.zig");
const Game = @import("../Game.zig");
const MenuState = @import("MenuState.zig");
const core = @import("../core.zig");
const Window = core.Window;

const FoxState = @This();

fox: Fox,

pub fn init(game: *Game, starting_angle: f32) FoxState {
    return .{
        .fox = Fox.init(&game.assets, starting_angle),
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
    _ = assets;

    window.setDrawColor(.{ .r = 127, .g = 255, .b = 255 });
    window.clear();

    self.fox.draw(window, interpolation);
}
