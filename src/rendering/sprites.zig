const std = @import("std");

pub const Sprite = struct {
    data: []const u8,
    stride_length: u8,
};
