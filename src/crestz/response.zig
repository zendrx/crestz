const std = @import("std");

pub const Response = struct {
    allocator: std.mem.Allocator,
    body: []u8,
    status: std.http.Status,

    pub fn deinit(self: *Response) []const u8 {
        return self.body;
    }

    pub fn raw(self: *Response) []const u8 {
        return self.body;
    }

    pub fn json(self: *Response) !std.json.Value {
        const parsed = try std.json.parseFromSlice(
            std.json.Value,
            self.allocator,
            self.body,
            .{},
        );
        return parsed.value;
    }
    pub fn jsonAs(self: *Response, comptime T: type) !T {
        const parsed = try std.json.parseFromSlice(
            T,
            self.allocator,
            self.body,
            .{},
        );
        return parsed.value;
    }
};
