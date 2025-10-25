const World = @import("../world.zig").World;
const rl = @import("raylib");
const std = @import("std");
const Constants = @import("../components.zig").Constants;
pub fn update(dt: f32, world: *World) !void{
    readInput(world);
    try applyInput(world, dt);
}
pub fn readInput(world: *World) void{
    world.input.thrust = rl.isKeyDown(rl.KeyboardKey.w) or rl.isKeyDown(rl.KeyboardKey.up) ;
    world.input.rotate_left = rl.isKeyDown(rl.KeyboardKey.a) or rl.isKeyDown(rl.KeyboardKey.left);
    world.input.rotate_right = rl.isKeyDown(rl.KeyboardKey.d) or rl.isKeyDown(rl.KeyboardKey.right);
    world.input.shoot = rl.isKeyPressed(rl.KeyboardKey.space);
}

pub fn applyInput(world: *World, dt: f32) !void{
    if(world.findShip()) |player|{
        if(world.input.thrust){
            const radian = (world.rotations.items[player] - 90) * std.math.pi / 180.0;
            const direction_x = @cos(radian);
            const direction_y = @sin(radian);
            world.velocities.items[player].x += direction_x * Constants.Ship.acceleration * dt;
            world.velocities.items[player].y += direction_y * Constants.Ship.acceleration * dt;
        }

        // rotation
        if(world.input.rotate_left){
            world.rotation_speeds.items[player] = -Constants.Ship.rotation_speed;
        }
        else if(world.input.rotate_right){
            world.rotation_speeds.items[player] = Constants.Ship.rotation_speed;
        }
        else{
            world.rotation_speeds.items[player] = 0.0;
        }

        if(world.input.shoot){
            const radian = (world.rotations.items[player] - 90) * std.math.pi / 180.0;
            const direction_x = @cos(radian);
            const direction_y = @sin(radian);
            try spawnBullet(
                world.positions.items[player],
                rl.Vector2{
                    .x = direction_x * Constants.Bullet.speed,
                    .y = direction_y * Constants.Bullet.speed},
                world);
        }
    }
}

fn spawnBullet(position: rl.Vector2, velocity: rl.Vector2, world: *World) !void{
    try world.addEntity(
        position,
        velocity,
        .Bullet_player,
        0,
        0,
        0,
        Constants.Bullet.lifetime,
        rl.Color.white);
}