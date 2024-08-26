const std = @import("std");
const Entity = @import("entity.zig").Entity;
const rect_from_entity_and_sprite = @import("entity.zig").rect_from_entity_and_sprite;
const GameState = @import("helpers.zig").GameState;
const PlayerProjectileEntity = @import("player_projectile.zig").PlayerProjectileEntity;
const entity_manager = @import("entity_manager.zig");
const rendering = @import("rendering");
const helpers = @import("helpers");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});

const SHOOT_PROJECTILE_COOLDOWN_MS = 500;

pub const PlayerEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    entity: Entity,
    last_projectile_shot_ms: ?i64,

    pub fn init(start_x: i32, start_y: i32, sprite_collection: *const rendering.sprites.SpriteCollection) PlayerEntity {
        const sprite = &sprite_collection.player;
        const entity = Entity.init(
            update,
            get_curr_sprite,
            start_x,
            start_y,
            helpers.Direction.Up,
            null,
        );

        return PlayerEntity{
            .entity = entity,
            .sprite = sprite,
            .last_projectile_shot_ms = null,
        };
    }

    fn shoot_projectile(self: *PlayerEntity, game_state: *GameState) !void {
        const projectile_entity: entity_manager.EntityType = .{ .player_projectile = PlayerProjectileEntity.init(
            self.entity.x,
            self.entity.y,
            self.entity.rotation,
            game_state.sprite_collection,
        ) };
        try game_state.entity_manager.register_entity(projectile_entity);
    }
};

pub fn get_curr_sprite(entity: *Entity) *const rendering.sprites.Sprite {
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    // const slice: []const rendering.sprites.Sprite = &.{self.sprite.*};
    // var s: rendering.sprites.Sprite = (std.heap.page_allocator.dupe(rendering.sprites.Sprite, slice) catch @panic("Could not allocate for sprite"))[0];
    // const coll = self.entity.collider.?;
    // var new_data = (std.heap.page_allocator.dupe(u8, s.data) catch @panic("Could not allocate data"));
    // s.data = new_data;

    // const coll_w: usize = @intCast(coll.w);
    // const coll_h: usize = @intCast(coll.h);

    // for (0..coll_h - 1) |y| {
    //     new_data[y * s.stride_length] = 46;
    //     new_data[y * s.stride_length + s.stride_length - 1] = 46;
    // }
    // for (0..coll_w - 1) |x| {
    //     new_data[x] = 46;
    //     new_data[x + (coll_h - 1) * s.stride_length] = 46;
    // }
    std.debug.print("Current position: ({}, {})\n", .{ self.entity.x, self.entity.y });
    std.debug.print("Current collider: ({})\n", .{self.entity.collider.?});
    return self.sprite;
}

pub fn update(entity: *Entity, game_state: *GameState) void {
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    if (game_state.keys_pressed[c.SDL_SCANCODE_S]) {
        self.entity.y += 1;
        self.entity.rotation = helpers.Direction.Down;
    }
    if (game_state.keys_pressed[c.SDL_SCANCODE_W]) {
        self.entity.y -= 1;
        self.entity.rotation = helpers.Direction.Up;
    }
    if (game_state.keys_pressed[c.SDL_SCANCODE_D]) {
        self.entity.x += 1;
        self.entity.rotation = helpers.Direction.Right;
    }
    if (game_state.keys_pressed[c.SDL_SCANCODE_A]) {
        self.entity.x -= 1;
        self.entity.rotation = helpers.Direction.Left;
    }
    if (game_state.keys_pressed[c.SDL_SCANCODE_SPACE]) proj_shot_blk: {
        if (self.last_projectile_shot_ms) |last_shot_msg| {
            if (last_shot_msg + SHOOT_PROJECTILE_COOLDOWN_MS > std.time.milliTimestamp()) {
                break :proj_shot_blk;
            }
        }
        self.shoot_projectile(game_state) catch {
            std.debug.print("Failed when spawning projectile.", .{});
        };
        self.last_projectile_shot_ms = std.time.milliTimestamp();
    }
    self.entity.collider = rect_from_entity_and_sprite(self.sprite, &self.entity);
}
