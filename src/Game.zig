const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");

const Assets = @import("Assets.zig");
const config = @import("config.zig");
const util = @import("util.zig");
const states = @import("states.zig");
const State = states.State;
const MenuState = states.MenuState;
const FoxState = states.FoxState;
const Input = @import("Input.zig");
const core = @import("core.zig");
const Window = core.Window;
const Event = core.Event;

const Allocator = std.mem.Allocator;

const Game = @This();

allocator: Allocator,
window: Window = undefined,
assets: Assets = .{},

running: bool = true,
// Initialized in initGame.
tick_rate: f32 = undefined,
last_time_count: u64 = undefined,
tick_time_left: u64 = undefined,
time_scale: f32 = undefined,
debug_restart: bool = false,
debug_reload: bool = false,

state: State = undefined,
input: Input = .{},

pub fn init(self: *Game) !void {
    self.window = try Window.init(.{
        .title = config.game_title,
        .width = config.resolution.width,
        .height = config.resolution.height,
        .resizable = true,
    });
    try self.initGame();
}

fn initGame(self: *Game) !void {
    self.tick_rate = config.default_tick_rate;
    self.last_time_count = core.getTimer();
    self.tick_time_left = 0;
    self.time_scale = 1;

    try self.assets.init(self.window);

    self.state = .{ .menu = try MenuState.init(self.*) };
    try self.tick(1 / self.tick_rate);
}

pub export fn initWrapper(self: *Game) c_int {
    self.initGame() catch return 1;
    return 0;
}

pub export fn deinit(self: *Game) void {
    self.deinitGame();
    self.window.deinit();
}

pub fn deinitGame(self: *Game) void {
    self.assets.deinit();
    self.state.deinitCurrent();
}

pub fn update(self: *Game) !void {
    while (Event.poll()) |event| {
        switch (event) {
            .quit => {
                self.running = false;
                return;
            },
            .key_down => |e| {
                if (build_options.mode == .dynamic) {
                    if (e.index == config.debug_restart_key) {
                        self.debug_restart = true;
                    }
                    if (e.index == config.debug_reload_key) {
                        self.debug_reload = true;
                    }
                }
                self.input.press(e.index);
            },
            .key_up => |e| {
                self.input.release(e.index);
            },
        }
    }

    const max_time_per_frame: u64 = config.max_seconds_per_frame * core.getTimerFrequency();

    const start = core.getTimer();
    const frame_duration: u64 = @intFromFloat(self.time_scale * @as(f32, @floatFromInt((start - self.last_time_count))));
    self.tick_time_left += @min(frame_duration, max_time_per_frame);
    self.last_time_count = start;

    const time_per_tick: u64 = @intFromFloat(@as(f32, @floatFromInt(core.getTimerFrequency())) / self.tick_rate);
    const seconds_per_tick: f32 = 1.0 / self.tick_rate;
    while (self.tick_time_left >= time_per_tick) {
        try self.tick(seconds_per_tick);
        self.tick_time_left -= time_per_tick;
    }

    const interpolation = @as(f32, @floatFromInt(self.tick_time_left)) / @as(f32, @floatFromInt(time_per_tick));

    try self.draw(interpolation);
}

fn tick(self: *Game, delta_time: f32) !void {
    switch (self.state) {
        .menu => try MenuState.update(self, delta_time),
        .fox => try FoxState.update(self, delta_time),
    }

    self.input.clear();
}

fn draw(self: *Game, interpolation: f32) !void {
    self.window.drawStart();

    switch (self.state) {
        .menu => |s| s.draw(&self.window, self.assets, interpolation),
        .fox => |s| s.draw(&self.window, self.assets, interpolation),
    }

    self.window.drawEnd();
}

pub export fn updateWrapper(self: *Game) c_int {
    self.update() catch return 1;
    return 0;
}
