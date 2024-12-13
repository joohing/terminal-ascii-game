const std = @import("std");
const rendering = @import("rendering");
const helpers = @import("helpers");
const GameState = @import("helpers.zig").GameState;
const Tag = @import("tags.zig").Tag;

var entity_id_ctr: u32 = 0;

const TAG_ARR_SIZE: u32 = 4;
pub const Entity = struct {
    id: u32,
    x: i32,
    y: i32,
    rotation: helpers.Direction,
    collider: ?helpers.Rect,
    _update: *const fn (entity: *Entity, game_state: *GameState) void,
    _get_curr_sprite: *const fn (entity: *Entity) *const rendering.sprites.Sprite,

    pub fn init(
        update_fn: fn (self: *Entity, game_state: *GameState) void,
        get_curr_sprite_fn: fn (self: *Entity) *const rendering.sprites.Sprite,
        x: i32,
        y: i32,
        rotation: helpers.Direction,
        rect: ?helpers.Rect,
    ) Entity {
        const id = entity_id_ctr;
        entity_id_ctr += 1;

        return Entity{
            .id = id,
            ._update = update_fn,
            .x = x,
            .y = y,
            .rotation = rotation,
            .collider = rect,
            ._get_curr_sprite = get_curr_sprite_fn,
        };
    }
    pub fn has_tag(self: *Entity, tag: Tag) bool {
        for (self.tags) |t| {
            if (t == tag) {
                return true;
            }
        }
        return false;
    }
    pub fn update(self: *Entity, game_state: *GameState) void {
        self._update(self, game_state);
    }

    pub fn get_curr_sprite(self: *Entity) *const rendering.sprites.Sprite {
        return self._get_curr_sprite(self);
    }
};
pub fn rect_from_sprite(sprite: *const rendering.sprites.Sprite) helpers.Rect {
    // The idea with this function is to take a sprite, and rotate it according to its rotation headers, like so:
    // r,1,1
    //      0 1 2
    //
    // 0    a s d
    // 1    a s d
    // 2    a s d
    // 3    a s d
    //
    // |
    // v
    //
    //      0 1 2 3
    //
    // -2
    // -1   d s a
    //  0   d s a
    //  1   d s a
    //  2   d s a
    //
    // It then needs to calculate the coordinates of the resulting sprite, in this example {.x=0, .y=-1, .w=3, .h=4}.
    // We do this by taking the corner points of the original sprite, (0, 0) and (2, 3) and using the helpers.rotate_point function to rotate them according to the headers in the sprite. This gives the following points:
    // rotate_point(0,0,1,1,helpers.Direction.Left) => (0,2)
    // rotate_point(2,3,1,1,helpers.Direction.Left) => (3,0)
    // now we can compute x as the minimum resulting x-value, and y in the same way.
    // width and height are then the difference between highest and lowest in their respective dimensions

    const width = sprite.stride_length;
    const height = @as(u8, @intCast(sprite.data.len / sprite.stride_length));
    const p1_x: i32 = 0;
    const p1_y: i32 = 0;
    const p2_x: i32 = width - 1;
    const p2_y: i32 = height - 1;
    const p1_rotated = helpers.rotate_point(p1_x, p1_y, sprite.headers.center_of_rotation_x, sprite.headers.center_of_rotation_y, sprite.headers.rotation.get_inverse());
    const p2_rotated = helpers.rotate_point(p2_x, p2_y, sprite.headers.center_of_rotation_x, sprite.headers.center_of_rotation_y, sprite.headers.rotation.get_inverse());
    const x = @min(p1_rotated.x, p2_rotated.x);
    const y = @min(p1_rotated.y, p2_rotated.y);
    const w = @max(p1_rotated.x, p2_rotated.x) - x + 1;
    const h = @max(p1_rotated.y, p2_rotated.y) - y + 1;

    return helpers.Rect{
        .x = x - sprite.headers.center_of_rotation_x,
        .y = y - sprite.headers.center_of_rotation_y,
        .w = w,
        .h = h,
    };
}
pub fn rect_from_entity_and_sprite(sprite: *const rendering.sprites.Sprite, entity: *const Entity) helpers.Rect {
    const r = rect_from_sprite(sprite);
    // do rotation
    const p1_rotated = helpers.rotate_point(r.x, r.y, 0, 0, entity.rotation);
    const p2_rotated = helpers.rotate_point(r.x + r.w - 1, r.y + r.h - 1, 0, 0, entity.rotation);

    var x = @min(p1_rotated.x, p2_rotated.x);
    var y = @min(p1_rotated.y, p2_rotated.y);
    const w = @max(p1_rotated.x, p2_rotated.x) - x;
    const h = @max(p1_rotated.y, p2_rotated.y) - y;

    // translate x and y based on entity position:
    x += entity.x;
    y += entity.y;

    return helpers.Rect{
        .x = x,
        .y = y,
        .w = w,
        .h = h,
    };
}

