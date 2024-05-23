const std = @import("std");

const writeDotId = @import("utils.zig").writeDotId;
const types = @import("types.zig");

pub const AttrList = struct {
    const Attr = struct {
        key: []const u8,
        value: []const u8,
    };

    arena: *std.heap.ArenaAllocator,
    entries: std.ArrayListUnmanaged(Attr),

    pub fn init(arena: *std.heap.ArenaAllocator) AttrList {
        return AttrList{ .arena = arena, .entries = .{} };
    }

    pub fn withAttr(self: AttrList, key: []const u8, value: []const u8) AttrList {
        var copy = self;
        copy.entries.append(self.arena.allocator(), .{ .key = key, .value = value }) catch @panic("allocation error");
        return copy;
    }

    pub fn withAttrPrint(self: AttrList, key: []const u8, comptime fmt: []const u8, args: anytype) AttrList {
        const value = std.fmt.allocPrint(self.arena.allocator(), fmt, args) catch @panic("allocation failure");
        return self.withAttr(key, value);
    }

    pub fn format(
        self: AttrList,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        w: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try self.writeTo(w);
    }

    pub fn writeTo(
        self: AttrList,
        w: anytype,
    ) !void {
        if (self.entries.items.len == 0) return;
        try w.writeByte('[');
        for (self.entries.items, 0..) |entry, idx| {
            if (idx > 0) try w.writeByte(',');
            try writeDotId(w, entry.key);
            try w.writeByte('=');
            try writeDotId(w, entry.value);
        }
        try w.writeByte(']');
    }

    pub fn asString(self: AttrList) ![]const u8 {
        return try std.fmt.allocPrint(self.arena.allocator(), "{}", .{self});
    }

    pub fn withArea(self: AttrList, value: f64) AttrList {
        return self.withAttrPrint("area", "{d}", .{value});
    }

    pub fn withArrowhead(self: AttrList, arrow: types.ArrowType) AttrList {
        return self.withAttrPrint("arrowhead", "{}", .{arrow});
    }

    pub fn withArrowsize(self: AttrList, size: f64) AttrList {
        return self.withAttrPrint("arrowsize", "{d}", .{size});
    }

    pub fn withArrowtail(self: AttrList, arrow: types.ArrowType) AttrList {
        return self.withAttrPrint("arrowtail", "{}", .{arrow});
    }

    pub fn withBb(self: AttrList, rect: types.Rect) AttrList {
        return self.withAttrPrint("bb", "{}", .{rect});
    }

    pub fn withBgcolor(self: AttrList, color: types.Color) AttrList {
        return self.withAttrPrint("bgcolor", "{}", .{color});
    }

    pub fn withCenter(self: AttrList, val: bool) AttrList {
        return self.withAttrPrint("center", "{}", .{val});
    }

    pub fn withCharset(self: AttrList, value: []const u8) AttrList {
        return self.withAttr("charset", value);
    }

    pub fn withClass(self: AttrList, value: []const u8) AttrList {
        return self.withAttr("class", value);
    }

    pub fn withClusterrank(self: AttrList, mode: types.ClusterMode) AttrList {
        return self.withAttrPrint("clusterrank", "{}", .{mode});
    }

    pub fn withColor(self: AttrList, color: types.Color) AttrList {
        return self.withAttrPrint("color", "{}", .{color});
    }

    pub fn withColorscheme(self: AttrList, value: []const u8) AttrList {
        return self.withAttr("colorscheme", value);
    }

    pub fn withComment(self: AttrList, comptime fmt: []const u8, args: anytype) AttrList {
        return self.withAttrPrint("comment", fmt, args);
    }

    pub fn withCompound(self: AttrList, value: bool) AttrList {
        return self.withAttrPrint("compound", "{}", .{value});
    }

    pub fn withConcentrate(self: AttrList, value: bool) AttrList {
        return self.withAttrPrint("concentrate", "{}", .{value});
    }

    pub fn withConstraint(self: AttrList, value: bool) AttrList {
        return self.withAttrPrint("constraint", "{}", .{value});
    }

    pub fn withDamping(self: AttrList, val: f64) AttrList {
        return self.withAttrPrint("damping", "{d}", .{val});
    }

    pub fn withDecorate(self: AttrList, value: bool) AttrList {
        return self.withAttrPrint("decorate", "{}", .{value});
    }

    pub fn withDefaultdist(self: AttrList, val: f64) AttrList {
        return self.withAttrPrint("defaultdist", "{d}", .{val});
    }

    pub fn withDim(self: AttrList, val: u8) AttrList {
        return self.withAttrPrint("dim", "{d}", .{val});
    }

    pub fn withDimen(self: AttrList, val: u8) AttrList {
        return self.withAttrPrint("dimen", "{d}", .{val});
    }

    pub fn withDir(self: AttrList, dir: types.DirType) AttrList {
        return self.withAttrPrint("dir", "{}", .{dir});
    }

    // TODO: Add diredgeconstraints. It has a weird type so skipping it for now.

    pub fn withDistortion(self: AttrList, val: f64) AttrList {
        return self.withAttrPrint("distortion", "{d}", .{val});
    }

    pub fn withDpi(self: AttrList, val: f64) AttrList {
        return self.withAttrPrint("dpi", "{d}", .{val});
    }

    pub fn withLabel(self: AttrList, comptime fmt: []const u8, args: anytype) AttrList {
        return self.withAttrPrint("label", fmt, args);
    }

    pub fn withShape(self: AttrList, shape: types.Shape) AttrList {
        return self.withAttrPrint("shape", "{}", .{shape});
    }
};

