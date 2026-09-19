import QtQuick
import ControlCenter

Rectangle {
    id: root
    radius: Theme.radius
    color: Theme.panelBg
    border.width: 1
    border.color: Theme.panelBorder
    default property alias content: inner.data

    property int padding: 16

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
