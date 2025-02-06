const c = @import("c");

pub const Event = union(enum) {
    quit: void,
    key_down: KeyEvent,
    key_up: KeyEvent,

    pub fn poll() ?Event {
        var event: c.SDL_Event = undefined;

        while (true) {
            if (c.SDL_PollEvent(&event) == 0) {
                return null;
            }

            return switch (event.type) {
                c.SDL_QUIT => .quit,
                c.SDL_KEYDOWN => .{ .key_down = .{ .index = event.key.keysym.sym } },
                c.SDL_KEYUP => .{ .key_up = .{ .index = event.key.keysym.sym } },
                else => continue,
            };
        }
    }
};

pub const KeyEvent = struct {
    index: i32,
};
