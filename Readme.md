# Crestz

A lighweight, dependency-free HTTP client library for zig built on top of the stdlib `std.http`, with a clean ergonomic
API for making requests and handling responses.

### Features
- Simple API `crestz.get` `crestz.post` in one call
- zero dependencies
- Json support: parse responses into any type `jsonAs(T)`
- Explicit memory management
- Custom headers

### Requirements
- zig `0.16.0`

### Installation

```bash
zig fetch --save git+https://github.com/zendrx/crestz.git
```

Then in `build.zig`
```zig
const crestz = b.dependency("crestz", .{});
exe.root_module.addImport("crestz", crestz.module("crestz"));
```

Or just clone into vendor

crestz is small enough

### Quick Start

#### Get

```zig
const std = @import("std");
const crestz = @import("crestz")

pub fn main(init: std.process.Init) !void {
  const io = init.io;
  const alloc = init.gpa;

  var resp = try crestz.get(io, alloc, "https://ziglang.org/", .{});
  defer resp.deinit();
  try std.Io.File.stdout().writeStreamingAll(io, "Body:\n{s}\n", .{resp.raw()});
}
```

#### Post Request
```zig
const payload =
  \\{"name": "crestz", "lang": "zig"}
  ;
var resp = try crestz.post(io, alloc, "https://ziglang.org/", .{
  .content_type = "application/json",
});

defer resp.deinit();
```
#### Authentication

```zig
var resp = try crestz.get(io, alloc, "https://ziglang.org", .{
  .authorization = "Bearer <token>",
  .user_agent = "crestz/0.1.0",
  .content_type = "application/json",
});
defer resp.deinit();
```

### Response Api

```zig
resp.raw();
resp.status();

const parsed = try resp.json();
defer parsed.deinit();
const name = parsed.value.obeject.get("name");

const user = try resp.jsonAs(User);
defer user.deinit();
```

> NOTE: json()/jsonAs(T) return `std.json.Parsed(T)`  keep returned wrapper alive while using the value and `defer parsed.deinit();` to free
>


### Headers

```zig
pub const Headers = struct {
  authorization = ?[]const u8 = null,
  user_agent = ?[]const u8 = null,
  content_type = ?[]const u8 = null,
}
```
all fields are optional pass only what you need

> Roadmap
- [] put / delete / patch helpers
- [] Response size limits & timeouts
- [] query parameter builder
- [] multipart / file upload support


