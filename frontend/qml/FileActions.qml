import QtQuick
import QtQuick.Dialogs

Item {
    id: root

    function openImage() { openDialog.open() }
    function saveImage() { overwriteDialog.open() }
    function saveImageAs() { saveDialog.open() }

    FileDialog {
        id: openDialog
        title: qsTr("Open image")
        nameFilters: [qsTr("Images (*.png *.jpg *.jpeg *.bmp *.tga *.gif *.psd *.hdr *.pic *.pnm *.ppm *.pgm)"), qsTr("All files (*)")]
        onAccepted: backend.openImage(selectedFile)
    }
    FileDialog {
        id: saveDialog
        title: qsTr("Save image as")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("PNG (*.png)"), qsTr("JPEG (*.jpg *.jpeg)"), qsTr("BMP (*.bmp)"), qsTr("TGA (*.tga)")]
        onAccepted: backend.saveImage(selectedFile)
    }
    OverwriteDialog { id: overwriteDialog }
}
