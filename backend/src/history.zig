const std = @import("std");

pub const Snapshot = struct {
    data: []u8,
    width: u32,
    height: u32,
};

/// Bounded undo/redo stack of full pixel-buffer snapshots.
/// `record` is used for new committed edits (clears redo).
/// `stashForRedo`/`stashForUndo` move a state between stacks without
/// clobbering the other one, so multi-level undo/redo both work.
pub const History = struct {
    const cap = 15;

    allocator: std.mem.Allocator,
    undo: [cap]?Snapshot = [_]?Snapshot{null} ** cap,
    undo_count: usize = 0,
    redo: [cap]?Snapshot = [_]?Snapshot{null} ** cap,
    redo_count: usize = 0,

    pub fn init(allocator: std.mem.Allocator) History {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *History) void {
        var i: usize = 0;
        while (i < self.undo_count) : (i += 1) self.allocator.free(self.undo[i].?.data);
        i = 0;
        while (i < self.redo_count) : (i += 1) self.allocator.free(self.redo[i].?.data);
    }

    fn pushRaw(self: *History, stack: *[cap]?Snapshot, count: *usize, data: []const u8, width: u32, height: u32) !void {
        const copy = try self.allocator.dupe(u8, data);
        if (count.* == cap) {
            self.allocator.free(stack[0].?.data);
            var i: usize = 0;
            while (i < cap - 1) : (i += 1) stack[i] = stack[i + 1];
            count.* -= 1;
        }
        stack[count.*] = .{ .data = copy, .width = width, .height = height };
        count.* += 1;
    }

    fn popRaw(stack: *[cap]?Snapshot, count: *usize) ?Snapshot {
        if (count.* == 0) return null;
        count.* -= 1;
        const s = stack[count.*];
        stack[count.*] = null;
        return s;
    }

    fn clearRedo(self: *History) void {
        var i: usize = 0;
        while (i < self.redo_count) : (i += 1) self.allocator.free(self.redo[i].?.data);
        self.redo_count = 0;
    }

    /// New committed edit: push onto undo, invalidate any redo history.
    pub fn record(self: *History, data: []const u8, width: u32, height: u32) !void {
        try self.pushRaw(&self.undo, &self.undo_count, data, width, height);
        self.clearRedo();
    }

    pub fn undoPop(self: *History) ?Snapshot {
        return popRaw(&self.undo, &self.undo_count);
    }

    pub fn redoPop(self: *History) ?Snapshot {
        return popRaw(&self.redo, &self.redo_count);
    }

    pub fn stashForRedo(self: *History, data: []const u8, width: u32, height: u32) !void {
        try self.pushRaw(&self.redo, &self.redo_count, data, width, height);
    }

    pub fn stashForUndo(self: *History, data: []const u8, width: u32, height: u32) !void {
        try self.pushRaw(&self.undo, &self.undo_count, data, width, height);
    }
};
