const std = @import("std");
const c = @import("c");

const Input = @This();

const Key = struct {
    sym: i32,
    pressed: bool = false,
    released: bool = false,
    held: bool = false,

    pub fn press(self: *Key) void {
        self.pressed = true;
        self.held = true;
    }

    pub fn release(self: *Key) void {
        self.released = true;
        self.held = false;
    }

    pub fn clear(self: *Key) void {
        self.pressed = false;
        self.released = false;
    }
};

confirm: Key = .{ .sym = c.SDLK_RETURN },
exit: Key = .{ .sym = c.SDLK_ESCAPE },
speedup: Key = .{ .sym = c.SDLK_SPACE },

const key_names = .{ "confirm", "exit", "speedup" };

pub fn press(self: *Input, sym: i32) void {
    inline for (key_names) |key_name| {
        const key = &@field(self, key_name);
        if (key.sym == sym) {
            key.press();
        }
    }
}

pub fn release(self: *Input, sym: i32) void {
    inline for (key_names) |key_name| {
        const key = &@field(self, key_name);
        if (key.sym == sym) {
            key.release();
        }
    }
}

pub fn clear(self: *Input) void {
    inline for (key_names) |key_name| {
        const key = &@field(self, key_name);
        key.clear();
    }
}
