const MenuState = @import("MenuState.zig");
const FoxState = @import("FoxState.zig");

pub const State = union(enum) {
    menu: MenuState,
    fox: FoxState,

    pub fn deinitCurrent(self: *State) void {
        switch (self.*) {
            .menu => |*m| m.deinit(),
            .fox => {},
        }
    }

    pub fn change(self: *State, new_state: State) void {
        self.deinitCurrent();
        self.* = new_state;
    }
};
