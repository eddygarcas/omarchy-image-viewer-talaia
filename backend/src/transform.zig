const std = @import("std");
const stb = @import("stb.zig").c;

pub const CropResult = struct {
    data: []u8,
    w: u32,
    h: u32,
};

pub fn rotate90(allocator: std.mem.Allocator, src: []const u8, w: u32, h: u32, clockwise: bool) ![]u8 {
    const new_w = h;
    const new_h = w;
    const dst = try allocator.alloc(u8, @as(usize, new_w) * @as(usize, new_h) * 4);
    var y: u32 = 0;
    while (y < h) : (y += 1) {
        var x: u32 = 0;
        while (x < w) : (x += 1) {
            const src_idx = (@as(usize, y) * w + x) * 4;
            var dx: u32 = undefined;
            var dy: u32 = undefined;
            if (clockwise) {
                dx = h - 1 - y;
                dy = x;
            } else {
                dx = y;
                dy = w - 1 - x;
            }
            const dst_idx = (@as(usize, dy) * new_w + dx) * 4;
            @memcpy(dst[dst_idx .. dst_idx + 4], src[src_idx .. src_idx + 4]);
        }
    }
    return dst;
}

pub fn flip(allocator: std.mem.Allocator, src: []const u8, w: u32, h: u32, horizontal: bool) ![]u8 {
    const dst = try allocator.alloc(u8, src.len);
    var y: u32 = 0;
    while (y < h) : (y += 1) {
        var x: u32 = 0;
        while (x < w) : (x += 1) {
            const sx = if (horizontal) w - 1 - x else x;
            const sy = if (horizontal) y else h - 1 - y;
            const src_idx = (@as(usize, sy) * w + sx) * 4;
            const dst_idx = (@as(usize, y) * w + x) * 4;
            @memcpy(dst[dst_idx .. dst_idx + 4], src[src_idx .. src_idx + 4]);
        }
    }
    return dst;
}

pub fn crop(allocator: std.mem.Allocator, src: []const u8, w: u32, h: u32, x: i32, y: i32, cw: i32, ch: i32) !CropResult {
    if (cw <= 0 or ch <= 0) return error.InvalidCrop;
    const iw: i32 = @intCast(w);
    const ih: i32 = @intCast(h);
    const x0 = std.math.clamp(x, 0, iw);
    const y0 = std.math.clamp(y, 0, ih);
    const x1 = std.math.clamp(x + cw, 0, iw);
    const y1 = std.math.clamp(y + ch, 0, ih);
    if (x1 <= x0 or y1 <= y0) return error.InvalidCrop;
    const new_w: u32 = @intCast(x1 - x0);
    const new_h: u32 = @intCast(y1 - y0);
    const dst = try allocator.alloc(u8, @as(usize, new_w) * @as(usize, new_h) * 4);
    var row: u32 = 0;
    while (row < new_h) : (row += 1) {
        const src_row: usize = @intCast(y0 + @as(i32, @intCast(row)));
        const src_start = (src_row * w + @as(usize, @intCast(x0))) * 4;
        const dst_start = @as(usize, row) * new_w * 4;
        @memcpy(dst[dst_start .. dst_start + new_w * 4], src[src_start .. src_start + new_w * 4]);
    }
    return .{ .data = dst, .w = new_w, .h = new_h };
}

/// stb mallocs its own output buffer internally; duplicate it into the
/// caller's allocator and free the stb-owned buffer via libc free directly
/// (never mix a raw malloc'd pointer into an arbitrary Allocator's free()).
pub fn resize(allocator: std.mem.Allocator, src: []const u8, w: u32, h: u32, new_w: u32, new_h: u32) ![]u8 {
    const out = stb.stbir_resize_uint8_linear(
        src.ptr,
        @intCast(w),
        @intCast(h),
        0,
        null,
        @intCast(new_w),
        @intCast(new_h),
        0,
        stb.STBIR_RGBA,
    );
    if (out == null) return error.ResizeFailed;
    defer std.c.free(out);
    const len = @as(usize, new_w) * @as(usize, new_h) * 4;
    return allocator.dupe(u8, out[0..len]);
}

fn clamp255(v: f32) f32 {
    return std.math.clamp(v, 0.0, 255.0);
}

/// Non-destructive color adjustment. brightness in [-100,100] (additive),
/// contrast in [-100,100] (classic contrast-correction formula),
/// saturation in [0,2] where 1.0 is neutral. Alpha is untouched.
pub fn adjust(allocator: std.mem.Allocator, src: []const u8, brightness: f32, contrast: f32, saturation: f32) ![]u8 {
    const dst = try allocator.alloc(u8, src.len);
    const contrast_factor = (259.0 * (contrast + 255.0)) / (255.0 * (259.0 - contrast));
    var i: usize = 0;
    while (i < src.len) : (i += 4) {
        var r: f32 = @floatFromInt(src[i]);
        var g: f32 = @floatFromInt(src[i + 1]);
        var b: f32 = @floatFromInt(src[i + 2]);

        r = clamp255(contrast_factor * (r - 128.0) + 128.0 + brightness);
        g = clamp255(contrast_factor * (g - 128.0) + 128.0 + brightness);
        b = clamp255(contrast_factor * (b - 128.0) + 128.0 + brightness);

        const gray = 0.299 * r + 0.587 * g + 0.114 * b;
        r = clamp255(gray + saturation * (r - gray));
        g = clamp255(gray + saturation * (g - gray));
        b = clamp255(gray + saturation * (b - gray));

        dst[i] = @intFromFloat(r);
        dst[i + 1] = @intFromFloat(g);
        dst[i + 2] = @intFromFloat(b);
        dst[i + 3] = src[i + 3];
    }
    return dst;
}
