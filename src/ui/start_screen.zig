const std = @import("std");
const game_width = @import("../config.zig").GAME_WIDTH;
const game_height = @import("../config.zig").GAME_HEIGHT;
const one_cycle_ns = @import("../config.zig").NS_PER_CYCLE;

/// A fragment that can be added to a render cycle, thus
/// being rendered the next time the buffer for rendering is
/// flushed.
pub const UIFragment = struct {
    /// The x-position at which to place the cursor when starting
    /// the drawing of this UIFragment.
    pos_x: u8,
    /// The y-position at which to place the cursor when starting
    /// the drawing of this UIFragment.
    pos_y: u8,
    /// The actual ASCII art that needs to get written to the
    /// render buffer, containing cursor movements as well.
    ascii: []const u8,
    update: fn (self: UIFragment) void,
};

/// A border containing the area used by the videogame.
pub fn get_game_border() UIFragment {
    const top_part = "/" ++ "-" ** (game_width - 2) ++ "\\\n";
    const side_bars_fragment = "|" ++ " " ** (game_width - 2) ++ "|";
    const side_bars = (side_bars_fragment ++ "\n") ** (game_height - 2);
    const bottom_part = "\\" ++ "-" ** (game_width - 2) ++ "/";

    const update = fn (self: UIFragment) void{};

    const frag = UIFragment{
        .pos_x = 0,
        .pos_y = 0,
        .ascii = top_part ++ side_bars ++ bottom_part,
        .update = update,
    };

    return frag;
}
