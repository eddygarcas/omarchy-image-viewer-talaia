import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

Dialog {
    id: root
    title: qsTr("Adjust color")
    modal: true
    anchors.centerIn: Overlay.overlay
    width: Math.min(380, parent ? parent.width - 32 : 380)
    property bool applied: false

    function preview() {
        backend.adjust(brightnessSlider.value, contrastSlider.value, saturationSlider.value)
    }

    onAboutToShow: {
        applied = false
        brightnessSlider.value = 0
        contrastSlider.value = 0
        saturationSlider.value = 1
    }
    onAccepted: {
        applied = true
        backend.commitAdjust()
    }
    onClosed: {
        if (!applied)
            backend.adjust(0, 0, 1)
    }

    ColumnLayout {
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: qsTr("Preview changes, then apply them to the image.")
            wrapMode: Text.WordWrap
            color: Theme.muted
            font.pointSize: Theme.bodyPointSize
        }

        Label { text: qsTr("Brightness"); font.pointSize: Theme.bodyPointSize }
        Slider {
            id: brightnessSlider
            Layout.fillWidth: true
            from: -100
            to: 100
            value: 0
            Accessible.name: qsTr("Brightness")
            onMoved: root.preview()
        }

        Label { text: qsTr("Contrast"); font.pointSize: Theme.bodyPointSize }
        Slider {
            id: contrastSlider
            Layout.fillWidth: true
            from: -100
            to: 100
            value: 0
            Accessible.name: qsTr("Contrast")
            onMoved: root.preview()
        }

        Label { text: qsTr("Saturation"); font.pointSize: Theme.bodyPointSize }
        Slider {
            id: saturationSlider
            Layout.fillWidth: true
            from: 0
            to: 2
            value: 1
            Accessible.name: qsTr("Saturation")
            onMoved: root.preview()
        }
    }

    footer: DialogButtonBox {
        RoundedButton { text: qsTr("Cancel"); DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
        RoundedButton { text: qsTr("Apply"); DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole }
    }
}
