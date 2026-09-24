import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

Rectangle {
    id: root
    implicitHeight: 64
    color: Theme.background
    border.color: Theme.border
    border.width: 1

    signal cropRequested()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        Label {
            text: qsTr("Edit")
            visible: root.width >= 700
            color: Theme.muted
            font.pointSize: Theme.captionPointSize
            font.weight: Font.Medium
            Layout.rightMargin: 8
        }
        RoundedToolButton {
            glyph: "rotate-left"
            Accessible.name: qsTr("Rotate left")
            ToolTip.text: qsTr("Rotate left")
            ToolTip.visible: hovered
            onClicked: backend.rotate(false)
        }
        RoundedToolButton {
            glyph: "rotate-right"
            Accessible.name: qsTr("Rotate right")
            ToolTip.text: qsTr("Rotate right")
            ToolTip.visible: hovered
            onClicked: backend.rotate(true)
        }
        RoundedToolButton {
            glyph: "flip-horizontal"
            Accessible.name: qsTr("Flip horizontal")
            ToolTip.text: qsTr("Flip horizontal")
            ToolTip.visible: hovered
            onClicked: backend.flip(true)
        }
        RoundedToolButton {
            glyph: "flip-vertical"
            Accessible.name: qsTr("Flip vertical")
            ToolTip.text: qsTr("Flip vertical")
            ToolTip.visible: hovered
            onClicked: backend.flip(false)
        }

        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 24; color: Theme.border; Layout.leftMargin: 6; Layout.rightMargin: 6 }

        RoundedToolButton {
            text: root.width < 800 ? "" : qsTr("Crop")
            glyph: "crop"
            Accessible.name: qsTr("Crop image")
            ToolTip.text: qsTr("Crop image")
            ToolTip.visible: hovered && text === ""
            onClicked: root.cropRequested()
        }
        RoundedToolButton {
            text: root.width < 800 ? "" : qsTr("Resize")
            glyph: "scaling"
            Accessible.name: qsTr("Resize image")
            ToolTip.text: qsTr("Resize image")
            ToolTip.visible: hovered && text === ""
            onClicked: resizeDialog.open()
        }
        RoundedToolButton {
            text: root.width < 950 ? "" : qsTr("Adjust")
            glyph: "adjust"
            Accessible.name: qsTr("Adjust color")
            ToolTip.text: qsTr("Adjust color")
            ToolTip.visible: hovered && text === ""
            onClicked: adjustDialog.open()
        }

        Item { Layout.fillWidth: true }

        RoundedToolButton {
            glyph: "undo"
            Accessible.name: qsTr("Undo")
            ToolTip.text: qsTr("Undo")
            ToolTip.visible: hovered
            onClicked: backend.undo()
        }
        RoundedToolButton {
            glyph: "redo"
            Accessible.name: qsTr("Redo")
            ToolTip.text: qsTr("Redo")
            ToolTip.visible: hovered
            onClicked: backend.redo()
        }
        RoundedToolButton {
            text: root.width < 720 ? "" : qsTr("Reset")
            glyph: "reset"
            Accessible.name: qsTr("Reset image")
            ToolTip.text: qsTr("Reset image")
            ToolTip.visible: hovered && text === ""
            onClicked: backend.resetImage()
        }
    }

    ResizeDialog { id: resizeDialog }
    AdjustDialog { id: adjustDialog }
}
