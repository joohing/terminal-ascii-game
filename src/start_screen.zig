const std = @import("std");
const NS_PER_US = 1000;
const NS_PER_MS = 1000 * NS_PER_US;
const NS_PER_S = 1000 * NS_PER_MS;

const TERM_WIDTH = 211;
const TERM_HEIGHT = 52;

const stdout = std.io.getStdOut();
var buffer = std.io.bufferedWriter(stdout.writer());
var writer = buffer.writer();

pub fn render_startup_screen() !void {
    try clear_terminal_screen();
    try render_game_border();
    try render_loading_bar();
}

/// Write the "clear screen" escape sequence to the buffer and flush.
fn clear_terminal_screen() !void {
    try writer.print("\x1B[2J\x1B[H", .{});
    try buffer.flush();
}

/// Renders a border representing the area used by the videogame.
fn render_game_border() !void {
    try writer.print("{s}{s}{s}", .{"/", "-" ** (TERM_WIDTH - 2), "\\"});
    const side_bars = "|" ++ " " ** (TERM_WIDTH - 2) ++ "|";
    try writer.print("{s}", .{(side_bars ++ "\n") ** (TERM_HEIGHT - 2)});
    try writer.print("{s}{s}{s}", .{"\\", "-" ** (TERM_WIDTH - 2), "/"});
    try buffer.flush();
}

/// Renders a fake loading bar.
fn render_loading_bar() !void {
    // Go to rows: 50, cols: 100 with the cursor and print the frame for the bar.
    try writer.print("\x1B[50;100H[          ]", .{});
    try buffer.flush();

    // Go to rows: 50, cols: 101 with the cursor.
    try writer.print("\x1B[50;101H", .{});

    // Write the hashtags inside the bar.
    inline for (0..10) |_| {
        std.time.sleep(1 * NS_PER_S);
        try writer.print("{s}", .{"#"});
        try buffer.flush();
    }
}
