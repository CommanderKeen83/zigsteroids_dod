const GameWorld = @import("../world.zig").World;


pub fn update(dt: f32, world: *GameWorld) void{
    for(world.lifetimes.items, 0..)|*lifetime, index|{
        if(lifetime.*)|*life| {
            life.* -= dt;
            if(life.* <= 0.0){
                world.removeEntity(index);
            }
        }
    }
}