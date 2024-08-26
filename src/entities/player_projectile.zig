const std = @import("std");
const Entity = @import("entity.zig").Entity;
const GameState = @import("helpers.zig").GameState;
const rendering = @import("rendering");
const helpers = @import("helpers");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});

const PROJECTILE_LIFETIME_MS = 1000;

pub const PlayerProjectileEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    speed: i32,
    entity: Entity,
    end_of_life: i64,

    pub fn init(start_x: i32, start_y: i32, direction: helpers.Direction, sprite_collection: *const rendering.sprites.SpriteCollection) PlayerProjectileEntity {
        const entity = Entity.init(
            update,
            get_curr_sprite,
            start_x,
            start_y,
            direction,
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
    switch (self.entity.rotation) {
        helpers.Direction.Up => self.entity.y -= self.speed,
        helpers.Direction.Right => self.entity.x += self.speed,
        helpers.Direction.Down => self.entity.y += self.speed,
        helpers.Direction.Left => self.entity.x -= self.speed,
    }
    if (self.end_of_life <= std.time.milliTimestamp()) {
        game_state.entity_manager.remove_entity(self.entity.id) catch unreachable;
    }
}
