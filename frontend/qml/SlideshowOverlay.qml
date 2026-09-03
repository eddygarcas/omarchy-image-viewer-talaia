import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Item {
    id: root
    anchors.fill: parent
    focus: true

    signal closed()

    property int intervalMs: 3000
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
        source: backend.hasImage ? ("image://backend/current/" + backend.generation) : ""
    }

    Timer {
        interval: root.intervalMs
        running: root.playing
        repeat: true
        onTriggered: backend.openImage(backend.folderModel.next())
    }

    MouseArea {
        anchors.fill: parent
        onClicked: controls.visible = !controls.visible
    }

    RowLayout {
        id: controls
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        spacing: 10

        Button { text: "⏮"; onClicked: backend.openImage(backend.folderModel.previous()) }
        Button {
            text: root.playing ? "⏸" : "⏵"
            onClicked: root.playing = !root.playing
        }
        Button { text: "⏭"; onClicked: backend.openImage(backend.folderModel.next()) }
        Button {
            text: root.expanded ? "Exit Fullscreen" : "Fullscreen"
            onClicked: root.toggleFullscreen()
        }
        Button { text: "Close"; onClicked: root.requestClose() }
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
