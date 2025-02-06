const c = @import("c");

const core = @import("../../core.zig");
const util = @import("../../util.zig");
const Color = util.Color;
const Texture = core.Texture;
const Rectangle = util.Rectangle;

const CreateWindowOptions = core.CreateWindowOptions;

const Window = @This();

window: *c.SDL_Window,
renderer: *c.SDL_Renderer,

pub fn init(options: CreateWindowOptions) !Window {
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

    const flags = blk: {
        var flags: u32 = c.SDL_WINDOW_SHOWN;
        if (options.resizable) {
            flags |= c.SDL_WINDOW_RESIZABLE;
        }
        break :blk flags;
    };

    const window = c.SDL_CreateWindow(
        options.title.ptr,
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        @intCast(options.width),
        @intCast(options.height),
        flags,
    ) orelse return error.CreateWindow;

    const renderer = c.SDL_CreateRenderer(
        window,
        -1,
        c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC,
    ) orelse return error.CreateRenderer;

    return .{
        .window = window,
        .renderer = renderer,
    };
}

pub fn deinit(self: *Window) void {
    c.SDL_DestroyRenderer(self.renderer);
    c.SDL_DestroyWindow(self.window);
    c.TTF_Quit();
    c.SDL_CloseAudio();
    c.IMG_Quit();
    c.SDL_Quit();
}

pub fn drawStart(self: *Window) void {
    _ = self;
}

pub fn drawEnd(self: *Window) void {
    _ = c.SDL_RenderPresent(self.renderer);
}

pub fn setDrawColor(self: *Window, color: Color) void {
    _ = c.SDL_SetRenderDrawColor(self.renderer, color.r, color.g, color.b, color.a);
}

pub fn clear(self: *Window) void {
    _ = c.SDL_RenderClear(self.renderer);
}

pub fn drawTexture(self: *Window, texture: Texture, source: ?Rectangle(i32), destination: Rectangle(i32)) void {
    const source_c: ?*c.SDL_Rect = if (source) |actual_source| blk: {
        var rect: c.SDL_Rect = .{
            .x = @intCast(actual_source.x),
            .y = @intCast(actual_source.y),
            .w = @intCast(actual_source.width),
            .h = @intCast(actual_source.height),
        };
        break :blk &rect;
    } else null;

    const destination_c: c.SDL_Rect = .{
        .x = @intCast(destination.x),
        .y = @intCast(destination.y),
        .w = @intCast(destination.width),
        .h = @intCast(destination.height),
    };
    _ = c.SDL_RenderCopy(self.renderer, texture.texture, source_c, &destination_c);
}
