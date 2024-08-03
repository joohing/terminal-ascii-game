pub const constants = @import("constants.zig");

const std = @import("std");

test {
    std.testing.refAllDecls(@This());
}

test {
    std.debug.print("hej", .{});
}
