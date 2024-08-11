const std = @import("std");
const WINDOW_WIDTH: usize = 211;
const WINDOW_HEIGHT: usize = 52;

pub const InputBuffer = struct {
    buf: [256]u8 = undefined,
    ptr: u8 = 0,
    mutex: std.Thread.Mutex,
};

pub const GameDisplay = struct {
    stdin_buffer: InputBuffer,
    stdin: std.fs.File,
    stdout: std.fs.File,

    pub fn init() !GameDisplay {
        std.debug.print("Initting!", .{});

        return GameDisplay{ .stdin = undefined, .stdout = std.io.getStdOut(), .stdin_buffer = InputBuffer{
            .buf = undefined,
            .ptr = 0,
            .mutex = .{},
        } };
    }

    pub fn start_stdin_reading_thread(self: *GameDisplay) !void {
        _ = try std.Thread.spawn(.{}, read_stdin_thread, .{&self.stdin_buffer});
    }

    pub fn display_buffer(self: *GameDisplay, buffer: []const u8) !void {
        try self.clear_display();
        try self.disable_echo();

        const row_count = WINDOW_HEIGHT;

        for (0..row_count) |row| {
            const start = row * WINDOW_WIDTH;
            const end = (row + 1) * WINDOW_WIDTH;
            try self.stdout.writer().print("{s}\n", .{buffer[start..end]});
        }

        _ = try self.stdout.writer().print("Input buffer: {s}", .{self.stdin_buffer.buf[0..self.stdin_buffer.ptr]});
    }

    fn hide_cursor(self: *GameDisplay) !void {
        try self.stdout.writer().print("\x1B[?25l\n", .{});
    }
    fn show_cursor(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[?25h\n", .{});
    }
    fn clear_display(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[2J\n", .{});
    }

    fn disable_echo(self: *GameDisplay) !void {
        _ = try self.stdout.writer().print("\x1B[12h\n", .{});
    }
};

fn read_stdin_thread(buffer: *InputBuffer) !void {
    const old_mode = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
    defer std.posix.tcsetattr(std.posix.STDIN_FILENO, .NOW, old_mode) catch {};

    var raw_mode = old_mode;
    raw_mode.lflag.ECHO = false;
    raw_mode.lflag.ICANON = false;
    try std.posix.tcsetattr(std.posix.STDIN_FILENO, .NOW, raw_mode);
    var buf: [1]u8 = undefined;

    while (true) {
        _ = try std.posix.read(std.posix.STDIN_FILENO, &buf);
        if (buf[0] == 'q') {
            _ = try std.posix.write(std.posix.STDOUT_FILENO, "hejsa");
            return;
        }

        buffer.mutex.lock();
        buffer.buf[buffer.ptr] = buf[0];
        buffer.ptr += 1;
        buffer.mutex.unlock();
    }
}
