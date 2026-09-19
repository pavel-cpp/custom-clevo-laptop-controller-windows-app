import QtQuick
import QtQuick.Window

// Invisible hit-areas along the edges/corners of a frameless Window that
// hand off to the native resize (Qt.startSystemResize). Not shown when the
// window is maximized.
Item {
    id: root
    property var window: null
    readonly property int grip: 5
    visible: window && window.visibility !== Window.Maximized

    function resize(edges) {
        if (root.window)
            root.window.startSystemResize(edges)
    }

    MouseArea {
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        height: root.grip
        cursorShape: Qt.SizeVerCursor
        onPressed: root.resize(Qt.TopEdge)
    }
    MouseArea {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: root.grip
        cursorShape: Qt.SizeVerCursor
        onPressed: root.resize(Qt.BottomEdge)
    }
    MouseArea {
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left
        width: root.grip
        cursorShape: Qt.SizeHorCursor
        onPressed: root.resize(Qt.LeftEdge)
    }
    MouseArea {
        anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right
        width: root.grip
        cursorShape: Qt.SizeHorCursor
        onPressed: root.resize(Qt.RightEdge)
    }

    MouseArea {
        anchors.left: parent.left; anchors.top: parent.top
        width: root.grip * 2; height: root.grip * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.resize(Qt.LeftEdge | Qt.TopEdge)
    }
    MouseArea {
        anchors.right: parent.right; anchors.top: parent.top
        width: root.grip * 2; height: root.grip * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.resize(Qt.RightEdge | Qt.TopEdge)
    }
    MouseArea {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        width: root.grip * 2; height: root.grip * 2
        cursorShape: Qt.SizeBDiagCursor
        onPressed: root.resize(Qt.LeftEdge | Qt.BottomEdge)
    }
    MouseArea {
        anchors.right: parent.right; anchors.bottom: parent.bottom
        width: root.grip * 2; height: root.grip * 2
        cursorShape: Qt.SizeFDiagCursor
        onPressed: root.resize(Qt.RightEdge | Qt.BottomEdge)
    }
}
