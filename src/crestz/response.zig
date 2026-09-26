const std = @import("std");

pub const Response = struct {
    alloc: std.mem.Allocator,
    body: []u8,
    status: std.http.Status,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        self.alloc.free(self.body);
    }

    pub fn raw(self: *Self) []const u8 {
        return self.body;
    }

    pub fn json(self: *Self) !std.json.Parsed(std.json.Value) {
        return std.json.parseFromSlice(
            std.json.Value,
            self.allocator,
            self.body,
            .{},
        );
    }

    pub fn jsonAs(self: *Self, comptime T: type) !std.json.Parsed(T) {
        return std.json.parseFromSlice(
            T,
            self.allocator,
            self.body,
            .{},
        );
    }
};
