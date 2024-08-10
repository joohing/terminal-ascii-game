const std = @import("std");
// const s = @import("sprite_files");
const rendering = @import("rendering");
const helpers = @import("helpers");

// pub const rendering = @import("rendering");
// const rendering = @import("rendering");
// const sprites = rendering.sprites;

// const sprites = @import("rendering/sprites.zig");
// const rendering_2 = @import("rendering/rendering.zig");

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    _ = try rendering.sprite_collection.load_sprite_collection(&allocator);
    var buffer: [helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]u8 = undefined;
    // const str = ;

    std.mem.copyForwards(u8, &buffer, "iter: ");
    const collection = try rendering.sprite_collection.load_sprite_collection(&allocator);
    const sprite = collection.TEST;
    var iter: u32 = 0;
    var game_display = rendering.display.GameDisplay{};
    while (true) {
        iter += 1;
        rendering.render.render_random(&buffer);
        rendering.render.render(&sprite, 0, 0, helpers.constants.WINDOW_WIDTH, &buffer);
        try game_display.display_buffer(&buffer);
        std.time.sleep(500000000);
    }
}

test "bla test" {
    // std.debug.print("asd", .{});
    var list = std.ArrayList(i32).init(std.testing.allocator);

    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

pub fn show_random_numbers() !void {
    var buffer: [helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]u8 = undefined;

    var iter: u32 = 0;
    while (true) {
        iter += 1;
        rendering.render.render_random(&buffer);
        try rendering.display.display_buffer(&buffer);
        std.time.sleep(500000000);
    }
}
