import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    component SecondaryButton: Rectangle {
        id: button
        property string text
        signal clicked()

        height: 34
        radius: Theme.radiusSm
        color: buttonMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.09)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        opacity: enabled ? 1 : 0.45

        Text {
            anchors.centerIn: parent
            text: button.text
            color: Theme.textPrimary
            font.pixelSize: 13
            font.family: Theme.fontFamily
        }
        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component PanelTitle: Text {
        color: Theme.textPrimary
        font.pixelSize: 15
        font.weight: Font.DemiBold
        font.family: Theme.fontFamily
    }

    component PanelNote: Text {
        color: Theme.textMuted
        font.pixelSize: 12
        font.family: Theme.fontFamily
        wrapMode: Text.WordWrap
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
                    height: firmwareCol.implicitHeight + 36
                    radius: Theme.radius
                    color: Theme.panelBg
                    border.width: 1
                    border.color: Theme.panelBorder

                    Column {
                        id: firmwareCol
                        x: 18; y: 18
                        width: parent.width - 36
                        spacing: 12

                        PanelTitle { text: qsTr("Firmware") }

                        Rectangle {
                            width: parent.width
                            height: 32
                            radius: Theme.radiusSm
                            color: Theme.fieldBg
                            border.width: 1
                            border.color: Theme.fieldBorder

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Embedded controller")
                                color: Theme.textMuted
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                            }
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: DeviceService.controllerVersion.length > 0 ? DeviceService.controllerVersion : "—"
                                color: Qt.rgba(1, 1, 1, 0.85)
                                font.pixelSize: 13
                                font.family: "Consolas"
                            }
                        }

                    }
                }

                Rectangle {
                    width: parent.width
                    height: startupCol.implicitHeight + 36
                    radius: Theme.radius
                    color: Theme.panelBg
                    border.width: 1
                    border.color: Theme.panelBorder

                    Column {
                        id: startupCol
                        x: 18; y: 18
                        width: parent.width - 36
                        spacing: 12

                        PanelTitle { text: qsTr("Startup") }

                        Row {
                            spacing: 10
                            ToggleSwitch {
                                enabled: Autostart.supported
                                checked: Autostart.enabled
                                onToggled: (v) => Autostart.setEnabled(v)
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: Autostart.enabled ? qsTr("Launches with Windows") : qsTr("Off")
                                color: Theme.textDim
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                            }
                        }

                        PanelNote {
                            width: parent.width
                            text: qsTr("Starts minimised to the notification area when you sign in and restores your last keyboard effect. Only the current user account is affected.")
                            lineHeight: 1.5
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
                            text: qsTr("Developed experimentally by Pavel Remdenok. All responsibility lies with the user.")
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

                    Item {
                        width: parent.width
                        height: 22
                        PanelTitle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Driver Capabilities")
                        }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            visible: DeviceService.available
                            text: qsTr("%n fan(s)", "", DeviceService.fanCount)
                            color: Theme.textDim
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                        }
                    }

                    PanelNote {
                        width: parent.width
                        visible: DeviceService.capabilities.length === 0
                        text: qsTr("Capabilities are read from the firmware once the driver is available.")
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
                                model: DeviceService.capabilities
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
                                        text: modelData.name
                                        color: Qt.rgba(1, 1, 1, 0.8)
                                        font.pixelSize: 13
                                        font.family: Theme.fontFamily
                                    }

                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: badgeText.implicitWidth + 16
                                        height: badgeText.implicitHeight + 4
                                        radius: height / 2
                                        color: modelData.supported ? Qt.rgba(0.298, 0.761, 1, 0.18) : Qt.rgba(1, 1, 1, 0.07)
                                        Text {
                                            id: badgeText
                                            anchors.centerIn: parent
                                            text: modelData.supported ? qsTr("Yes") : qsTr("No")
                                            color: modelData.supported ? "#79cfff" : Theme.textMuted
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
