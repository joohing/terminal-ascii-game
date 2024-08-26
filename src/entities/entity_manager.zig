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
};

const EntityManagerError = error{
    NoMoreEntitySlots,
    NoEntityFound,
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
                const this_id = get_entity(entity).id;
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
                const inner_entity = get_entity(entity);
                inner_entity.update(game_state);
            }
        }
    }
    pub fn get_all_entities(self: *EntityManager, buffer: *[128]*Entity) []*Entity {
        var index: u32 = 0;

        for (&self.entity_buffer) |*maybe_entity| {
            if (maybe_entity.*) |*entity| {
                buffer[index] = get_entity(entity);
                index += 1;
            }
        }
        return buffer[0..index];
    }
};

fn get_entity(entity: *EntityType) *Entity {
    return switch (entity.*) {
        .enemy => &entity.enemy.entity,
        .player => &entity.player.entity,
        .player_projectile => &entity.player_projectile.entity,
    };
}
