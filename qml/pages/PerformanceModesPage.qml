import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    property int mode: 1
    readonly property var modeDescriptions: [
        qsTr("Fan speed and processor power stay low; suited to a quiet working environment."),
        qsTr("Performance is sacrificed to reduce battery drain, which extends run time."),
        qsTr("A balanced profile between power, heat and noise for gaming and media."),
        qsTr("CPU and GPU run at their highest power limit; fan noise and heat increase.")
    ]

    Column {
        id: content
        width: parent.width
        spacing: 0

        Text {
            text: qsTr("Performance Modes")
            color: Theme.textPrimary
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.family: Theme.fontFamily
        }
        Text {
            text: qsTr("Switch the balance of power, heat and noise in a single tap.")
            color: Theme.textSecondary
            font.pixelSize: 13
            font.family: Theme.fontFamily
            topPadding: 6
        }

        Item { width: 1; height: 24 }

        Grid {
            id: cardGrid
            width: parent.width
            columns: 4
            columnSpacing: 14
            rowSpacing: 14
            readonly property real cardWidth: (width - columnSpacing * (columns - 1)) / columns

            ModeCard {
                width: cardGrid.cardWidth
                title: qsTr("Silent Mode")
                subtitle: qsTr("≤ 30 dB · Low fan speed")
                selected: root.mode === 0
                onClicked: root.mode = 0
                IconSilent { anchors.centerIn: parent; width: 76; height: 76; color: Theme.accent }
            }
            ModeCard {
                width: cardGrid.cardWidth
                title: qsTr("Power Saver")
                subtitle: qsTr("Longer battery life")
                selected: root.mode === 1
                onClicked: root.mode = 1
                IconPowerSaver { anchors.centerIn: parent; width: 80; height: 80; color: Theme.accent }
            }
            ModeCard {
                width: cardGrid.cardWidth
                title: qsTr("Entertainment Mode")
                subtitle: qsTr("Balanced gaming profile")
                selected: root.mode === 2
                onClicked: root.mode = 2
                IconEntertainment { anchors.centerIn: parent; width: 84; height: 84; color: Theme.accent }
            }
            ModeCard {
                width: cardGrid.cardWidth
                title: qsTr("Full Performance")
                subtitle: qsTr("Maximum power limit")
                selected: root.mode === 3
                onClicked: root.mode = 3
                IconFullPerformance { anchors.centerIn: parent; width: 84; height: 84; color: Theme.accent }
            }
        }

        Item { width: 1; height: 22 }

        Rectangle {
            width: parent.width
            height: descColumn.implicitHeight + 36
            radius: Theme.radius
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Theme.panelBorder2

            Column {
                id: descColumn
                x: 20; y: 18
                width: parent.width - 40
                spacing: 6

                Text {
                    text: qsTr("Description")
                    color: Theme.textPrimary
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    font.family: Theme.fontFamily
                }
                Text {
                    width: parent.width
                    text: root.modeDescriptions[root.mode]
                    color: Theme.textDim
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                }
            }
        }
    }
}
