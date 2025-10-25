const World = @import("../world.zig").World;
const rl = @import("raylib");
const math = @import("std").math;
const Constants = @import("../components.zig").Constants;

fn get_transform(entity_world_position: rl.Vector2, entity_local_position: rl.Vector2, angle: f32, scale: f32) rl.Vector2{
    const rad = angle * math.pi / 180.0;
    // scale is 80.0;
    const rotation = rl.math.vector2Scale(rl.math.vector2Rotate(entity_local_position, rad), scale);
    return rl.Vector2{
        .x = (entity_world_position.x + rotation.x),
        .y = (entity_world_position.y + rotation.y),
    };
}

pub fn render(world: *World) void{
    for(world.entityTypes.items, 0..)|entitytype, index|{
        const world_position = world.positions.items[index];
        const rotation = world.rotations.items[index];
        const color = world.colors.items[index];

        switch(entitytype) {
            .Ship => {
            for(0..Constants.Ship.hull.len) | hull_index |{
                const local_position = Constants.Ship.hull[hull_index];
                const next_localPosition = Constants.Ship.hull[(hull_index + 1) % Constants.Ship.hull.len];
                const transformed_point =
                    get_transform(world_position, local_position, rotation, Constants.Ship.scale);
                const next_transformed_point =
                    get_transform(world_position, next_localPosition, rotation, Constants.Ship.scale);

                rl.drawLineEx(transformed_point,
                    next_transformed_point,
                    Constants.Ship.hull_thickness,
                    color);
                }
            },
            .Asteroid_large => {},
            .Asteroid_medium=> {},
            .Asteroid_small=> {},
            .Bullet_enemy=> {},
            .Bullet_player=> {
                const ix : i32 = @intFromFloat(world.positions.items[index].x);
                const iy :i32 = @intFromFloat(world.positions.items[index].y);
                rl.drawCircle(ix, iy, 2, rl.Color.white);
            },
            .Enemy_large=> {},
            .Enemy_small=> {},
            .Particle=> {},
        }
    }
}