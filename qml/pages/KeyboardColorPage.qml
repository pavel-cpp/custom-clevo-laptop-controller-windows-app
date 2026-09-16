import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    property bool bootEffect: false
    property bool effectsActive: true
    property bool colorActive: true
    property bool sleepActive: true

    property int effectIndex: 6
    readonly property var effectNames: [
        qsTr("Breathing (Driver)"), qsTr("Cycle (Driver)"), qsTr("Wave (Driver)"),
        qsTr("Dance (Driver)"), qsTr("Tempo (Driver)"), qsTr("Flash (Driver)"),
        qsTr("Breathing (Software)"), qsTr("Cycle (Software)"), qsTr("Wave (Software)"),
        qsTr("Spectrum (Software)")
    ]

    property real hue: 333
    property real saturation: 57
    property real hsvValue: 73
    property int brightness: 175

    readonly property color previewColor: Qt.hsva(hue / 360, saturation / 100, hsvValue / 100, 1)
    readonly property int rr: Math.round(previewColor.r * 255)
    readonly property int gg: Math.round(previewColor.g * 255)
    readonly property int bb: Math.round(previewColor.b * 255)

    function hex2(n) {
        const s = n.toString(16).toUpperCase()
        return s.length < 2 ? "0" + s : s
    }
    readonly property string hexString: "#" + hex2(rr) + hex2(gg) + hex2(bb)

    Column {
        id: content
        width: parent.width
        spacing: 0

        Row {
            width: parent.width

            Column {
                width: parent.width - bootRow.width
                Text {
                    text: qsTr("Keyboard Color")
                    color: Theme.textPrimary
                    font.pixelSize: 27
                    font.weight: Font.DemiBold
                    font.family: Theme.fontFamily
                }
                Text {
                    text: qsTr("Manage effects, color and the sleep timer.")
                    color: Theme.textSecondary
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    topPadding: 6
                }
            }

            Row {
                id: bootRow
                anchors.top: parent.top
                anchors.topMargin: 8
                spacing: 10
                ToggleSwitch {
                    checked: root.bootEffect
                    onToggled: (v) => root.bootEffect = v
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Boot Effect")
                    color: Qt.rgba(1, 1, 1, 0.85)
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                }
            }
        }

        Item { width: 1; height: 22 }

        Row {
            id: columns
            width: parent.width
            spacing: 16

            readonly property real middleWidth: width - 288 - 300 - spacing * 2

            // ---- Effects ------------------------------------------------
            Rectangle {
                width: 288
                height: Math.max(fanEffectsCol.implicitHeight + 32, colorPanel.height)
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: fanEffectsCol
                    x: 16; y: 16
                    width: parent.width - 32
                    spacing: 12

                    Item {
                        width: parent.width
                        height: 22
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Effects")
                            color: Theme.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                        }
                        Row {
                            id: effectsHeader
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            ToggleSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: root.effectsActive
                                onToggled: (v) => root.effectsActive = v
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Active")
                                color: Theme.textDim
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 2

                        Repeater {
                            model: root.effectNames
                            delegate: Item {
                                width: parent.width
                                height: 34

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.radiusSm
                                    color: index === root.effectIndex ? Theme.selectedBg
                                                                       : (fxMouse.containsMouse ? Theme.hoverBg : "transparent")
                                }
                                Rectangle {
                                    x: 0; y: 9
                                    width: 3; height: 16; radius: 2
                                    color: Theme.accent
                                    opacity: index === root.effectIndex ? 1 : 0
                                }
                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData
                                    color: Theme.textPrimary
                                    font.pixelSize: 13
                                    font.family: Theme.fontFamily
                                }
                                MouseArea {
                                    id: fxMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.effectIndex = index
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: Theme.radiusSm
                        color: applyMouse.containsMouse ? Theme.accentHover : Theme.accent
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Apply Effect")
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

            // ---- Color ----------------------------------------------------
            Rectangle {
                id: colorPanel
                width: columns.middleWidth
                height: colorCol.implicitHeight + 32
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: colorCol
                    x: 16; y: 16
                    width: parent.width - 32
                    spacing: 14

                    Item {
                        width: parent.width
                        height: 22
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Color")
                            color: Theme.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            font.family: Theme.fontFamily
                        }
                        Row {
                            id: colorHeader
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            ToggleSwitch {
                                anchors.verticalCenter: parent.verticalCenter
                                checked: root.colorActive
                                onToggled: (v) => root.colorActive = v
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Active")
                                color: Theme.textDim
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 14
                        ColorPickerSV {
                            width: parent.width - 20 - 14
                            height: 184
                            hue: root.hue
                            saturation: root.saturation
                            value: root.hsvValue
                            onChanged: (s, v) => { root.saturation = s; root.hsvValue = v }
                        }
                        HueSlider {
                            width: 20
                            height: 184
                            hue: root.hue
                            onChanged: (h) => root.hue = h
                        }
                    }

                    Grid {
                        id: rgbGrid
                        width: parent.width
                        columns: 3
                        columnSpacing: 10
                        readonly property real fieldWidth: (width - columnSpacing * 2) / 3

                        Column {
                            spacing: 5
                            Text { text: "R"; color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: rgbGrid.fieldWidth; height: 32; radius: Theme.radiusSm
                                color: Theme.fieldBg
                                border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                       text: root.rr; color: Theme.textPrimary; font.pixelSize: 13; font.family: Theme.fontFamily }
                            }
                        }
                        Column {
                            spacing: 5
                            Text { text: "G"; color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: rgbGrid.fieldWidth; height: 32; radius: Theme.radiusSm
                                color: Theme.fieldBg
                                border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                       text: root.gg; color: Theme.textPrimary; font.pixelSize: 13; font.family: Theme.fontFamily }
                            }
                        }
                        Column {
                            spacing: 5
                            Text { text: "B"; color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: rgbGrid.fieldWidth; height: 32; radius: Theme.radiusSm
                                color: Theme.fieldBg
                                border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                       text: root.bb; color: Theme.textPrimary; font.pixelSize: 13; font.family: Theme.fontFamily }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Brightness")
                            color: Theme.textMuted
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }
                        GradientSlider {
                            width: parent.width - 76 - 40
                            anchors.verticalCenter: parent.verticalCenter
                            from: 0; to: 255
                            value: root.brightness
                            onMoved: (v) => root.brightness = Math.round(v)
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            horizontalAlignment: Text.AlignRight
                            text: root.brightness
                            color: Theme.textPrimary
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: 12
                        Text { anchors.verticalCenter: parent.verticalCenter; text: qsTr("Preview"); color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                        Rectangle {
                            width: 64; height: 26; radius: Theme.radiusSm
                            border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.18)
                            color: root.previewColor
                        }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: qsTr("Name"); color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                        Rectangle {
                            width: parent.width - 64 - 76 - 36 - 24
                            height: 30; radius: Theme.radiusSm
                            color: Theme.fieldBg
                            border.width: 1; border.color: Theme.fieldBorder
                            Text {
                                anchors.left: parent.left; anchors.leftMargin: 10; anchors.verticalCenter: parent.verticalCenter
                                text: root.hexString; color: Theme.textPrimary; font.pixelSize: 13; font.family: Theme.fontFamily
                            }
                        }
                    }
                }
            }

            // ---- Sleep Timer -----------------------------------------------
            Rectangle {
                width: 300
                height: Math.max(sleepCol.implicitHeight + 32, colorPanel.height)
                radius: Theme.radius
                color: Theme.panelBg
                border.width: 1
                border.color: Theme.panelBorder

                Column {
                    id: sleepCol
                    x: 16; y: 16
                    width: parent.width - 32
                    spacing: 12

                    Text {
                        text: qsTr("Keyboard Sleep Timer")
                        color: Theme.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }

                    Row {
                        spacing: 8
                        ToggleSwitch {
                            checked: root.sleepActive
                            onToggled: (v) => root.sleepActive = v
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Active")
                            color: Theme.textDim
                            font.pixelSize: 12
                            font.family: Theme.fontFamily
                        }
                    }

                    Item { width: 1; height: 6 }

                    Grid {
                        id: hmsGrid
                        width: parent.width
                        columns: 3
                        columnSpacing: 10
                        readonly property real fieldWidth: (width - columnSpacing * 2) / 3

                        Column {
                            spacing: 5
                            Text { text: qsTr("Hours"); color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: hmsGrid.fieldWidth; height: 38; radius: Theme.radiusSm
                                color: Theme.fieldBg; border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.centerIn: parent; text: "0"; color: Theme.textPrimary; font.pixelSize: 15; font.family: Theme.fontFamily }
                            }
                        }
                        Column {
                            spacing: 5
                            Text { text: qsTr("Minutes"); color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: hmsGrid.fieldWidth; height: 38; radius: Theme.radiusSm
                                color: Theme.fieldBg; border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.centerIn: parent; text: "10"; color: Theme.textPrimary; font.pixelSize: 15; font.family: Theme.fontFamily }
                            }
                        }
                        Column {
                            spacing: 5
                            Text { text: qsTr("Seconds"); color: Theme.textMuted; font.pixelSize: 11; font.family: Theme.fontFamily }
                            Rectangle {
                                width: hmsGrid.fieldWidth; height: 38; radius: Theme.radiusSm
                                color: Theme.fieldBg; border.width: 1; border.color: Theme.fieldBorder
                                Text { anchors.centerIn: parent; text: "0"; color: Theme.textPrimary; font.pixelSize: 15; font.family: Theme.fontFamily }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: Theme.radiusSm
                        color: sleepApplyMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.09)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.12)
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Apply")
                            color: Theme.textPrimary
                            font.pixelSize: 13
                            font.family: Theme.fontFamily
                        }
                        MouseArea {
                            id: sleepApplyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Keyboard backlight turns off after the set delay and comes back on the next keypress.")
                        color: Theme.textMuted
                        font.pixelSize: 12
                        font.family: Theme.fontFamily
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }
                }
            }
        }
    }
}
