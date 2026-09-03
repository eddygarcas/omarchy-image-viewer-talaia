import QtQuick
import QtQuick.Controls

Button {
    id: control

    background: Rectangle {
        implicitWidth: 76
        implicitHeight: 34
        radius: 8
        color: control.down ? "#3a4150" : (control.hovered ? "#343b48" : "#2a303c")
        border.color: "#4a5261"
        border.width: 1
        opacity: control.enabled ? 1.0 : 0.5
    }
}
