import QtQuick
import QtQuick.Shapes
import ControlCenter

// Editable temperature/fan-speed curve. `points` is a JS array of
// {t: 0-100, f: 0-100} sorted by t ascending; dragging a handle keeps a
// minimum 3-unit temperature gap from its neighbours, mirroring the
// original design's curve editor.
Item {
    id: root

    property var points: []
    property int dragIndex: -1

    readonly property real plotLeft: 10
    readonly property real plotTop: 10
    readonly property real plotWidth: Math.max(1, width - 20)
    readonly property real plotHeight: Math.max(1, height - 20)

    function px(t) { return root.plotLeft + (t / 100) * root.plotWidth }
    function py(f) { return root.plotTop + (1 - f / 100) * root.plotHeight }

    function polylinePath() {
        if (!points || points.length === 0)
            return ""
        var d = "M" + px(points[0].t) + " " + py(points[0].f)
        for (var i = 1; i < points.length; i++)
            d += " L" + px(points[i].t) + " " + py(points[i].f)
        return d
    }

    function areaPath() {
        if (!points || points.length === 0)
            return ""
        var bottom = root.plotTop + root.plotHeight
        var d = "M" + root.plotLeft + " " + bottom
        for (var i = 0; i < points.length; i++)
            d += " L" + px(points[i].t) + " " + py(points[i].f)
        d += " L" + (root.plotLeft + root.plotWidth) + " " + bottom + " Z"
        return d
    }

    function updateDrag(mx, my) {
        const i = root.dragIndex
        if (i < 0 || !points || i >= points.length)
            return
        const next = points.map((p) => ({ t: p.t, f: p.f }))
        const lo = i > 0 ? next[i - 1] : null
        const hi = i < next.length - 1 ? next[i + 1] : null

        let t = Math.round(((mx - plotLeft) / plotWidth) * 100)
        let f = Math.round((1 - (my - plotTop) / plotHeight) * 100)
        t = Math.max(lo ? lo.t + 3 : 0, Math.min(hi ? hi.t - 3 : 100, t))
        f = Math.max(0, Math.min(100, f))

        next[i].t = t
        next[i].f = f
        root.points = next
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
    }

    // Grid: 3 horizontal + 3 vertical divider lines within the inset plot area.
    Repeater {
        model: [0.25, 0.5, 0.75]
        Rectangle {
            x: root.plotLeft
            y: root.plotTop + root.plotHeight * modelData
            width: root.plotWidth
            height: 1
            color: Qt.rgba(1, 1, 1, 0.09)
        }
    }
    Repeater {
        model: [0.25, 0.5, 0.75]
        Rectangle {
            x: root.plotLeft + root.plotWidth * modelData
            y: root.plotTop
            width: 1
            height: root.plotHeight
            color: Qt.rgba(1, 1, 1, 0.09)
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: Qt.rgba(0.298, 0.761, 1, 0.14)
            strokeColor: "transparent"
            PathSvg { path: root.areaPath() }
        }
        ShapePath {
            strokeColor: Theme.accent
            strokeWidth: 2
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            PathSvg { path: root.polylinePath() }
        }
    }

    Repeater {
        model: root.points
        delegate: Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "white"
            border.width: 4
            border.color: Theme.accent
            x: root.px(modelData.t) - width / 2
            y: root.py(modelData.f) - height / 2
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.dragIndex >= 0 ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        onPressed: (mouse) => {
            let bestIndex = -1
            let bestDist = 14
            for (let i = 0; i < root.points.length; i++) {
                const dx = mouse.x - root.px(root.points[i].t)
                const dy = mouse.y - root.py(root.points[i].f)
                const dist = Math.sqrt(dx * dx + dy * dy)
                if (dist < bestDist) {
                    bestDist = dist
                    bestIndex = i
                }
            }
            root.dragIndex = bestIndex
        }
        onPositionChanged: (mouse) => {
            if (root.dragIndex >= 0)
                root.updateDrag(mouse.x, mouse.y)
        }
        onReleased: root.dragIndex = -1
    }
}
