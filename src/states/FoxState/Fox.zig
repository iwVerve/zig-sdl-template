const std = @import("std");
const c = @import("c");

const config = @import("../../config.zig");
const util = @import("../../util.zig");
const Assets = @import("../../Assets.zig");
const Game = @import("../../Game.zig");
const core = @import("../../core.zig");
const Window = core.Window;
const Rectangle = util.Rectangle;

const Fox = @This();

angle: f32,
position: util.InterpolatedVector2(f32),

const center = .{ .x = config.resolution.width / 2, .y = config.resolution.height / 2 };
const size = .{ .width = 64, .height = 64 };
const distance = 96;
const degrees_per_second = 90;

pub fn init(starting_angle: f32) Fox {
    return .{
        .angle = starting_angle,
        .position = util.InterpolatedVector2(f32).init(getPosition(starting_angle)),
    };
}

pub fn update(self: *Fox, delta_time: f32, game: *Game) void {
    if (game.input.speedup.pressed) {
        _ = c.Mix_PlayChannel(-1, game.assets.speedup, 0);
    }

    const actual_degrees_per_second = @as(f32, if (game.input.speedup.held) 2 else 1) * degrees_per_second;

    self.angle += delta_time * actual_degrees_per_second;
    self.position.set(getPosition(self.angle));
}

fn getPosition(angle: f32) util.Vector2(f32) {
    const math = std.math;

    return .{
        .x = center.x - size.width / 2 + distance * @cos(math.degreesToRadians(angle)),
        .y = center.y - size.height / 2 - distance * @sin(math.degreesToRadians(angle)),
    };
}

pub fn draw(self: Fox, window: *Window, assets: Assets, interpolation: f32) void {
    const draw_pos = self.position.get(interpolation);
    const rect: Rectangle(u32) = .{
        .x = @intFromFloat(draw_pos.x),
        .y = @intFromFloat(draw_pos.y),
        .width = size.width,
        .height = size.height,
    };

    window.drawTexture(assets.fox, null, rect);
}
