const std = @import("std");
const build_options = @import("build_options");

const Game = @import("Game.zig");
const config = @import("config.zig");

const DynLib = std.DynLib;

const dll_name = "bin/" ++ config.game_title ++ ".dll";

var dll: DynLib = undefined;
pub var init_fn: if (build_options.static) void else *@TypeOf(Game.initWrapper) = undefined;
pub var update_fn: if (build_options.static) void else *@TypeOf(Game.updateWrapper) = undefined;

pub fn dllOpen() !void {
    dll = try DynLib.open(dll_name);
    init_fn = dll.lookup(@TypeOf(init_fn), "initWrapper") orelse return error.Lookup;
    update_fn = dll.lookup(@TypeOf(update_fn), "updateWrapper") orelse return error.Lookup;
}

pub fn dllClose() void {
    dll.close();
}
