import QtQuick
import ControlCenter

Item {
    id: root

    property real hue: 0          // 0-360
    property real saturation: 50  // 0-100
    property real value: 50       // 0-100
    signal changed(real saturation, real value)

    readonly property color hueColor: Qt.hsva(hue / 360, 1, 1, 1)

    Rectangle {
        anchors.fill: parent
        radius: 6
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: root.hueColor }
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: 6
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    Item {
        x: root.width * (root.saturation / 100) - width / 2
        y: root.height * (1 - root.value / 100) - height / 2
        width: 14
        height: 14

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.5)
        }
        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: 6
            color: "transparent"
            border.width: 2
            border.color: "white"
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor

        function apply(mx, my) {
            const s = Math.max(0, Math.min(1, mx / root.width))
            const v = 1 - Math.max(0, Math.min(1, my / root.height))
            root.saturation = s * 100
            root.value = v * 100
            root.changed(root.saturation, root.value)
        }

        onPressed: (mouse) => apply(mouse.x, mouse.y)
        onPositionChanged: (mouse) => { if (pressed) apply(mouse.x, mouse.y) }
    }
}
