import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    property int fanMode: 0
    property real balance: 0 // -10..10

    readonly property var fanModeData: [
        { name: qsTr("Automatic"), note: qsTr("Everyday use"), desc: qsTr("Fan speed is adjusted automatically; intended for everyday use.") },
        { name: qsTr("Maximum Fan Speed"), note: qsTr("Full speed"), desc: qsTr("Fans run at maximum speed continuously: lowest temperature, highest noise.") },
        { name: qsTr("MaxQ"), note: qsTr("If supported"), desc: qsTr("Fan speed is capped, the system stays quiet and the power limit is lowered.") },
        { name: qsTr("Anti-Dust"), note: qsTr("If supported"), desc: qsTr("Fans spin in reverse to blow dust out of the heatsink.") },
        { name: qsTr("Custom Curve"), note: qsTr("Manual"), desc: qsTr("You set the temperature and fan speed thresholds yourself.") }
    ]

    component AxisNumbers: Column {
        width: 16
        height: parent ? parent.height : 196
        Repeater {
            model: ["100", "75", "50", "25", "0"]
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                text: modelData
                color: Theme.textFaint
                font.pixelSize: 10
                font.family: Theme.fontFamily
                height: 196 / 5
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Column {
        id: content
        width: parent.width
        spacing: 0

        Text {
            text: qsTr("Fan Control")
            color: Theme.textPrimary
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.family: Theme.fontFamily
        }
        Text {
            text: qsTr("Pick a profile or tune the curve manually.")
            color: Theme.textSecondary
            font.pixelSize: 13
            font.family: Theme.fontFamily
            topPadding: 6
        }

        Item { width: 1; height: 22 }

        Grid {
            id: modeGrid
            width: parent.width
            columns: 5
            columnSpacing: 10
            readonly property real cardWidth: (width - columnSpacing * (columns - 1)) / columns

            Repeater {
                model: root.fanModeData
                delegate: Rectangle {
                    width: modeGrid.cardWidth
                    height: 84
                    radius: Theme.radius
                    color: index === root.fanMode ? Theme.selectedBg : Theme.panelBg
                    border.width: 1
                    border.color: index === root.fanMode ? Theme.accent : Theme.panelBorder

                    Column {
                        x: 14; y: 12
                        width: parent.width - 28
                        spacing: 3
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 12
                        Text {
                            width: parent.width
                            text: modelData.name
                            color: Theme.textPrimary
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            width: parent.width
                            text: modelData.note
                            color: Theme.textMuted
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.fanMode = index
                    }
                }
            }
        }

        Item { width: 1; height: 18 }

        Rectangle {
            width: parent.width
            height: 52
            radius: Theme.radius
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Theme.panelBorder2

            Row {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 16

                Text {
                    width: 64
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Balance")
                    color: Theme.textPrimary
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    font.family: Theme.fontFamily
                }
                GradientSlider {
                    width: parent.width - 64 - 40 - 32
                    anchors.verticalCenter: parent.verticalCenter
                    from: -10; to: 10
                    value: root.balance
                    onMoved: (v) => root.balance = Math.round(v)
                }
                Text {
                    width: 40
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: root.balance
                    color: Theme.textPrimary
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                }
            }
        }

        Item { width: 1; height: 16 }

        Grid {
            width: parent.width
            columns: 2
            columnSpacing: 16
            rowSpacing: 16
            readonly property real colWidth: (width - columnSpacing) / columns

            Rectangle {
                width: parent.colWidth
                height: fanCol1.implicitHeight + 36
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: fanCol1
                    x: 18; y: 18
                    width: parent.width - 36
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 20
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                               text: qsTr("CPU"); color: Theme.textPrimary; font.pixelSize: 17; font.weight: Font.DemiBold; font.family: Theme.fontFamily }
                        Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                               text: "2540 RPM · 35% · 52°C"; color: Theme.textDim; font.pixelSize: 13; font.family: Theme.fontFamily }
                    }

                    Row {
                        width: parent.width
                        spacing: 8
                        Item {
                            width: 16; height: 196
                            Text {
                                anchors.centerIn: parent
                                rotation: -90
                                text: qsTr("Fan Speed (%)")
                                color: Theme.textDim
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                            }
                        }
                        AxisNumbers {}
                        Column {
                            width: parent.width - 16 - 16 - 16
                            spacing: 6
                            FanCurveChart {
                                id: cpuChart
                                width: parent.width
                                height: 196
                                points: [ { t: 40, f: 35 }, { t: 60, f: 80 }, { t: 80, f: 99 }, { t: 100, f: 100 } ]
                            }
                            Row {
                                width: parent.width
                                Repeater {
                                    model: ["0", "25", "50", "75", "100 °C"]
                                    Text {
                                        width: parent.width / 5
                                        horizontalAlignment: index === 4 ? Text.AlignRight : Text.AlignLeft
                                        text: modelData
                                        color: Theme.textFaint
                                        font.pixelSize: 10
                                        font.family: Theme.fontFamily
                                    }
                                }
                            }
                            Row {
                                width: parent.width
                                spacing: 6
                                Repeater {
                                    model: cpuChart.points
                                    delegate: Rectangle {
                                        width: (parent.width - 6 * 3) / 4
                                        height: 28
                                        radius: Theme.radiusSm
                                        color: Theme.fieldBg
                                        border.width: 1
                                        border.color: Theme.fieldBorder
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.t + "° · " + modelData.f + "%"
                                            color: Theme.textPrimary
                                            font.pixelSize: 12
                                            font.family: Theme.fontFamily
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.colWidth
                height: fanCol2.implicitHeight + 36
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: fanCol2
                    x: 18; y: 18
                    width: parent.width - 36
                    spacing: 16

                    Item {
                        width: parent.width
                        height: 20
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                               text: qsTr("GPU"); color: Theme.textPrimary; font.pixelSize: 17; font.weight: Font.DemiBold; font.family: Theme.fontFamily }
                        Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                               text: "0 RPM · 0% · 20°C"; color: Theme.textDim; font.pixelSize: 13; font.family: Theme.fontFamily }
                    }

                    Row {
                        width: parent.width
                        spacing: 8
                        Item {
                            width: 16; height: 196
                            Text {
                                anchors.centerIn: parent
                                rotation: -90
                                text: qsTr("Fan Speed (%)")
                                color: Theme.textDim
                                font.pixelSize: 10
                                font.family: Theme.fontFamily
                            }
                        }
                        AxisNumbers {}
                        Column {
                            width: parent.width - 16 - 16 - 16
                            spacing: 6
                            FanCurveChart {
                                id: gpuChart
                                width: parent.width
                                height: 196
                                points: [ { t: 40, f: 35 }, { t: 60, f: 69 }, { t: 80, f: 81 }, { t: 100, f: 100 } ]
                            }
                            Row {
                                width: parent.width
                                Repeater {
                                    model: ["0", "25", "50", "75", "100 °C"]
                                    Text {
                                        width: parent.width / 5
                                        horizontalAlignment: index === 4 ? Text.AlignRight : Text.AlignLeft
                                        text: modelData
                                        color: Theme.textFaint
                                        font.pixelSize: 10
                                        font.family: Theme.fontFamily
                                    }
                                }
                            }
                            Row {
                                width: parent.width
                                spacing: 6
                                Repeater {
                                    model: gpuChart.points
                                    delegate: Rectangle {
                                        width: (parent.width - 6 * 3) / 4
                                        height: 28
                                        radius: Theme.radiusSm
                                        color: Theme.fieldBg
                                        border.width: 1
                                        border.color: Theme.fieldBorder
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.t + "° · " + modelData.f + "%"
                                            color: Theme.textPrimary
                                            font.pixelSize: 12
                                            font.family: Theme.fontFamily
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { width: 1; height: 16 }

        Rectangle {
            width: parent.width
            height: 68
            radius: Theme.radius
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Theme.panelBorder2

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 20

                Column {
                    width: parent.width - 106
                    spacing: 5
                    Text {
                        text: qsTr("Description")
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }
                    Text {
                        width: parent.width
                        text: root.fanModeData[root.fanMode].desc
                        color: Theme.textDim
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }
                }

                Rectangle {
                    width: 86
                    height: 34
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Theme.radiusSm
                    color: applyMouse.containsMouse ? Theme.accentHover : Theme.accent
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Apply")
                        color: Theme.accentText
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
