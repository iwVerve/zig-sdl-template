const std = @import("std");

const config = @import("../../config.zig");
const util = @import("../../util.zig");
const Assets = @import("../../Assets.zig");
const Game = @import("../../Game.zig");
const core = @import("../../core.zig");
const Window = core.Window;
const Rectangle = util.Rectangle;
const Texture = core.Texture;
const InterpolatedVector2 = util.InterpolatedVector2;

const Fox = @This();

angle: f32,
position: util.InterpolatedVector2(f32),
texture: Texture,

const center = .{ .x = config.resolution.width / 2, .y = config.resolution.height / 2 };
const distance = 96;
const degrees_per_second = 90;
const draw_size = .{ .x = 64, .y = 64 };

pub fn init(assets: *Assets, starting_angle: f32) Fox {
    return .{
        .angle = starting_angle,
        .position = InterpolatedVector2(f32).init(getPosition(starting_angle)),
        .texture = assets.fox,
    };
}

pub fn update(self: *Fox, delta_time: f32, game: *Game) void {
    if (game.input.speedup.pressed) {
        game.assets.speedup.play();
    }

    const actual_degrees_per_second = @as(f32, if (game.input.speedup.held) 2 else 1) * degrees_per_second;

    self.angle += delta_time * actual_degrees_per_second;
    self.position.set(getPosition(self.angle));
}

fn getPosition(angle: f32) util.Vector2(f32) {
    const math = std.math;

    return .{
        .x = center.x + distance * @cos(math.degreesToRadians(angle)),
        .y = center.y - distance * @sin(math.degreesToRadians(angle)),
    };
}

pub fn draw(self: Fox, window: *Window, interpolation: f32) void {
    const draw_pos = self.position.get(interpolation);
    const rect: Rectangle(i32) = .{
        .x = @as(i32, @intFromFloat(draw_pos.x)) - draw_size.x / 2,
        .y = @as(i32, @intFromFloat(draw_pos.y)) - draw_size.y / 2,
        .width = draw_size.x,
        .height = draw_size.y,
    };

    window.drawTexture(self.texture, null, rect);
}
