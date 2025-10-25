const World = @import("../world.zig").World;
const Constants = @import("../components.zig").Constants;
const rl = @import("raylib");
const std = @import("std");
pub fn update(dt: f32, gameworld: *World) void{
    update_positions(dt, gameworld);
    update_rotations(dt, gameworld);
    applyFriction(dt, gameworld);

}
pub fn update_positions(dt: f32, gameworld: *World) void{
    for(gameworld.positions.items, gameworld.velocities.items) |*position, velocity|{
        position.x += velocity.x * dt;
        position.y += velocity.y * dt;
    }

}
pub fn update_rotations(dt: f32, gameworld: *World) void{
    for(gameworld.rotations.items, gameworld.rotation_speeds.items) |*rotation, rotation_speed|{
        rotation.* += rotation_speed * dt;
    }
}
pub fn applyFriction(dt: f32, gameworld: *World) void{
    if(gameworld.findShip()) |ship_index|{
        const friction = std.math.pow(f32, Constants.Ship.friction, dt);
        gameworld.velocities.items[ship_index] =
        rl.math.vector2Scale(gameworld.velocities.items[ship_index], friction);
    }
}