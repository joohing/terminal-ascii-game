### Game loop

```
Game loop:
    sleep_for_stable_framerate()
    # updates
    for entity in entities:
        entity.update()

    # renders
    render_ui(game_state)
    for e in entities:
        render(e.sprite_ptr, e.position.x, e.position.y)

def render_ui(game_state):
    Based on current game state, render some UI.
    The UI probably needs to maintain some state (which menu item has been selected?) that
    should not be stored in the general game state.

def render(sprite_ptr, pos_x, pos_y):
    The general render function that can render a sprite
    This should render the sprite at the given position.
```

What is a sprite? A sprite should be the minimum rectangle that includes all pixels to be drawn.
For example consider this sprite:

\
 \
  O

We compute the minimum rectangle including all pixels:
|---|
|\  |
| \ |
|  O|
|---|
This means we need a u8 buffer of length 3x3=9 to store the whole sprite.
Any pixels that are empty are simply transparent, and do not override the pixels that have already been written.

We can represent this using a Sprite struct:

```
const Sprite = struct {
    sprite_buffer: []u8 // this is a slice of dynamic length. Can we somehow store this without the heap?
    width: u8,  // width of the rectangle shown above
}
```

### Storage of sprites

Sprite files need a header which contains `width`, `lines_per_frame`.

The sprite files have different frames of the sprite. When the sprite frames are used in sequence it makes
an animation. E.g.:

```
/--
|  
|  
--\
  |
  |
```

If you then have the sprite in a buffer you could get the second frame in the animation by going
`sprite_buffer[width * lines_per_frame.. width * lines_per_frame + lines_per_frame]`

Do a struct:

```
const Sprites = struct {
    MONSTER_SPRITE: []u8,
    PLAYER_SPRITE: []u8,
    fn init(self) {
        return Sprites(
            MONSTER_SPRITE=load_sprite("monster_sprite.txt"),
            PLAYER_SPRITE=load_sprite("player_sprite.txt")
        );
    }
}
```

### Loading sprites

Sprites can have any amount of chars in each line, as long as it's below `width`. If the line ends
up being less than `width` then the line is padded with whitespace.

The animations of the sprites are loaded by getting the amount of lines per frame as well as `width` from the
header and then using the `width` to access the i'th frame in the animation.

`load_sprite` should do a heap allocation and store the sprite there. We need to do this because we don't know the size of it.

### Entities

An entity has multiple sprites, typically for the different frames in the animation. The struct could look
like this:

```Zig
const Entity = struct {
    sprite = *[]u8,
}
```

So all of the frames are loaded in the same buffer (and in the same variable). Then the entity has the
`frame`-variable, which can be used to index into the `sprites` array. `frame` is then updated each time the
game renders/wants a new frame, for example: `monster.frame = (monster.frame + 1) % (sprites.len() /
lines_per_frame)`. This sets the `frame` field to be plus one each render loop, unless you surpass the count
of frames, in which case it goes to 0 again.

###### Entity rendering

The render loop calls all entites' update functions. Those are instantiated by e.g. `PlayerEntity`, which
passes in a function `_update` that can reference code in the `PlayerEntity`.

Complex logic relating to the sprite to be displayed is handled by a struct containing the entity struct. For
example, you might want the player to have a direction for the walking animation. The `PlayerEntity` struct
then contains an `Entity` object, which gets its `_update` function called. The player entity catches this and
performs logic such as "Aha, I'm walking left now", and then sets the sprite in the `Entity` object to reflect
this.
