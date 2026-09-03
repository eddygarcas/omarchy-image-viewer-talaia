#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Building backend (zig)"
(cd "$ROOT_DIR/backend" && zig build)

echo "==> Configuring frontend (cmake)"
cmake -S "$ROOT_DIR/frontend" -B "$ROOT_DIR/frontend/build" -G Ninja -DCMAKE_BUILD_TYPE=Debug

echo "==> Building frontend"
cmake --build "$ROOT_DIR/frontend/build"

echo "==> Done: $ROOT_DIR/frontend/build/image-viewer"
