import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool cropActive: false

    function startCrop() {
        if (!backend.hasImage)
            return
        selection.visible = false
        viewport.resetZoom()
        root.cropActive = true
    }

    function cancelCrop() {
        root.cropActive = false
        selection.visible = false
    }

    function applyCrop() {
        if (!selection.visible || selection.width < 4 || selection.height < 4
                || img.paintedWidth <= 0 || img.paintedHeight <= 0) {
            cancelCrop()
            return
        }
        const paintedX = (img.width - img.paintedWidth) / 2
        const paintedY = (img.height - img.paintedHeight) / 2
        const scaleX = backend.imageWidth / img.paintedWidth
        const scaleY = backend.imageHeight / img.paintedHeight

        const px = Math.round((selection.x - paintedX) * scaleX)
        const py = Math.round((selection.y - paintedY) * scaleY)
        const pw = Math.round(selection.width * scaleX)
        const ph = Math.round(selection.height * scaleY)

        backend.crop(Math.max(0, px), Math.max(0, py), pw, ph)
        root.cropActive = false
        selection.visible = false
    }

    Connections {
        target: backend
        // A new image, or any committed edit, should start from a clean
        // fit-to-view - stale zoom/pan wouldn't make sense against it.
        function onCommitted() { viewport.resetZoom() }
    }

    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
    }

    Item {
        id: viewport
        anchors.fill: parent
        anchors.margins: 12
        clip: true

        readonly property real minZoom: 1.0
        readonly property real maxZoom: 8.0
        property real zoomScale: 1.0
        property real offsetX: 0
        property real offsetY: 0

        function resetZoom() {
            zoomScale = minZoom
            offsetX = 0
            offsetY = 0
        }

        function clampOffsets() {
            const scaledW = width * zoomScale
            const scaledH = height * zoomScale
            offsetX = scaledW <= width ? (width - scaledW) / 2
                                        : Math.min(0, Math.max(width - scaledW, offsetX))
            offsetY = scaledH <= height ? (height - scaledH) / 2
                                         : Math.min(0, Math.max(height - scaledH, offsetY))
        }

        Image {
            id: img
            x: viewport.offsetX
            y: viewport.offsetY
            width: viewport.width
            height: viewport.height
            transformOrigin: Item.TopLeft
            scale: viewport.zoomScale
            fillMode: Image.PreserveAspectFit
            smooth: true
            cache: false
            asynchronous: true
            source: backend.hasImage ? ("image://backend/current/" + backend.generation) : ""

            BusyIndicator {
                anchors.centerIn: parent
                running: img.status === Image.Loading
            }

            MouseArea {
                id: panZoomArea
                anchors.fill: parent
                enabled: backend.hasImage && !root.cropActive
                acceptedButtons: Qt.LeftButton
                cursorShape: viewport.zoomScale > viewport.minZoom ? Qt.OpenHandCursor : Qt.ArrowCursor
                property point lastViewportPos: Qt.point(0, 0)

                onPressed: (mouse) => {
                    lastViewportPos = mapToItem(viewport, mouse.x, mouse.y)
                }
                onPositionChanged: (mouse) => {
                    if (!pressed || viewport.zoomScale <= viewport.minZoom)
                        return
                    const p = mapToItem(viewport, mouse.x, mouse.y)
                    viewport.offsetX += p.x - lastViewportPos.x
                    viewport.offsetY += p.y - lastViewportPos.y
                    viewport.clampOffsets()
                    lastViewportPos = p
                }
                onDoubleClicked: viewport.resetZoom()
                onWheel: (wheel) => {
                    if (!(wheel.modifiers & Qt.ControlModifier)) {
                        wheel.accepted = false
                        return
                    }
                    wheel.accepted = true
                    const oldScale = viewport.zoomScale
                    const factor = wheel.angleDelta.y > 0 ? 1.15 : 1 / 1.15
                    const newScale = Math.max(viewport.minZoom, Math.min(viewport.maxZoom, oldScale * factor))
                    if (newScale === oldScale)
                        return
                    // Keep the content point under the cursor fixed on screen.
                    viewport.offsetX += wheel.x * (oldScale - newScale)
                    viewport.offsetY += wheel.y * (oldScale - newScale)
                    viewport.zoomScale = newScale
                    viewport.clampOffsets()
                }
            }
        }

        MouseArea {
            id: cropMouseArea
            anchors.fill: img
            visible: root.cropActive
            enabled: root.cropActive
            cursorShape: Qt.CrossCursor

            readonly property real paintedX: (img.width - img.paintedWidth) / 2
            readonly property real paintedY: (img.height - img.paintedHeight) / 2
            readonly property real minX: paintedX
            readonly property real minY: paintedY
            readonly property real maxX: paintedX + img.paintedWidth
            readonly property real maxY: paintedY + img.paintedHeight
            property real startX: 0
            property real startY: 0

            function clampX(v) { return Math.max(minX, Math.min(maxX, v)) }
            function clampY(v) { return Math.max(minY, Math.min(maxY, v)) }

            onPressed: (mouse) => {
                startX = clampX(mouse.x)
                startY = clampY(mouse.y)
                selection.x = startX
                selection.y = startY
                selection.width = 0
                selection.height = 0
                selection.visible = true
            }
            onPositionChanged: (mouse) => {
                if (!pressed)
                    return
                const cx = clampX(mouse.x)
                const cy = clampY(mouse.y)
                selection.x = Math.min(startX, cx)
                selection.y = Math.min(startY, cy)
                selection.width = Math.abs(cx - startX)
                selection.height = Math.abs(cy - startY)
            }
        }

        Rectangle {
            id: selection
            visible: false
            color: "#3391c4ff"
            border.color: "#ffffff"
            border.width: 1
        }
    }

    Label {
        visible: backend.hasImage && !root.cropActive
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        text: viewport.zoomScale > viewport.minZoom + 0.001
              ? Math.round(viewport.zoomScale * 100) + "%"
              : "Ctrl+Scroll to zoom"
        color: "#999999"
        font.pixelSize: 12
    }

    Label {
        anchors.centerIn: parent
        text: "Open an image to get started"
        visible: !backend.hasImage
        color: "#888888"
        font.pixelSize: 18
    }

    Label {
        visible: root.cropActive
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        text: "Drag to select the crop area"
        color: "#dddddd"
        font.pixelSize: 13
    }

    Row {
        visible: root.cropActive
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 16
        spacing: 8

        RoundedButton {
            text: "Apply Crop"
            enabled: selection.visible && selection.width > 4 && selection.height > 4
            onClicked: root.applyCrop()
        }
        RoundedButton {
            text: "Cancel"
            onClicked: root.cancelCrop()
        }
    }
}
