import QtQuick
import ControlCenter

Item {
    id: root
    width: parent ? parent.width : 220
    height: 40

    property string label: ""
    property bool selected: false
    property bool collapsed: false
    default property alias content: iconContainer.data

    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color: root.selected ? Theme.selectedBg : (mouse.containsMouse ? Theme.hoverBg : "transparent")
        Behavior on color { ColorAnimation { duration: 90 } }
    }

    Rectangle {
        x: 0
        y: (parent.height - 18) / 2
        width: 3
        height: 18
        radius: 2
        color: Theme.accent
        opacity: root.selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 14

        Item {
            id: iconContainer
            width: 18
            height: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: 14
            font.family: Theme.fontFamily
            opacity: root.collapsed ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
