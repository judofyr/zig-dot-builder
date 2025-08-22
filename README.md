# zig-dot-builder

`zig-dot-builder` is a library for creating `.dot` files which can be used by [Graphviz](https://graphviz.org/) to produce useful diagrams.
This is very useful for debugging complicated (and maybe even not-so-complicated!) data structures.

**Features:**

- Type-safe API for building attributes.
- Supports recursive graphs.
- Automatically escapes identifier.
- Stores all intermediate strings in a single arena allocator.

## Getting started

There's three main concepts you need to know:

- You'll have to provide your own **Node** implementation.
- You use **Builder** to define nodes and edges.
- You use **AttrList** to declare attributes on these nodes/edges.

### Node implementation

A _node_ is a struct which implements two methods:

- `writeId`: This method accepts a writer and should write out the node's unique ID.
- `build`: This method will be invoked once per node and should declare the node and its edges.

```zig
const dot = @import("dot-builder");

/// Node declaration:
const ExampleNode = struct {
    id: []const u8,
    val: i32,

    child: ?*const ExampleNode,

    pub fn writeId(self: *const ExampleNode, w: anytype) !void {
        try w.print("{s}", .{self.id});
    }

    pub fn build(self: *const ExampleNode, b: anytype) !void {
        try b.defNode(self, b.attrs().withLabel("{f}", .{self.val}));
        if (self.child) |child| {
            try b.defEdge(self, child, null);
        }
    }
};
```

There's three methods you'll use inside `build()`:

- `b.defNode(Node, ?*AttrList)`: Declares a node with attributes.
- `b.defEdge(Node, Node, ?*AttrList)`: Declares a directed edge between two nodes with attributes.
- `b.attrs()`: Starts a new attribute list.
  You use this as a parameter to `defNode` and `defEdge`.

### Generating .dot

To generate a .dot file you'll have to:

- Initialize the builder with an arena allocator.
- Call `b.visit` on the "root" nodes.
- Call `b.writeTo` to write the .dot file.

```zig
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var b = dot.Builder(*const ExampleNode).init(arena);

    // Visit a node:
    try b.visit(node);

    // Output:
    const stdout = std.io.getStdOut();
    try b.writeTo(stdout.writer());
}
```
