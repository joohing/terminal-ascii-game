const std = @import("std");
const start_screen = @import("ui/start_screen.zig");
const config = @import("config.zig");
const rendering = @import("renderer/rendering.zig");

pub fn main() !void {
    const renderer = rendering.UIRenderer{
        .active = true,
        .ui_type = rendering.UIType.startup_screen,
    };

    try render_loop(renderer);
}

fn render_loop(renderer: rendering.UIRenderer) !void {
    while (true) {
        try renderer.render();

        std.time.sleep(config.NS_PER_CYCLE);
    }
}
