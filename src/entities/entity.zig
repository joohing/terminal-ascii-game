const rendering = @import("rendering");
const helpers = @import("helpers");

pub const Entity = struct {
    x: i32,
    y: i32,
    rotation: helpers.Direction,
    _update: *const fn (entity: *Entity, keys_pressed: *const [256]bool) void,
    _get_curr_sprite: *const fn (entity: *Entity) *const rendering.sprites.Sprite,

    pub fn init(
        update_fn: fn (self: *Entity, keys_pressed: *const [256]bool) void,
        get_curr_sprite_fn: fn (self: *Entity) *const rendering.sprites.Sprite,
        x: i32,
        y: i32,
        rotation: helpers.Direction,
    ) Entity {
        return Entity{
            ._update = update_fn,
            .x = x,
            .y = y,
            .rotation = rotation,
            ._get_curr_sprite = get_curr_sprite_fn,
        };
    }
    pub fn update(self: *Entity, keys_pressed: *const [256]bool) void {
        self._update(self, keys_pressed);
    }

    pub fn get_curr_sprite(self: *Entity) *const rendering.sprites.Sprite {
        return self._get_curr_sprite(self);
    }
};
