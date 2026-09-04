import QtQuick
import QtQuick.Shapes
import ImageViewer
import "Icons.js" as Icons

// One toolbar icon, chosen by name. Lucide draws on a 24 unit grid at stroke 2;
// this scales that down to the slot and redraws it with square caps and mitered
// joins instead of Lucide's rounded ones, for a sharper look at small sizes.
Item {
    id: root

    property string name: "close"
    property color color: "transparent"
    readonly property real grid: 24
    // The min() against the slot means a smaller caller-set width/height still
    // wins, and nothing can make the icon larger than its own size property.
    property real size: Theme.iconSize
    readonly property real glyphSize: Math.min(root.size, root.width, root.height)
    readonly property real gridScale: root.glyphSize / root.grid
    property real strokeWidth: Theme.strokeWidth

    Shape {
        width: root.grid
        height: root.grid
        x: (root.width - root.glyphSize) / 2
        y: (root.height - root.glyphSize) / 2
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { xScale: root.gridScale; yScale: root.gridScale }

        ShapePath {
            strokeColor: root.color
            fillColor: "transparent"
            strokeWidth: root.strokeWidth
            capStyle: ShapePath.SquareCap
            joinStyle: ShapePath.MiterJoin
            PathSvg { path: Icons.pathFor(root.name) }
        }
    }
}
