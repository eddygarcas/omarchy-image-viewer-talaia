import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

Rectangle {
    id: root
    implicitHeight: 68
    color: Theme.background
    border.color: Theme.border
    border.width: 1

    signal openRequested()
    signal saveRequested()
    signal saveAsRequested()
    signal slideshowRequested()

    readonly property bool compact: width < 760
    readonly property string fileName: backend.hasImage
        ? backend.currentPath.split("/").pop() : qsTr("Talaia")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 80
            spacing: 0

            Label {
                Layout.fillWidth: true
                text: root.fileName
                elide: Text.ElideMiddle
                color: Theme.foreground
                font.pointSize: Theme.titlePointSize
                font.weight: Font.Medium
            }
            Label {
                Layout.fillWidth: true
                text: backend.hasImage
                    ? qsTr("%1 × %2 pixels").arg(backend.imageWidth).arg(backend.imageHeight)
                    : qsTr("Image viewer")
                elide: Text.ElideRight
                color: Theme.muted
                font.pointSize: Theme.captionPointSize
            }
        }

        RoundedButton {
            text: qsTr("Open")
            glyph: "folder-open"
            Accessible.name: qsTr("Open image")
            onClicked: root.openRequested()
        }
        RoundedButton {
            text: root.compact ? "" : qsTr("Save")
            glyph: "save"
            enabled: backend.hasImage
            Accessible.name: qsTr("Save image")
            ToolTip.text: qsTr("Save image")
            ToolTip.visible: hovered && root.compact
            onClicked: root.saveRequested()
        }
        RoundedButton {
            text: root.compact ? "" : qsTr("Save As")
            glyph: "save"
            enabled: backend.hasImage
            Accessible.name: qsTr("Save image as")
            ToolTip.text: qsTr("Save image as")
            ToolTip.visible: hovered && root.compact
            onClicked: root.saveAsRequested()
        }
        RoundedButton {
            text: root.compact ? "" : qsTr("Slideshow")
            glyph: "play"
            enabled: backend.hasImage && backend.folderModel.count > 1
            Accessible.name: qsTr("Start slideshow")
            ToolTip.text: qsTr("Start slideshow")
            ToolTip.visible: hovered && root.compact
            onClicked: root.slideshowRequested()
        }
    }
}
