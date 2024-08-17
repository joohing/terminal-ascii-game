pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

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
    // const old_mode = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
    // defer std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, old_mode) catch {};

    // var raw_mode = old_mode;
    // raw_mode.lflag.ECHO = false;
    // raw_mode.lflag.ICANON = false;
    // try std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, raw_mode);

    // var buf: [1]u8 = undefined;
    // while (true) {
    //     _ = try std.posix.read(std.posix.STDIN_FILENO, &buf);
    //     if (buf[0] == 'q') {
    //         _ = try std.posix.write(std.posix.STDOUT_FILENO, "hejsa");
    //         return;
    //     }
    // }

    var allocator = std.heap.page_allocator;
    var buffer: [helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]u8 = undefined;

    const collection = try rendering.sprite_collection.load_sprite_collection(&allocator);
    const sprite = collection.TEST;
    var iter: u32 = 0;
    var game_display = try rendering.display.GameDisplay.init();

    // var buf: [1]u8 = undefined;
    var sprite_x: i16 = 0;
    var sprite_y: i16 = 0;
    var input_buffer: [32]u32 = std.mem.zeroes([32]u32);
    gameloop: while (true) {
        iter += 1;
        // std.io.getStdIn().(buffer: []u8, offset: u64);
        // _ = try std.posix.read(std.posix.STDIN_FILENO, &buf);
        // if (buf[0] == 'q') {
        //     _ = try std.posix.write(std.posix.STDOUT_FILENO, "hejsa");
        //     return;
        // }
        // while (game_display.stdin_buffer.ptr > 0) {
        //     game_display.stdin_buffer.mutex.lock();
        //     game_display.stdin_buffer.ptr -= 1;
        //     const key = game_display.stdin_buffer.buf[game_display.stdin_buffer.ptr];
        //     if (key == 'w') {
        //         sprite_y -= 1;
        //     }
        //     if (key == 's') {
        //         sprite_y += 1;
        //     }
        //     if (key == 'd') {
        //         sprite_x += 1;
        //     }
        //     if (key == 'a') {
        //         sprite_x -= 1;
        //     }
        //     game_display.stdin_buffer.mutex.unlock();
        // }
        rendering.render.render_random(&buffer);
        rendering.render.render(&sprite, sprite_x, sprite_y, helpers.constants.WINDOW_WIDTH, &buffer);
        try game_display.display_buffer(&buffer);

        const key_pressed_count = rendering.display.read_events(&input_buffer) catch {
            std.debug.print("Quit button was pressed. Quitting now", .{});
            rendering.display.c.SDL_Quit();
            break :gameloop;
        };
        std.debug.print("{}, {}", .{ sprite_x, sprite_y });
        if (key_pressed_count == 1) {
            std.debug.print("Found button press: {any}\n", .{input_buffer[0]});
            std.debug.print("Scancode s: {}\n", .{@as(u32, c.SDL_SCANCODE_S)});
            if (input_buffer[0] == @as(u32, @intCast(c.SDL_SCANCODE_S))) {
                sprite_y += 1;
            }
            if (input_buffer[0] == @as(u8, @intCast(c.SDL_SCANCODE_W))) {
                sprite_y -= 1;
            }
            if (input_buffer[0] == @as(u8, @intCast(c.SDL_SCANCODE_D))) {
                sprite_x += 1;
            }
            if (input_buffer[0] == @as(u8, @intCast(c.SDL_SCANCODE_A))) {
                sprite_x -= 1;
            }
        }
        std.debug.print("[Iter: {}]Keys pressed: {any}\n", .{ iter, input_buffer[0..key_pressed_count] });
        // std.time.sleep(50000000);
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
        // std.time.sleep(500000000);
    }
}
