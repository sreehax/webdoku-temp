const std = @import("std");
const Self = @This();
const ConnectionsList = std.ArrayList(usize);

id: usize,
value: usize,
connections: ConnectionsList,

pub fn init(self: *Self, alloc: *std.mem.Allocator, id: usize, value: usize) void {
    self.id = id;
    self.value = value;
    self.connections = ConnectionsList.init(alloc);
}

pub fn addConnection(self: *Self, connection: *@This()) !void {
    for (self.connections.items) |item| {
        if (connection.id == item) return;
    }
    try self.connections.append(connection.id);
}

pub fn deinit(self: *Self) void {
    self.connections.deinit();
}