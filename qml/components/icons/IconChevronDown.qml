import QtQuick
import QtQuick.Shapes

// Dropdown chevron (viewBox 0 0 10 6).
Item {
    id: root
    property color color: "white"

    Shape {
        width: 10
        height: 6
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: "M1 1l4 4 4-4" }
        }
    }
}
