const rendering = @import("rendering");
const helpers = @import("helpers");
const GameState = @import("helpers.zig").GameState;

var entity_id_ctr: u32 = 0;
pub const Entity = struct {
    id: u32,
    x: i32,
    y: i32,
    rotation: helpers.Direction,
    _update: *const fn (entity: *Entity, game_state: *GameState) void,
    _get_curr_sprite: *const fn (entity: *Entity) *const rendering.sprites.Sprite,

    pub fn init(
        update_fn: fn (self: *Entity, game_state: *GameState) void,
        get_curr_sprite_fn: fn (self: *Entity) *const rendering.sprites.Sprite,
        x: i32,
        y: i32,
        rotation: helpers.Direction,
    ) Entity {
        const id = entity_id_ctr;
        entity_id_ctr += 1;
        return Entity{
            .id = id,
            ._update = update_fn,
            .x = x,
            .y = y,
            .rotation = rotation,
            ._get_curr_sprite = get_curr_sprite_fn,
        };
    }
    pub fn update(self: *Entity, game_state: *GameState) void {
        self._update(self, game_state);
    }

    pub fn get_curr_sprite(self: *Entity) *const rendering.sprites.Sprite {
        return self._get_curr_sprite(self);
    }
};
