const Entity = @import("entity").Entity;
const entity_manager = @import("entity_manager.zig");
const sprites = @import("rendering").sprites;

pub const GameState = struct {
    keys_pressed: *[256]bool,
    entity_manager: *entity_manager.EntityManager,
    sprite_collection: *const sprites.SpriteCollection,
};
