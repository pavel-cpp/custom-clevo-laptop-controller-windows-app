import QtQuick

// Three dots icon (viewBox 0 0 20 20) used for "For Enthusiasts".
Item {
    id: root
    property color color: "white"
    readonly property real s: root.width / 20
    readonly property real r: 1.5 * root.s

    Repeater {
        model: [4, 10, 16]
        Rectangle {
            width: root.r * 2
            height: width
            radius: width / 2
            color: root.color
            x: modelData * root.s - width / 2
            y: 10 * root.s - height / 2
        }
    }
}
