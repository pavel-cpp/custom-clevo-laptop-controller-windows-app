import QtQuick
import QtQuick.Shapes

// Muted snowflake icon (viewBox 0 0 48 48) used for "Silent Mode".
Item {
    id: root
    property color color: "white"
    readonly property color bladeColor: Qt.rgba(color.r, color.g, color.b, 0.9)

    Shape {
        width: 48
        height: 48
        transformOrigin: Item.TopLeft
        scale: root.width / width
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 2
            fillColor: "transparent"
            PathSvg { path: "M24 24m-17 0a17 17 0 1 0 34 0a17 17 0 1 0 -34 0" }
        }
        // One ShapePath per blade: a filled ShapePath only renders its first
        // subpath, so the four blades cannot share a single path string.
        ShapePath {
            fillColor: root.bladeColor
            strokeColor: "transparent"
            PathSvg { path: "M24 24c0-7 3-11 6-10s2 7-6 10z" }
        }
        ShapePath {
            fillColor: root.bladeColor
            strokeColor: "transparent"
            PathSvg { path: "M24 24c7 0 11 3 10 6s-7 2-10-6z" }
        }
        ShapePath {
            fillColor: root.bladeColor
            strokeColor: "transparent"
            PathSvg { path: "M24 24c0 7-3 11-6 10s-2-7 6-10z" }
        }
        ShapePath {
            fillColor: root.bladeColor
            strokeColor: "transparent"
            PathSvg { path: "M24 24c-7 0-11-3-10-6s7-2 10 6z" }
        }
        ShapePath {
            strokeColor: root.color
            strokeWidth: 2.4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M11 37L37 11" }
        }
    }
}
