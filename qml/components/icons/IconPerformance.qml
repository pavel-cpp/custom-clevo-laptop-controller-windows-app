import QtQuick
import QtQuick.Shapes

// Gauge/speedometer icon (viewBox 0 0 20 20) used for "Performance Modes".
Item {
    id: root
    property color color: "white"

    Shape {
        id: shape
        width: 20
        height: 20
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M2.5 14a8 8 0 1 1 15 0" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.6
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M10 14l4.5-5" }
        }
    }

    Rectangle {
        width: 1.6 * 2 * (root.width / 20)
        height: width
        radius: width / 2
        color: root.color
        x: (10 - 1.6) * (root.width / 20)
        y: (14 - 1.6) * (root.width / 20)
    }
}
