const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
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
    const module_paths = [_][]const u8{ "src/main.zig", "src/rendering/rendering.zig", "src/helpers/helpers.zig" };
    var modules = [_]*std.Build.Module{undefined} ** module_paths.len;
    var module_names = [_][]const u8{undefined} ** module_paths.len;

    const test_step = b.step("test", "Run unit tests");
    for (module_paths, 0..) |module_path, index| {
        var it = std.mem.split(u8, module_path, "/");
        const file_name = last(&it);
        const module_name = file_name[0 .. file_name.len - 4];
        const module = b.addModule(module_name, .{ .root_source_file = .{ .path = module_path } });
        modules[index] = module;
        module_names[index] = module_name;

        std.debug.print("Discovered module with name {s}\n", .{module_name});
        exe.root_module.addImport(module_name, module);
    }
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
        test_step.dependOn(&run_unit_test_module.step);
    }

    // lib_unit_tests.root_module.addImport("helpers", helpers_mod);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    // test_step.dependOn(&run_lib_unit_tests.step);
    // test_step.dependOn(&lib_unit_tests.step);
}

fn last(iter: *std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence)) []const u8 {
    var prev_value: []const u8 = undefined;
    while (iter.next()) |value| {
        prev_value = value;
    }

    return prev_value;
}
