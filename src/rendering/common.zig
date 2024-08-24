const helpers = @import("helpers");

pub const RenderBuffer = struct {
    chars: []u8,
    rotation: []helpers.Direction,
};
