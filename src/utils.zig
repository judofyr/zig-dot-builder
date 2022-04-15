const std = @import("std");

pub fn writeDotId(w: anytype, s: []const u8) !void {
    try w.writeByte('"');
    for (s) |char| {
        if (char == '"') {
            try w.writeByte('\\');
        }
        try w.writeByte(char);
    }
    try w.writeByte('"');
}

const testing = std.testing;

test "writeDotId" {
    var buf: [50]u8 = undefined;

    {
        var fbs = std.io.fixedBufferStream(&buf);
        try writeDotId(fbs.writer(), "abc");
        try testing.expectEqualStrings("\"abc\"", fbs.getWritten());
    }

    {
        var fbs = std.io.fixedBufferStream(&buf);
        try writeDotId(fbs.writer(), "ab\"c");
        try testing.expectEqualStrings("\"ab\\\"c\"", fbs.getWritten());
    }
}
