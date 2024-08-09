const sprites = @import("sprites.zig");
const std = @import("std");

pub const SpriteCollection = struct {
    TEST: sprites.Sprite,
    jonathan: sprites.Sprite,
    MONSTER_1: sprites.Sprite,
    er: sprites.Sprite,
    dum: sprites.Sprite,
    
};


pub fn load_sprite_collection(allocator: *std.mem.Allocator) !SpriteCollection {
    
    const TEST_file = try std.fs.cwd().openFile("assets/sprites/TEST.sprite", .{});
    const TEST_file_size: u64 = (try TEST_file.stat()).size;
    const TEST_content = try allocator.alloc(u8, @intCast(TEST_file_size));
    _ = try TEST_file.read(TEST_content);
    const TEST_stride = find_first_newline(TEST_content);
    
    
    const jonathan_file = try std.fs.cwd().openFile("assets/sprites/jonathan.sprite", .{});
    const jonathan_file_size: u64 = (try jonathan_file.stat()).size;
    const jonathan_content = try allocator.alloc(u8, @intCast(jonathan_file_size));
    _ = try jonathan_file.read(jonathan_content);
    const jonathan_stride = find_first_newline(jonathan_content);
    
    
    const MONSTER_1_file = try std.fs.cwd().openFile("assets/sprites/MONSTER_1.sprite", .{});
    const MONSTER_1_file_size: u64 = (try MONSTER_1_file.stat()).size;
    const MONSTER_1_content = try allocator.alloc(u8, @intCast(MONSTER_1_file_size));
    _ = try MONSTER_1_file.read(MONSTER_1_content);
    const MONSTER_1_stride = find_first_newline(MONSTER_1_content);
    
    
    const er_file = try std.fs.cwd().openFile("assets/sprites/er.sprite", .{});
    const er_file_size: u64 = (try er_file.stat()).size;
    const er_content = try allocator.alloc(u8, @intCast(er_file_size));
    _ = try er_file.read(er_content);
    const er_stride = find_first_newline(er_content);
    
    
    const dum_file = try std.fs.cwd().openFile("assets/sprites/dum.sprite", .{});
    const dum_file_size: u64 = (try dum_file.stat()).size;
    const dum_content = try allocator.alloc(u8, @intCast(dum_file_size));
    _ = try dum_file.read(dum_content);
    const dum_stride = find_first_newline(dum_content);
    


    return SpriteCollection {
        .TEST = sprites.Sprite {
            .data=TEST_content,
            .stride_length=@intCast(TEST_stride),
        },
    
        .jonathan = sprites.Sprite {
            .data=jonathan_content,
            .stride_length=@intCast(jonathan_stride),
        },
    
        .MONSTER_1 = sprites.Sprite {
            .data=MONSTER_1_content,
            .stride_length=@intCast(MONSTER_1_stride),
        },
    
        .er = sprites.Sprite {
            .data=er_content,
            .stride_length=@intCast(er_stride),
        },
    
        .dum = sprites.Sprite {
            .data=dum_content,
            .stride_length=@intCast(dum_stride),
        },
    
    };
    
    
}


fn find_first_newline(buffer: []u8) usize {
    for (buffer, 0..) |char, index| {
        if (char == 10) {
            return index;
        }
    }
    return 0;
}