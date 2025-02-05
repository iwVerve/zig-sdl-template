const std = @import("std");

pub fn Vector2(comptime T: type) type {
    return struct {
        x: T = 0,
        y: T = 0,
    };
}

pub fn InterpolatedVector2(comptime T: type) type {
    return struct {
        const Self = @This();

        current: Vector2(T),
        prev: Vector2(T),

        pub fn init(vector: Vector2(T)) Self {
            return .{
                .current = vector,
                .prev = vector,
            };
        }

        pub fn set(self: *Self, new: Vector2(T)) void {
            self.prev = self.current;
            self.current = new;
        }

        pub fn get(self: Self, interpolation: f32) Vector2(T) {
            return .{
                .x = std.math.lerp(self.prev.x, self.current.x, interpolation),
                .y = std.math.lerp(self.prev.y, self.current.y, interpolation),
            };
        }
    };
}

pub fn Rectangle(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        width: T,
        height: T,
    };
}
