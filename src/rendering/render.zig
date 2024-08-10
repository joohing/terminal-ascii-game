const std = @import("std");
const sprites = @import("sprites.zig");
// const constants = @import("helpers").constants;

pub fn render(sprite: *const sprites.Sprite, x: i8, y: i8, window_width: u8, render_buffer: []u8) void {
    const window_height = render_buffer.len / window_width;
    for (sprite.data, 0..) |pixel, index| {
        if (pixel == 32) {
            continue;
        }

        const this_x = @as(i16, @intCast(index % sprite.stride_length)) + x;
        const this_y = @as(i16, @intCast(index / sprite.stride_length)) + y;

        const buffer_index = this_x + this_y * @as(i16, @intCast(window_width));
        if (this_x >= 0 and this_y >= 0 and this_x < window_width and this_y < window_height) {
            render_buffer[@intCast(buffer_index)] = pixel;
        }
    }
}

pub fn render_random(render_buffer: []u8) void {
    const timestamp = std.time.nanoTimestamp();
    var rand = std.rand.Xoroshiro128.init(@intCast(timestamp));
    rand.fill(render_buffer);
    for (render_buffer) |*pixel| {
        pixel.* = pixel.* % 10;
        pixel.* += 48;
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

fn pretty_print(buffer: []u8, comptime window_width: u8) void {
    var curr_start: u8 = 0;

    std.debug.print("\n", .{});
    const h_line = "-" ** 12;

    std.debug.print("{s}\n", .{h_line});
    while (curr_start + window_width <= buffer.len) {
        std.debug.print("|{s}|\n", .{buffer[curr_start .. curr_start + window_width]});
        curr_start += window_width;
    }
    std.debug.print("{s}\n", .{h_line});
}

// test "can render single sprite" {
//     var buffer = [_]u8{@intFromEnum(constants.Ascii.SPACE)} ** @intCast(10 * 10); // 32 is the space character
//     const data = [_][]const u8{"- - >< - -"};
//     const sprite = sprites.Sprite{ .data = data[0], .stride_length = 5 };
//     render(&sprite, 0, 0, 10, &buffer);
//     // pretty_print(&buffer, 10);
//     try std.testing.expectEqualStrings("- - >     < - -     ", buffer[0..20]);
// }

// test "can render two sprites" {
//     var buffer = [_]u8{@intFromEnum(constants.Ascii.SPACE)} ** @intCast(10 * 10); // 32 is the space character
//     const data = [_][]const u8{"- - >< - -"};
//     const sprite = sprites.Sprite{ .data = data[0], .stride_length = 5 };
//     render(&sprite, 0, 0, 10, &buffer);
//     render(&sprite, 0, 3, 10, &buffer);
//     // pretty_print(&buffer, 10);
//     try std.testing.expectEqualStrings("- - >     < - -               - - >     < - -     ", buffer[0..50]);
// }

// test "can render sprite out of bounds pos" {
//     var buffer = [_]u8{@intFromEnum(constants.Ascii.SPACE)} ** @intCast(10 * 10); // 32 is the space character
//     const data = [_][]const u8{"- - >< - -"};
//     const sprite = sprites.Sprite{ .data = data[0], .stride_length = 5 };
//     render(&sprite, 7, 9, 10, &buffer);

//     // pretty_print(&buffer, 10);
//     try std.testing.expectEqualStrings("                 - -", buffer[80..100]);
// }

// test "can render sprite out of bounds neg" {
//     var buffer = [_]u8{@intFromEnum(constants.Ascii.SPACE)} ** @intCast(10 * 10); // 32 is the space character
//     const data = [_][]const u8{"- - >< - -"};
//     const sprite = sprites.Sprite{ .data = data[0], .stride_length = 5 };
//     render(&sprite, -2, -1, 10, &buffer);

//     // pretty_print(&buffer, 10);
//     try std.testing.expectEqualStrings("- -                 ", buffer[0..20]);
// }
