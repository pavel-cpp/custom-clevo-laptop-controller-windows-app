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
                    height: {
                        switch (appState.page) {
                        case 0: return perfPage.implicitHeight
                        case 1: return kbPage.implicitHeight
                        case 2: return fanPage.implicitHeight
                        default: return advPage.implicitHeight
                        }
                    }

                    PerformanceModesPage {
                        id: perfPage
                        width: parent.width
                        visible: appState.page === 0
                    }
                    KeyboardColorPage {
                        id: kbPage
                        width: parent.width
                        visible: appState.page === 1
                    }
                    FanControlPage {
                        id: fanPage
                        width: parent.width
                        visible: appState.page === 2
                    }
                    EnthusiastsPage {
                        id: advPage
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
