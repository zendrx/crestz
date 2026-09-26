const std = @import("std");
const crestz = @import("./src/crestz.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var req = try crestz.get(io, allocator, "https://github.com/", .{});
    const res = req.raw();
    std.debug.print("here {s}\n", .{res});
}
