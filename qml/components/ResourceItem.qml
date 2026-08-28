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

    function getIcon(type) {
        switch(type) {
            case "link": return "🔗"
            case "document": return "📄"
            case "folder": return "📁"
            case "note": return "📝"
            default: return "📌"
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

            Text {
                anchors.centerIn: parent
                text: root.getIcon(root.resource.type)
                font.pixelSize: 16
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
            text: "🗑️"
            flat: true
            implicitWidth: 30
            implicitHeight: 30
            onClicked: root.deleted()
        }
    }
}