const testing = std.testing;

test "area" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withArea(5.6);
    try testing.expectEqualStrings("[\"area\"=\"5.6\"]", try attrs.asString());
}

test "arrowhead" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withArrowhead(.tee);
    try testing.expectEqualStrings("[\"arrowhead\"=\"tee\"]", try attrs.asString());
}

test "arrowsize" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withArrowsize(3.14);
    try testing.expectEqualStrings("[\"arrowsize\"=\"3.14\"]", try attrs.asString());
}

test "arrowtail" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withArrowtail(.tee);
    try testing.expectEqualStrings("[\"arrowtail\"=\"tee\"]", try attrs.asString());
}

test "bb" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withBb(.{ .llx = 0, .lly = 5, .urx = 10, .ury = 12.5 });
    try testing.expectEqualStrings("[\"bb\"=\"0,5,10,12.5\"]", try attrs.asString());
}

test "bgcolor" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withBgcolor(.{ .name = "green" });
    try testing.expectEqualStrings("[\"bgcolor\"=\"green\"]", try attrs.asString());
}

test "center" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withCenter(true);
    try testing.expectEqualStrings("[\"center\"=\"true\"]", try attrs.asString());
}

test "charset" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withCharset("latin1");
    try testing.expectEqualStrings("[\"charset\"=\"latin1\"]", try attrs.asString());
}

test "class" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withClass("foo");
    try testing.expectEqualStrings("[\"class\"=\"foo\"]", try attrs.asString());
}

test "clusterrank" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withClusterrank(.local);
    try testing.expectEqualStrings("[\"clusterrank\"=\"local\"]", try attrs.asString());
}

test "color (named)" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withColor(.{ .name = "yellow" });
    try testing.expectEqualStrings("[\"color\"=\"yellow\"]", try attrs.asString());
}

test "color (rgb)" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withColor(types.rgb(0xFF, 0x00, 0x00));
    try testing.expectEqualStrings("[\"color\"=\"#ff0000\"]", try attrs.asString());
}

test "color (idx)" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withColor(.{ .num = 3 });
    try testing.expectEqualStrings("[\"color\"=\"3\"]", try attrs.asString());
}

test "colorschema" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withColorscheme("oranges9");
    try testing.expectEqualStrings("[\"colorscheme\"=\"oranges9\"]", try attrs.asString());
}

test "comment" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withComment("abc", .{});
    try testing.expectEqualStrings("[\"comment\"=\"abc\"]", try attrs.asString());
}

test "compound" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withCompound(true);
    try testing.expectEqualStrings("[\"compound\"=\"true\"]", try attrs.asString());
}

test "concentrate" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withConcentrate(true);
    try testing.expectEqualStrings("[\"concentrate\"=\"true\"]", try attrs.asString());
}

test "constraint" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withConstraint(true);
    try testing.expectEqualStrings("[\"constraint\"=\"true\"]", try attrs.asString());
}

test "damping" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDamping(0.5);
    try testing.expectEqualStrings("[\"damping\"=\"0.5\"]", try attrs.asString());
}

test "decorate" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDecorate(true);
    try testing.expectEqualStrings("[\"decorate\"=\"true\"]", try attrs.asString());
}

test "defaultdist" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDefaultdist(10.3);
    try testing.expectEqualStrings("[\"defaultdist\"=\"10.3\"]", try attrs.asString());
}

test "dim" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDim(3);
    try testing.expectEqualStrings("[\"dim\"=\"3\"]", try attrs.asString());
}

test "dimen" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDimen(8);
    try testing.expectEqualStrings("[\"dimen\"=\"8\"]", try attrs.asString());
}

test "dir" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDir(.both);
    try testing.expectEqualStrings("[\"dir\"=\"both\"]", try attrs.asString());
}

test "distortion" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDistortion(-0.5);
    try testing.expectEqualStrings("[\"distortion\"=\"-0.5\"]", try attrs.asString());
}

test "dpi" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    var attrs = AttrList.init(&arena).withDpi(100);
    try testing.expectEqualStrings("[\"dpi\"=\"100\"]", try attrs.asString());
}
