const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");

const Assets = @import("Assets.zig");
const config = @import("config.zig");
const util = @import("util.zig");
const Fox = @import("Fox.zig");

const Allocator = std.mem.Allocator;

const Game = @This();

allocator: Allocator,
window: *c.SDL_Window = undefined,
renderer: *c.SDL_Renderer = undefined,
assets: Assets = .{},

running: bool = true,
tick_rate: f32 = 60,
last_time_count: u64 = undefined,
tick_time_left: u64 = 0,

fox: Fox = undefined,

pub fn init(self: *Game) !void {
    try self.initWindow();
    try self.initGame();
}

fn initWindow(self: *Game) !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        return error.SDLInitialization;
    }

    if (c.IMG_Init(c.IMG_INIT_PNG) < 0) {
        return error.IMGInitialization;
    }

    self.window = c.SDL_CreateWindow(
        config.game_title,
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        config.resolution.width,
        config.resolution.height,
        c.SDL_WINDOW_SHOWN,
    ) orelse return error.CreateWindow;

    self.renderer = c.SDL_CreateRenderer(
        self.window,
        -1,
        c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC,
    ) orelse return error.CreateRenderer;

    if (!builtin.target.isWasm()) {
        const path = try std.fs.selfExeDirPathAlloc(self.allocator);
        defer self.allocator.free(path);

        var dir = try std.fs.openDirAbsolute(std.fs.path.dirname(path) orelse return error.Path, .{});
        defer dir.close();
        try dir.setAsCwd();
    }
}

fn initGame(self: *Game) !void {
    self.last_time_count = c.SDL_GetPerformanceCounter();
    try self.assets.init(self.renderer);

    self.fox = Fox.init(0);

    try self.tick(1 / self.tick_rate);
}

export fn initWrapper(self: *Game) c_int {
    self.init() catch return 1;
    return 0;
}

pub export fn deinit(self: *Game) void {
    self.deinitGame();
    self.deinitWindow();
}

fn deinitGame(self: *Game) void {
    self.assets.deinit();
}

fn deinitWindow(self: *Game) void {
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.SDL_Quit();
}

pub fn update(self: *Game) !void {
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            c.SDL_QUIT => {
                self.running = false;
                return;
            },
            else => {},
        }
    }

    const max_seconds_per_frame = 1;
    const max_time_per_frame: u64 = max_seconds_per_frame * c.SDL_GetPerformanceFrequency();

    const start = c.SDL_GetPerformanceCounter();
    self.tick_time_left += @min(start - self.last_time_count, max_time_per_frame);
    self.last_time_count = start;

    const time_per_tick: u64 = @intFromFloat(@as(f32, @floatFromInt(c.SDL_GetPerformanceFrequency())) / self.tick_rate);
    const seconds_per_tick: f32 = 1.0 / self.tick_rate;
    while (self.tick_time_left >= time_per_tick) {
        try self.tick(seconds_per_tick);
        self.tick_time_left -= time_per_tick;
    }

    const interpolation = @as(f32, @floatFromInt(self.tick_time_left)) / @as(f32, @floatFromInt(time_per_tick));

    try self.draw(interpolation);
}

fn tick(self: *Game, delta_time: f32) !void {
    self.fox.update(delta_time);
}

fn draw(self: *Game, interpolation: f32) !void {
    _ = c.SDL_SetRenderDrawColor(self.renderer, 127, 255, 255, 255);
    _ = c.SDL_RenderClear(self.renderer);

    self.fox.draw(self.renderer, self.assets, interpolation);

    c.SDL_RenderPresent(self.renderer);
}

export fn updateWrapper(self: *Game) c_int {
    self.update() catch return 1;
    return 0;
}
