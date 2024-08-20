const std = @import("std");
const Entity = @import("entity.zig").Entity;
const rendering = @import("rendering");
const c = @cImport({
    @cInclude("SDL2/sdl.h");
});
pub const PlayerEntity = struct {
    sprite: *const rendering.sprites.Sprite,
    entity: Entity,

    pub fn init(start_x: i32, start_y: i32, sprite_collection: *const rendering.sprite_collection.SpriteCollection) PlayerEntity {
        const entity = Entity.init(
            update,
            get_curr_sprite,
            start_x,
            start_y,
        );

        return PlayerEntity{
            .entity = entity,
            .sprite = &sprite_collection.TEST,
        };
    }
};

pub fn get_curr_sprite(entity: *Entity) *const rendering.sprites.Sprite {
    std.debug.print("Getting sprite\n", .{});
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    const entity_address = @intFromPtr(entity);
    const player_address = @intFromPtr(self);

    std.debug.print("Player address from builtin {}\n", .{player_address});
    std.debug.print("Entity address from builtin {}\n", .{entity_address});

    std.debug.print("Got the sprite {}\n", .{self.*});
    return self.sprite;
}

pub fn update(entity: *Entity, keys_pressed: *const [256]bool) void {
    const self: *PlayerEntity = @fieldParentPtr("entity", entity);
    if (keys_pressed[c.SDL_SCANCODE_S]) {
        self.entity.y += 1;
    }
    if (keys_pressed[c.SDL_SCANCODE_W]) {
        self.entity.y -= 1;
    }
    if (keys_pressed[c.SDL_SCANCODE_D]) {
        self.entity.x += 1;
    }
    if (keys_pressed[c.SDL_SCANCODE_A]) {
        self.entity.x -= 1;
    }
}
