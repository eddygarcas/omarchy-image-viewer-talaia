import QtQuick
import QtQuick.Controls
import ImageViewer

Button {
    id: control

    // Name of a Glyph icon (see Icons.js) to show before the label; "" for none.
    property string glyph: ""

    background: Rectangle {
        implicitWidth: 76
        implicitHeight: 34
        radius: Theme.cornerRadius
        color: control.down ? Theme.surfaceActive : (control.hovered ? Theme.surfaceHover : Theme.surface)
        border.color: Theme.border
        border.width: 1
        opacity: control.enabled ? 1.0 : 0.5
    }

    contentItem: Item {
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Glyph {
                name: control.glyph
                visible: control.glyph !== ""
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.iconSize
                height: Theme.iconSize
                color: control.enabled ? Theme.foreground : Theme.muted
            }
            Text {
                text: control.text
                visible: control.text !== ""
                anchors.verticalCenter: parent.verticalCenter
                color: control.enabled ? Theme.foreground : Theme.muted
                font: control.font
            }
        }
    }
}
