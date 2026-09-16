import QtQuick
import QtQuick.Window
import QtQuick.Controls
import ControlCenter

Window {
    id: root
    width: 1280
    height: 760
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    title: qsTr("Control Center")
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    Component.onCompleted: WinChrome.applyAcrylicEffect(root)

    QtObject {
        id: appState
        property int page: 0
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.visibility === Window.Maximized ? 0 : 10
        color: Theme.windowFill
        border.width: root.visibility === Window.Maximized ? 0 : 1
        border.color: Qt.rgba(1, 1, 1, 0.09)
        clip: true

        TitleBar {
            id: titleBar
            window: root
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Item {
            id: body
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            NavRail {
                id: navRail
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                currentIndex: appState.page
                onNavigate: (index) => appState.page = index
            }

            Flickable {
                id: scrollArea
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: navRail.right
                anchors.right: parent.right
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                contentWidth: width
                contentHeight: pagesContainer.height + 26 + 36

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                Item {
                    id: pagesContainer
                    x: 36
                    y: 26
                    width: scrollArea.width - 72
                    readonly property real pagesTop: driverBanner.visible ? driverBanner.height + 18 : 0
                    height: pagesTop + (function() {
                        switch (appState.page) {
                        case 0: return perfPage.implicitHeight
                        case 1: return kbPage.implicitHeight
                        case 2: return fanPage.implicitHeight
                        default: return advPage.implicitHeight
                        }
                    })()

                    Rectangle {
                        id: driverBanner
                        width: parent.width
                        height: bannerCol.implicitHeight + 28
                        visible: !DeviceService.available
                        radius: Theme.radius
                        color: Theme.warningBg
                        border.width: 1
                        border.color: Theme.warningBorder

                        Column {
                            id: bannerCol
                            x: 16; y: 14
                            width: parent.width - 32
                            spacing: 4
                            Text {
                                text: qsTr("Laptop controls are unavailable")
                                color: Theme.textPrimary
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                font.family: Theme.fontFamily
                            }
                            Text {
                                width: parent.width
                                text: qsTr("The Insyde DCHU driver could not be opened, so settings are shown but not applied. %1")
                                          .arg(DeviceService.errorMessage)
                                color: Theme.textDim
                                font.pixelSize: 12
                                font.family: Theme.fontFamily
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    PerformanceModesPage {
                        id: perfPage
                        y: pagesContainer.pagesTop
                        width: parent.width
                        visible: appState.page === 0
                        enabled: PowerService.available
                    }
                    KeyboardColorPage {
                        id: kbPage
                        y: pagesContainer.pagesTop
                        width: parent.width
                        visible: appState.page === 1
                    }
                    FanControlPage {
                        id: fanPage
                        y: pagesContainer.pagesTop
                        width: parent.width
                        visible: appState.page === 2
                    }
                    EnthusiastsPage {
                        id: advPage
                        y: pagesContainer.pagesTop
                        width: parent.width
                        visible: appState.page === 3
                    }
                }
            }
        }
    }

    ResizeBorders {
        anchors.fill: parent
        window: root
    }
}
