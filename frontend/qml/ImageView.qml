import QtQuick
import QtQuick.Controls
import ImageViewer

Item {
    id: root

    property bool cropActive: false
    readonly property int zoomPercent: Math.round(viewport.zoomScale * 100)
    signal openRequested()

    function resetZoom() { viewport.resetZoom() }
    function zoomIn() { viewport.zoomAt(1.2, viewport.width / 2, viewport.height / 2) }
    function zoomOut() { viewport.zoomAt(1 / 1.2, viewport.width / 2, viewport.height / 2) }

    function startCrop() {
        if (!backend.hasImage)
            return
        viewport.resetZoom()
        root.cropActive = true
        selection.x = (img.width - img.paintedWidth) / 2 + img.paintedWidth / 4
        selection.y = (img.height - img.paintedHeight) / 2 + img.paintedHeight / 4
        selection.width = img.paintedWidth / 2
        selection.height = img.paintedHeight / 2
        selection.visible = true
        root.forceActiveFocus()
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

    Keys.onPressed: function (event) {
        if (!root.cropActive || root.activeFocus !== root)
            return
        if (event.key === Qt.Key_Escape) {
            root.cancelCrop()
            event.accepted = true
            return
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.applyCrop()
            event.accepted = true
            return
        }
        const resize = (event.modifiers & Qt.ShiftModifier) !== 0
        const step = 10
        const left = (img.width - img.paintedWidth) / 2
        const top = (img.height - img.paintedHeight) / 2
        const right = left + img.paintedWidth
        const bottom = top + img.paintedHeight
        if (event.key === Qt.Key_Left) {
            if (resize)
                selection.width = Math.max(4, selection.width - step)
            else
                selection.x = Math.max(left, selection.x - step)
        } else if (event.key === Qt.Key_Right) {
            if (resize)
                selection.width = Math.min(right - selection.x, selection.width + step)
            else
                selection.x = Math.min(right - selection.width, selection.x + step)
        } else if (event.key === Qt.Key_Up) {
            if (resize)
                selection.height = Math.max(4, selection.height - step)
            else
                selection.y = Math.max(top, selection.y - step)
        } else if (event.key === Qt.Key_Down) {
            if (resize)
                selection.height = Math.min(bottom - selection.y, selection.height + step)
            else
                selection.y = Math.min(bottom - selection.height, selection.y + step)
        } else {
            return
        }
        event.accepted = true
    }

    Connections {
        target: backend
        // A new image, or any committed edit, should start from a clean
        // fit-to-view - stale zoom/pan wouldn't make sense against it.
        function onCommitted() { viewport.resetZoom() }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas
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

        function zoomAt(factor, centerX, centerY) {
            const oldScale = zoomScale
            const newScale = Math.max(minZoom, Math.min(maxZoom, oldScale * factor))
            if (newScale === oldScale)
                return
            offsetX = centerX - (centerX - offsetX) * newScale / oldScale
            offsetY = centerY - (centerY - offsetY) * newScale / oldScale
            zoomScale = newScale
            clampOffsets()
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
            sourceSize: Qt.size(backend.imageWidth, backend.imageHeight)
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
                    const factor = wheel.angleDelta.y > 0 ? 1.15 : 1 / 1.15
                    const point = mapToItem(viewport, wheel.x, wheel.y)
                    viewport.zoomAt(factor, point.x, point.y)
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
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
            border.color: Theme.foreground
            border.width: 1
        }
    }

    Column {
        anchors.centerIn: parent
        visible: !backend.hasImage
        spacing: 14

        Glyph {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "folder-open"
            width: 48
            height: 48
            size: 48
            color: Theme.muted
            Accessible.ignored: true
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Your images, in focus")
            color: Theme.foreground
            font.pointSize: Theme.titlePointSize
            font.weight: Font.Medium
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Open an image to view and edit it")
            color: Theme.muted
            font.pointSize: Theme.bodyPointSize
        }
        RoundedButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Open image")
            glyph: "folder-open"
            onClicked: root.openRequested()
        }
    }

    Label {
        anchors.centerIn: parent
        visible: backend.hasImage && img.status === Image.Error
        text: qsTr("This image could not be displayed")
        color: Theme.error
        font.pointSize: Theme.bodyPointSize
    }

    Label {
        visible: root.cropActive
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 8
        width: Math.min(parent.width - 24, implicitWidth)
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("Drag to select · arrows move · Shift+arrows resize · Enter applies")
        color: Theme.foreground
        font.pointSize: Theme.bodyPointSize
    }

    Row {
        visible: root.cropActive
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 16
        spacing: 8

        RoundedButton {
            text: qsTr("Apply crop")
            enabled: selection.visible && selection.width > 4 && selection.height > 4
            onClicked: root.applyCrop()
        }
        RoundedButton {
            text: qsTr("Cancel")
            onClicked: root.cancelCrop()
        }
    }
}
