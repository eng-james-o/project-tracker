import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    property var step: ({})
    signal toggled(bool completed)
    signal deleted()

    implicitHeight: 44
    radius: 6
    color: "#F8F9FA"
    border.color: "#E0E0E0"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        CheckBox {
            id: chk
            checked: root.step.completed || false
            onToggled: root.toggled(chk.checked)
        }

        Text {
            text: root.step.title || ""
            font.pixelSize: 13
            font.strikeout: root.step.completed
            color: root.step.completed ? "#80868B" : "#202124"
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Text {
            text: root.step.deadline ? ("📅 " + root.step.deadline) : ""
            font.pixelSize: 11
            color: "#70757A"
            visible: root.step.deadline && root.step.deadline.length > 0
        }

        Button {
            text: "🗑️"
            flat: true
            implicitWidth: 30
            implicitHeight: 30
            onClicked: root.deleted()
        }
    }
}
