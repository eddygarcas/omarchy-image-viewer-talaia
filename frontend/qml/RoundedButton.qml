import QtQuick
import QtQuick.Controls.Basic
import ImageViewer

Button {
    id: control

    // Name of a Glyph icon (see Icons.js) to show before the label; "" for none.
    property string glyph: ""
    activeFocusOnTab: true
    implicitWidth: Math.max(Theme.controlHeight, contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Theme.controlHeight
    leftPadding: 12
    rightPadding: 12
    font.pointSize: Theme.bodyPointSize

    background: Rectangle {
        radius: Theme.cornerRadius
        color: control.down ? Theme.surfaceActive : (control.hovered ? Theme.surfaceHover : Theme.surface)
        border.color: control.activeFocus ? Theme.accent : Theme.border
        border.width: control.activeFocus ? 2 : 1
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
