import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 1100
    height: 750
    minimumWidth: 480
    minimumHeight: 360
    visible: true
    title: backend.hasImage ? (backend.currentPath.split("/").pop() + " — Talaia") : "Talaia"
    color: "#1e1e1e"

    FileDialog {
        id: openDialog
        title: "Open Image"
        nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.tga *.gif *.psd *.hdr *.pic *.pnm *.ppm *.pgm)", "All files (*)"]
        onAccepted: backend.openImage(selectedFile)
    }

    FileDialog {
        id: saveDialog
        title: "Save Image As"
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG (*.png)", "JPEG (*.jpg *.jpeg)", "BMP (*.bmp)", "TGA (*.tga)"]
        onAccepted: backend.saveImage(selectedFile)
    }

    Connections {
        target: backend
        function onErrorOccurred(message) {
            errorLabel.text = message
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 4000
        onTriggered: errorLabel.text = ""
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ScrollView {
            id: topBarScroll
            Layout.fillWidth: true
            Layout.preferredHeight: topBarRow.implicitHeight + 16
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOff
            contentWidth: topBarRow.implicitWidth

            Row {
                id: topBarRow
                spacing: 8
                padding: 8

                RoundedButton { text: "Open"; onClicked: openDialog.open() }
                RoundedButton { text: "Save As"; enabled: backend.hasImage; onClicked: saveDialog.open() }
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 24
                    rightPadding: 24
                    text: backend.hasImage ? (backend.imageWidth + " × " + backend.imageHeight) : ""
                    color: "#bbbbbb"
                }
                RoundedButton {
                    text: "Slideshow"
                    enabled: backend.hasImage && backend.folderModel.count > 1
                    onClicked: slideshowLoader.active = true
                }
            }
        }

        ImageView {
            id: imageView
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        EditToolbar {
            Layout.fillWidth: true
            visible: backend.hasImage
        }

        Label {
            id: errorLabel
            Layout.fillWidth: true
            Layout.margins: 4
            color: "#ff8080"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Loader {
        id: slideshowLoader
        anchors.fill: parent
        active: false
        sourceComponent: SlideshowOverlay {
            onClosed: slideshowLoader.active = false
        }
    }
}
