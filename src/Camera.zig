const std = @import("std");
const c = @import("c");

const util = @import("util.zig");

const math = std.math;
const Vector2 = util.Vector2;

const Camera = @This();

renderer: *c.SDL_Renderer,
position: Vector2(f32) = .{},

pub fn worldToScreen(self: Camera, position: Vector2(f32)) Vector2(f32) {
    return .{
        .x = position.x - self.position.x,
        .y = position.y - self.position.y,
    };
}

pub fn renderCopy(self: Camera, texture: *c.SDL_Texture, source: ?*c.SDL_Rect, destination: ?*c.SDL_Rect) void {
    const screen_position = self.worldToScreen(.{ .x = @floatFromInt(destination.?.x), .y = @floatFromInt(destination.?.y) });
    const screen_destination: c.SDL_Rect = .{
        .x = @intFromFloat(screen_position.x),
        .y = @intFromFloat(screen_position.y),
        .w = destination.?.w,
        .h = destination.?.h,
    };
    _ = c.SDL_RenderCopy(self.renderer, texture, source, &screen_destination);
}
