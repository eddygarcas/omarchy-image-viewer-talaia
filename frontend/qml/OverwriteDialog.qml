import QtQuick
import QtQuick.Controls
import ImageViewer

Dialog {
    id: root
    title: qsTr("Overwrite original image?")
    modal: true
    anchors.centerIn: Overlay.overlay
    onAccepted: backend.saveImage(backend.currentPath)

    Label {
        width: Math.min(360, Overlay.overlay ? Overlay.overlay.width - 64 : 360)
        wrapMode: Text.WordWrap
        font.pointSize: Theme.bodyPointSize
        text: qsTr("Save changes to “%1”? This replaces the original file.")
            .arg(backend.hasImage ? backend.currentPath.split("/").pop() : "")
    }
    footer: DialogButtonBox {
        RoundedButton { text: qsTr("Cancel"); DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
        RoundedButton { text: qsTr("Overwrite"); DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole }
    }
}
