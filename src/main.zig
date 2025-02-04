const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");
const build_options = @import("build_options");

const hotreload = @import("hotreload.zig");
const Game = @import("Game.zig");

const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    if (build_options.mode != .web) {
        try setCwd(allocator);
    }

    var game: Game = .{ .allocator = allocator };

    try game.init();
    defer game.deinit();

    switch (build_options.mode) {
        .static => while (game.running) {
            try game.update();
        },
        .dynamic => {
            try hotreload.dllOpen();
            while (game.running) {
                if (hotreload.update_fn(&game) != 0) {
                    return error.Update;
                }
            }
        },
        .web => {
            c.emscripten_set_main_loop_arg(&emscripten_main_loop, &game, 0, true);
        },
    }
}

fn emscripten_main_loop(game_ptr: ?*anyopaque) callconv(.C) void {
    const game: *Game = @ptrCast(@alignCast(game_ptr));
    game.update() catch {};
}

fn setCwd(allocator: Allocator) !void {
    const path = try std.fs.selfExeDirPathAlloc(allocator);
    defer allocator.free(path);

    var dir = try std.fs.openDirAbsolute(std.fs.path.dirname(path) orelse return error.Path, .{});
    defer dir.close();

    try dir.setAsCwd();
}
