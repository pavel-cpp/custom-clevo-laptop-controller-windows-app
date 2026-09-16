import QtQuick
import ControlCenter

// One of the three Windows caption buttons (minimize / maximize / close).
Item {
    id: root
    width: 46
    height: 46

    property string kind: "minimize" // "minimize" | "maximize" | "restore" | "close"
    property bool isClose: false

    signal clicked()

    readonly property color iconColor: mouse.containsMouse ? Theme.textPrimary : Qt.rgba(1, 1, 1, 0.85)

    Rectangle {
        anchors.fill: parent
        color: mouse.containsMouse ? (root.isClose ? Theme.closeHover : Theme.hoverBg) : "transparent"
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    // Minimize: a single horizontal line.
    Rectangle {
        visible: root.kind === "minimize"
        anchors.centerIn: parent
        width: 11
        height: 1
        color: root.iconColor
    }

    // Maximize: a square outline.
    Rectangle {
        visible: root.kind === "maximize"
        anchors.centerIn: parent
        width: 11
        height: 11
        color: "transparent"
        border.width: 1
        border.color: root.iconColor
    }

    // Restore: two overlapping square outlines.
    Item {
        visible: root.kind === "restore"
        anchors.centerIn: parent
        width: 11
        height: 11
        Rectangle {
            x: 2; y: 0; width: 9; height: 9
            color: "transparent"; border.width: 1; border.color: root.iconColor
        }
        Rectangle {
            x: 0; y: 2; width: 9; height: 9
            color: "transparent"; border.width: 1; border.color: root.iconColor
        }
    }

    // Close: an X made from two rotated lines.
    Item {
        visible: root.kind === "close"
        anchors.centerIn: parent
        width: 14
        height: 14
        Rectangle {
            anchors.centerIn: parent
            width: 14; height: 1; color: root.iconColor; rotation: 45
        }
        Rectangle {
            anchors.centerIn: parent
            width: 14; height: 1; color: root.iconColor; rotation: -45
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
