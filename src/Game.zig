const std = @import("std");
const builtin = @import("builtin");
const c = @import("c");

const Assets = @import("Assets.zig");
const config = @import("config.zig");

const Allocator = std.mem.Allocator;

const Game = @This();

allocator: Allocator,
window: *c.SDL_Window = undefined,
renderer: *c.SDL_Renderer = undefined,
assets: Assets = .{},

running: bool = true,
last_update: u64 = undefined,

angle: f32 = 0,

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
        c.SDL_RENDERER_ACCELERATED,
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
    self.last_update = c.SDL_GetPerformanceCounter();
    try self.assets.init(self.renderer);
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
    const start = c.SDL_GetPerformanceCounter();

    self.angle += 2;

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

    try self.draw();

    const frame_time_ms = 1000.0 / @as(comptime_float, config.frame_rate);
    const end = c.SDL_GetPerformanceCounter();
    const frame_duration_ms = @as(f32, @floatFromInt(1000 * (end - start))) / @as(f32, @floatFromInt(c.SDL_GetPerformanceFrequency()));
    c.SDL_Delay(@intFromFloat(@max(0, frame_time_ms - frame_duration_ms)));
}

fn draw(self: *Game) !void {
    const math = std.math;

    _ = c.SDL_SetRenderDrawColor(self.renderer, 127, 255, 255, 255);
    _ = c.SDL_RenderClear(self.renderer);

    const center = .{ .x = config.resolution.width / 2, .y = config.resolution.height / 2 };
    const size = .{ .w = 64, .h = 64 };
    const distance = 96;
    const rect: c.SDL_Rect = .{
        .x = @intFromFloat(center.x - size.w / 2 + distance * @cos(math.degreesToRadians(self.angle))),
        .y = @intFromFloat(center.y - size.h / 2 - distance * @sin(math.degreesToRadians(self.angle))),
        .w = size.w,
        .h = size.h,
    };
    _ = c.SDL_RenderCopy(self.renderer, self.assets.fox, null, &rect);

    c.SDL_RenderPresent(self.renderer);
}

export fn updateWrapper(self: *Game) c_int {
    self.update() catch return 1;
    return 0;
}
