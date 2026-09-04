pragma Singleton
import QtQuick

// Talaia's design tokens. Colors default to the app's original hand-picked dark
// palette, then get overridden once at startup from the live Omarchy palette at
// ~/.local/state/omarchy/current/theme/colors.toml (read via the themeReader
// context property set up in main.cpp), so the app matches whatever Omarchy theme
// is active instead of carrying its own fixed colors - the same idea flea.git's
// own Theme.qml/Color singleton is built around.
QtObject {
    id: root

    readonly property color fallbackBackground: "#1e1e1e"
    readonly property color fallbackSurface: "#2a303c"
    readonly property color fallbackSurfaceHover: "#343b48"
    readonly property color fallbackSurfaceActive: "#3a4150"
    readonly property color fallbackBorder: "#4a5261"
    readonly property color fallbackForeground: "#eeeeee"
    readonly property color fallbackMuted: "#bbbbbb"
    readonly property color fallbackAccent: "#7fb2ff"
    readonly property color fallbackError: "#ff8080"

    property color background: fallbackBackground
    // The image viewport is a shade off the window chrome so the two read as
    // separate surfaces; canvas is derived from background once a palette loads.
    property color canvas: fallbackSurface
    property color surface: fallbackSurface
    property color surfaceHover: fallbackSurfaceHover
    property color surfaceActive: fallbackSurfaceActive
    property color border: fallbackBorder
    property color foreground: fallbackForeground
    property color muted: fallbackMuted
    property color accent: fallbackAccent
    property color error: fallbackError

    readonly property int cornerRadius: 8
    readonly property int iconSize: 16
    readonly property real strokeWidth: 1.5

    function parseToml(text) {
        var out = {}
        var lines = String(text).split("\n")
        for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^\s*([a-zA-Z0-9_]+)\s*=\s*"([^"]*)"\s*$/)
            if (m)
                out[m[1]] = m[2]
        }
        return out
    }

    function pick(map, keys, fallback) {
        for (var i = 0; i < keys.length; i++) {
            if (map[keys[i]])
                return map[keys[i]]
        }
        return fallback
    }

    function hexToRgb(hex) {
        var h = String(hex).replace("#", "")
        return {
            r: parseInt(h.substring(0, 2), 16),
            g: parseInt(h.substring(2, 4), 16),
            b: parseInt(h.substring(4, 6), 16)
        }
    }

    // Mixes hex toward target by amount (0..1) - used to derive hover/active/canvas
    // shades from the palette's single surface/background color, since Omarchy's
    // colors.toml only models one shade of each rather than a full ladder.
    function mix(hex, targetHex, amount) {
        var c = hexToRgb(hex)
        var t = hexToRgb(targetHex)
        return Qt.rgba((c.r + (t.r - c.r) * amount) / 255,
                        (c.g + (t.g - c.g) * amount) / 255,
                        (c.b + (t.b - c.b) * amount) / 255, 1)
    }

    function applyPalette(text) {
        if (!text)
            return
        var p = root.parseToml(text)
        var bg = root.pick(p, ["background"], root.fallbackBackground)
        var fg = root.pick(p, ["foreground"], root.fallbackForeground)
        var surf = root.pick(p, ["lighter_background", "selection"], root.fallbackSurface)

        root.background = bg
        root.foreground = fg
        root.muted = root.pick(p, ["muted", "dark_foreground"], root.fallbackMuted)
        root.accent = root.pick(p, ["accent", "red"], root.fallbackAccent)
        root.error = root.pick(p, ["red"], root.fallbackError)
        root.surface = surf
        root.surfaceHover = root.mix(surf, fg, 0.12)
        root.surfaceActive = root.mix(surf, fg, 0.2)
        root.border = root.mix(surf, fg, 0.28)
        root.canvas = root.mix(bg, fg, 0.05)
    }

    Component.onCompleted: {
        if (typeof themeReader !== "undefined")
            root.applyPalette(themeReader.omarchyColors())
    }
}
