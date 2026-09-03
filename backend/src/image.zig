const std = @import("std");
const stb = @import("stb.zig").c;
const transform = @import("transform.zig");
const History = @import("history.zig").History;

pub const Image = struct {
    allocator: std.mem.Allocator,

    base: []u8,
    width: u32,
    height: u32,

    /// Pristine pixels as loaded from disk; never mutated. Used by reset().
    original: []u8,
    original_width: u32,
    original_height: u32,

    /// Live, uncommitted color adjustment params. 0/0/1.0 == neutral.
    brightness: f32 = 0,
    contrast: f32 = 0,
    saturation: f32 = 1.0,

    history: History,

    fn resetAdjustParams(self: *Image) void {
        self.brightness = 0;
        self.contrast = 0;
        self.saturation = 1.0;
    }

    pub fn deinit(self: *Image) void {
        const allocator = self.allocator;
        allocator.free(self.base);
        allocator.free(self.original);
        self.history.deinit();
        allocator.destroy(self);
    }

    /// Buffer reflecting base + live adjustments. Freshly allocated each
    /// call; caller (the C ABI boundary) owns the result.
    pub fn displayCopy(self: *Image) ![]u8 {
        if (self.brightness == 0 and self.contrast == 0 and self.saturation == 1.0) {
            return self.allocator.dupe(u8, self.base);
        }
        return transform.adjust(self.allocator, self.base, self.brightness, self.contrast, self.saturation);
    }

    fn replaceBase(self: *Image, new_data: []u8, new_w: u32, new_h: u32) !void {
        try self.history.record(self.base, self.width, self.height);
        self.allocator.free(self.base);
        self.base = new_data;
        self.width = new_w;
        self.height = new_h;
        self.resetAdjustParams();
    }

    pub fn rotate90(self: *Image, clockwise: bool) !void {
        const rotated = try transform.rotate90(self.allocator, self.base, self.width, self.height, clockwise);
        try self.replaceBase(rotated, self.height, self.width);
    }

    pub fn flip(self: *Image, horizontal: bool) !void {
        const flipped = try transform.flip(self.allocator, self.base, self.width, self.height, horizontal);
        try self.replaceBase(flipped, self.width, self.height);
    }

    pub fn crop(self: *Image, x: i32, y: i32, w: i32, h: i32) !void {
        const result = try transform.crop(self.allocator, self.base, self.width, self.height, x, y, w, h);
        try self.replaceBase(result.data, result.w, result.h);
    }

    pub fn resize(self: *Image, new_w: u32, new_h: u32) !void {
        if (new_w == 0 or new_h == 0) return error.InvalidSize;
        const resized = try transform.resize(self.allocator, self.base, self.width, self.height, new_w, new_h);
        try self.replaceBase(resized, new_w, new_h);
    }

    pub fn commitAdjust(self: *Image) !void {
        if (self.brightness == 0 and self.contrast == 0 and self.saturation == 1.0) return;
        const baked = try transform.adjust(self.allocator, self.base, self.brightness, self.contrast, self.saturation);
        try self.replaceBase(baked, self.width, self.height);
    }

    pub fn undo(self: *Image) bool {
        const snap = self.history.undoPop() orelse return false;
        self.history.stashForRedo(self.base, self.width, self.height) catch {};
        self.allocator.free(self.base);
        self.base = snap.data;
        self.width = snap.width;
        self.height = snap.height;
        self.resetAdjustParams();
        return true;
    }

    pub fn redo(self: *Image) bool {
        const snap = self.history.redoPop() orelse return false;
        self.history.stashForUndo(self.base, self.width, self.height) catch {};
        self.allocator.free(self.base);
        self.base = snap.data;
        self.width = snap.width;
        self.height = snap.height;
        self.resetAdjustParams();
        return true;
    }

    pub fn reset(self: *Image) !void {
        const fresh = try self.allocator.dupe(u8, self.original);
        try self.replaceBase(fresh, self.original_width, self.original_height);
    }

    fn hasExt(path: []const u8, ext: []const u8) bool {
        if (path.len < ext.len) return false;
        return std.ascii.eqlIgnoreCase(path[path.len - ext.len ..], ext);
    }

    pub fn save(self: *Image, path: []const u8) !void {
        const buf = try self.displayCopy();
        defer self.allocator.free(buf);
        const path_z = try self.allocator.dupeZ(u8, path);
        defer self.allocator.free(path_z);

        const w: c_int = @intCast(self.width);
        const h: c_int = @intCast(self.height);
        const stride: c_int = @intCast(self.width * 4);
        const ok: c_int = blk: {
            if (hasExt(path, ".png")) {
                break :blk stb.stbi_write_png(path_z.ptr, w, h, 4, buf.ptr, stride);
            } else if (hasExt(path, ".jpg") or hasExt(path, ".jpeg")) {
                break :blk stb.stbi_write_jpg(path_z.ptr, w, h, 4, buf.ptr, 90);
            } else if (hasExt(path, ".bmp")) {
                break :blk stb.stbi_write_bmp(path_z.ptr, w, h, 4, buf.ptr);
            } else if (hasExt(path, ".tga")) {
                break :blk stb.stbi_write_tga(path_z.ptr, w, h, 4, buf.ptr);
            } else {
                break :blk stb.stbi_write_png(path_z.ptr, w, h, 4, buf.ptr, stride);
            }
        };
        if (ok == 0) return error.SaveFailed;
    }
};

