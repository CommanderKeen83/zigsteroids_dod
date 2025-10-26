const rl = @import("raylib");
const std = @import("std");
const ArrayList = std.array_list.Managed;
const EntityType = @import("components.zig").EntityType;
const InputState = @import("components.zig").InputState;
const Utils = @import("utils.zig");
pub const World = struct{
    pub const SCREEN_WIDTH = 800;
    pub const SCREEN_HEIGHT = 600;
    positions: ArrayList(rl.Vector2),
    velocities: ArrayList(rl.Vector2),  // the "intent" to move
    entityTypes: ArrayList(EntityType),
    rotations: ArrayList(f32),          // angle in degrees
    rotation_speeds: ArrayList(f32),    // the "intent" to rotate
    collision_radii: ArrayList(f32),
    shoot_cooldowns: ArrayList(f32),
    lifetimes: ArrayList(?f32),
    active: ArrayList(bool),
    colors: ArrayList(rl.Color),
    input: InputState,

    // utils
    random: Utils.Random,


    pub fn init(allocator: std.mem.Allocator) World{
        return World{
            .positions = ArrayList(rl.Vector2).init(allocator),
            .velocities = ArrayList(rl.Vector2).init(allocator),
            .entityTypes = ArrayList(EntityType).init(allocator),
            .rotations = ArrayList(f32).init(allocator),
            .rotation_speeds = ArrayList(f32).init(allocator),
            .collision_radii = ArrayList(f32).init(allocator),
            .shoot_cooldowns = ArrayList(f32).init(allocator),
            .lifetimes = ArrayList(?f32).init(allocator),
            .active = ArrayList(bool).init(allocator),
            .colors = ArrayList(rl.Color).init(allocator),
            .input = InputState{},
            .random = Utils.Random.init(1234),
        };
    }
    pub fn deinit(self: *World) void {
        self.positions.deinit();
        self.velocities.deinit();
        self.entityTypes.deinit();
        self.rotations.deinit();
        self.rotation_speeds.deinit();
        self.collision_radii.deinit();
        self.shoot_cooldowns.deinit();
        self.lifetimes.deinit();
        self.active.deinit();
        self.colors.deinit();
    }

    pub fn addEntity(self: *World,
        position: rl.Vector2,
        velocity: rl.Vector2,
        entitytype: EntityType,
        rotation: f32,
        rotation_speed: f32,
        shoot_cooldown: f32,
        lifetime: ?f32,
        color: rl.Color,
    ) !void {
        try self.positions.append(position);
        try self.velocities.append(velocity);
        try self.entityTypes.append(entitytype);
        try self.rotations.append(rotation);
        try self.rotation_speeds.append(rotation_speed);
        try self.collision_radii.append(entitytype.getCollisionRadius());
        try self.shoot_cooldowns.append(shoot_cooldown);
        try self.lifetimes.append(lifetime);
        try self.active.append(true);
        try self.colors.append(color);
    }

    pub fn removeEntity(self: *World, index: usize) void{
        if(index >= self.active.items.len) { return; }
        self.active.items[index] = false;
    }
    pub fn cleanupInactive(self: *World) void{
        var index : usize = 0;
        while (index < self.active.items.len){
            if (self.active.items[index] == false){
                const last = self.active.items.len - 1;
                if(index != last){
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
            }
            else{
                index += 1;
            }
        }
    }
    pub fn swapEntity(self: *World, first: usize, second: usize) void{
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
    pub fn findShip(self: *const World) ?usize{
        for(self.entityTypes.items, 0..) | item, index | {
            if(item == .Ship){
                return index;
            }
        }
        return null;
    }
};