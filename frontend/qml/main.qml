import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

ApplicationWindow {
    id: window
    width: 1100
    height: 750
    minimumWidth: 480
    minimumHeight: 360
    visible: true
    title: backend.hasImage ? qsTr("%1 — Talaia").arg(backend.currentPath.split("/").pop()) : qsTr("Talaia")
    color: Theme.background

    FileActions { id: fileActions }

    Connections {
        target: backend
        function onErrorOccurred(message) {
            statusBar.errorMessage = message
            errorTimer.restart()
        }
    }
    Timer {
        id: errorTimer
        interval: 5000
        onTriggered: statusBar.errorMessage = ""
    }

    Shortcut { sequence: StandardKey.Open; onActivated: fileActions.openImage() }
    Shortcut { sequence: StandardKey.Save; enabled: backend.hasImage; onActivated: fileActions.saveImage() }
    Shortcut { sequence: "Ctrl+Shift+S"; enabled: backend.hasImage; onActivated: fileActions.saveImageAs() }
    Shortcut { sequence: StandardKey.Undo; enabled: backend.hasImage; onActivated: backend.undo() }
    Shortcut { sequence: StandardKey.Redo; enabled: backend.hasImage; onActivated: backend.redo() }
    Shortcut { sequence: "Ctrl+0"; enabled: backend.hasImage; onActivated: imageView.resetZoom() }
    Shortcut { sequence: "Ctrl++"; enabled: backend.hasImage; onActivated: imageView.zoomIn() }
    Shortcut { sequence: "Ctrl+-"; enabled: backend.hasImage; onActivated: imageView.zoomOut() }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ViewerHeader {
            Layout.fillWidth: true
            onOpenRequested: fileActions.openImage()
            onSaveRequested: fileActions.saveImage()
            onSaveAsRequested: fileActions.saveImageAs()
            onSlideshowRequested: slideshowLoader.active = true
        }
        ImageView {
            id: imageView
            Layout.fillWidth: true
            Layout.fillHeight: true
            onOpenRequested: fileActions.openImage()
        }
        EditToolbar {
            Layout.fillWidth: true
            visible: backend.hasImage
            onCropRequested: imageView.startCrop()
        }
        ViewerStatusBar {
            id: statusBar
            Layout.fillWidth: true
            zoomPercent: imageView.zoomPercent
        }
    }

    Loader {
        id: slideshowLoader
        anchors.fill: parent
        active: false
        sourceComponent: SlideshowOverlay { onClosed: slideshowLoader.active = false }
    }
}
