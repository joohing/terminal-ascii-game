const std = @import("std");
const start_screen = @import("start_screen.zig");

pub fn main() !void {
    try start_screen.render_startup_screen();
}
