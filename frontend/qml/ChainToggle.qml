import QtQuick
import QtQuick.Controls

// A link/broken-chain toggle for locking width+height together, drawn from
// two simple rounded-rect "links" since no system icon theme ships a
// linked/unlinked chain glyph.
RoundedToolButton {
    id: control
    checkable: true
    checked: true
    ToolTip.text: checked ? "Width and height are linked" : "Width and height are independent"
    ToolTip.visible: hovered

    readonly property color linkColor: checked ? "#7fb2ff" : "#8a93a6"

    contentItem: Item {
        implicitWidth: 22
        implicitHeight: 22

        Rectangle {
            width: 13; height: 8
            radius: 4
            color: "transparent"
            border.width: 2
            border.color: control.linkColor
            rotation: -35
            anchors.horizontalCenter: parent.horizontalCenter
            y: control.checked ? 5 : 2
            Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
        }
        Rectangle {
            width: 13; height: 8
            radius: 4
            color: "transparent"
            border.width: 2
            border.color: control.linkColor
            rotation: -35
            anchors.horizontalCenter: parent.horizontalCenter
            y: control.checked ? 9 : 12
            Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
        }
    }
}
