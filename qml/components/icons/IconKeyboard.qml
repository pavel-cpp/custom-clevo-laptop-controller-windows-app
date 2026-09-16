import QtQuick

// Keyboard icon (viewBox 0 0 20 20) used for "Keyboard Color".
Item {
    id: root
    property color color: "white"
    readonly property real s: root.width / 20
    readonly property real sw: 1.3 * s

    Rectangle {
        x: 1.5 * root.s
        y: 5.5 * root.s
        width: 17 * root.s
        height: 11 * root.s
        radius: 2 * root.s
        color: "transparent"
        border.width: root.sw
        border.color: root.color
    }

    // M5 9h1.5
    Rectangle {
        x: 5 * root.s; y: 9 * root.s - height / 2
        width: 1.5 * root.s; height: root.sw; radius: height / 2
        color: root.color
    }
    // M8.5 9H10
    Rectangle {
        x: 8.5 * root.s; y: 9 * root.s - height / 2
        width: 1.5 * root.s; height: root.sw; radius: height / 2
        color: root.color
    }
    // M12 9h1.5
    Rectangle {
        x: 12 * root.s; y: 9 * root.s - height / 2
        width: 1.5 * root.s; height: root.sw; radius: height / 2
        color: root.color
    }
    // M5 12.5h9
    Rectangle {
        x: 5 * root.s; y: 12.5 * root.s - height / 2
        width: 9 * root.s; height: root.sw; radius: height / 2
        color: root.color
    }
}
