const std = @import("std");
const sprites = @import("sprites.zig");
const constants = @import("helpers").constants;
const helpers = @import("helpers");
const common = @import("common.zig");

pub fn render(
    sprite: *const sprites.Sprite,
    x: i32,
    y: i32,
    rotation: helpers.Direction,
    window_width: u8,
    render_buffer: *common.RenderBuffer,
) void {
    const rel_rotation = rotation.get_direction_diff(sprite.headers.rotation);

    // std.debug.print("Starting render {}...\n", .{sprite});
    const window_height = render_buffer.chars.len / window_width;
    for (sprite.data, 0..) |pixel, index| {
        if (pixel == 32) {
            continue;
        }
        const px_x = @as(i32, @intCast(index % sprite.stride_length));
        const px_y = @as(i32, @intCast(index / sprite.stride_length));
        const rel_coords = rotate_point(px_x, px_y, sprite.headers.center_of_rotation_x, sprite.headers.center_of_rotation_y, rel_rotation);

        const abs_coords = .{ .x = rel_coords.x + x - sprite.headers.center_of_rotation_x, .y = rel_coords.y + y - sprite.headers.center_of_rotation_y };
        std.debug.print("coords: {}\n", .{abs_coords});

        const buffer_index = abs_coords.x + abs_coords.y * @as(i32, @intCast(window_width));
        if (abs_coords.x >= 0 and abs_coords.y >= 0 and abs_coords.x < window_width and abs_coords.y < window_height) {
            render_buffer.chars[@intCast(buffer_index)] = pixel;
            render_buffer.rotation[@intCast(buffer_index)] = rel_rotation;
        }
    }
}

pub fn render_0(render_buffer: []u8) void {
    for (render_buffer) |*pixel| {
        pixel.* = 32;
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

fn rotate_point(px: i32, py: i32, rotation_axis_x: i32, rotation_axis_y: i32, rotation: helpers.Direction) struct { x: i32, y: i32 } {
    const x_diff = rotation_axis_x - px;
    const y_diff = rotation_axis_y - py;
    //2,0
    return switch (rotation) {
        .Up => .{ .x = px, .y = py },
        .Right => {
            const res_x = rotation_axis_x + y_diff;
            const res_y = rotation_axis_y - x_diff;
            return .{ .x = res_x, .y = res_y };
        },
        .Down => {
            const res_x = x_diff + rotation_axis_x;
            const res_y = y_diff + rotation_axis_y;
            return .{ .x = res_x, .y = res_y };
        },
        .Left => {
            const res_x = rotation_axis_x - y_diff;
            const res_y = rotation_axis_y + x_diff;
            return .{ .x = res_x, .y = res_y };
        },
    };
}

test "can_rotate_point_right" {
    //
    //  O
    //
    //
    const rotated_point = rotate_point(0, 0, 1, 1, helpers.Direction.Right);
    std.debug.print("Rotated: {}\n", .{rotated_point});
    try std.testing.expect(rotated_point.x == 2 and rotated_point.y == 0);
}

test "can_rotate_point_right_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, helpers.Direction.Right);
    std.debug.print("Rotated: {}\n", .{rotated_point});
    try std.testing.expect(rotated_point.x == 1 and rotated_point.y == 0);
}
test "can_rotate_point_down_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, helpers.Direction.Down);
    std.debug.print("Rotated: {}\n", .{rotated_point});
    try std.testing.expect(rotated_point.x == 3 and rotated_point.y == 0);
}
test "can_rotate_point_left_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, helpers.Direction.Left);
    std.debug.print("Rotated: {}\n", .{rotated_point});
    try std.testing.expect(rotated_point.x == 3 and rotated_point.y == 2);
}
test "can_rotate_point_up_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, helpers.Direction.Up);
    std.debug.print("Rotated: {}\n", .{rotated_point});
    try std.testing.expect(rotated_point.x == 1 and rotated_point.y == 2);
}
