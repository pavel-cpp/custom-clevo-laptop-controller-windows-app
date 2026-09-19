import QtQuick
import QtQuick.Shapes

// Battery + leaf icon (viewBox 0 0 48 48) used for "Power Saver".
Item {
    id: root
    property color color: "white"
    readonly property real s: root.width / 48

    Rectangle {
        x: 6 * root.s
        y: 20 * root.s
        width: 28 * root.s
        height: 15 * root.s
        radius: 3 * root.s
        color: "transparent"
        border.width: 2.4 * root.s
        border.color: root.color
    }

    Shape {
        width: 48
        height: 48
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M36 25h2.5a1.5 1.5 0 0 1 0 5H36z" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 2.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M11 24.5v6M15.5 24.5v6M20 24.5v6" }
        }
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M27 19c0-7 5-9 11-9 0 7-4 10-11 9z" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 2
            fillColor: "transparent"
            PathSvg { path: "M27 19c-2-4 0-7 0-7" }
        }
    }
}
