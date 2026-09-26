const std = @import("std");
const response = @import("response.zig").Response;

pub const Request = struct {
    alloc: std.mem.Allocator,
    url: []const u8,
    method: std.http.Method,
    headers: std.http.Client.Request.Headers,
    body: ?[]const u8,

    pub fn execute(self: *Request, io: std.Io) !response {
        var client = std.http.Client{ .allocator = self.alloc, .io = io };
        defer client.deinit();

        //const buffer: std.ArrayList(u8) = .empty;
        // defer buffer.deinit(self.allocator);

        var buffer = std.Io.Writer.Allocating.init(self.alloc);
        defer buffer.deinit();

        const result = try client.fetch(.{
            .location = .{ .url = self.url },
            .method = self.method,
            .headers = self.headers,
            .payload = self.body orelse "",
            .response_writer = &buffer.writer,
        });
        if (result.status.class() != .success) {
            return error.RequestFailed;
        }

        const body = try self.alloc.dupe(u8, buffer.written());

        return response{ .alloc = self.alloc, .body = body, .status = result.status };
    }
};

pub const Options = struct {
    headers: std.http.Client.Request.Headers,
    body: ?[]const u8 = null,
};

pub fn init(allocator: std.mem.Allocator, url: []const u8, method: std.http.Method, opts: Options) Request {
    return Request{
        .alloc = allocator,
        .url = url,
        .method = method,
        .headers = opts.headers,
        .body = opts.body,
    };
}
