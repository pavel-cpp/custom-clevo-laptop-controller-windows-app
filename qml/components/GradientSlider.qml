import QtQuick
import ControlCenter

Item {
    id: root
    height: 18

    property real from: 0
    property real to: 1
    property real value: 0
    signal moved(real value)

    readonly property real ratio: (to > from) ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Qt.rgba(1, 1, 1, 0.22)

        Rectangle {
            width: track.width * root.ratio
            height: parent.height
            radius: 2
            color: Theme.accent
        }
    }

    Rectangle {
        width: 18
        height: 18
        radius: 9
        color: "white"
        border.width: 4
        border.color: Theme.accent
        y: (root.height - height) / 2
        x: track.width * root.ratio - width / 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function apply(mx) {
            const p = Math.max(0, Math.min(1, mx / track.width))
            const v = root.from + p * (root.to - root.from)
            root.value = v
            root.moved(v)
        }

        onPressed: (mouse) => apply(mouse.x)
        onPositionChanged: (mouse) => { if (pressed) apply(mouse.x) }
    }
}
