import QtQuick
import QtQuick.Controls

Item {
    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
    }

    Image {
        id: img
        anchors.fill: parent
        anchors.margins: 12
        fillMode: Image.PreserveAspectFit
        smooth: true
        cache: false
        asynchronous: true
        source: backend.hasImage ? ("image://backend/current/" + backend.generation) : ""

        BusyIndicator {
            anchors.centerIn: parent
            running: img.status === Image.Loading
        }
    }

    Label {
        anchors.centerIn: parent
        text: "Open an image to get started"
        visible: !backend.hasImage
        color: "#888888"
        font.pixelSize: 18
    }
}
