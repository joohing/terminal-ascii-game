const std = @import("std");
const sprites = @import("sprites.zig");
const constants = @import("helpers").constants;
const helpers = @import("helpers");
pub fn render(sprite: *const sprites.Sprite, x: i32, y: i32, rotation: helpers.Direction, window_width: u8, render_buffer: []u8) void {
    std.debug.print("Starting render {}...\n", .{sprite});
    const window_height = render_buffer.len / window_width;
    for (sprite.data, 0..) |pixel, index| {
        if (pixel == 32) {
            continue;
        }
        const height = @as(i32, @intCast(sprite.data.len / sprite.stride_length));
        const px_x = @as(i32, @intCast(index % sprite.stride_length));
        const px_y = @as(i32, @intCast(index / sprite.stride_length));
        const rel_coords: struct { x: i32, y: i32 } = switch (rotation) {
            .Up => .{ .x = px_x, .y = px_y },
            .Down => blk: {
                const rot_x = sprite.stride_length - px_x;
                const rot_y = height - px_y;
                break :blk .{ .x = rot_x, .y = rot_y };
            },
            .Left => blk: {
                const rot_x = px_y;
                const rot_y = sprite.stride_length - px_x;
                break :blk .{ .x = rot_x, .y = rot_y };
            },
            .Right => blk: {
                const rot_x = height - px_y;
                const rot_y = px_x;
                break :blk .{ .x = rot_x, .y = rot_y };
            },
        };
        const abs_coords = .{ .x = rel_coords.x + x, .y = rel_coords.y + y };
        std.debug.print("coords: {}\n", .{abs_coords});

        const buffer_index = abs_coords.x + abs_coords.y * @as(i32, @intCast(window_width));
        if (abs_coords.x >= 0 and abs_coords.y >= 0 and abs_coords.x < window_width and abs_coords.y < window_height) {
            render_buffer[@intCast(buffer_index)] = pixel;
        }
    }
}
// pub fn render_entity(entity: *Entity, render_buffer: []u8) void {
//     render(entity.get_curr_sprite(), entity.x, entity.y, constants.WINDOW_WIDTH, constants.WINDOW_HEIGHT, render_buffer);
// }
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
