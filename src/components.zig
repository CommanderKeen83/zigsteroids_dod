const rl = @import("raylib");



pub const EntityType = enum{
    Ship,
    Asteroid_large,
    Asteroid_medium,
    Asteroid_small,
    Bullet_enemy,
    Bullet_player,
    Enemy_large,
    Enemy_small,
    Particle,

    pub fn getCollisionRadius(self: *const EntityType) f32{
        return switch(self.*){
            .Ship => 12.0,
            .Asteroid_large => 40.0,
            .Asteroid_medium => 25.0,
            .Asteroid_small => 15.0,
            .Bullet_enemy => 2.0,
            .Bullet_player => 2.0,
            .Enemy_large => 20.0,
            .Enemy_small => 12.0,
            .Particle => 1.0,
        };
    }

    pub fn getPointValue(self: *const EntityType) i32{
        return switch(self){
            .Asteroid_large => 5,
            .Asteroid_medium => 10,
            .Asteroid_small => 15,
            .Enemy_large => 20,
            .Enemy_small => 25,
            else => 0,
        };
    }
}; // End of EntityType

// direct
pub const InputState = struct{
    thrust: bool = false,
    rotate_left: bool = false,
    rotate_right: bool = false,
    shoot: bool = false,
};

pub const Constants = struct{
  pub const Ship = struct {
      pub const acceleration = 200.0;
      pub const rotation_speed = 160.0;
      pub const max_velocity = 100.0;
      pub const friction = 0.6;
      pub const hull_thickness = 2.0;
      pub const scale = 80.0;
      pub const hull: [5]rl.Vector2 = .{
          rl.Vector2{.x = 0, .y = -0.1}, // nose
          rl.Vector2{.x = 0.1, .y = 0.2}, // right bottom
          rl.Vector2{.x = 0.05, .y = 0.15}, // inner right corner
          rl.Vector2{.x = -0.05, .y = 0.15}, // inner left corner
          rl.Vector2{.x = -0.1, .y = 0.2}, // left bottom
      };
  };
  pub const Enemy = struct{
      pub const spawn_interval = 15.0;
      pub const shoot_cooldown = 2.0;
      pub const accleration = 100.0;
  };
  pub const Bullet = struct{
      pub const speed = 400.0;
      pub const lifetime = 0.5;
  };
  pub const Asteroid = struct{
      pub const rotation_speed = 10.0;

  };
  pub const Particle = struct{
      pub const lifetime = 2.0;
  };

};