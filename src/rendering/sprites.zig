const std = @import("std");

pub const SpriteCollection = struct {
    MONSTER_SPRITE: Sprite,
};

pub const Sprite = struct {
    data: []const u8,
    stride_length: u8,
};

pub fn init_sprite_collection(allocator: std.mem.Allocator) !SpriteCollection {
    var data = try allocator.alloc(u8, 12);
    std.mem.copyForwards(u8, data, " - - > < - -");
    const monster_sprite = Sprite{
        .data = &data,
        .stride_length = 6,
    };
    return SpriteCollection{ .MONSTER_SPRITE = monster_sprite };
}
