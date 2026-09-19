import QtQuick
import QtQuick.Window
import ControlCenter

Item {
    id: root
    height: 46
    property var window: null

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.separator
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        Image {
            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            source: "../../resources/app_icon.svg"
            sourceSize: Qt.size(54, 54)
            smooth: true
            mipmap: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Control Center")
            color: Qt.rgba(1, 1, 1, 0.82)
            font.pixelSize: 12
            font.family: Theme.fontFamily
        }
    }

    // Draggable region: the whole title bar minus the caption-button cluster.
    MouseArea {
        anchors.left: parent.left
        anchors.right: buttons.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        acceptedButtons: Qt.LeftButton
        onPressed: (mouse) => {
            if (root.window)
                root.window.startSystemMove()
        }
        onDoubleClicked: root.toggleMaximize()
    }

    function toggleMaximize() {
        if (!root.window)
            return
        root.window.visibility = (root.window.visibility === Window.Maximized)
            ? Window.Windowed
            : Window.Maximized
    }

    Row {
        id: buttons
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height

        CaptionButton {
            height: parent.height
            kind: "minimize"
            onClicked: if (root.window) root.window.showMinimized()
        }
        CaptionButton {
            height: parent.height
            kind: root.window && root.window.visibility === Window.Maximized ? "restore" : "maximize"
            onClicked: root.toggleMaximize()
        }
        CaptionButton {
            height: parent.height
            kind: "close"
            isClose: true
            onClicked: if (root.window) root.window.close()
        }
    }
}
