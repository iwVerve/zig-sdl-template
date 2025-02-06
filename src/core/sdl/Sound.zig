const c = @import("c");

const Sound = @This();

sound: [*c]c.Mix_Chunk,

pub fn open(path: []const u8) !Sound {
    return .{
        .sound = c.Mix_LoadWAV(path.ptr) orelse return error.LoadWAV,
    };
}

pub fn deinit(self: *Sound) void {
    c.Mix_FreeChunk(self.sound);
}

pub fn play(self: Sound) void {
    _ = c.Mix_PlayChannel(-1, self.sound, 0);
}
