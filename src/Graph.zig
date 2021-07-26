const std = @import("std");
const Node = @import("Node.zig");
const Self = @This();
const NodeList = std.AutoHashMap(usize, *Node);

nodecount: usize,
nodes: NodeList,
alloc: *std.mem.Allocator,

pub fn new(alloc: *std.mem.Allocator) Self {
    return .{
        .nodecount = 0,
        .nodes = NodeList.init(alloc),
        .alloc = alloc
    };
}

pub fn addNode(self: *Self, id: usize, value: usize) !void {
    self.nodecount += 1;
    const node = try self.alloc.create(Node);
    node.init(self.alloc, id, value);
    try self.nodes.put(id, node);
}

pub fn setNodeValue(self: *Self, id: usize, value: usize) void {
    const node = self.nodes.get(id) orelse return;
    node.value = value;
}

pub fn deinit(self: *Self) void {
    var it = self.nodes.valueIterator();
    while (it.next()) |item| {
        self.alloc.destroy(item);
    }
    self.nodes.deinit();
}

pub fn connect(self: *Self, id1: usize, id2: usize) !void {
    const node1 = self.nodes.get(id1) orelse return;
    const node2 = self.nodes.get(id2) orelse return;

    try node1.addConnection(node2);
    try node2.addConnection(node1);
}

pub fn isConnected(self: *Self, id1: usize, id2: usize) bool {
    const node1 = self.nodes.get(id1) orelse return false;
    const contains = for (node1.connections.items) |connid| {
        if (connid == id2) break true;
    } else false;

    if (id1 != id2 and contains) return true;
    return false;
}