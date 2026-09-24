import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ImageViewer

Dialog {
    id: root
    title: qsTr("Resize image")
    modal: true
    anchors.centerIn: Overlay.overlay
    property real aspect: 1

    onAboutToShow: {
        widthSpin.value = backend.imageWidth
        heightSpin.value = backend.imageHeight
        aspect = backend.imageHeight > 0 ? backend.imageWidth / backend.imageHeight : 1
        chainToggle.checked = true
    }
    onAccepted: backend.resizeImage(widthSpin.value, heightSpin.value)

    GridLayout {
        columns: 3
        rowSpacing: 12
        columnSpacing: 12

        Label { text: qsTr("Width (px)"); font.pointSize: Theme.bodyPointSize }
        SpinBox {
            id: widthSpin
            from: 1
            to: 20000
            Accessible.name: qsTr("Width in pixels")
            onValueModified: {
                if (chainToggle.checked)
                    heightSpin.value = Math.max(1, Math.round(value / root.aspect))
            }
        }
        ChainToggle {
            id: chainToggle
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignVCenter
        }
        Label { text: qsTr("Height (px)"); font.pointSize: Theme.bodyPointSize }
        SpinBox {
            id: heightSpin
            from: 1
            to: 20000
            Accessible.name: qsTr("Height in pixels")
            onValueModified: {
                if (chainToggle.checked)
                    widthSpin.value = Math.max(1, Math.round(value * root.aspect))
            }
        }
    }

    footer: DialogButtonBox {
        RoundedButton { text: qsTr("Cancel"); DialogButtonBox.buttonRole: DialogButtonBox.RejectRole }
        RoundedButton { text: qsTr("Resize"); DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole }
    }
}