test "open, rotate90, save round trip" {
    const allocator = std.testing.allocator;
    // Plain paths, written/read via stb's own fopen() - no Zig fs/Io.Dir needed.
    const in_path = "/tmp/imgbackend_test_in.png";
    const out_path = "/tmp/imgbackend_test_out.png";

    // 4x2 solid red RGBA image as input fixture.
    const w: u32 = 4;
    const h: u32 = 2;
    var pixels: [4 * 2 * 4]u8 = undefined;
    var i: usize = 0;
    while (i < pixels.len) : (i += 4) {
        pixels[i] = 255;
        pixels[i + 1] = 0;
        pixels[i + 2] = 0;
        pixels[i + 3] = 255;
    }
    const write_ok = stb.stbi_write_png(in_path, @intCast(w), @intCast(h), 4, &pixels, @intCast(w * 4));
    try std.testing.expect(write_ok != 0);

    const img = try open(allocator, in_path);
    defer img.deinit();
    try std.testing.expectEqual(@as(u32, 4), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);

    try img.rotate90(true);
    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 4), img.height);

    try img.save(out_path);

    var w2: c_int = 0;
    var h2: c_int = 0;
    var ch2: c_int = 0;
    const reloaded = stb.stbi_load(out_path, &w2, &h2, &ch2, 4);
    try std.testing.expect(reloaded != null);
    defer stb.stbi_image_free(reloaded);
    try std.testing.expectEqual(@as(c_int, 2), w2);
    try std.testing.expectEqual(@as(c_int, 4), h2);

    try std.testing.expect(img.undo());
    try std.testing.expectEqual(@as(u32, 4), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expect(img.redo());
    try std.testing.expectEqual(@as(u32, 2), img.width);
}

pub fn open(allocator: std.mem.Allocator, path: []const u8) !*Image {
    var w: c_int = 0;
    var h: c_int = 0;
    var channels: c_int = 0;

    const path_z = try allocator.dupeZ(u8, path);
    defer allocator.free(path_z);

    const data = stb.stbi_load(path_z.ptr, &w, &h, &channels, 4);
    if (data == null) return error.LoadFailed;
    defer stb.stbi_image_free(data);

    const len = @as(usize, @intCast(w)) * @as(usize, @intCast(h)) * 4;
    const loaded = data[0..len];
    // Always duplicate into the caller's allocator - the stb buffer is
    // malloc'd and must be freed via stbi_image_free, not via `allocator`.
    const original = try allocator.dupe(u8, loaded);
    const base_copy = try allocator.dupe(u8, loaded);

    const img = try allocator.create(Image);
    img.* = .{
        .allocator = allocator,
        .base = base_copy,
        .width = @intCast(w),
        .height = @intCast(h),
        .original = original,
        .original_width = @intCast(w),
        .original_height = @intCast(h),
        .history = History.init(allocator),
    };
    return img;
}
