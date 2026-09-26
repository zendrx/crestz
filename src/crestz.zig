const std = @import("std");

const Request = @import("./crestz/request.zig");
const response = @import("./crestz/response.zig").Response;

pub const Headers = struct {
    authorization: ?[]const u8 = null,
    content_type: ?[]const u8 = null,
    user_agent: ?[]const u8 = null,
};

pub fn get(io: std.Io, allocator: std.mem.Allocator, url: []const u8, headers: Headers) !response {
    var req = Request.init(allocator, url, .GET, .{ .headers = mapHeaders(headers) });
    return try req.execute(io);
}

pub fn post(io: std.Io, allocator: std.mem.Allocator, url: []const u8, body: []const u8, headers: Headers) !response {
    var req = Request.init(allocator, url, .POST, .{
        .headers = mapHeaders(headers),
        .body = body,
    });
    return try req.execute(io);
}

fn mapHeaders(headers: Headers) std.http.Client.Request.Headers {
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
    return header;
}
