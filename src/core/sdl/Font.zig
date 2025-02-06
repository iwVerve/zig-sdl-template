const c = @import("c");

const Font = @This();

font: *c.TTF_Font,

pub fn init(path: []const u8, size: u32) !Font {
    return .{
        .font = c.TTF_OpenFont(path.ptr, @intCast(size)) orelse return error.OpenFont,
    };
}

pub fn deinit(self: *Font) void {
    c.TTF_CloseFont(self.font);
}
