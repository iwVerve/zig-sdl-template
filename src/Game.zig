const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");
const build_options = @import("build_options");

const Assets = @import("Assets.zig");
const config = @import("config.zig");
const util = @import("util.zig");
const states = @import("states.zig");
const State = states.State;
const MenuState = states.MenuState;
const FoxState = states.FoxState;
const Input = @import("Input.zig");

const Allocator = std.mem.Allocator;

const Game = @This();

allocator: Allocator,
window: *c.SDL_Window = undefined,
renderer: *c.SDL_Renderer = undefined,
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
    try self.initWindow();
    try self.initGame();
}

fn initWindow(self: *Game) !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) < 0) {
        return error.SDLInitialization;
    }

    if (c.IMG_Init(c.IMG_INIT_PNG) < 0) {
        return error.IMGInitialization;
    }

    if (c.Mix_OpenAudio(44100, c.AUDIO_S16SYS, 2, 4096) < 0) {
        return error.MixInitialization;
    }

    if (c.TTF_Init() < 0) {
        return error.TTFInitialization;
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
}

fn initGame(self: *Game) !void {
    self.tick_rate = config.default_tick_rate;
    self.last_time_count = c.SDL_GetPerformanceCounter();
    self.tick_time_left = 0;
    self.time_scale = 1;

    try self.assets.init(self.renderer);

    self.state = .{ .menu = try MenuState.init(self.*) };
    try self.tick(1 / self.tick_rate);
}

pub export fn initWrapper(self: *Game) c_int {
    self.initGame() catch return 1;
    return 0;
}

pub export fn deinit(self: *Game) void {
    self.deinitGame();
    self.deinitWindow();
}

pub fn deinitGame(self: *Game) void {
    self.assets.deinit();
    self.state.deinitCurrent();
}

fn deinitWindow(self: *Game) void {
    c.TTF_Quit();
    c.SDL_CloseAudio();
    c.IMG_Quit();
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
            c.SDL_KEYDOWN => {
                const sym = event.key.keysym.sym;
                if (build_options.mode == .dynamic) {
                    if (sym == config.debug_restart_key) {
                        self.debug_restart = true;
                    }
                    if (sym == config.debug_reload_key) {
                        self.debug_reload = true;
                    }
                }
                self.input.press(sym);
            },
            c.SDL_KEYUP => {
                self.input.release(event.key.keysym.sym);
            },
            else => {},
        }
    }

    const max_time_per_frame: u64 = config.max_seconds_per_frame * c.SDL_GetPerformanceFrequency();

    const start = c.SDL_GetPerformanceCounter();
    const frame_duration: u64 = @intFromFloat(self.time_scale * @as(f32, @floatFromInt((start - self.last_time_count))));
    self.tick_time_left += @min(frame_duration, max_time_per_frame);
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
    switch (self.state) {
        .menu => try MenuState.update(self, delta_time),
        .fox => try FoxState.update(self, delta_time),
    }

    self.input.clear();
}

fn draw(self: *Game, interpolation: f32) !void {
    switch (self.state) {
        .menu => |s| s.draw(self.renderer, self.assets, interpolation),
        .fox => |s| s.draw(self.renderer, self.assets, interpolation),
    }

    c.SDL_RenderPresent(self.renderer);
}

pub export fn updateWrapper(self: *Game) c_int {
    self.update() catch return 1;
    return 0;
}
