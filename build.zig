const std = @import("std");


pub fn build(b: *std.Build) void {

    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });
    const raylib_artifact = raylib_dep.artifact("raylib");
    const raylib_module = raylib_dep.module("raylib");

    const mod = b.addModule("asteroids_dod_allman", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
    });


    const exe = b.addExecutable(.{
        .name = "asteroids_dod_allman",
        .root_module = b.createModule(.{

            .root_source_file = b.path("src/main.zig"),

            .target = target,
            .optimize = optimize,
            // List of modules available for import in source files part of the
            // root module.
            .imports = &.{
                .{ .name = "asteroids_dod_allman", .module = mod },
                .{ .name = "raylib", .module = raylib_module },
            },
        }),
    });
    exe.linkLibrary(raylib_artifact);


    b.installArtifact(exe);
   const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

}
