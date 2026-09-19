import QtQuick
import ControlCenter

Item {
    id: root
    width: collapsed ? Theme.navCollapsedWidth : Theme.navExpandedWidth
    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    property bool collapsed: false
    property int currentIndex: 0
    readonly property var labels: ["Performance Modes", "Keyboard Color", "Fan Control", "For Enthusiasts"]

    signal navigate(int index)

    clip: true

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.separator
    }

    Column {
        width: Theme.navExpandedWidth
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 6
        anchors.topMargin: 6
        spacing: 2

        // Hamburger toggle.
        Item {
            width: parent.width - 12
            height: 40

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSm
                color: hamburger.containsMouse ? Theme.hoverBg : "transparent"
                Behavior on color { ColorAnimation { duration: 90 } }
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3.5
                Repeater {
                    model: 3
                    Rectangle { width: 16; height: 1.3; color: Qt.rgba(1, 1, 1, 0.9) }
                }
            }

            MouseArea {
                id: hamburger
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.collapsed = !root.collapsed
            }
        }

        Item { width: 1; height: 8 }

        NavItem {
            label: root.labels[0]
            selected: root.currentIndex === 0
            collapsed: root.collapsed
            onClicked: root.navigate(0)
            IconPerformance { anchors.fill: parent; color: Theme.textPrimary }
        }
        NavItem {
            label: root.labels[1]
            selected: root.currentIndex === 1
            collapsed: root.collapsed
            onClicked: root.navigate(1)
            IconKeyboard { anchors.fill: parent; color: Theme.textPrimary }
        }
        NavItem {
            label: root.labels[2]
            selected: root.currentIndex === 2
            collapsed: root.collapsed
            onClicked: root.navigate(2)
            IconFan { anchors.fill: parent; color: Theme.textPrimary }
        }
        NavItem {
            label: root.labels[3]
            selected: root.currentIndex === 3
            collapsed: root.collapsed
            onClicked: root.navigate(3)
            IconEnthusiasts { anchors.fill: parent; color: Theme.textPrimary }
        }
    }
}
