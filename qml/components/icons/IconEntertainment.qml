import QtQuick
import QtQuick.Shapes

// Speed gauge icon (viewBox 0 0 48 48) used for "Entertainment Mode".
Item {
    id: root
    property color color: "white"

    Shape {
        width: 48
        height: 48
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Qt.rgba(root.color.r, root.color.g, root.color.b, 0.22)
            strokeColor: "transparent"
            PathSvg { path: "M6 32a18 18 0 1 1 36 0z" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 3
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M6 32a18 18 0 0 1 30-13.4" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 3.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M24 32l12-11" }
        }
        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"
            PathSvg { path: "M24 32m-3 0a3 3 0 1 0 6 0a3 3 0 1 0 -6 0" }
        }
    }
}
