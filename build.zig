const std = @import("std");
const builtin = @import("builtin");
const helpers = @import("src/helpers/helpers.zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    comptime {
        const target_version = "0.13.0";
        if (!std.mem.eql(u8, target_version, builtin.zig_version_string)) {
            const your_version_msg = "Your Zig version is: ";
            const target_version_msg = ". Unsupported Zig version. Please upgrade to ";
            var msg: [helpers.DEST_BUFFER_SIZE]u8 = undefined;

            std.mem.copyForwards(u8, &msg, your_version_msg);
            std.mem.copyForwards(u8, msg[your_version_msg.len..], builtin.zig_version_string);
            std.mem.copyForwards(u8, msg[your_version_msg.len + builtin.zig_version_string.len ..], target_version_msg);
            std.mem.copyForwards(u8, msg[your_version_msg.len + builtin.zig_version_string.len + target_version_msg.len ..], target_version);

            // helpers.concat_strs(your_version_msg, builtin.zig_version_string, &msg, 0);
            // helpers.concat_strs(msg[0 .. your_version_msg.len + builtin.zig_version_string.len], target_version_msg, &msg, your_version_msg.len + builtin.zig_version_string.len);
            // // std.mem.copyForwards(u8, &dest, msg);
            // std.mem.copyForwards(u8, dest[msg.len..], builtin.zig_version_string);
            @compileError(&msg);
        }
    }
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "terminal-ascii-game",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "terminal-ascii-game",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // const sdl_dep = b.dependency("SDL", .{
    //     .optimize = .ReleaseFast,
    //     .target = target,
    // });

    // const sdl_artifact = sdl_dep.artifact("SDL2");
    exe.addIncludePath(.{ .src_path = .{ .owner = b, .sub_path = "/opt/homebrew/include/SDL2" } });
    exe.addLibraryPath(.{ .src_path = .{ .owner = b, .sub_path = "/opt/homebrew/lib/" } });
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("SDL2_ttf");

    const use_cache = b.option(
        bool,
        "use_cache",
        "If true, use no test cache",
    ) orelse false;

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    // const lib_unit_tests = b.addTest(.{
    //     .root_source_file = b.path("src/root.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const module_paths = [_][]const u8{
        "src/main.zig",
        "src/rendering/rendering.zig",
        "src/helpers/helpers.zig",
        "src/entities/entities.zig",
    };
    var modules = [_]*std.Build.Module{undefined} ** module_paths.len;
    var module_names = [_][]const u8{undefined} ** module_paths.len;

    const test_step = b.step("test", "Run unit tests");
    for (module_paths, 0..) |module_path, index| {
        var it = std.mem.split(u8, module_path, "/");
        const file_name = last(&it);
        const module_name = file_name[0 .. file_name.len - 4];
        const module = b.addModule(module_name, .{ .target = target, .root_source_file = .{ .src_path = .{ .owner = b, .sub_path = module_path } } });
        modules[index] = module;

        module_names[index] = module_name;
        // std.debug.print("Discovered module with name {s}\n", .{module_name});
        exe.root_module.addImport(module_name, module);
        module.linkSystemLibrary("SDL2", .{});
    }
    modules[1].addImport(module_names[2], modules[2]);
    modules[3].addImport(module_names[1], modules[1]);

    for (0..module_paths.len) |index| {
        const unit_test_module = b.addTest(.{
            .root_source_file = b.path(module_paths[index]),
            .target = target,
            .optimize = optimize,
        });
        for (0..module_paths.len) |inner_index| {
            unit_test_module.root_module.addImport(module_names[inner_index], modules[inner_index]);
        }
        const run_unit_test_module = b.addRunArtifact(unit_test_module);
        run_unit_test_module.step.name = module_names[index];
        // NOTE: Upgrading to 0.13.0 BROKE this part! Now unit tests always run with cache. Use --summary all to verify what tests have actually run.
        if (!use_cache) {
            run_unit_test_module.has_side_effects = true;
        }

        test_step.dependOn(&run_unit_test_module.step);
    }
}

fn last(iter: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence)) []const u8 {
    var prev_value: []const u8 = undefined;
    while (iter.next()) |value| {
        prev_value = value;
    }

    return prev_value;
}
