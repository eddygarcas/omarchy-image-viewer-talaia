import QtQuick
import QtQuick.Controls
import ImageViewer

Item {
    id: root
    anchors.fill: parent
    focus: true

    signal closed()

    property int intervalMs: 5000
    property bool playing: true
    property bool expanded: false

    function toggleFullscreen() {
        const win = Window.window
        if (!win)
            return
        if (win.visibility === Window.FullScreen) {
            win.visibility = Window.Windowed
            root.expanded = false
        } else {
            win.visibility = Window.FullScreen
            root.expanded = true
        }
    }

    function requestClose() {
        if (root.expanded)
            toggleFullscreen()
        root.closed()
    }

    Rectangle { anchors.fill: parent; color: "black" }

    Image {
        id: slideImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: false
        asynchronous: true
        sourceSize: Qt.size(backend.imageWidth, backend.imageHeight)
        source: backend.hasImage ? ("image://backend/current/" + backend.generation) : ""
    }

    Timer {
        interval: root.intervalMs
        running: root.playing
        repeat: true
        onTriggered: backend.openImage(backend.folderModel.next())
    }

    ScrollView {
        id: controlsScroll
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        width: Math.min(parent.width - 40, controls.implicitWidth)
        height: controls.implicitHeight
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Row {
            id: controls
            spacing: 10

            RoundedToolButton {
                glyph: "skip-back"
                Accessible.name: qsTr("Previous image")
                ToolTip.text: qsTr("Previous image")
                ToolTip.visible: hovered
                onClicked: backend.openImage(backend.folderModel.previous())
            }
            RoundedToolButton {
                glyph: root.playing ? "pause" : "play"
                Accessible.name: root.playing ? qsTr("Pause slideshow") : qsTr("Play slideshow")
                ToolTip.text: Accessible.name
                ToolTip.visible: hovered
                onClicked: root.playing = !root.playing
            }
            RoundedToolButton {
                glyph: "skip-forward"
                Accessible.name: qsTr("Next image")
                ToolTip.text: qsTr("Next image")
                ToolTip.visible: hovered
                onClicked: backend.openImage(backend.folderModel.next())
            }

            ToolSeparator {}

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Interval")
                color: Theme.foreground
            }
            Slider {
                id: intervalSlider
                anchors.verticalCenter: parent.verticalCenter
                from: 5
                to: 30
                stepSize: 1
                value: root.intervalMs / 1000
                width: 110
                Accessible.name: qsTr("Slideshow interval in seconds")
                onMoved: root.intervalMs = value * 1000
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("%1 s").arg(Math.round(intervalSlider.value))
                color: Theme.foreground
            }

            ToolSeparator {}

            RoundedButton {
                text: root.expanded ? qsTr("Exit fullscreen") : qsTr("Fullscreen")
                glyph: root.expanded ? "collapse" : "expand"
                onClicked: root.toggleFullscreen()
            }
            RoundedButton {
                text: qsTr("Close")
                glyph: "close"
                onClicked: root.requestClose()
            }
        }
    }

    Keys.onEscapePressed: root.requestClose()
    Keys.onSpacePressed: root.playing = !root.playing
    Keys.onLeftPressed: backend.openImage(backend.folderModel.previous())
    Keys.onRightPressed: backend.openImage(backend.folderModel.next())
    Keys.onPressed: function (event) {
        if (event.key === Qt.Key_F11) {
            toggleFullscreen()
            event.accepted = true
        }
    }

    Component.onCompleted: forceActiveFocus()
}
