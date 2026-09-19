import QtQuick
import ControlCenter

Item {
    id: root
    implicitHeight: content.implicitHeight

    readonly property int customCard: 4
    readonly property int dustCleaningCard: 3

    // Card picked in the UI; it takes effect with Apply.
    property int selectedMode: Math.max(0, FanService.mode)
    // Offset shown while the slider is dragged, before it is committed.
    property int offsetDraft: FanService.offset
    property string statusMessage: ""
    property bool statusIsError: false

    readonly property var fanModeData: [
        { name: qsTr("Automatic"), note: qsTr("Everyday use"), supported: true,
          desc: qsTr("Fan speed is adjusted automatically; intended for everyday use.") },
        { name: qsTr("Maximum Fan Speed"), note: qsTr("Full speed"), supported: true,
          desc: qsTr("Fans run at maximum speed continuously: lowest temperature, highest noise.") },
        { name: qsTr("MaxQ"), note: qsTr("If supported"), supported: FanService.supportsMaxQ,
          desc: qsTr("Fan speed is capped, the system stays quiet and the power limit is lowered.") },
        { name: qsTr("Anti-Dust"), note: qsTr("Runs once"), supported: FanService.supportsDustCleaning,
          desc: qsTr("Fans spin in reverse for a short while to blow dust out of the heatsink.") },
        { name: qsTr("Custom Curve"), note: qsTr("Manual"), supported: FanService.supportsCustomCurves,
          desc: qsTr("Drag the middle points of each curve, then apply. The first point is set by the firmware and the last is always full speed.") }
    ]

    function loadCurves() {
        cpuPanel.chart.points = FanService.cpuCurve
        gpuPanel.chart.points = FanService.gpuCurve
    }

    function showStatus(message, isError) {
        root.statusMessage = message
        root.statusIsError = isError
    }

    function apply() {
        const error = FanService.applyMode(root.selectedMode, cpuPanel.chart.points, gpuPanel.chart.points)
        if (error.length > 0)
            showStatus(error, true)
        else if (root.selectedMode === root.dustCleaningCard)
            showStatus(qsTr("Dust cleaning started."), false)
        else
            showStatus(qsTr("Applied."), false)
    }

    Component.onCompleted: loadCurves()

    Connections {
        target: FanService
        function onCurvesChanged() { root.loadCurves() }
    }

    // Poll fan speeds only while this page is on screen.
    Binding {
        target: FanService
        property: "telemetryActive"
        value: root.visible && FanService.available
    }

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

    // Inline components cannot see this document's ids, so everything the
    // panel needs from the page arrives through properties.
    component FanPanel: Rectangle {
        id: panel
        property string title
        property string telemetry
        property bool editable: false
        property alias chart: chart

        height: panelCol.implicitHeight + 36
        radius: Theme.radius
        color: Theme.panelBg
        border.width: 1
        border.color: Theme.panelBorder

        Column {
            id: panelCol
            x: 18; y: 18
            width: parent.width - 36
            spacing: 16

            Item {
                width: parent.width
                height: 20
                Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                       text: panel.title; color: Theme.textPrimary; font.pixelSize: 17; font.weight: Font.DemiBold; font.family: Theme.fontFamily }
                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                       text: panel.telemetry; color: Theme.textDim; font.pixelSize: 13; font.family: Theme.fontFamily }
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
                        id: chart
                        width: parent.width
                        height: 196
                        lockedIndices: [0, 3]
                        interactive: panel.editable
                        opacity: interactive ? 1 : 0.6
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
                            model: chart.points
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

    Column {
        id: content
        width: parent.width
        spacing: 0
        enabled: FanService.available

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
                    color: index === root.selectedMode ? Theme.selectedBg
                                                       : (cardMouse.containsMouse ? Theme.panelBgHover : Theme.panelBg)
                    border.width: 1
                    border.color: index === root.selectedMode ? Theme.accent : Theme.panelBorder
                    opacity: modelData.supported ? 1 : 0.55

                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        visible: index === FanService.mode
                        text: qsTr("Active")
                        color: Theme.accent
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }

                    Column {
                        x: 14
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
                            text: modelData.supported ? modelData.note : qsTr("Not reported by firmware")
                            color: Theme.textMuted
                            font.pixelSize: 11
                            font.family: Theme.fontFamily
                        }
                    }
                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedMode = index
                            root.statusMessage = ""
                        }
                    }
                }
            }
        }

        Item { width: 1; height: 18 }

        Rectangle {
            width: parent.width
            height: 62
            radius: Theme.radius
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Theme.panelBorder2

            Row {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 16

                Column {
                    width: 190
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: qsTr("Speed offset")
                        color: Theme.textPrimary
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.family: Theme.fontFamily
                    }
                    Text {
                        text: qsTr("Added on top of the active curve")
                        color: Theme.textMuted
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                    }
                }
                GradientSlider {
                    width: parent.width - 190 - 40 - 32
                    anchors.verticalCenter: parent.verticalCenter
                    from: 0; to: 100
                    value: root.offsetDraft
                    onMoved: (v) => root.offsetDraft = Math.round(v)
                    onReleased: (v) => {
                        const error = FanService.setOffset(Math.round(v))
                        if (error.length > 0)
                            root.showStatus(error, true)
                        root.offsetDraft = FanService.offset
                    }
                }
                Text {
                    width: 40
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    text: root.offsetDraft + "%"
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

            FanPanel {
                id: cpuPanel
                width: parent.colWidth
                title: qsTr("CPU")
                telemetry: FanService.cpuRpm + " RPM · " + FanService.cpuDuty + "% · " + FanService.cpuTemperature + "°C"
                editable: root.selectedMode === root.customCard
            }
            FanPanel {
                id: gpuPanel
                width: parent.colWidth
                title: qsTr("GPU")
                telemetry: FanService.gpuRpm + " RPM · " + FanService.gpuDuty + "% · " + FanService.gpuTemperature + "°C"
                editable: root.selectedMode === root.customCard
            }
        }

        Item { width: 1; height: 16 }

        Rectangle {
            width: parent.width
            height: Math.max(68, descCol.implicitHeight + 32)
            radius: Theme.radius
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: Theme.panelBorder2

            Column {
                id: descCol
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 32 - buttons.width - 20
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
                    text: root.fanModeData[root.selectedMode].desc
                    color: Theme.textDim
                    font.pixelSize: 13
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                }
                Text {
                    width: parent.width
                    visible: root.statusMessage.length > 0
                    text: root.statusMessage
                    color: root.statusIsError ? Theme.errorText : Theme.accent
                    font.pixelSize: 12
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                }
            }

            Row {
                id: buttons
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    visible: root.selectedMode === root.customCard
                    width: 110
                    height: 34
                    radius: Theme.radiusSm
                    color: resetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.09)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Factory curve")
                        color: Theme.textPrimary
                        font.pixelSize: 13
                        font.family: Theme.fontFamily
                    }
                    MouseArea {
                        id: resetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cpuPanel.chart.points = FanService.defaultCurve(false)
                            gpuPanel.chart.points = FanService.defaultCurve(true)
                        }
                    }
                }

                Rectangle {
                    width: 86
                    height: 34
                    radius: Theme.radiusSm
                    color: applyMouse.containsMouse ? Theme.accentHover : Theme.accent
                    Text {
                        anchors.centerIn: parent
                        text: root.selectedMode === root.dustCleaningCard ? qsTr("Start") : qsTr("Apply")
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
                        onClicked: root.apply()
                    }
                }
            }
        }
    }
}