test "rect_from_sprite 3x3, u,0,0" {
    const data = "asdasdasd"[0..];
    const sprite = rendering.sprites.Sprite{
        .data = data,
        .stride_length = 3,
        .headers = rendering.sprites.Headers{
            .rotation = helpers.Direction.Up,
            .center_of_rotation_x = 0,
            .center_of_rotation_y = 0,
        },
    };

    const rect = rect_from_sprite(&sprite);
    try std.testing.expect(rect.x == 0 and rect.y == 0 and rect.w == 3 and rect.h == 3);
}
test "rect_from_sprite 3x3, r,1,1" {
    const data = "asdasdasd"[0..];
    const sprite = rendering.sprites.Sprite{
        .data = data,
        .stride_length = 3,
        .headers = rendering.sprites.Headers{
            .rotation = helpers.Direction.Right,
            .center_of_rotation_x = 1,
            .center_of_rotation_y = 1,
        },
    };

    const rect = rect_from_sprite(&sprite);
    try std.testing.expect(rect.x == -1 and rect.y == -1 and rect.w == 3 and rect.h == 3);
}
test "rect_from_sprite 4x3, r,1,1" {
    // r,1,1
    //      0 1 2 3
    //
    // 0    a s d f
    // 1    a s d f
    // 2    a s d f
    // 3    a s d f
    //
    // |
    // v
    //
    //      0 1 2 3
    //
    //-1    f f f f
    // 0    d d d d
    // 1    s s s s
    // 2    a a a a
    //
    const data = "asdfasdfasdf"[0..];
    const sprite = rendering.sprites.Sprite{
        .data = data,
        .stride_length = 4,
        .headers = rendering.sprites.Headers{
            .rotation = helpers.Direction.Right,
            .center_of_rotation_x = 1,
            .center_of_rotation_y = 1,
        },
    };

    const rect = rect_from_sprite(&sprite);
    try std.testing.expect(rect.x == -1 and rect.y == -2 and rect.w == 3 and rect.h == 4);
}
test "rect_from_sprite 3x4, r,1,1" {
    // r,1,1
    //      0 1 2
    //
    // 0    a s d
    // 1    a s d
    // 2    a s d
    // 3    a s d
    //
    // |
    // v
    //
    //      0 1 2 3
    //
    // 0    d d d d
    // 1    s s s s
    // 2    a a a a
    //

    const data = "asdasdasdasd"[0..];
    const sprite = rendering.sprites.Sprite{
        .data = data,
        .stride_length = 3,
        .headers = rendering.sprites.Headers{
            .rotation = helpers.Direction.Right,
            .center_of_rotation_x = 1,
            .center_of_rotation_y = 1,
        },
    };

    const rect = rect_from_sprite(&sprite);
    try std.testing.expect(rect.x == -1 and rect.y == -1 and rect.w == 4 and rect.h == 3);
}

test "rect_from_sprite 3x4, d,1,1" {
    // r,1,1
    //      0 1 2
    //
    // 0    a s d
    // 1    a s d
    // 2    a s d
    // 3    a s d
    //
    // |
    // v
    //
    //      0 1 2 3
    //
    // -2
    // -1   d s a
    //  0   d s a
    //  1   d s a
    //  2   d s a
    //

    const data = "asdasdasdasd"[0..];
    const sprite = rendering.sprites.Sprite{
        .data = data,
        .stride_length = 3,
        .headers = rendering.sprites.Headers{
            .rotation = helpers.Direction.Right,
            .center_of_rotation_x = 1,
            .center_of_rotation_y = 1,
        },
    };

    const rect = rect_from_sprite(&sprite);
    try std.testing.expect(rect.x == -1 and rect.y == -1 and rect.w == 4 and rect.h == 3);
}
