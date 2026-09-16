import QtQuick
import QtQuick.Shapes

// Compass icon (viewBox 0 0 20 20) used for "Fan Control".
Item {
    id: root
    property color color: "white"
    readonly property real s: root.width / 20
    readonly property real sw: 1.3 * s

    Rectangle {
        width: 8.2 * 2 * root.s
        height: width
        radius: width / 2
        x: (10 * root.s) - width / 2
        y: (10 * root.s) - height / 2
        color: "transparent"
        border.width: root.sw
        border.color: root.color
    }
    Rectangle {
        width: 2 * 2 * root.s
        height: width
        radius: width / 2
        x: (10 * root.s) - width / 2
        y: (10 * root.s) - height / 2
        color: "transparent"
        border.width: root.sw
        border.color: root.color
    }

    Shape {
        width: 20
        height: 20
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.3
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            PathSvg { path: "M10 8V2.2M12 10.6l5.2 2.4M8 10.6L2.8 13" }
        }
    }
}
