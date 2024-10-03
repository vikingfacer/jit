const std = @import("std");

fn makeContainerFile() !std.fs.File {
    const rand = std.crypto.random;
    var tempfile = [_]u8{0} ** 256;
    const tempfilename = try std.fmt.bufPrint(&tempfile, "/tmp/bf-jit-{d}", .{rand.int(u64)});
    std.debug.print("{s}\n", .{tempfile});

    const file = try std.fs.createFileAbsolute(tempfilename, .{ .read = true });

    const empty4096 = [_]u8{0} ** 4096;

    try file.writeAll(&empty4096);
    return file;
}

pub fn main() !void {
    const contain = try makeContainerFile();
    defer contain.close();
    const meta = try contain.metadata();
    var containWalker = try std.os.mmap(null, meta.size(), //
        std.os.PROT.EXEC | std.os.PROT.WRITE, //
        std.os.MAP.SHARED, //
        contain.handle, 0);
    defer std.os.munmap(containWalker);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
