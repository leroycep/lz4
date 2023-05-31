const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const optimize = b.standardOptimizeOption(.{});

    const liblz4_static = b.addStaticLibrary(.{
        .name = "lz4",
        .target = target,
        .optimize = optimize,
    });
    liblz4_static.installHeader("lib/lz4.h", "lz4.h");
    liblz4_static.addCSourceFile("lib/lz4.c", &.{});
    liblz4_static.linkLibC();
    b.installArtifact(liblz4_static);

    const liblz4hc_static = b.addStaticLibrary(.{
        .name = "lz4hc",
        .target = target,
        .optimize = optimize,
    });
    liblz4hc_static.installHeader("lib/lz4hc.h", "lz4hc.h");
    liblz4hc_static.addCSourceFile("lib/lz4hc.c", &.{});
    liblz4hc_static.linkLibrary(liblz4_static);
    b.installArtifact(liblz4hc_static);

    const liblz4frame_static = b.addStaticLibrary(.{
        .name = "lz4frame",
        .target = target,
        .optimize = optimize,
    });
    liblz4frame_static.installHeader("lib/lz4frame.h", "lz4frame.h");
    liblz4frame_static.installHeader("lib/lz4frame_static.h", "lz4frame_static.h");
    liblz4frame_static.addCSourceFiles(&.{
        "lib/lz4frame.c",
        "lib/xxhash.c",
    }, &.{});
    liblz4frame_static.linkLibrary(liblz4hc_static);
    b.installArtifact(liblz4frame_static);

    const liblz4file_static = b.addStaticLibrary(.{
        .name = "lz4file",
        .target = target,
        .optimize = optimize,
    });
    liblz4file_static.installHeader("lib/lz4file.h", "lz4file.h");
    liblz4file_static.addCSourceFile("lib/lz4file.c", &.{});
    liblz4file_static.linkLibrary(liblz4frame_static);
    b.installArtifact(liblz4file_static);

    // Examples
    const example_printVersion = b.addExecutable(.{
        .name = "printVersion",
        .target = target,
        .optimize = optimize,
    });
    example_printVersion.addCSourceFile("examples/printVersion.c", &.{});
    example_printVersion.linkLibrary(liblz4_static);
    b.installArtifact(example_printVersion);

    const example_fileCompress = b.addExecutable(.{
        .name = "fileCompress",
        .target = target,
        .optimize = optimize,
    });
    example_fileCompress.addCSourceFile("examples/fileCompress.c", &.{});
    example_fileCompress.linkLibrary(liblz4file_static);
    b.installArtifact(example_fileCompress);
}
