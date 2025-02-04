const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");
const build_options = @import("build_options");

const Game = @import("Game.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game: Game = .{ .allocator = allocator };

    try game.init();
    defer game.deinit();

    if (builtin.target.isWasm()) {
        c.emscripten_set_main_loop_arg(&emscripten_main_loop, &game, 0, true);
    } else if (build_options.static) {
        while (game.running) {
            try game.update();
        }
    } else {}
}

fn emscripten_main_loop(game_ptr: ?*anyopaque) callconv(.C) void {
    const game: *Game = @ptrCast(@alignCast(game_ptr));
    game.update() catch {};
}
