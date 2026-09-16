import QtQuick
import QtQuick.Shapes

// Turbo/wings icon (viewBox 0 0 48 48) used for "Full Performance".
Item {
    id: root
    property color color: "white"
    readonly property real s: root.width / 48

    Rectangle {
        x: 13 * root.s
        y: 20 * root.s
        width: 22 * root.s
        height: 12 * root.s
        radius: 2 * root.s
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
            strokeColor: root.color
            strokeWidth: 2.2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M13 20c-4-3-6-7-4-11 3 4 5 2 5 2M35 20c4-3 6-7 4-11-3 4-5 2-5 2M24 20c-2-4-1-8 2-11-1 5 2 6 2 6M13 32c-4 3-6 7-4 11 3-4 5-2 5-2M35 32c4 3 6 7 4 11-3-4-5-2-5-2M24 32c-2 4-1 8 2 11-1-5 2-6 2-6" }
        }
    }
}
