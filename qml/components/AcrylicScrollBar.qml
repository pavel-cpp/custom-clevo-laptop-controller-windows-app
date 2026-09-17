import QtQuick
import QtQuick.Controls.Basic
import ControlCenter

// Windows 11 style overlay scroll bar: a thin translucent thumb that widens
// under the pointer and fades out while the content is idle.
ScrollBar {
    id: root
    policy: ScrollBar.AsNeeded
    minimumSize: 0.08
    implicitWidth: 14
    padding: 4

    readonly property bool expanded: hovered || pressed

    background: Item {}

    contentItem: Item {
        implicitWidth: 6
        implicitHeight: 40
        opacity: root.active || root.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: root.expanded ? 6 : 3
            radius: width / 2
            color: Qt.rgba(1, 1, 1, root.pressed ? 0.55 : root.expanded ? 0.42 : 0.3)
            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }
}
