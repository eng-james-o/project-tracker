import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    property var resource: ({})
    signal openClicked()
    signal deleted()

    implicitHeight: resource.type === "note" ? 80 : 50
    radius: 6
    color: "#FFFFFF"
    border.color: "#E0E0E0"
    border.width: 1

    function getIconSource(type) {
        switch(type) {
            case "link": return "../../assets/link.svg"
            case "document": return "../../assets/file-text.svg"
            case "folder": return "../../assets/projects.svg"
            case "note": return "../../assets/edit.svg"
            default: return "../../assets/file-text.svg"
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            color: "#F1F3F4"

            Image {
                anchors.centerIn: parent
                source: root.getIconSource(root.resource.type)
                sourceSize.width: 16
                sourceSize.height: 16
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.resource.title || "Untitled Resource"
                font.pixelSize: 13
                font.bold: true
                color: "#202124"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.resource.path_or_content || ""
                font.pixelSize: 11
                color: "#5F6368"
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: root.resource.type === "note" ? 2 : 1
                wrapMode: Text.Wrap
            }
        }

        CustomButton {
            text: "Open"
            variant: "secondary"
            implicitWidth: 60
            implicitHeight: 28
            visible: root.resource.type !== "note"
            onClicked: Qt.openUrlExternally(root.resource.path_or_content)
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
