const std = @import("std");

const Request = @import("./crestz/request.zig");
const Response = @import("./crestz/response.zig");

pub const crestz = struct {
    pub const Requests = Request;
    pub const Responses = Response;
};

pub const Headers = struct {
    authorization: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    user_agent: ?[]const u8 = null,
};

pub fn get(io: std.Io, allocator: std.mem.Allocator, url: []const u8, headers: Headers) !Response {
    var header: std.http.Client.Request.Headers = .{};

    if (headers.authorization) |v| {
        header.authorization = .{ .override = v };
    }

    if (headers.user_agent) |v| {
        header.user_agent = .{ .override = v };
    }
    if (headers.content_type) |v| {
        header.content_type = .{ .override = v };
    }

    var req = Request.init(allocator, url, .GET, .{ .headers = header, .max_response_size = 1024 * 1024 });
    return try req.execute(io);
}

pub fn post(allocator: std.mem.Allocator, url: []const u8, body: []const u8, headers: Headers) !Response {
    var header: std.http.Client.Request.Headers = .{};
    if (headers.authorization) |v| {
        header.authorization = .{ .override = v };
    }

    if (headers.user_agent) |v| {
        header.user_agent = .{ .override = v };
    }
    if (headers.content_type) |v| {
        header.content_type = .{ .override = v };
    }

    var req = Request.init(allocator, url, .POST, .{
        .headers = header,
        .body = body,
    });
    return try req.execute();
}
