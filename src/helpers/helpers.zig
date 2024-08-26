pub const constants = @import("constants.zig");

const std = @import("std");
pub const DEST_BUFFER_SIZE = 256;

pub fn concat_strs(s1: []const u8, s2: []const u8, dest: *[DEST_BUFFER_SIZE]u8, buffer_start: usize) void {
    std.mem.copyForwards(u8, dest[buffer_start..], s1);
    std.mem.copyForwards(u8, dest[buffer_start + s1.len ..], s2);
}

pub const Direction = enum {
    Up,
    Right,
    Down,
    Left,

    pub fn to_angle(self: *const Direction) f32 {
        return @as(f32, @floatFromInt(self.to_int())) * 90.0;
    }
    pub fn get_direction_diff(self: *const Direction, other: Direction) Direction {
        // Gets the difference between two directions.
        // Examples:
        //    Direction.Up.get_direction_diff(Direction.Right) => Direction.Right
        //    Direction.Down.get_direction_diff(Direction.Left) => Direction.Right
        //    Direction.Right.get_direction_diff(Direction.Up) => Direction.Left

        const diff = @as(i32, self.to_int()) - @as(i32, other.to_int());
        return switch (@mod(diff, 4)) {
            0 => Direction.Up,
            1 => Direction.Right,
            2 => Direction.Down,
            3 => Direction.Left,
            else => unreachable,
        };
    }
    pub fn get_inverse(self: *const Direction) Direction {
        return switch (self.*) {
            Direction.Up => Direction.Up,
            Direction.Right => Direction.Left,
            Direction.Down => Direction.Down,
            Direction.Left => Direction.Right,
        };
    }
    fn to_int(self: *const Direction) u2 {
        return switch (self.*) {
            Direction.Up => 0,
            Direction.Right => 1,
            Direction.Down => 2,
            Direction.Left => 3,
        };
    }
};

const ArrUtilError = error{
    ItemNotFound,
};

const StrToBoolError = error{
    InvalidString,
};

fn join_strs(s1: []const u8, s2: []const u8, buf: []u8) void {
    for (s1, 0..) |char, index| {
        buf[index] = char;
    }
    for (s2, 0..) |char, index| {
        buf[s1.len + index] = char;
    }
}

test {
    std.testing.refAllDecls(@This());
}

pub const Rect = struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub fn rotate_point(px: i32, py: i32, rotation_axis_x: i32, rotation_axis_y: i32, rotation: Direction) struct { x: i32, y: i32 } {
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
    const rotated_point = rotate_point(0, 0, 1, 1, Direction.Right);
    try std.testing.expect(rotated_point.x == 2 and rotated_point.y == 0);
}

test "can_rotate_point_right_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, Direction.Right);
    try std.testing.expect(rotated_point.x == 1 and rotated_point.y == 0);
}
test "can_rotate_point_down_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, Direction.Down);
    try std.testing.expect(rotated_point.x == 3 and rotated_point.y == 0);
}
test "can_rotate_point_left_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, Direction.Left);
    try std.testing.expect(rotated_point.x == 3 and rotated_point.y == 2);
}
test "can_rotate_point_up_v2" {
    // 0 1 2 3 4
    // 1   O
    // 2 X
    // 3
    const rotated_point = rotate_point(1, 2, 2, 1, Direction.Up);
    try std.testing.expect(rotated_point.x == 1 and rotated_point.y == 2);
}
