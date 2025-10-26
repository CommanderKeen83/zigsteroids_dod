const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;
const PhysicsSystem = @import("systems/physics.zig");
const InputSystem = @import("systems/input.zig");
const RenderSystem = @import("systems/render.zig");
const EntityType = @import("components.zig").EntityType;
const LifetimeSystem = @import("systems/lifetime.zig");
pub fn main() !void{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = World.init(allocator);
    try world.addEntity(
        rl.Vector2{.x = World.SCREEN_WIDTH / 2, .y = World.SCREEN_HEIGHT / 2 },
        rl.Vector2{.x = 0, .y = 0 },
        EntityType.Ship,
        0,
        0,
        0,
        null,
        rl.Color.red
    );
    rl.initWindow(World.SCREEN_WIDTH, World.SCREEN_HEIGHT, "Asteroids_dod_allman");
    defer rl.closeWindow();

    defer world.deinit();

    while(!rl.windowShouldClose()){
        rl.beginDrawing();
        defer rl.endDrawing();
        const frametime = rl.getFrameTime();

        rl.clearBackground(rl.Color.sky_blue);
        PhysicsSystem.update(frametime, &world);
        try InputSystem.update(frametime, &world);
        LifetimeSystem.update(frametime, &world);

        RenderSystem.render(&world);

        world.cleanupInactive();

    }
}