const std = @import("std");

const Request = @import("./crestz/request.zig");
const Response = @import("./crestz/response.zig");

pub const crestz = struct {
    pub const Requests = Request;
    pub const Responses = Response;
};

pub const GetO = struct {
    headers: std.http.Client.Request.Headers = .{},
    max_response_size: usize = 1024 * 1024,
};

pub fn get(io: std.Io, allocator: std.mem.Allocator, url: []const u8, opts: GetO) !Response {
    var req = try Request.init(allocator, url, .GET, .{ .headers = opts.headers, .max_response_size = opts.max_response_size });
    defer req.deinit();
    return try req.execute(io);
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
