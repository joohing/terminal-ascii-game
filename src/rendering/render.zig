const std = @import("std");
const sprites = @import("sprites.zig");
const constants = @import("helpers").constants;

fn render(sprite: *sprites.Sprite, x: u8, y: u8, render_buffer: *[constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT]u32) void {
    for (sprite.data, 0..) |pixel, index| {
        if (pixel == constants.Ascii.SPACE) {
            continue;
        }
        const this_x = x + index % sprite.stride_length;
        const this_y = y + index / sprite.stride_length;

        render_buffer[this_x + this_y * constants.WINDOW_WIDTH] = pixel;
    }
}

test "can render single sprite" {
    var buffer: [constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT]u8 = .{0 ** constants.WINDOW_WIDTH * constants.WINDOW_HEIGHT};
    const sprite_data = " - - > < - -";
    const sprite = sprites.Sprite{ .data = &sprite_data, .stride_length = 6 };
    render(*sprite, 0, 0, &buffer);
    try std.testing.expect(false);
}
