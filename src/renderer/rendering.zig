const std = @import("std");
const game_width = @import("../config.zig").GAME_WIDTH;
const game_height = @import("../config.zig").GAME_HEIGHT;
const one_cycle_ns = @import("../config.zig").NS_PER_CYCLE;

const ui = @import("../ui/start_screen.zig");

const stdout = std.io.getStdOut();
var buffer = std.io.bufferedWriter(stdout.writer());
var writer = buffer.writer();

pub const UIType = enum(u8) {
    startup_screen = 0,
    menu_screen = 1,
    gameplay = 2,
};

pub const UIRenderer = struct {
    active: bool,
    ui_type: UIType,
    pub fn render(self: UIRenderer) !void {
        if (!self.active) {
            return;
        }

        switch (self.ui_type) {
            UIType.startup_screen => {
                try render_startup_screen();
            },
            UIType.menu_screen => {},
            UIType.gameplay => {},
        }

        try buffer.flush();
    }
};

const EntityRenderer = struct {
    active: bool,
    fn render() !void {}
};

fn render_startup_screen() !void {
    try hide_terminal_cursor();
    try clear_terminal_screen();
    try add_game_border_to_render_cycle();
    try render_loading_bar();
    try show_terminal_cursor();
}

/// Renders a fake loading bar.
fn render_loading_bar() !void {
    // Go to rows: 50, cols: 100 with the cursor and print the frame for the bar.
    try move_cursor_to(50, 100);
    try writer.print("[          ]", .{});

    // Go to rows: 50, cols: 101 with the cursor.
    try writer.print("\x1B[50;101H", .{});

    // Write the hashtags inside the bar.
    inline for (0..10) |_| {
        std.time.sleep(1 * one_cycle_ns);
        try writer.print("{s}", .{"#"});
        try buffer.flush();
    }
}

/// Use an escape sequence to hide the cursor
fn hide_terminal_cursor() !void {
    try writer.print("\x1B[?25l", .{});
}

/// Use an escape sequence to show the cursor
fn show_terminal_cursor() !void {
    try writer.print("\x1B[?25h", .{});
    try buffer.flush();
}

/// Write the "clear screen" escape sequence to the buffer
fn clear_terminal_screen() !void {
    try writer.print("\x1B[2J\x1B[H", .{});
}

/// Renders a border representing the area used by the videogame.
fn add_game_border_to_render_cycle() !void {
    const frag = ui.get_game_border();
    try add_ui_fragment_to_render_cycle(frag);
}

/// Write the fragment to the buffer so that it will be displayed on flush.
fn add_ui_fragment_to_render_cycle(fragment: ui.UIFragment) !void {
    try move_cursor_to(fragment.pos_x, fragment.pos_y);
    try writer.print("{s}", .{fragment.ascii});
}

/// Move to the given coordinates of the screen.
fn move_cursor_to(x: u8, y: u8) !void {
    try writer.print("\x1B[{d};{d}H", .{ x, y });
}
