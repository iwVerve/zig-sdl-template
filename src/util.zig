const std = @import("std");

pub const Vector2 = struct {
    x: f32 = 0,
    y: f32 = 0,
};

pub const InterpolatedVector2 = struct {
    current: Vector2,
    prev: Vector2,

    pub fn init(vector: Vector2) InterpolatedVector2 {
        return .{
            .current = vector,
            .prev = vector,
        };
    }

    pub fn set(self: *InterpolatedVector2, new: Vector2) void {
        self.prev = self.current;
        self.current = new;
    }

    pub fn get(self: InterpolatedVector2, interpolation: f32) Vector2 {
        return .{
            .x = std.math.lerp(self.prev.x, self.current.x, interpolation),
            .y = std.math.lerp(self.prev.y, self.current.y, interpolation),
        };
    }
};
