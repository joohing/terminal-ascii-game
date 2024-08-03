const std = @import("std");
const sprites = @import("sprites.zig");
const constants = @import("helpers").constants;

pub fn render(sprite: *const sprites.Sprite, x: u8, y: u8, render_buffer: *[constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT]u8) void {
    for (sprite.data, 0..) |pixel, index| {
        if (pixel == @intFromEnum(constants.Ascii.SPACE)) {
            continue;
        }
        const this_x = x + index % sprite.stride_length;

        const this_y = y + index / sprite.stride_length;

        render_buffer[this_x + this_y * constants.WINDOW_WIDTH] = pixel;
    }
}

// fn render_ui(game_state: GameState) !void {
//     switch (GameState.Situation) {
//         Situation.GAMEPLAY => {
//             rendering.
//         };
//     }
// }

const GameState = struct {
    situation: Situation,
};

const Situation = enum(u8) {
    STARTUP = 0,
    STARTMENU = 1,
    GAMEPLAY = 2,
};

test "can render single sprites" {
    std.debug.print("hejrasmus", .{});
    var buffer: [constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT]u8 = .{0} ** @intCast(constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT);
    const data = [_][]const u8{" - - > < - -"};
    const sprite = sprites.Sprite{ .data = data[0], .stride_length = 6 };
    render(&sprite, 0, 0, &buffer);
    try std.testing.expect(true);
}
