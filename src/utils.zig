
const std = @import("std");
pub const Random = struct{
    rng: std.Random.DefaultPrng,
    pub fn init(seed: u64) Random{
        return Random{
            .rng = std.Random.DefaultPrng.init(seed),
        };
    }
    pub fn float(self: *Random, min: f32, max: f32) float {
        const rand_val = self.rng.random().float(f32);
        return min + ((max - min) * rand_val);
    }

};