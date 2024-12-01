const std = @import("std");
const builtin = @import("builtin");
const config = @import("src/config.zig");

const Build = std.Build;
const Compile = Build.Step.Compile;
const TranslateC = Build.Step.TranslateC;
const Run = Build.Step.Run;
const ResolvedTarget = Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const LazyPath = Build.LazyPath;
const ArrayList = std.ArrayList;

const sdl_dependencies: []const SDLDependency = &.{
    .{ .name = "sdl2", .lib_name = "SDL2" },
    .{ .name = "sdl2image", .lib_name = "SDL2_image" },
};

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const strip = b.option(bool, "strip", "") orelse false;

    if (target.result.os.tag == .emscripten) {
        try addEmscriptenBuild(b, target, optimize);
    } else {
        addNativeBuild(b, target, optimize, strip);
    }
}

fn addNativeBuild(b: *Build, target: ResolvedTarget, optimize: OptimizeMode, strip: bool) void {
    // COMPILE

    const c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const exe = b.addExecutable(.{
        .name = "sdl-emscripten",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip,
    });
    if (target.result.os.tag == .windows) {
        exe.subsystem = .Windows;
    }

    inline for (sdl_dependencies) |sdl_dep| {
        linkSdlDependency(b, sdl_dep, exe, c);
    }
    b.installArtifact(exe);

    exe.root_module.addImport("c", c.createModule());

    inline for (config.install_dirs) |install_path| {
        const install_dir = b.addInstallDirectory(.{ .source_dir = b.path(install_path), .install_dir = .{ .custom = "" }, .install_subdir = install_path });
        exe.step.dependOn(&install_dir.step);
    }

    // RUN

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // TEST

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

// SDL

const SDLDependency = struct {
    name: []const u8,
    lib_name: []const u8,
};

fn linkSdlDependency(b: *Build, comptime sdl_dep: SDLDependency, exe: *Compile, c: *TranslateC) void {
    const dep = b.dependency(sdl_dep.name, .{});

    const lib_file_name = sdl_dep.lib_name ++ ".dll";
    const dll_install = b.addInstallBinFile(dep.path("lib/x64/" ++ lib_file_name), lib_file_name);
    exe.step.dependOn(&dll_install.step);

    exe.addLibraryPath(dep.path("lib/x64/"));
    c.addIncludePath(dep.path("include"));
    exe.linkSystemLibrary(sdl_dep.lib_name);
}

// EMSCRIPTEN

fn addEmscriptenBuild(b: *Build, target: ResolvedTarget, optimize: OptimizeMode) !void {
    const emsdk = b.dependency("emsdk", .{});
    const emsdk_sysroot = emsdk.path("upstream/emscripten/cache/sysroot");
    b.sysroot = emsdk_sysroot.getPath(b);

    const c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    c.addIncludePath(emsdk.path("upstream/emscripten/cache/sysroot/include"));

    const exe = try compileEmscripten(
        b,
        "sdl-emscripten",
        b.path("src/main.zig"),
        target,
        optimize,
        emsdk_sysroot,
    );
    exe.root_module.addImport("c", c.createModule());

    const linkStep = try emLinkStep(b, .{
        .lib_main = exe,
        .target = target,
        .optimize = optimize,
    });
    var run = emRunStep(b, .{ .name = "sdl-emscripten" });
    run.step.dependOn(&linkStep.step);
    const run_cmd = b.step("run", "Run the web demo");
    run_cmd.dependOn(&run.step);
}

fn compileEmscripten(b: *Build, name: []const u8, root_source_file: LazyPath, resolved_target: ResolvedTarget, optimize: OptimizeMode, emsdk_sysroot: LazyPath) !*Compile {
    const target = resolved_target.query;
    const new_target = b.resolveTargetQuery(.{
        .cpu_arch = target.cpu_arch,
        .cpu_model = target.cpu_model,
        .cpu_features_add = target.cpu_features_add,
        .cpu_features_sub = target.cpu_features_sub,
        .os_tag = .wasi,
        .os_version_min = target.os_version_min,
        .os_version_max = target.os_version_max,
        .glibc_version = target.glibc_version,
        .abi = target.abi,
        .dynamic_linker = target.dynamic_linker,
        .ofmt = target.ofmt,
    });

    const exe_lib = b.addStaticLibrary(.{
        .name = name,
        .root_source_file = root_source_file,
        .target = new_target,
        .optimize = optimize,
    });

    exe_lib.addSystemIncludePath(emsdk_sysroot.path(b, "include"));

    if (new_target.query.os_tag == .wasi) {
        const webhack_c =
            \\// Zig adds '__stack_chk_guard', '__stack_chk_fail', and 'errno',
            \\// which emscripten doesn't actually support.
            \\// Seems that zig ignores disabling stack checking,
            \\// and I honestly don't know why emscripten doesn't have errno.
            \\// TODO: when the updateTargetForWeb workaround gets removed, see if those are nessesary anymore
            \\#include <stdint.h>
            \\uintptr_t __stack_chk_guard;
            \\//I'm not certain if this means buffer overflows won't be detected,
            \\// However, zig is pretty safe from those, so don't worry about it too much.
            \\void __stack_chk_fail(void){}
            \\int errno;
        ;

        const webhack_c_file_step = b.addWriteFiles();
        const webhack_c_file = webhack_c_file_step.add("webhack.c", webhack_c);
        exe_lib.addCSourceFile(.{ .file = webhack_c_file, .flags = &.{} });
    }
    return exe_lib;
}

fn emSdkSetupStep(b: *Build) !?*Run {
    const emsdk_path = emSdkPath(b);
    const dot_emsc_path = b.pathJoin(&.{ emsdk_path, ".emscripten" });
    const dot_emsc_path_exists = !std.meta.isError(std.fs.accessAbsolute(dot_emsc_path, .{}));
    if (!dot_emsc_path_exists) {
        var cmd = ArrayList([]const u8).init(b.allocator);
        defer cmd.deinit();

        if (builtin.os.tag == .windows) {
            try cmd.append(b.pathJoin(&.{ emsdk_path, "emsdk.bat" }));
        } else {
            try cmd.append("bash");
            try cmd.append(b.pathJoin(&.{ emsdk_path, "emsdk" }));
        }

        const emsdk_install = b.addSystemCommand(cmd.items);
        emsdk_install.addArgs(&.{ "install", "latest" });
        const emsdk_activate = b.addSystemCommand(cmd.items);
        emsdk_activate.addArgs(&.{ "activate", "latest" });
        emsdk_activate.step.dependOn(&emsdk_install.step);

        return emsdk_activate;
    } else {
        return null;
    }
}

const EmLinkOptions = struct {
    target: ResolvedTarget,
    optimize: OptimizeMode,
    lib_main: *Compile,
    release_use_closure: bool = true,
    release_use_lto: bool = true,
    use_webgpu: bool = false,
    use_webgl2: bool = false,
    use_emalloc: bool = false,
    use_filesystem: bool = true,
    shell_file_path: ?[]const u8 = null,
    extra_args: []const []const u8 = &.{},
};

fn emLinkStep(b: *Build, options: EmLinkOptions) !*Run {
    const emcc_path = b.pathJoin(&.{ emSdkPath(b), "upstream", "emscripten", "emcc" });

    try std.fs.cwd().makePath(b.fmt("{s}/web", .{b.install_path}));

    var emcc_cmd = ArrayList([]const u8).init(b.allocator);
    defer emcc_cmd.deinit();

    try emcc_cmd.append(emcc_path);
    if (options.optimize == .Debug) {
        try emcc_cmd.append("-Og");
        try emcc_cmd.append("-sASSERTIONS=1");
        try emcc_cmd.append("-sSAFE_HEAP=1");
        try emcc_cmd.append("-sSTACK_OVERFLOW_CHECK=1");
        try emcc_cmd.append("-gsource-map");
        try emcc_cmd.append("--emrun");
    } else {
        try emcc_cmd.append("-sASSERTIONS=0");
        if (options.optimize == .ReleaseSmall) {
            try emcc_cmd.append("-Oz");
        } else {
            try emcc_cmd.append("-O3");
        }
        if (options.release_use_lto) {
            try emcc_cmd.append("-flto");
        }
        if (options.release_use_closure) {
            try emcc_cmd.append("--closure");
            try emcc_cmd.append("1");
        }
    }

    if (options.use_webgpu) {
        try emcc_cmd.append("-sUSE_WEBGPU=1");
    }
    if (options.use_webgl2) {
        try emcc_cmd.append("-sUSE_WEBGL2=1");
    }
    if (!options.use_filesystem) {
        try emcc_cmd.append("-sNO_FILESYSTEM=1");
    }
    if (options.use_emalloc) {
        try emcc_cmd.append("-sMALLOC='emalloc'");
    }
    if (options.shell_file_path) |shell_file_path| {
        try emcc_cmd.append(b.fmt("--shell-file={s}", .{shell_file_path}));
    }

    try emcc_cmd.append("-sUSE_SDL=2");
    try emcc_cmd.append("-sUSE_SDL_IMAGE=2");
    try emcc_cmd.append("-sUSE_LIBPNG");
    try emcc_cmd.append("-sSDL2_IMAGE_FORMATS=['png']");

    try emcc_cmd.append("-sGL_ENABLE_GET_PROC_ADDRESS=1");
    try emcc_cmd.append("-sINITIAL_MEMORY=64Mb");
    try emcc_cmd.append("-sSTACK_SIZE=16Mb");

    try emcc_cmd.append("-sUSE_OFFSET_CONVERTER=1");
    try emcc_cmd.append("-sFULL_ES3=1");
    try emcc_cmd.append("-sUSE_GLFW=1");

    inline for (config.install_dirs) |install_dir| {
        try emcc_cmd.append("--embed-file");
        try emcc_cmd.append(install_dir);
    }

    try emcc_cmd.append(b.fmt("-o{s}/web/{s}.html", .{ b.install_path, options.lib_main.name }));
    for (options.extra_args) |arg| {
        try emcc_cmd.append(arg);
    }

    const emcc = b.addSystemCommand(emcc_cmd.items);
    emcc.setName("emcc");

    const maybe_emsdk_setup = try emSdkSetupStep(b);
    if (maybe_emsdk_setup) |emsdk_setup| {
        options.lib_main.step.dependOn(&emsdk_setup.step);
    }

    const sysroot_include_path = if (b.sysroot) |sysroot| b.pathJoin(&.{ sysroot, "include" }) else @panic("");

    emcc.addArtifactArg(options.lib_main);
    var it = options.lib_main.root_module.iterateDependencies(options.lib_main, false);
    while (it.next()) |item| {
        if (maybe_emsdk_setup) |emsdk_setup| {
            item.compile.?.step.dependOn(&emsdk_setup.step);
        }
        if (sysroot_include_path.len > 0) {
            item.module.addSystemIncludePath(.{ .cwd_relative = sysroot_include_path });
        }
        for (item.module.link_objects.items) |link_object| {
            switch (link_object) {
                .other_step => |compile_step| {
                    switch (compile_step.kind) {
                        .lib => emcc.addArtifactArg(compile_step),
                        else => {},
                    }
                },
                else => {},
            }
        }
    }

    b.getInstallStep().dependOn(&emcc.step);
    return emcc;
}

const EmRunOptions = struct {
    name: []const u8,
};

fn emRunStep(b: *Build, options: EmRunOptions) *Run {
    const emrun_path = b.pathJoin(&.{ emSdkPath(b), "upstream", "emscripten", "emrun" });
    const web_path = b.pathJoin(&.{ ".", "zig-out", "web", options.name });
    const emrun = b.addSystemCommand(&.{ emrun_path, "--serve_after_exit", "--serve_after_close", b.fmt("{s}.html", .{web_path}) });
    return emrun;
}

fn emSdkPath(b: *Build) []const u8 {
    const emsdk = b.dependency("emsdk", .{});
    const emsdk_path = emsdk.path("").getPath(b);
    return emsdk_path;
}