import QtQuick
import QtQuick.Controls
import "../"

TextField {
    id: control
    property string label: ""

    implicitHeight: label ? 58 : 38
    topPadding: label ? 22 : 8
    bottomPadding: 8
    leftPadding: 10
    rightPadding: 10
    selectByMouse: true
    font.pixelSize: 13
    color: Style.textMain
    placeholderTextColor: Style.textSecondary
    selectionColor: Style.primaryHover
    selectedTextColor: Style.surface

    background: Item {
        anchors.fill: parent

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            text: control.label
            visible: control.label.length > 0
            font.pixelSize: 11
            font.weight: Font.Medium
            color: Style.textSecondary
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38
            radius: Style.radiusMedium
            color: Style.background
            border.color: control.activeFocus ? Style.primary : Style.border
            border.width: control.activeFocus ? 2 : 1
        }
    }
}
