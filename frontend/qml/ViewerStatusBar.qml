import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

Rectangle {
    id: root
    implicitHeight: 32
    color: Theme.background

    property string errorMessage: ""
    property int zoomPercent: 100

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 8

        Label {
            Layout.fillWidth: true
            elide: Text.ElideRight
            color: text ? Theme.error : Theme.muted
            text: root.errorMessage
            font.pointSize: Theme.captionPointSize
            Accessible.role: Accessible.AlertMessage
        }
        Label {
            visible: backend.hasImage && !root.errorMessage
            text: qsTr("%1 of %2").arg(backend.folderModel.currentIndex + 1).arg(backend.folderModel.count)
            color: Theme.muted
            font.pointSize: Theme.captionPointSize
        }
        Label {
            visible: backend.hasImage
            text: qsTr("%1% · Ctrl+scroll to zoom").arg(root.zoomPercent)
            color: Theme.muted
            font.pointSize: Theme.captionPointSize
        }
    }
}
