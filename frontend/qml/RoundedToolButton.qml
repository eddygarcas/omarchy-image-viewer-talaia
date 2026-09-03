import QtQuick
import QtQuick.Controls

ToolButton {
    id: control

    background: Rectangle {
        implicitWidth: 34
        implicitHeight: 34
        radius: 8
        color: control.down ? "#3a4150" : (control.hovered ? "#343b48" : "transparent")
        border.color: (control.hovered || control.down) ? "#4a5261" : "transparent"
        border.width: 1
        opacity: control.enabled ? 1.0 : 0.5
    }
}
