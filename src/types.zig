const std = @import("std");

pub const Shape = enum {
    box,
    polygon,
    ellipse,
    oval,
    circle,
    point,
    egg,
    triangle,
    plaintext,
    plain,
    diamond,
    trapezium,
    parallelogram,
    house,
    pentagon,
    hexagon,
    septagon,
    octagon,
    doublecircle,
    doubleoctagon,
    tripleoctagon,
    invtriangle,
    invtrapezium,
    invhouse,
    Mdiamond,
    Msquare,
    Mcircle,
    rect,
    rectangle,
    square,
    star,
    none,
    underline,
    cylinder,
    note,
    tab,
    folder,
    box3d,
    component,
    promoter,
    cds,
    terminator,
    utr,
    primersite,
    restrictionsite,
    fivepoverhang,
    threepoverhang,
    noverhang,
    assembly,
    signature,
    insulator,
    ribosite,
    rnastab,
    proteasesite,
    proteinstab,
    rpromoter,
    rarrow,
    larrow,
    lpromoter,

    record,

    pub fn format(
        self: Shape,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const ArrowType = enum {
    normal,
    inv,
    dot,
    invdot,
    odot,
    invodot,
    none,
    tee,
    empty,
    invempty,
    diamond,
    odiamond,
    ediamond,
    crow,
    box,
    obox,
    open,
    halfopen,
    vee,

    pub fn format(
        self: ArrowType,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const Rect = struct {
    llx: f64,
    lly: f64,
    urx: f64,
    ury: f64,

    pub fn format(
        self: Rect,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{d},{d},{d},{d}", self);
    }
};

pub const ClusterMode = enum {
    local,
    global,
    node,

    pub fn format(
        self: ClusterMode,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const DirType = enum {
    forward,
    back,
    both,
    none,

    pub fn format(
        self: DirType,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const Rankdir = enum {
    TB,
    LR,
    BT,
    RL,

    pub fn format(
        self: Rankdir,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(@tagName(self));
    }
};

pub const RGB = struct {
    red: u8,
    green: u8,
    blue: u8,

    pub fn format(
        self: RGB,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("#{x:0>2}{x:0>2}{x:0>2}", .{ self.red, self.green, self.blue });
    }
};

pub fn rgb(r: u8, g: u8, b: u8) Color {
    return Color{ .rgb = RGB{ .red = r, .green = g, .blue = b } };
}

pub const Color = union(enum) {
    rgb: RGB,
    num: usize,
    name: []const u8,

    pub fn format(
        self: Color,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        switch (self) {
            .rgb => |r| try r.format(fmt, options, writer),
            .name => |name| try writer.writeAll(name),
            .num => |n| try writer.print("{}", .{n}),
        }
    }
};
