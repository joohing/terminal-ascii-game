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

test {
    std.testing.refAllDecls(@This());
}
