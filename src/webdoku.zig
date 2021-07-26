const std = @import("std");
const Graph = @import("Graph.zig");

var arr = [_]u8{0} ** 81;
export fn add(a: isize, b: isize) isize {
    return a + b;
}
export fn getBoardLocation() [*]u8 {
   return &arr;
}

export fn solve() bool {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    
    var graph = Graph.new(&arena.allocator);
    defer graph.deinit();
    for (arr) |val, i| {
        graph.addNode(i, val) catch return false;
    }
    connectRows(&graph) catch return false;
    connectColumns(&graph) catch return false;
    connect3x3(&graph) catch return false;

    var given = std.ArrayList(u8).init(&arena.allocator);
    defer given.deinit();
    var i: u8 = 0;
    while (i < arr.len) : (i += 1) {
        if (arr[i] != 0) given.append(i) catch return false;
    }

    return recursiveSolve(&graph, 0, given.items);
}

fn recursiveSolve(g: *Graph, vertex: u8, given: []const u8) bool {
    if (vertex == g.nodecount) return true;
    var c: u8 = 1;
    while (c < 10) : (c += 1) {
        if (canIColor(g, vertex, c, given)) {
            arr[vertex] = c;
            if (recursiveSolve(g, vertex+1, given)) return true;
        }
        if (!contains(u8, given, vertex)) {
            arr[vertex] = 0;
        }
    }
    return false;
}

fn canIColor(g: *Graph, vertex: u8, c: u8, given: []const u8) bool {
    if (contains(u8, given, vertex) and arr[vertex] == c) {
        return true;
    } else if (contains(u8, given, vertex)) {
        return false;
    }
    var i: u8 = 0;
    while (i < g.nodecount) : (i += 1) {
        if (arr[i] == c and g.isConnected(vertex, i)) {
            return false;
        }
    }
    return true;
}
fn connectRows(g: *Graph) !void {
    var row: usize = 0;
    var _num: usize = 0;
    var _other: usize = 0;
    while (row < 9) : (row += 1) {
        while (_num < 9) : (_num += 1) {
            while (_other < 9) : (_other += 1) {
                const num = _num + row * 9;
                const other = _other + row * 9;
                if (num != other) try g.connect(num, other);
            }
            _other = 0;
        }
        _num = 0;
    }
}

fn connectColumns(g: *Graph) !void {
    var col: usize = 0;
    var _num: usize = 0;
    var _other: usize = 0;
    while (col < 9) : (col += 1) {
        while (_num < 9) : (_num += 1) {
            while (_other < 9) : (_other += 1) {
                const num = col + _num * 9;
                const other = col + _other * 9;
                if (num != other) try g.connect(num, other);
            }
            _other = 0;
        }
        _num = 0;
    }
}

fn connect3x3(g: *Graph) !void {
    var row: usize = 0;
    var col: usize = 0;
    var row3x3: usize = 0;
    var col3x3: usize = 0;
    while (row < 9) : (row += 1) {
        while (col < 9) : (col += 1) {
            const current = row * 9 + col;
            const startrow = row - (row % 3);
            const startcol = col - (col % 3);
            row3x3 = startrow;
            while (row3x3 < startrow+3) : (row3x3 += 1) {
                col3x3 = startcol;
                while (col3x3 < startcol+3) : (col3x3 += 1) {
                    const curr3x3 = row3x3 * 9 + col3x3;
                    if (current != curr3x3) try g.connect(current, curr3x3);
                }
            }
        }
        col = 0;
    }
}

fn contains(comptime T: type, slice: []const T, val: T) bool {
    return for (slice) |current| {
        if (current == val) break true;
    } else {
        return false;
    };
}