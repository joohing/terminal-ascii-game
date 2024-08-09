const std = @import("std");

pub const Sprite = struct {
    data: []const u8,
    stride_length: u8,
};

// pub fn init_sprite_collection(allocator: std.mem.Allocator) !SpriteCollection {
//     var data = try allocator.alloc(u8, 12);
//     std.mem.copyForwards(u8, data, " - - > < - -");
//     const monster_sprite = Sprite{
//         .data = &data,
//         .stride_length = 6,
//     };
//     return SpriteCollection{ .MONSTER_SPRITE = monster_sprite };
// }

// pub fn load_all_sprites() SpriteCollection {
//     const sprite_filenames: []const []const u8 = sprite_files.sprite_files;

//     for (sprite_filenames) |filename| {
//         std.debug.print("Found sprite filename: {s}", .{filename});
//     }

//     return SpriteCollection{ .MONSTER_SPRITE = Sprite{
//         .data = undefined,
//         .stride_length = undefined,
//     } };

//     // std.meta.declarationInfo(comptime T: type, comptime decl_name: []const u8)
//     // const field_info = std.meta.fieldInfo(SpriteCollection, .MONSTER_SPRITE);
//     // const file_name = field_info.name + ".txt";
//     // std.fs.cwd().openFile("assets/sprites", flags: File.OpenFlags)
//     // std.fs.openFileAbsolute(absolute_path: []const u8, flags: File.OpenFlags)
// }
