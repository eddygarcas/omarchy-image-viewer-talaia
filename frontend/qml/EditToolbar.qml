import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: toolRow.implicitHeight + 16

    function resetSliders() {
        brightnessSlider.value = 0
        contrastSlider.value = 0
        saturationSlider.value = 1.0
    }

    Connections {
        target: backend
        // Every committed op (geometric or Apply) resets adjustments to
        // neutral on the backend side; keep the sliders in sync.
        function onImageChanged() { root.resetSliders() }
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        contentWidth: toolRow.implicitWidth

        Row {
            id: toolRow
            spacing: 6
            padding: 8

            RoundedToolButton { icon.name: "object-rotate-left-symbolic"; ToolTip.text: "Rotate left"; ToolTip.visible: hovered; onClicked: backend.rotate(false) }
            RoundedToolButton { icon.name: "object-rotate-right-symbolic"; ToolTip.text: "Rotate right"; ToolTip.visible: hovered; onClicked: backend.rotate(true) }
            RoundedToolButton { icon.name: "object-flip-horizontal-symbolic"; ToolTip.text: "Flip horizontal"; ToolTip.visible: hovered; onClicked: backend.flip(true) }
            RoundedToolButton { icon.name: "object-flip-vertical-symbolic"; ToolTip.text: "Flip vertical"; ToolTip.visible: hovered; onClicked: backend.flip(false) }

            ToolSeparator {}

            RoundedToolButton { text: "Crop"; onClicked: cropDialog.open() }
            RoundedToolButton { text: "Resize"; onClicked: resizeDialog.open() }

            ToolSeparator {}

            Label { anchors.verticalCenter: parent.verticalCenter; text: "B" }
            Slider {
                id: brightnessSlider
                anchors.verticalCenter: parent.verticalCenter
                from: -100; to: 100; value: 0
                width: 90
                onMoved: backend.adjust(value, contrastSlider.value, saturationSlider.value)
            }
            Label { anchors.verticalCenter: parent.verticalCenter; text: "C" }
            Slider {
                id: contrastSlider
                anchors.verticalCenter: parent.verticalCenter
                from: -100; to: 100; value: 0
                width: 90
                onMoved: backend.adjust(brightnessSlider.value, value, saturationSlider.value)
            }
            Label { anchors.verticalCenter: parent.verticalCenter; text: "S" }
            Slider {
                id: saturationSlider
                anchors.verticalCenter: parent.verticalCenter
                from: 0; to: 2; value: 1
                width: 90
                onMoved: backend.adjust(brightnessSlider.value, contrastSlider.value, value)
            }
            RoundedToolButton { text: "Apply"; ToolTip.text: "Bake in the color adjustment"; ToolTip.visible: hovered; onClicked: backend.commitAdjust() }

            ToolSeparator {}

            RoundedToolButton { icon.name: "edit-undo-symbolic"; ToolTip.text: "Undo"; ToolTip.visible: hovered; onClicked: backend.undo() }
            RoundedToolButton { icon.name: "edit-redo-symbolic"; ToolTip.text: "Redo"; ToolTip.visible: hovered; onClicked: backend.redo() }
            RoundedToolButton { text: "Reset"; ToolTip.text: "Revert to the originally opened image"; ToolTip.visible: hovered; onClicked: backend.resetImage() }
        }
    }

    Dialog {
        id: cropDialog
        title: "Crop"
        modal: true
        anchors.centerIn: Overlay.overlay
        onAboutToShow: {
            xSpin.value = 0
            ySpin.value = 0
            wSpin.value = backend.imageWidth
            hSpin.value = backend.imageHeight
        }
        onAccepted: backend.crop(xSpin.value, ySpin.value, wSpin.value, hSpin.value)

        GridLayout {
            columns: 2
            Label { text: "X" }
            SpinBox { id: xSpin; from: 0; to: Math.max(0, backend.imageWidth - 1) }
            Label { text: "Y" }
            SpinBox { id: ySpin; from: 0; to: Math.max(0, backend.imageHeight - 1) }
            Label { text: "Width" }
            SpinBox { id: wSpin; from: 1; to: Math.max(1, backend.imageWidth) }
            Label { text: "Height" }
            SpinBox { id: hSpin; from: 1; to: Math.max(1, backend.imageHeight) }
        }

        footer: DialogButtonBox {
            RoundedButton { text: "Cancel"; DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
            RoundedButton { text: "OK"; DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole }
        }
    }

    Dialog {
        id: resizeDialog
        title: "Resize"
        modal: true
        anchors.centerIn: Overlay.overlay
        onAboutToShow: {
            rwSpin.value = backend.imageWidth
            rhSpin.value = backend.imageHeight
        }
        onAccepted: backend.resizeImage(rwSpin.value, rhSpin.value)

        GridLayout {
            columns: 2
            Label { text: "Width" }
            SpinBox { id: rwSpin; from: 1; to: 20000 }
            Label { text: "Height" }
            SpinBox { id: rhSpin; from: 1; to: 20000 }
        }

        footer: DialogButtonBox {
            RoundedButton { text: "Cancel"; DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
            RoundedButton { text: "OK"; DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole }
        }
    }
}
