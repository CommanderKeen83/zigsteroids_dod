const rl = @import("raylib");
const std = @import("std");
const ArrayList = std.array_list.Aligned;
const EntityType = @import("components.zig").EntityType;
const InputState = @import("components.zig").InputState;
const Utils = @import("utils.zig");

pub const World = struct {
    pub const SCREEN_WIDTH = 800;
    pub const SCREEN_HEIGHT = 600;
    allocator: std.mem.Allocator,
    positions: ArrayList(rl.Vector2, null),
    velocities: ArrayList(rl.Vector2, null), // the "intent" to move
    entityTypes: ArrayList(EntityType, null),
    rotations: ArrayList(f32, null), // angle in degrees
    rotation_speeds: ArrayList(f32, null), // the "intent" to rotate
    collision_radii: ArrayList(f32, null),
    shoot_cooldowns: ArrayList(f32, null),
    lifetimes: ArrayList(?f32, null),
    active: ArrayList(bool, null),
    colors: ArrayList(rl.Color, null),
    input: InputState,

    // utils
    random: Utils.Random,

    pub fn init(allocator: std.mem.Allocator) World {
        return World{
            .allocator = allocator,
            .positions = ArrayList(rl.Vector2, null).empty,
            .velocities = ArrayList(rl.Vector2, null).empty,
            .entityTypes = ArrayList(EntityType, null).empty,
            .rotations = ArrayList(f32, null).empty,
            .rotation_speeds = ArrayList(f32, null).empty,
            .collision_radii = ArrayList(f32, null).empty,
            .shoot_cooldowns = ArrayList(f32, null).empty,
            .lifetimes = ArrayList(?f32, null).empty,
            .active = ArrayList(bool, null).empty,
            .colors = ArrayList(rl.Color, null).empty,
            .input = InputState{},
            .random = Utils.Random.init(1234),
        };
    }
    pub fn deinit(self: *World) void {
        self.positions.deinit(self.allocator);
        self.velocities.deinit(self.allocator);
        self.entityTypes.deinit(self.allocator);
        self.rotations.deinit(self.allocator);
        self.rotation_speeds.deinit(self.allocator);
        self.collision_radii.deinit(self.allocator);
        self.shoot_cooldowns.deinit(self.allocator);
        self.lifetimes.deinit(self.allocator);
        self.active.deinit(self.allocator);
        self.colors.deinit(self.allocator);
    }

    pub fn addEntity(
        self: *World,
        position: rl.Vector2,
        velocity: rl.Vector2,
        entitytype: EntityType,
        rotation: f32,
        rotation_speed: f32,
        shoot_cooldown: f32,
        lifetime: ?f32,
        color: rl.Color,
    ) !void {
        try self.positions.append(self.allocator, position);
        try self.velocities.append(self.allocator, velocity);
        try self.entityTypes.append(self.allocator, entitytype);
        try self.rotations.append(self.allocator, rotation);
        try self.rotation_speeds.append(self.allocator, rotation_speed);
        try self.collision_radii.append(self.allocator, entitytype.getCollisionRadius());
        try self.shoot_cooldowns.append(self.allocator, shoot_cooldown);
        try self.lifetimes.append(self.allocator, lifetime);
        try self.active.append(self.allocator, true);
        try self.colors.append(self.allocator, color);
    }

    pub fn removeEntity(self: *World, index: usize) void {
        // Mark an entity inactive by index. If index is out of range, do nothing.
        if (index >= self.active.items.len) {
            return;
        }
        // Set active flag to false; cleanupInactive will compact arrays later.
        self.active.items[index] = false;
    }

    pub fn cleanupInactive(self: *World) void {
        var index: usize = 0;
        while (index < self.active.items.len) {
            if (self.active.items[index] == false) {
                const last = self.active.items.len - 1;
                if (index != last) {
                    self.swapEntity(index, last);
                }
                _ = self.positions.pop();
                _ = self.velocities.pop();
                _ = self.entityTypes.pop();
                _ = self.rotations.pop();
                _ = self.rotation_speeds.pop();
                _ = self.collision_radii.pop();
                _ = self.shoot_cooldowns.pop();
                _ = self.lifetimes.pop();
                _ = self.active.pop();
                _ = self.colors.pop();
            } else {
                index += 1;
            }
        }
    }
    pub fn swapEntity(self: *World, first: usize, second: usize) void {
        std.mem.swap(rl.Vector2, &self.positions.items[first], &self.positions.items[second]);
        std.mem.swap(rl.Vector2, &self.velocities.items[first], &self.velocities.items[second]);
        std.mem.swap(EntityType, &self.entityTypes.items[first], &self.entityTypes.items[second]);
        std.mem.swap(f32, &self.rotations.items[first], &self.rotations.items[second]);
        std.mem.swap(f32, &self.rotation_speeds.items[first], &self.rotation_speeds.items[second]);
        std.mem.swap(f32, &self.collision_radii.items[first], &self.collision_radii.items[second]);
        std.mem.swap(f32, &self.shoot_cooldowns.items[first], &self.shoot_cooldowns.items[second]);
        std.mem.swap(?f32, &self.lifetimes.items[first], &self.lifetimes.items[second]);
        std.mem.swap(bool, &self.active.items[first], &self.active.items[second]);
        std.mem.swap(rl.Color, &self.colors.items[first], &self.colors.items[second]);
    }

    pub fn entityCount(self: *const World) usize {
        return self.active.items.len;
    }
    pub fn findShip(self: *const World) ?usize {
        for (self.entityTypes.items, 0..) |item, index| {
            if (item == .Ship) {
                return index;
            }
        }
        return null;
    }
};
