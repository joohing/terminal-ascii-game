const std = @import("std");
const Entity = @import("entity.zig").Entity;
const rendering = @import("rendering");
const helpers = @import("helpers");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});
pub const PlayerEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    entity: Entity,

    pub fn init(start_x: i32, start_y: i32, sprite_collection: *const rendering.sprites.SpriteCollection) PlayerEntity {
        const entity = Entity.init(
            update,
            get_curr_sprite,
            start_x,
            start_y,
            helpers.Direction.Up,
        );

        return PlayerEntity{
            .entity = entity,
            .sprite = &sprite_collection.TEST,
        };
    }
};

pub fn get_curr_sprite(entity: *Entity) *const rendering.sprites.Sprite {
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    return self.sprite;
}

pub fn update(entity: *Entity, keys_pressed: *const [256]bool) void {
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    if (keys_pressed[c.SDL_SCANCODE_S]) {
        self.entity.y += 1;
        self.entity.rotation = helpers.Direction.Down;
    }
    if (keys_pressed[c.SDL_SCANCODE_W]) {
        self.entity.y -= 1;
        self.entity.rotation = helpers.Direction.Up;
    }
    if (keys_pressed[c.SDL_SCANCODE_D]) {
        self.entity.x += 1;
        self.entity.rotation = helpers.Direction.Right;
    }
    if (keys_pressed[c.SDL_SCANCODE_A]) {
        self.entity.x -= 1;
        self.entity.rotation = helpers.Direction.Left;
    }
}
