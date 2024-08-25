pub const constants = @import("constants.zig");

const std = @import("std");
pub const DEST_BUFFER_SIZE = 256;

pub fn concat_strs(s1: []const u8, s2: []const u8, dest: *[DEST_BUFFER_SIZE]u8, buffer_start: usize) void {
    std.mem.copyForwards(u8, dest[buffer_start..], s1);
    std.mem.copyForwards(u8, dest[buffer_start + s1.len ..], s2);
}

// pub fn concat_3_strs(s1: []const u8, s2: []const u8, s3: []const u8, dest: *[DEST_BUFFER_SIZE]u8) void {
//     std.mem.copyForwards(u8, dest, s1);
//     std.mem.copyForwards(u8, dest[s1.len..], s2);
// }

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

pub fn remove(arr: []*anyopaque, item: *anyopaque) ArrUtilError!void {
    for (arr, 0..) |arr_item, index| {
        if (arr_item == item) {
            arr[index] = arr[arr.len - 1];
            arr[arr.len - 1] = null;
            return;
        }
    }
    return ArrUtilError.ItemNotFound;
}

const StrToBoolError = error{
    InvalidString,
};

pub fn str_to_bool(s: []u8) StrToBoolError!bool {
    if (s == &"true") {
        return true;
    }
    if (s == &"false") {
        return false;
    }
    return StrToBoolError.InvalidString;
}

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
