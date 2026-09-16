import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    property bool touchpadEnabled: true

    readonly property var flags: [
        ["LoadDefault", "False"], ["PCbeep", "1"], ["OCLoadDefault", "False"],
        ["EnergyStar15C", "1"], ["BatteryChargeControl", "0"], ["FanSpeedSupport", "True"],
        ["SupportGamingGroup", "True"], ["Support3dHeadphone", "False"], ["SupportTpColor", "False"],
        ["CustomFanSupport", "True"], ["WakeUpLanSupport", "False"], ["SupportCheckNotAirplaneOsd", "True"],
        ["SupportKbBacklight", "True"], ["SupportMaxQ", "False"]
    ]

    function flagIsNumeric(v) { return v !== "True" && v !== "False" }
    function flagBg(v) {
        if (flagIsNumeric(v)) return Qt.rgba(1, 1, 1, 0.10)
        return v === "True" ? Qt.rgba(0.298, 0.761, 1, 0.18) : Qt.rgba(1, 1, 1, 0.07)
    }
    function flagFg(v) {
        if (flagIsNumeric(v)) return "white"
        return v === "True" ? "#79cfff" : Theme.textMuted
    }

    Column {
        id: content
        width: parent.width
        spacing: 0

        Text {
            text: qsTr("For Enthusiasts")
            color: Theme.textPrimary
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.family: Theme.fontFamily
        }
        Text {
            text: qsTr("Driver capabilities and experimental settings.")
            color: Theme.textSecondary
            font.pixelSize: 13
            font.family: Theme.fontFamily
            topPadding: 6
        }

        Item { width: 1; height: 22 }

        Row {
            width: parent.width
            spacing: 16

            Column {
                width: 320
                spacing: 12

                Rectangle {
                    width: parent.width
                    height: displayCol.implicitHeight + 36
                    radius: Theme.radius
                    color: Theme.panelBg
                    border.width: 1
                    border.color: Theme.panelBorder

                    Column {
                        id: displayCol
                        x: 18; y: 18
                        width: parent.width - 36
                        spacing: 12

                        Text {
                            text: qsTr("Display Mode")
                            color: Theme.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                        }
                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: Theme.radiusSm
                            color: displayMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Theme.fieldBg
                            border.width: 1
                            border.color: Theme.fieldBorder

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: "144 Hz · sRGB"
                                color: Qt.rgba(1, 1, 1, 0.85)
                                font.pixelSize: 13
                                font.family: Theme.fontFamily
                            }
                            IconChevronDown {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 10; height: 6
                                color: Qt.rgba(1, 1, 1, 0.85)
                            }
                            MouseArea {
                                id: displayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 76
                    radius: Theme.radius
                    color: Theme.panelBg
                    border.width: 1
                    border.color: Theme.panelBorder

                    Row {
                        anchors.fill: parent
                        anchors.margins: 18
                        Column {
                            width: parent.width - 40
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: qsTr("TouchPad")
                                color: Theme.textPrimary
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamily
                            }
                            Text {
                                text: qsTr("Enable / disable")
                                color: Theme.textMuted
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                            }
                        }
                        ToggleSwitch {
                            anchors.verticalCenter: parent.verticalCenter
                            checked: root.touchpadEnabled
                            onToggled: (v) => root.touchpadEnabled = v
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: warnCol.implicitHeight + 36
                    radius: Theme.radius
                    color: Qt.rgba(0.298, 0.761, 1, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(0.298, 0.761, 1, 0.34)

                    Column {
                        id: warnCol
                        x: 18; y: 18
                        width: parent.width - 36
                        spacing: 14

                        Text {
                            width: parent.width
                            text: qsTr("Developed experimentally by Boran Software. All responsibility lies with the user.")
                            color: Qt.rgba(1, 1, 1, 0.85)
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                            wrapMode: Text.WordWrap
                            lineHeight: 1.55
                        }
                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: Theme.radiusSm
                            color: quitMouse.containsMouse ? Theme.accentHover : Theme.accent
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("Quit Application")
                                color: Theme.accentText
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamily
                            }
                            MouseArea {
                                id: quitMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.quit()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width - 320 - 16
                height: flagsCol.implicitHeight + 36
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: flagsCol
                    x: 18; y: 18
                    width: parent.width - 36
                    spacing: 14

                    Text {
                        text: qsTr("Driver Capabilities for Enthusiasts")
                        color: Theme.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }

                    Flickable {
                        width: parent.width
                        height: Math.min(392, flagList.implicitHeight)
                        contentWidth: width
                        contentHeight: flagList.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: flagList
                            width: parent.width

                            Repeater {
                                model: root.flags
                                delegate: Rectangle {
                                    width: flagList.width
                                    height: 36
                                    color: flagMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                                    radius: Theme.radiusSm

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: 1
                                        color: Theme.separator
                                    }

                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData[0]
                                        color: Qt.rgba(1, 1, 1, 0.8)
                                        font.pixelSize: 13
                                        font.family: "Consolas"
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: badgeText.implicitWidth + 16
                                        height: badgeText.implicitHeight + 4
                                        radius: height / 2
                                        color: root.flagBg(modelData[1])
                                        Text {
                                            id: badgeText
                                            anchors.centerIn: parent
                                            text: modelData[1]
                                            color: root.flagFg(modelData[1])
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            font.family: Theme.fontFamily
                                        }
                                    }

                                    MouseArea {
                                        id: flagMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
