import QtQuick
import QtQuick.Controls

// A link/broken-chain toggle for locking width+height together.
RoundedToolButton {
    id: control
    checkable: true
    checked: true
    glyph: checked ? "link" : "unlink"
    ToolTip.text: checked ? "Width and height are linked" : "Width and height are independent"
    ToolTip.visible: hovered
}
