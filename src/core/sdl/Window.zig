const c = @import("c");

const WindowCore = @import("../Window.zig");

const CreateWindowOptions = WindowCore.CreateWindowOptions;

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
        var flags = c.SDL_WINDOW_SHOWN;
        if (options.resizable) {
            flags |= c.SDL_WINDOW_RESIZABLE;
        }
        break :blk flags;
    };

    const window = c.SDL_CreateWindow(
        options.title,
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
