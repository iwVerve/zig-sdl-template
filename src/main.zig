const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");

const Game = @import("Game.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game: Game = .{ .allocator = allocator };

    try game.init();
    defer game.deinit();

    if (builtin.target.isWasm()) {
        emscripten_game = &game;
        c.emscripten_set_main_loop(&emscripten_main_loop, 0, true);
    } else {
        while (game.running) {
            try game.update();
        }
    }
}

var emscripten_game: *Game = undefined;
fn emscripten_main_loop() callconv(.C) void {
    Game.update(emscripten_game) catch {};
}
