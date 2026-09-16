import QtQuick
import ControlCenter

Item {
    id: root
    width: 40
    height: 20

    property bool checked: false
    signal toggled(bool checked)

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.accent : Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        border.color: root.checked ? Theme.accent : Qt.rgba(1, 1, 1, 0.45)
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        width: 14
        height: 14
        radius: 7
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? "white" : Qt.rgba(1, 1, 1, 0.75)
        Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
