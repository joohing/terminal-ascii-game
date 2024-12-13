const EntityType = @import("entity_manager.zig").EntityType;
const EntityTypeIter = @import("entity_manager.zig").EntityTypeIter;
const Entity = @import("entity.zig").Entity;

pub fn detect_collisions(entity: *Entity, entities: *EntityTypeIter, collision_buffer: []*EntityType) []*EntityType {
    // const detect_collision = fn (e2: *EntityType) bool {
    //     const inner_e = get_entity(entity);
    //     if (inner_e.collider) |e_coll| {
    //         const x_overlap = entity_coll.x + entity_coll.w >= e_coll.x and e_coll.x <= entity_coll.x + entity_coll.w;
    //         const y_overlap = entity_coll.y + entity_coll.h >= e_coll.y and e_coll.y <= entity_coll.y + entity_coll.h;
    //         if (x_overlap and y_overlap) {
    //             return true;
    //         }
    //     }
    //     return false;
    // }

    // var comparator = (Comparator{
    //     .entity = entity,
    // });
    // _ = comparator.compare(entities.next() orelse unreachable);
    // const compare_fn = comparator.compare;
    // return EntityTypeIter{
    //     .entities = entities,
    //     .index = 0,
    //     .filter_fn = compare_fn,
    // };
    // const entity_coll = get_entity(entity).collider orelse return &.{};
    // var index: usize = 0;
    const entity_coll = entity.collider orelse return &.{};
    var index: usize = 0;

    while (entities.next()) |e| {
        const inner_e = e.get_inner();
        if (inner_e.collider) |e_coll| {
            const x_overlap = entity_coll.x + entity_coll.w >= e_coll.x and entity_coll.x <= e_coll.x + e_coll.w;
            const y_overlap = entity_coll.y + entity_coll.h >= e_coll.y and entity_coll.y <= e_coll.y + e_coll.h;

            if (x_overlap and y_overlap) {
                collision_buffer[index] = e;
                index += 1;
            }
        }
    }
    return collision_buffer[0..index];
}

// pub fn detect_collision_single_pair(e1: *Entity, e2: *EntityType) bool {
//     const inner_e = get_entity(e);
//     if (inner_e.collider) |e_coll| {
//         const x_overlap = entity_coll.x + entity_coll.w >= e_coll.x and e_coll.x <= entity_coll.x + entity_coll.w;
//         const y_overlap = entity_coll.y + entity_coll.h >= e_coll.y and e_coll.y <= entity_coll.y + entity_coll.h;
//         if (x_overlap and y_overlap) {
//             return true;
//         }
//     }
//     return false;
// }

// pub const Comparator = struct {
//     entity: *Entity,

//     pub fn compare(self: *Comparator, other: *EntityType) bool {
//         const entity_coll = self.entity.collider orelse return false;
//         const inner_e = other.get_inner();
//         if (inner_e.collider) |e_coll| {
// const x_overlap = entity_coll.x + entity_coll.w >= e_coll.x and entity_coll.x <= e_coll.x + e_coll.w;
// const y_overlap = entity_coll.y + entity_coll.h >= e_coll.y and entity_coll.y <= e_coll.y + e_coll.h;
//             if (x_overlap and y_overlap) {
//                 return true;
//             }
//         }
//         return false;
//     }
// };
