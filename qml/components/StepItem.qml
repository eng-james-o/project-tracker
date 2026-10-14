import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property var step: ({})
    signal toggled(bool completed)
    signal editClicked()
    signal deleted()

    implicitHeight: 44
    radius: Style.radiusMedium
    color: Style.background
    border.color: Style.border
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        CustomCheckBox {
            id: chk
            checked: root.step.completed || false
            onToggled: root.toggled(chk.checked)
        }

        Text {
            text: root.step.title || ""
            font.pixelSize: 13
            font.strikeout: root.step.completed
            color: root.step.completed ? Style.textLight : Style.textMain
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        RowLayout {
            spacing: 4
            visible: root.step.deadline && root.step.deadline.length > 0

            Image {
                source: "../../assets/calendar.svg"
                sourceSize.width: 12
                sourceSize.height: 12
            }

            Text {
                text: root.step.deadline || ""
                font.pixelSize: 11
                color: Style.textLight
            }
        }

        CustomButton {
            variant: "icon"
            iconSource: "../../assets/edit.svg"
            onClicked: root.editClicked()
        }

        CustomButton {
            variant: "icon"
            iconSource: "../../assets/trash.svg"
            onClicked: root.deleted()
        }
    }
}
