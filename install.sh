#!/usr/bin/env bash
# Installs Talaia for the current user: builds it, symlinks the `talaia`
# command into ~/.local/bin, installs the app icon into the hicolor theme,
# and registers a desktop entry so it shows up in app launchers.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="$ROOT_DIR/frontend/build/image-viewer"
ICON_SRC="$ROOT_DIR/frontend/resources/icons/talaia.svg"

echo "==> Building"
"$ROOT_DIR/build.sh"

echo "==> Installing command: ~/.local/bin/talaia"
mkdir -p "$HOME/.local/bin"
ln -sf "$BIN_PATH" "$HOME/.local/bin/talaia"

echo "==> Installing icon into the hicolor theme"
for size in 16 22 24 32 48 64 96 128 256 512; do
    dest="$HOME/.local/share/icons/hicolor/${size}x${size}/apps"
    mkdir -p "$dest"
    rsvg-convert -w "$size" -h "$size" "$ICON_SRC" -o "$dest/talaia.png"
done
mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps"
cp "$ICON_SRC" "$HOME/.local/share/icons/hicolor/scalable/apps/talaia.svg"

echo "==> Installing desktop entry"
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/talaia.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Talaia
GenericName=Image Viewer
Comment=View and edit images — crop, resize, adjust, and slideshow a whole folder in fullscreen
Exec=$HOME/.local/bin/talaia %f
Icon=talaia
Terminal=false
StartupWMClass=image-viewer
Categories=Graphics;Viewer;Photography;
MimeType=image/png;image/jpeg;image/bmp;image/x-tga;image/x-portable-pixmap;image/x-portable-graymap;image/x-portable-anymap;
Keywords=image;photo;viewer;editor;slideshow;crop;resize;
EOF

command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications" || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -f "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "==> Done. Launch with 'talaia' or find Talaia in your app launcher."
