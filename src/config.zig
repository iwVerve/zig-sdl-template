const c = @import("c");

pub const game_title = "Zig SDL2 Template";

// INSTALL

pub const data_dir = "data";

pub const install_dirs = &.{
    data_dir,
};

pub const static_build_path = "static";
pub const dynamic_build_path = "dynamic";
pub const web_build_path = "web";

// GAME

pub const default_tick_rate = 60;

pub const resolution = .{
    .width = 640,
    .height = 360,
};

pub const max_seconds_per_frame = 1;

/// Restarts the game when pressed in dynamic builds. Set to null to disable.
pub const debug_restart_key: ?i32 = c.SDLK_F2;
/// Reloads game code when pressed in dynamic builds. Set to null to disable.
pub const debug_reload_key: ?i32 = c.SDLK_F3;
