const std = @import("std");
const Entity = @import("entity.zig").Entity;
const rect_from_entity_and_sprite = @import("entity.zig").rect_from_entity_and_sprite;
const GameState = @import("helpers.zig").GameState;
const rendering = @import("rendering");
const helpers = @import("helpers");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});

fn next_dir(dir: helpers.Direction) helpers.Direction {
    return switch (dir) {
        .Up => .Right,
        .Right => .Down,
        .Down => .Left,
        .Left => .Up,
    };
}

pub const EnemyEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    entity: Entity,
    frames_until_change_dir: u32,
    health: i32,

    pub fn init(start_x: i32, start_y: i32, sprite_collection: *const rendering.sprites.SpriteCollection) EnemyEntity {
        const entity = Entity.init(
            update,
            get_curr_sprite,
            start_x,
            start_y,
            helpers.Direction.Up,
            null,
        );

        return EnemyEntity{
            .entity = entity,
            .sprite = &sprite_collection.MONSTER_1,
            .frames_until_change_dir = 10,
            .health = 10,
        };
    }
};

pub fn get_curr_sprite(entity: *Entity) *const rendering.sprites.Sprite {
    const self: *EnemyEntity = @fieldParentPtr("entity", entity);
    return self.sprite;
}

pub fn update(entity: *Entity, game_state: *GameState) void {
    const self: *EnemyEntity = @fieldParentPtr("entity", entity);
    self.frames_until_change_dir = self.frames_until_change_dir - 1;
    if (self.frames_until_change_dir == 0) {
        self.entity.rotation = next_dir(self.entity.rotation);
        self.frames_until_change_dir = 10;
    }
    switch (self.entity.rotation) {
        .Up => {
            self.entity.y -= 1;
        },
        .Right => {
            self.entity.x += 1;
        },
        .Down => {
            self.entity.y += 1;
        },
        .Left => {
            self.entity.x -= 1;
        },
    }
    self.entity.collider = rect_from_entity_and_sprite(self.sprite, &self.entity);

    if (self.health <= 0) {
        game_state.entity_manager.remove_entity(self.entity.id) catch unreachable;
        return;
    }
}
