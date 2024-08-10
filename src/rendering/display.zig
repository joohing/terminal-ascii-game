const std = @import("std");
const WINDOW_WIDTH: usize = 211;
const WINDOW_HEIGHT: usize = 52;

pub const GameDisplay = struct {
    stdout: std.fs.File = std.io.getStdOut(),

    pub fn display_buffer(self: *GameDisplay, buffer: []const u8) !void {
        try self.clear_display();

        const row_count = WINDOW_HEIGHT;

        for (0..row_count) |row| {
            const start = row * WINDOW_WIDTH;
            const end = (row + 1) * WINDOW_WIDTH;
            try self.stdout.writer().print("{s}\n", .{buffer[start..end]});
        }
    }

    fn hide_cursor(self: *GameDisplay) !void {
        try self.stdout.writer().print("\x1B[?25l\n", .{});
    }
    fn show_cursor(self: *GameDisplay) !void {
        try self.stdout.writer().print("\x1B[?25h\n", .{});
    }
    fn clear_display(self: *GameDisplay) !void {
        try self.stdout.writer().print("\x1B[2J\n", .{});
    }
};
