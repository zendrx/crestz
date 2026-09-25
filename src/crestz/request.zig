const std = @import("std");
const Response = @import("response.zig").Response;

pub const Rerror = error{
    RequestFailed,
    AllocationFailed,
    ClientFailed,
};

pub const Request = struct {
    alloc: std.mem.Allocator,
    url: []const u8,
    method: std.http.Method,
    headers: std.http.Client.Request.Headers,
    body: ?[]const u8,
    max_response_size: usize = 1024 * 1024,

    pub fn execute(self: *Request, io: std.Io) Rerror!Response {
        var client = std.http.Client{ .allocator = self.alloc, .io = io };
        defer client.deinit();

        //const buffer: std.ArrayList(u8) = .empty;
        // defer buffer.deinit(self.allocator);

        var buffer = std.Io.Writer.Allocating.init(self.alloc);
        defer buffer.deinit();

        const result = client.fetch(.{
            .location = .{ .url = self.url },
            .method = self.method,
            .headers = self.headers,
            .payload = self.body orelse "",
            .response_writer = &buffer.writer,
        }) catch return Rerror.ClientFailed;
        if (result.status.class() != .success) {
            return Rerror.RequestFailed;
        }

        const body = self.alloc.dupe(u8, buffer.written()) catch return Rerror.AllocationFailed;

        return Response{ .allocator = self.alloc, .body = body, .status = result.status };
    }
};

pub const Options = struct {
    headers: std.http.Client.Request.Headers,
    body: ?[]const u8 = null,
    max_response_size: usize = 1024 * 1024,
};

pub fn init(allocator: std.mem.Allocator, url: []const u8, method: std.http.Method, opts: Options) Request {
    return Request{
        .alloc = allocator,
        .url = url,
        .method = method,
        .headers = opts.headers,
        .body = opts.body orelse null,
        .max_response_size = opts.max_response_size,
    };
}
