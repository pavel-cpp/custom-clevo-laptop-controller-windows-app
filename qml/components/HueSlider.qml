import QtQuick

Item {
    id: root
    width: 20

    property real hue: 0 // 0-360
    signal changed(real hue)

    Rectangle {
        anchors.fill: parent
        radius: 6
        gradient: Gradient {
            GradientStop { position: 0 / 6; color: "#ff0000" }
            GradientStop { position: 1 / 6; color: "#ffff00" }
            GradientStop { position: 2 / 6; color: "#00ff00" }
            GradientStop { position: 3 / 6; color: "#00ffff" }
            GradientStop { position: 4 / 6; color: "#0000ff" }
            GradientStop { position: 5 / 6; color: "#ff00ff" }
            GradientStop { position: 6 / 6; color: "#ff0000" }
        }
    }

    Rectangle {
        x: -3
        width: parent.width + 6
        height: 4
        radius: 3
        color: "white"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.45)
        y: root.height * (root.hue / 360) - height / 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function apply(my) {
            const p = Math.max(0, Math.min(1, my / root.height))
            root.hue = p * 360
            root.changed(root.hue)
        }

        onPressed: (mouse) => apply(mouse.y)
        onPositionChanged: (mouse) => { if (pressed) apply(mouse.y) }
    }
}
