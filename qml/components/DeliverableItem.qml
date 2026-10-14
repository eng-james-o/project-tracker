import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property var deliverable: ({})
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
            checked: root.deliverable.completed || false
            onToggled: root.toggled(chk.checked)
        }

        Image {
            source: "../../assets/package.svg"
            sourceSize.width: 16
            sourceSize.height: 16
        }

        Text {
            text: root.deliverable.title || ""
            font.pixelSize: 13
            font.bold: true
            font.strikeout: root.deliverable.completed
            color: root.deliverable.completed ? Style.textLight : Style.textMain
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        RowLayout {
            spacing: 4
            visible: root.deliverable.deadline && root.deliverable.deadline.length > 0

            Image {
                source: "../../assets/calendar.svg"
                sourceSize.width: 12
                sourceSize.height: 12
            }

            Text {
                text: root.deliverable.deadline || ""
                font.pixelSize: 11
                color: Style.danger
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
