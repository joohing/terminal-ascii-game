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
    for (sprite.curr_frame, 0..) |pixel, index| {
        if (pixel == 32) {
            continue;
        }
        const px_x = @as(i32, @intCast(index % sprite.stride_length));
        const px_y = @as(i32, @intCast(index / sprite.stride_length));
        const rel_coords = helpers.rotate_point(px_x, px_y, sprite.headers.center_of_rotation_x, sprite.headers.center_of_rotation_y, rel_rotation);

        const abs_coords = .{ .x = rel_coords.x + x - sprite.headers.center_of_rotation_x, .y = rel_coords.y + y - sprite.headers.center_of_rotation_y };

        const buffer_index = abs_coords.x + abs_coords.y * @as(i32, @intCast(window_width));
        if (abs_coords.x >= 0 and abs_coords.y >= 0 and abs_coords.x < window_width and abs_coords.y < window_height) {
            render_buffer.chars[@intCast(buffer_index)] = pixel;
            render_buffer.rotation[@intCast(buffer_index)] = rel_rotation;
        }
    }
}

pub fn render_rect(
    rect: helpers.Rect,
    char: u8,
    window_width: u8,
    render_buffer: *common.RenderBuffer,
) void {
    // rect.x and rect.y might be negative, so we do a @max computation aswell
    const rect_x = rect.x;
    const rect_y = rect.y;
    const rect_w = rect.w;
    const rect_h = rect.h;

    var x: i32 = rect_x;
    while (x < rect_x + rect_w + 1) : (x += 1) {
        if (in_range(x, 0, window_width - 1) and in_range(rect_y, 0, @intCast(render_buffer.chars.len / window_width - 1))) {
            const ind_1 = x + rect_y * window_width;
            render_buffer.chars[@intCast(ind_1)] = char;
            render_buffer.rotation[@intCast(ind_1)] = helpers.Direction.Up;
        }
        if (in_range(x, 0, window_width - 1) and in_range(rect_y + rect_h, 0, @intCast(render_buffer.chars.len / window_width - 1))) {
            const ind_2 = x + (rect_y + rect_h) * window_width;

            render_buffer.chars[@intCast(ind_2)] = char;
            render_buffer.rotation[@intCast(ind_2)] = helpers.Direction.Up;
        }
    }
    var y: i32 = rect_y;
    while (y < rect_y + rect_h + 1) : (y += 1) {
        if (in_range(rect_x, 0, window_width - 1) and in_range(y, 0, @intCast(render_buffer.chars.len / window_width - 1))) {
            const ind_1 = rect_x + y * window_width;
            render_buffer.chars[@intCast(ind_1)] = char;
            render_buffer.rotation[@intCast(ind_1)] = helpers.Direction.Up;
        }

        if (in_range(rect_x + rect_w, 0, window_width - 1) and in_range(y, 0, @intCast(render_buffer.chars.len / window_width - 1))) {
            const ind_2 = rect_x + rect_w + y * window_width;
            render_buffer.chars[@intCast(ind_2)] = char;
            render_buffer.rotation[@intCast(ind_2)] = helpers.Direction.Up;
        }
    }
}

fn in_range(val: i32, lower: i32, upper: i32) bool {
    return val >= lower and val <= upper;
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
