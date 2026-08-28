import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    property var deliverable: ({})
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
            color: root.deliverable.completed ? "#80868B" : "#202124"
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
                color: "#D93025"
            }
        }

        Button {
            flat: true
            implicitWidth: 30
            implicitHeight: 30
            contentItem: Image {
                anchors.centerIn: parent
                source: "../../assets/trash.svg"
                sourceSize.width: 16
                sourceSize.height: 16
            }
            onClicked: root.deleted()
        }
    }
}
