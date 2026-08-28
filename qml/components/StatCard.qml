import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    property string value: "0"
    property string accentColor: "#1A73E8"
    property string iconSource: ""

    implicitWidth: 180
    implicitHeight: 90
    radius: 10
    color: "#FFFFFF"

    // Drop shadow simulation via soft border
    border.color: "#E0E0E0"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 22
            color: Qt.alpha(root.accentColor, 0.12)

            Image {
                anchors.centerIn: parent
                source: root.iconSource
                sourceSize.width: 22
                sourceSize.height: 22
                visible: root.iconSource.length > 0
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.title
                font.pixelSize: 12
                color: "#70757A"
                font.weight: Font.Medium
            }

            Text {
                text: root.value
                font.pixelSize: 22
                font.bold: true
                color: "#202124"
            }
        }
    }
}
