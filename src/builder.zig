const std = @import("std");

const AttrList = @import("attrs.zig").AttrList;
const writeDotId = @import("utils.zig").writeDotId;

const MAX_ID = 128;

pub fn Builder(comptime Node: type) type {
    return struct {
        const Self = @This();

        const Queue = std.ArrayList(Node);
        const EdgeList = std.ArrayList(EdgeEntry);
        const NodeList = std.ArrayList(NodeEntry);
        const NodeMap = std.hash_map.StringHashMap(usize);

        const NodeEntry = struct {
            id: []const u8,
            node: Node,
            attrs: ?AttrList = null,
        };

        const EdgeEntry = struct {
            fromId: []const u8,
            toId: []const u8,
            attrs: ?AttrList = null,
        };

        arena: *std.heap.ArenaAllocator,
        queue: Queue,

        // These are arrays so that we preserve the order of which they are inserted.
        nodes: NodeList,
        edges: EdgeList,
        node_map: NodeMap,

        pub fn init(arena: *std.heap.ArenaAllocator) !Self {
            const allocator = arena.allocator();
            return Self{
                .arena = arena,
                .queue = Queue.init(allocator),
                .nodes = NodeList.init(allocator),
                .edges = EdgeList.init(allocator),
                .node_map = NodeMap.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.* = undefined;
        }

        /// Visits a node.
        pub fn visit(self: *Self, node: Node) !void {
            _ = try self.nodeEntry(node);
        }

        /// Defines a node with
        pub fn defNode(self: *Self, node: Node, node_attrs: ?AttrList) !void {
            var entry = try self.nodeEntry(node);
            entry.attrs = node_attrs;
        }

        pub fn defEdge(self: *Self, from: Node, to: Node, edge_attrs: ?AttrList) !void {
            const fromId = (try self.nodeEntry(from)).id;
            const toId = (try self.nodeEntry(to)).id;
            try self.edges.append(.{ .fromId = fromId, .toId = toId, .attrs = edge_attrs });
        }

        /// Creates a new attribute list using the same arena allocator.
        pub fn attrs(self: *Self) AttrList {
            return AttrList.init(self.arena);
        }

        /// Returns a string which is owned by the arena allocator. Panics on allocation failure.
        pub fn str(self: *Self, s: []const u8) []const u8 {
            return self.arena.allocator().dupe(u8, s) catch @panic("allocation failure");
        }

        // Returns the corresponding NodeEntry for a Node.
        // This pointer is only valid until the next call of `nodeEntry`.
        fn nodeEntry(self: *Self, node: Node) !*NodeEntry {
            var idBuf: [MAX_ID]u8 = undefined;
            var fbs = std.io.fixedBufferStream(&idBuf);
            try node.writeId(fbs.writer());

            const id = fbs.getWritten();
            const result = try self.node_map.getOrPut(id);
            if (!result.found_existing) {
                result.value_ptr.* = self.nodes.items.len;

                const localId = self.str(id);
                try self.nodes.append(NodeEntry{
                    .id = localId,
                    .node = node,
                });

                // We'll also have to set this one since the key that we used in getOrPut is not owned by the hash map.
                result.key_ptr.* = localId;

                // Push to queue as well.
                try self.queue.append(node);
            }

            return &self.nodes.items[result.value_ptr.*];
        }

        /// Process all pending nodes which hasn't been built yet.
        pub fn processQueue(self: *Self) !void {
            while (self.queue.items.len > 0) {
                const node = self.queue.orderedRemove(0);
                try node.build(self);
            }
        }

        /// Writes the generated .dot output to a writer.
        /// This will first call `processQueue` to work through all pending nodes.
        pub fn writeTo(self: *Self, w: anytype) !void {
            try self.processQueue();

            try w.writeAll("digraph {\n");

            for (self.nodes.items) |node| {
                try writeDotId(w, node.id);
                if (node.attrs) |node_attrs| {
                    try node_attrs.writeTo(w);
                }
                try w.writeAll(";\n");
            }

            for (self.edges.items) |edge| {
                try writeDotId(w, edge.fromId);
                try w.writeAll(" -> ");
                try writeDotId(w, edge.toId);
                if (edge.attrs) |edge_attrs| {
                    try edge_attrs.writeTo(w);
                }
                try w.writeAll(";\n");
            }

            try w.writeAll("}\n");
        }
    };
}

const testing = std.testing;

const ExampleNode = struct {
    id: []const u8,
    val: i32,

    children: []const *const ExampleNode,

    pub fn writeId(self: *const ExampleNode, w: anytype) !void {
        try w.print("{s}", .{self.id});
    }

    pub fn build(self: *const ExampleNode, b: anytype) !void {
        try b.defNode(self, b.attrs().withLabel("{}", .{self.val}));
        for (self.children, 0..) |child, idx| {
            try b.defEdge(self, child, b.attrs().withLabel("{}", .{idx}));
        }
    }
};

test "example" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();

    const ex1 = ExampleNode{
        .id = "a",
        .val = 1,
        .children = &.{},
    };

    const ex2 = ExampleNode{
        .id = "b",
        .val = 2,
        .children = &.{&ex1},
    };

    const ex3 = ExampleNode{
        .id = "c",
        .val = 3,
        .children = &.{},
    };

    const ex4 = ExampleNode{
        .id = "d",
        .val = 4,
        .children = &.{&ex3},
    };

    const ex5 = ExampleNode{
        .id = "e",
        .val = 5,
        .children = &.{ &ex2, &ex4 },
    };

    // This tests that we actually output/visit the nodes in breadth-first order.

    var b = try Builder(*const ExampleNode).init(&arena);
    try b.visit(&ex5);

    var out = std.ArrayList(u8).init(testing.allocator);
    defer out.deinit();
    try b.writeTo(out.writer());

    const result =
        \\digraph {
        \\"e"["label"="5"];
        \\"b"["label"="2"];
        \\"d"["label"="4"];
        \\"a"["label"="1"];
        \\"c"["label"="3"];
        \\"e" -> "b"["label"="0"];
        \\"e" -> "d"["label"="1"];
        \\"b" -> "a"["label"="0"];
        \\"d" -> "c"["label"="0"];
        \\}
        \\
    ;

    try testing.expectEqualStrings(result, out.items);
}
