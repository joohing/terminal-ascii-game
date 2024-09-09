const Entity = @import("entity.zig").Entity;
const PlayerEntity = @import("player_entity.zig").PlayerEntity;
const PlayerProjectileEntity = @import("player_projectile.zig").PlayerProjectileEntity;
const EnemyEntity = @import("enemy_entity.zig").EnemyEntity;
const GameState = @import("helpers.zig").GameState;
const rendering = @import("rendering");
const EntityTypeEnum = enum {
    player,
    enemy,
    player_projectile,
};
const helpers = @import("helpers");

pub const EntityType = union(EntityTypeEnum) {
    player: PlayerEntity,
    enemy: EnemyEntity,
    player_projectile: PlayerProjectileEntity,

    pub fn get_inner(entity: *EntityType) *Entity {
        return switch (entity.*) {
            .enemy => &entity.enemy.entity,
            .player => &entity.player.entity,
            .player_projectile => &entity.player_projectile.entity,
        };
    }
};

const EntityManagerError = error {
    NoMoreEntitySlots,
    NoEntityFound,
};

const EntityTypeIterEnum = enum {
    slice,
    iter,
};

const EntityTypeIterUnion = union(EntityTypeIterEnum) {
    slice: []?EntityType,
    iter: *EntityTypeIter,
};

pub const EntityTypeIter = struct {
    // Iterates over either another EntityTypeIter or a slice of EntityType.
    index: usize = 0,
    entities: EntityTypeIterUnion,
    filter_fn: *const fn (entity: *EntityType) bool,

    pub fn from_slice(entities: []?EntityType, filter_fn: *const fn (entity: *EntityType) bool) EntityTypeIter {
        return EntityTypeIter{
            .entities = EntityTypeIterUnion{ .slice = entities },
            .index = 0,
            .filter_fn = filter_fn,
        };
    }
    pub fn from_iter(iter: *EntityTypeIter, filter_fn: *const fn (entity: *EntityType) bool) EntityTypeIter {
        return EntityTypeIter{
            .entities = EntityTypeIterUnion{ .iter = iter },
            .index = 0,
            .filter_fn = filter_fn,
        };
    }

    pub fn next(self: *EntityTypeIter) ?*EntityType {
        switch (self.entities) {
            .slice => |entity_slice| {
                for (entity_slice[self.index..]) |*maybe_entity| {
                    self.index += 1;

                    const entity: *EntityType = if (maybe_entity.* != null) @ptrCast(maybe_entity) else continue;

                    if (self.filter_fn(entity)) {
                        return entity;
                    }
                }
            },
            .iter => |iter| {
                while (iter.next()) |entity| {
                    if (self.filter_fn(entity)) {
                        return entity;
                    }
                }
            },
        }

        return null;
    }
};

pub const EntityManager = struct {
    entity_buffer: [128]?EntityType,
    entity_ptrs: [128]?*Entity,

    pub fn init() EntityManager {
        return EntityManager{
            .entity_buffer = .{null} ** 128,
            .entity_ptrs = .{null} ** 128,
        };
    }

    fn find_first_free_slot(self: *EntityManager) !usize {
        for (0..self.entity_buffer.len) |ind| {
            if (self.entity_buffer[ind] == null) {
                return ind;
            }
        }
        return EntityManagerError.NoMoreEntitySlots;
    }

    pub fn register_entity(self: *EntityManager, entity: EntityType) !void {
        const index = try self.find_first_free_slot();
        self.entity_buffer[index] = entity;
    }
    pub fn remove_entity(self: *EntityManager, id: u32) !void {
        for (&self.entity_buffer, 0..) |*maybe_entity, ind| {
            if (maybe_entity.*) |*entity| {
                const this_id = entity.get_inner().id;
                if (this_id == id) {
                    self.entity_buffer[ind] = null;
                    return;
                }
            }
        }
        return EntityManagerError.NoEntityFound;
    }

    pub fn update(self: *EntityManager, game_state: *GameState) !void {
        for (&self.entity_buffer) |*maybe_entity| {
            if (maybe_entity.*) |*entity| {
                const inner_entity = entity.get_inner();
                inner_entity.update(game_state);
            }
        }
    }
    pub fn get_all_entities(self: *EntityManager, buffer: *[128]*EntityType) []*EntityType {
        var index: u32 = 0;

        for (&self.entity_buffer) |*maybe_entity| {
            if (maybe_entity.*) |*entity| {
                buffer[index] = entity;
                index += 1;
            }
        }
        return buffer[0..index];
    }
    pub fn get_all_entities_iter(self: *EntityManager) EntityTypeIter {
        const compare = struct {
            pub fn compare(_: *EntityType) bool {
                return true;
            }
        }.compare;

        return EntityTypeIter.from_slice(
            &self.entity_buffer,
            compare,
        );
    }
};
