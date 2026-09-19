import QtQuick
import ControlCenter

// Integer entry styled like the other input fields. `value` is shown while
// the field is not being edited; `edited` reports what the user typed.
Rectangle {
    id: root
    height: 38
    radius: Theme.radiusSm
    color: Theme.fieldBg
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.fieldBorder
    opacity: enabled ? 1 : 0.45

    property int value: 0
    property int minimum: 0
    property int maximum: 99

    signal edited(int value)

    onValueChanged: if (!input.activeFocus) input.text = value

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.textPrimary
        selectionColor: Theme.accent
        selectedTextColor: Theme.accentText
        font.pixelSize: 15
        font.family: Theme.fontFamily
        selectByMouse: true
        text: root.value
        validator: IntValidator { bottom: root.minimum; top: root.maximum }

        onTextEdited: {
            const parsed = parseInt(text)
            root.edited(isNaN(parsed) ? root.minimum : Math.min(root.maximum, Math.max(root.minimum, parsed)))
        }
        onEditingFinished: text = root.value
    }
}
