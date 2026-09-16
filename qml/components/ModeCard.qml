import QtQuick
import ControlCenter

Item {
    id: root
    height: 250

    property string title: ""
    property string subtitle: ""
    property bool selected: false
    default property alias iconContent: iconArea.data

    signal clicked()

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: mouse.containsMouse ? Theme.panelBgHover : Theme.panelBg
        border.width: 1
        border.color: Theme.panelBorder
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: "transparent"
        border.width: 1.5
        border.color: Theme.accent
        opacity: root.selected ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 0

        Item {
            id: iconArea
            width: parent.width
            height: parent.height - titleText.height - subtitleText.height - 3
        }

        Text {
            id: titleText
            width: parent.width
            text: root.title
            color: Theme.textPrimary
            font.pixelSize: 15
            font.weight: Font.DemiBold
            font.family: Theme.fontFamily
        }
        Text {
            id: subtitleText
            width: parent.width
            text: root.subtitle
            color: Theme.textMuted
            font.pixelSize: 12
            font.family: Theme.fontFamily
            topPadding: 3
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
