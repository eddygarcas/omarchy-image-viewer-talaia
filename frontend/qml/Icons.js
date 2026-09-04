.pragma library

// Lucide-static path data, ISC licence, https://github.com/lucide-icons/lucide -
// one "d" per icon on its native 24 unit grid. Glyph.qml draws these with square
// caps and mitered joins rather than Lucide's default rounded ones, the same
// sharp-corner "Omarchy cut" flea.git's own icon set uses.
//
// A few source icons use <rect>/<line> primitives, which QtQuick.Shapes' PathSvg
// can't draw directly - those are flattened to plain path commands below (e.g.
// pause's two rounded rects become plain closed rects, dropping the corner
// radius to match the square-corner cut everywhere else).
var PATHS = {
    // rotate-ccw / rotate-cw
    "rotate-left": "M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8 M3 3v5h5",
    "rotate-right": "M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8 M21 3v5h-5",
    // flip-horizontal-2 / flip-vertical-2
    "flip-horizontal": "M3 7l5 5-5 5V7 M21 7l-5 5 5 5V7 M12 20v2 M12 14v2 M12 8v2 M12 2v2",
    "flip-vertical": "M17 3l-5 5-5-5h10 M17 21l-5-5-5 5h10 M4 12H2 M10 12H8 M16 12h-2 M22 12h-2",
    // undo-2 / redo-2
    "undo": "M9 14 4 9l5-5 M4 9h10.5a5.5 5.5 0 0 1 5.5 5.5a5.5 5.5 0 0 1-5.5 5.5H11",
    "redo": "M15 14l5-5-5-5 M20 9H9.5A5.5 5.5 0 0 0 4 14.5A5.5 5.5 0 0 0 9.5 20H13",
    "crop": "M6 2v14a2 2 0 0 0 2 2h14 M18 22V8a2 2 0 0 0-2-2H2",
    "scaling": "M12 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7 M14 15H9v-5 M16 3h5v5 M21 3 9 15",
    "check": "M20 6 9 17l-5-5",
    "folder-open": "M6 14l1.5-2.9A2 2 0 0 1 9.24 10H20a2 2 0 0 1 1.94 2.5l-1.54 6a2 2 0 0 1-1.95 1.5H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3.9a2 2 0 0 1 1.69.9l.81 1.2a2 2 0 0 0 1.67.9H18a2 2 0 0 1 2 2v2",
    "save": "M15.2 3a2 2 0 0 1 1.4.6l3.8 3.8a2 2 0 0 1 .6 1.4V19a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z M17 21v-7a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v7 M7 3v4a1 1 0 0 0 1 1h7",
    "play": "M5 5a2 2 0 0 1 3.008-1.728l11.997 6.998a2 2 0 0 1 .003 3.458l-12 7A2 2 0 0 1 5 19z",
    // pause's two rx=1 rounded rects, squared off per the cut
    "pause": "M14 3h5v18h-5z M5 3h5v18h-5z",
    "skip-back": "M17.971 4.285A2 2 0 0 1 21 6v12a2 2 0 0 1-3.029 1.715l-9.997-5.998a2 2 0 0 1-.003-3.432z M3 20V4",
    "skip-forward": "M21 4v16 M6.029 4.285A2 2 0 0 0 3 6v12a2 2 0 0 0 3.029 1.715l9.997-5.998a2 2 0 0 0 .003-3.432z",
    // maximize / minimize-2, renamed for what they mean in the slideshow toolbar
    "expand": "M8 3H5a2 2 0 0 0-2 2v3 M21 8V5a2 2 0 0 0-2-2h-3 M3 16v3a2 2 0 0 0 2 2h3 M16 21h3a2 2 0 0 0 2-2v-3",
    "collapse": "M14 10l7-7 M20 10h-6V4 M3 21l7-7 M4 14h6v6",
    "close": "M18 6 6 18 M6 6l12 12",
    // link-2's <line> flattened to a plain horizontal segment
    "link": "M9 17H7A5 5 0 0 1 7 7h2 M15 7h2a5 5 0 1 1 0 10h-2 M8 12h8",
    // unlink's four <line> corner ticks flattened the same way
    "unlink": "M18.84 12.25l1.72-1.71h-.02a5.004 5.004 0 0 0-.12-7.07 5.006 5.006 0 0 0-6.95 0l-1.72 1.71 M5.17 11.75l-1.71 1.71a5.004 5.004 0 0 0 .12 7.07 5.006 5.006 0 0 0 6.95 0l1.71-1.71 M8 2v3 M2 8h3 M16 19v3 M19 16h3"
}

var FALLBACK = "close"

function pathFor(name) {
    return PATHS[name] || PATHS[FALLBACK]
}
