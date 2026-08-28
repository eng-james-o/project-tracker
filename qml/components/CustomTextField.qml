import QtQuick
import QtQuick.Controls

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
    color: "#202124"
    placeholderTextColor: "#70757A" // High contrast visible placeholder

    background: Item {
        anchors.fill: parent

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            text: control.label
            visible: control.label.length > 0
            font.pixelSize: 11
            font.weight: Font.Medium
            color: "#5F6368"
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38
            radius: 6
            color: "#F8F9FA"
            border.color: control.activeFocus ? "#1A73E8" : "#DADCE0"
            border.width: control.activeFocus ? 2 : 1
        }
    }
}
