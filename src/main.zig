pub const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");
const rendering = @import("rendering");
const helpers = @import("helpers");
const Entity = @import("entities").entity.Entity;
const PlayerEntity = @import("entities").player_entity.PlayerEntity;
const EnemyEntity = @import("entities").enemy_entity.EnemyEntity;

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    // var render_buffer: rendering.common.RenderBuffer[helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]u8 = undefined;
    var char_buffer: [helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]u8 = undefined;
    var rotation_buffer: [helpers.constants.WINDOW_WIDTH * helpers.constants.WINDOW_HEIGHT]helpers.Direction = undefined;
    var render_buffer = rendering.common.RenderBuffer{
        .chars = &char_buffer,
        .rotation = &rotation_buffer,
    };
    const collection = try rendering.sprites.load_sprite_collection(&allocator);
    var iter: u32 = 0;
    var game_display = try rendering.display.GameDisplay.init();

    const time_per_frame: i128 = @intFromFloat(1.0 / @as(f32, @floatFromInt(helpers.constants.FPS)) * @as(f32, 1000000000));

    var prev_frame = std.time.nanoTimestamp();
    var next_frame = prev_frame + time_per_frame;
    var player_entity = PlayerEntity.init(10, 20, &collection);
    var enemy_entity = EnemyEntity.init(20, 20, &collection);
    var entities: [256]*Entity = .{undefined} ** 256;
    entities[0] = &player_entity.entity;
    entities[1] = &enemy_entity.entity;

    const last_entity_ptr: u32 = 2;

    gameloop: while (true) {
        iter += 1;

        const sleep_time = next_frame - prev_frame;

        std.time.sleep(@intCast(sleep_time));
        const nanos_elapsed = std.time.nanoTimestamp() - prev_frame;
        const millis_elapsed: i32 = @intFromFloat(@as(f32, @floatFromInt(nanos_elapsed)) / @as(f32, @floatFromInt(1000000)));
        _ = millis_elapsed;
        //std.debug.print("Frametime: {}ms\n", .{millis_elapsed});
        prev_frame = std.time.nanoTimestamp();
        next_frame = prev_frame + time_per_frame;

        rendering.render.render_0(render_buffer.chars);
        const keys_pressed = game_display.read_events() catch {
            std.debug.print("Quit button was pressed. Quitting now", .{});
            rendering.display.c.SDL_Quit();
            break :gameloop;
        };

        for (entities[0..last_entity_ptr]) |entity| {
            entity.update(keys_pressed);
        }

        for (entities[0..last_entity_ptr]) |entity| {
            rendering.render.render(
                entity.get_curr_sprite(),
                entity.x,
                entity.y,
                entity.rotation,
                helpers.constants.WINDOW_WIDTH,
                &render_buffer,
            );
        }
        try game_display.display_buffer(&render_buffer);
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
