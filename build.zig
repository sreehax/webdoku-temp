const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const exe = b.addSharedLibrary("webdoku", "src/webdoku.zig", .unversioned);
    exe.setBuildMode(.ReleaseSmall);
    exe.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding
    });
    exe.strip = true;
    exe.install();
}