const std = @import("std");
const c = @import("c");

const Input = @This();

const KeyInput = struct {
    key: i32,
    pressed: bool = false,
    released: bool = false,
    held: bool = false,

    pub fn press(self: *KeyInput) void {
        if (!self.held) {
            self.pressed = true;
            self.held = true;
        }
    }

    pub fn release(self: *KeyInput) void {
        if (self.held) {
            self.released = true;
            self.held = false;
        }
    }

    pub fn clear(self: *KeyInput) void {
        self.pressed = false;
        self.released = false;
    }
};

confirm: KeyInput = .{ .key = c.SDLK_RETURN },
exit: KeyInput = .{ .key = c.SDLK_ESCAPE },
speedup: KeyInput = .{ .key = c.SDLK_SPACE },

pub const key_names = .{ "confirm", "exit", "speedup" };

pub fn press(self: *Input, key: i32) void {
    inline for (key_names) |key_name| {
        const key_input = &@field(self, key_name);
        if (key_input.key == key) {
            key_input.press();
        }
    }
}

pub fn release(self: *Input, key: i32) void {
    inline for (key_names) |key_name| {
        const key_input = &@field(self, key_name);
        if (key_input.key == key) {
            key_input.release();
        }
    }
}

pub fn clear(self: *Input) void {
    inline for (key_names) |key_name| {
        const key_input = &@field(self, key_name);
        key_input.clear();
    }
}
