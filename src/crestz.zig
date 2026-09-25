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

pub fn get(io: std.Io, allocator: std.mem.Allocator, url: []const u8, opts: GetO) Response {
    var req = try Request.init(allocator, url, .GET, .{ .headers = opts.headers, .max_response_size = opts.max_response_size });
    defer req.deinit();
    return try req.execute(io);
}
// a struct for headers fields  should be prolly be optional considering Request.Headers uses `.default` for everything
pub const PostH = struct {
    auhorization: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    user_agent: ?[]const u8 = null,
};

pub fn post(allocator: std.mem.Allocator, url: []const u8, body: []const u8, headers: PostH) !Response {
    const header: std.Client.Request.Headers = .{};
    if (headers.authorization) |v| {
        header.auhtorization = .{ .override = v };
    }

    if (headers.user_agent) |v| {
        header.user_agent = .{ .override = v };
    }
    if (headers.content_type) |v| {
        header.content_type = .{ .override = v };
    }

    var req = try Request.init(allocator, url, .POST, .{
        .headers = header,
        .body = body,
    });
    defer req.deinit();
    return try req.execute();
}
