const std = @import("std");
const Response = @import("response.zig").Response;

pub const Request = struct {
    allocator: std.mem.Allocator,
    url: []const u8,
    method: std.http.Method,
    headers: []const std.http.Header,
    body: ?[]const u8,
    max_response_size: usize = 1024 * 1024,
};

pub const Options = struct {
    headers: []const std.http.Header,
    body: ?[]const u8 = null,
    max_response_size: usize = 1024 * 1024,
};

pub fn init(allocator: std.mem.Allocator, url: []const u8, method: std.http.Method, opts: Options) !Request {
    return Request{
        .allocator = allocator,
        .url = try allocator.dupe(u8, url),
        .method = method,
        .headers = try allocator.dupe(std.http.Header, opts.headers),
        .body = if (opts.body) |b| try allocator.dupe(u8, b) else null,
        .max_response_size = opts.max_response.size,
    };
}

pub fn deinit(self: *Request) void {
    self.allocator.free(@constCast(self.url));
    self.allocator.free(@constCast(self.headers));
    if (self.body) |b| self.allocator.free(@constCast(b));
}

pub fn execute(self: *Request) !Response {
    var client = std.http.Client{ .allocator = self.allocator };
    defer client.deinit();

    var buffer = std.ArrayList(u8).init(self.allocator);
    defer buffer.deinit();

    var buffer_writer = buffer.writer();

    const result = try client.fetch(.{
        .location = .{ .url = self.url },
        .method = self.method,
        .headers = self.headers,
        .payload = self.body orelse "",
        .response_writer = &buffer_writer,
    });
    if (result.status.class() != .success) {
        return error.RequestFailed;
    }

    const body = try self.allocator.dupe(u8, buffer.items);

    return Response{ .allocator = self.allocator, .body = body, .status = result.status };
}
