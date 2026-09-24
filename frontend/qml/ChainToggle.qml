import QtQuick
import QtQuick.Controls

// A link/broken-chain toggle for locking width+height together.
RoundedToolButton {
    id: control
    checkable: true
    checked: true
    glyph: checked ? "link" : "unlink"
    Accessible.name: checked ? qsTr("Keep aspect ratio") : qsTr("Change width and height independently")
    ToolTip.text: checked ? qsTr("Width and height are linked") : qsTr("Width and height are independent")
    ToolTip.visible: hovered
}
