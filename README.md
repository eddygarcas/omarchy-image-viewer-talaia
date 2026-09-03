# Talaia

A desktop image viewer with a **Zig** backend (vendored `stb_image` /
`stb_image_write` / `stb_image_resize2`) and a **Qt6/QML** frontend.

Named after the *talaia* — a coastal watchtower built to see the whole
horizon — this is a viewer for looking at your images clearly, including
in fullscreen slideshow.

![Screenshot](docs/screenshot.png)

## Features

- Open any image `stb_image` supports: PNG, JPEG, BMP, GIF (static), TGA,
  PSD, HDR, PIC, PNM/PPM/PGM (no WebP/AVIF/HEIC/SVG)
- Edit tools: rotate, flip, crop, resize, brightness/contrast/saturation
  (live preview, non-destructive until applied), undo/redo, save
- Slideshow over the containing folder, with play/pause, prev/next, and
  fullscreen expand (button, F11, or Escape to exit-then-close)

## Architecture

```
backend/    Zig shared library (C ABI) - decode/encode/transform, no UI
frontend/   Qt6/QML application - UI, folder navigation, slideshow
```

The frontend links directly against the backend's compiled `.so` and talks
to it through the C header in `backend/include/imgbackend.h`. Pixel buffers
are handed to Qt with zero-copy ownership transfer (`QImage` frees them via
a callback into the Zig allocator).

### Why this stack

**Zig for the backend — C interop, not memory safety.** Zig's `@cImport`
and `addCSourceFile` let `stb_image.h` be dropped straight into the build
with no binding-generation step: its functions are called as if they were
native Zig, sharing the same allocator/ABI boundary as the C code with no
translation layer. That's the real reason for choosing it over, say, Rust,
where vendoring a C header means writing (or generating) an FFI shim first.

Zig is *not* memory-safe the way Rust, Go, or Java are, though — there's no
borrow checker, no lifetime tracking, no GC. Memory management is manual,
just like C: you call `allocator.alloc`/`allocator.free` yourself, and
nothing in the type system stops a double-free, a use-after-free, or
handing a buffer to the wrong allocator. What Zig gives instead is a
language built to make manual memory management easier to get right, via
opt-in *runtime* checks rather than compile-time guarantees: bounds-checked
slices (in Debug/ReleaseSafe builds), non-null pointers by default with
explicit `?T` for nullability, typed error unions instead of hidden
exceptions, no hidden allocations, and a debug allocator that can catch
misuse like double-frees via canary checks.

That last point isn't theoretical here — it's how a real bug got caught
while writing the backend's unit test. `image.open()` was duplicating a
`stbi_load` buffer into whatever allocator the caller passed in, but a
helper (`resize`) was returning a raw `stbi_image_resize2`-malloc'd pointer
that later got freed through that same arbitrary allocator. In production
this happened to work, because the one allocator actually used
(`std.heap.c_allocator`) reduces to plain `malloc`/`free` for byte buffers.
The moment the test used a different (bookkeeping) allocator, it crashed
with an "invalid free" canary panic. Zig didn't prevent the bug — it made
it loud and catchable in a test rather than silent heap corruption in the
field. That's the honest version of "Zig is safer": better failure modes
for mistakes C lets you make silently, not immunity to them.

**QML for the frontend — separating UI from logic, not hot-reload.** QML
keeps *what the UI looks like* (declarative markup + property bindings)
separate from *what the app does* (the `ImageBackend` C++ object, exposed
to QML as invokable methods and properties). That split is why the
toolbar-overflow fix mentioned in the commit history — converting two
`RowLayout`s to scrollable `ScrollView`s — was a pure `.qml` change, no
C++ or Zig recompilation involved, and why Qt Quick Controls provided
dialogs, sliders, and spin boxes for free instead of hand-rolled widgets.
One nuance: this app compiles QML ahead-of-time (`qmlcachegen`) for
performance, so "easier to improve" means less code and faster iteration
per change, not literal hot-reload without a rebuild.

**Backend/frontend split — a reusable core, with one caveat.** The C-ABI
boundary means any frontend that can link a `.so` and call C functions — a
GTK app, a CLI tool, a different QML app, bindings from another language
entirely — gets image load/save/rotate/flip/crop/resize/adjust/undo/redo
for free, with no Qt dependency at all. That's the payoff of exposing
`imgbackend.h` at the boundary instead of Zig types directly, which
nothing outside Zig could call.

The caveat: not *everything* is in the backend. Folder scanning for the
slideshow (`FolderModel`, built on `QDir`) lives entirely in the Qt
frontend, not the Zig backend — a deliberate call, since Qt's filesystem
APIs are already solid and duplicating directory listing in Zig would've
been pure overhead. It means a hypothetical second frontend would need to
reimplement folder navigation itself; only the pixel-manipulation core is
actually shared.

## Prerequisites

- [Zig](https://ziglang.org/) 0.16
- Qt6 (`qt6-base`, `qt6-declarative` — on Arch/Omarchy: `sudo pacman -S qt6-base qt6-declarative`)
- CMake and Ninja (`sudo pacman -S cmake ninja`)
- A C/C++ toolchain (gcc or clang)

## Building

```sh
./build.sh
```

This runs `zig build` in `backend/` to produce `backend/zig-out/lib/libimgbackend.so`,
then configures and builds `frontend/` with CMake/Ninja, producing:

```
frontend/build/image-viewer
```

## Installing

```sh
./install.sh
```

Builds the app, symlinks it as `talaia` into `~/.local/bin`, installs the
app icon into `~/.local/share/icons/hicolor`, and registers a desktop entry
in `~/.local/share/applications` so **Talaia** shows up in your app
launcher. Requires `rsvg-convert` (`sudo pacman -S librsvg`) to rasterize
the icon.

## Running

```sh
talaia [path/to/image]              # after ./install.sh
./frontend/build/image-viewer [path/to/image]   # without installing
```

Passing a path on the command line opens it immediately; otherwise use the
**Open** button in the app.

## Testing

The backend has a unit test covering the open → rotate → save → undo/redo
round trip:

```sh
cd backend && zig build test
```
