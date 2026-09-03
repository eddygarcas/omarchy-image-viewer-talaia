const std = @import("std");
const image = @import("image.zig");
const Image = image.Image;

const alloc = std.heap.c_allocator;

pub const ImgPixels = extern struct {
    data: ?[*]u8,
    width: c_int,
    height: c_int,
    stride: c_int,
};

const empty_pixels = ImgPixels{ .data = null, .width = 0, .height = 0, .stride = 0 };

fn asImage(h: ?*anyopaque) ?*Image {
    return @as(?*Image, @ptrCast(@alignCast(h)));
}

export fn img_open(path: [*c]const u8) ?*anyopaque {
    if (path == null) return null;
    const slice = std.mem.span(path);
    const img = image.open(alloc, slice) catch return null;
    return @ptrCast(img);
}

export fn img_close(h: ?*anyopaque) void {
    const img = asImage(h) orelse return;
    img.deinit();
}

export fn img_get_pixels(h: ?*anyopaque) ImgPixels {
    const img = asImage(h) orelse return empty_pixels;
    const buf = img.displayCopy() catch return empty_pixels;
    return .{
        .data = buf.ptr,
        .width = @intCast(img.width),
        .height = @intCast(img.height),
        .stride = @intCast(img.width * 4),
    };
}

export fn img_free_pixels(data: ?[*]u8) void {
    const ptr = data orelse return;
    std.c.free(ptr);
}

export fn img_get_width(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    return @intCast(img.width);
}

export fn img_get_height(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    return @intCast(img.height);
}

export fn img_rotate90(h: ?*anyopaque, clockwise: c_int) c_int {
    const img = asImage(h) orelse return 0;
    img.rotate90(clockwise != 0) catch return 0;
    return 1;
}

export fn img_flip(h: ?*anyopaque, horizontal: c_int) c_int {
    const img = asImage(h) orelse return 0;
    img.flip(horizontal != 0) catch return 0;
    return 1;
}

export fn img_crop(h: ?*anyopaque, x: c_int, y: c_int, w: c_int, ch: c_int) c_int {
    const img = asImage(h) orelse return 0;
    img.crop(x, y, w, ch) catch return 0;
    return 1;
}

export fn img_resize(h: ?*anyopaque, new_w: c_int, new_h: c_int) c_int {
    const img = asImage(h) orelse return 0;
    if (new_w <= 0 or new_h <= 0) return 0;
    img.resize(@intCast(new_w), @intCast(new_h)) catch return 0;
    return 1;
}

export fn img_adjust(h: ?*anyopaque, brightness: f32, contrast: f32, saturation: f32) void {
    const img = asImage(h) orelse return;
    img.brightness = brightness;
    img.contrast = contrast;
    img.saturation = saturation;
}

export fn img_commit_adjust(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    img.commitAdjust() catch return 0;
    return 1;
}

export fn img_undo(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    return if (img.undo()) 1 else 0;
}

export fn img_redo(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    return if (img.redo()) 1 else 0;
}

export fn img_reset(h: ?*anyopaque) c_int {
    const img = asImage(h) orelse return 0;
    img.reset() catch return 0;
    return 1;
}

export fn img_save(h: ?*anyopaque, path: [*c]const u8) c_int {
    const img = asImage(h) orelse return 0;
    if (path == null) return 0;
    img.save(std.mem.span(path)) catch return 0;
    return 1;
}
