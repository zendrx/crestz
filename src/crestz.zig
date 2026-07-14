const std = @import("std");

const Request = @import("./crestz/request.zig").Request;
const Response = @import("./crestz/response.zig").Response;

pub const crestz = struct {
    pub const Requests = Request;
    pub const Responses = Response;
};

pub fn get(allocator: std.mem.Allocator, url: []const u8) !Response {
    var req = try Request.init(allocator, url, .GET, .{});
    defer req.deinit();
    return req.execute();
}

pub fn post(allocator: std.mem.Allocator, url: []const u8, body: []const u8) !Response {
    const headers = [_]std.http.Header{
        .{ .name = "Content-Type", .value = "application/json" },
    };
    var req = try Request.init(allocator, url, .POST, .{
        .headers = headers,
        .body = body,
    });
    defer req.deinit();
    return try req.execute();
}
