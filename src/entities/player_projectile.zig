const std = @import("std");
const Entity = @import("entity.zig").Entity;
const rect_from_entity_and_sprite = @import("entity.zig").rect_from_entity_and_sprite;
const GameState = @import("helpers.zig").GameState;
const EntityType = @import("entity_manager.zig").EntityType;
const rendering = @import("rendering");
const helpers = @import("helpers");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});
const detect_collisions = @import("collisions.zig").detect_collisions;

const PROJECTILE_LIFETIME_MS = 1000;
const FRAMES_PER_ANIMATION_STEP = 2;

pub const PlayerProjectileEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    speed: i32,
    entity: Entity,
    end_of_life: i64,

    pub fn init(start_x: i32, start_y: i32, direction: helpers.Direction, sprite_collection: *const rendering.sprites.SpriteCollection) PlayerProjectileEntity {
        const entity = Entity.init(
            update,
            get_curr_sprite,
            FRAMES_PER_ANIMATION_STEP,
            start_x,
            start_y,
            direction,
            null,
        );

        return PlayerProjectileEntity{
            .entity = entity,
            .sprite = &sprite_collection.player_projectile,
            .speed = 1,
            .end_of_life = std.time.milliTimestamp() + PROJECTILE_LIFETIME_MS,
        };
    }
};

pub fn get_curr_sprite(entity: *Entity) *const rendering.sprites.Sprite {
    const self: *PlayerProjectileEntity = @fieldParentPtr("entity", entity);
    return self.sprite;
}

pub fn update(entity: *Entity, game_state: *GameState) void {
    const self: *PlayerProjectileEntity = @fieldParentPtr("entity", entity);
    var remove_this = false;
    switch (self.entity.rotation) {
        helpers.Direction.Up => self.entity.y -= self.speed,
        helpers.Direction.Right => self.entity.x += self.speed,
        helpers.Direction.Down => self.entity.y += self.speed,
        helpers.Direction.Left => self.entity.x -= self.speed,
    }
    self.entity.collider = rect_from_entity_and_sprite(self.sprite, &self.entity);

    var collision_buffer: [128]*EntityType = undefined;
    const collisions = detect_collisions(
        &self.entity,
        blk: {
            var entities = game_state.entity_manager.get_all_entities_iter();
            break :blk &entities;
        },
        &collision_buffer,
    );

    for (collisions) |other_entity| {
        switch (other_entity.*) {
            .enemy => |*enemy| {
                enemy.health -= 5;
                remove_this = true;
            },
            else => {},
        }
    }

    if (self.end_of_life <= std.time.milliTimestamp()) {
        remove_this = true;
    }

    if (remove_this) {
        game_state.entity_manager.remove_entity(self.entity.id) catch unreachable;
    }
}
