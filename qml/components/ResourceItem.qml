import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property var resource: ({})
    signal editClicked()
    signal deleted()
    signal viewClicked()

    implicitHeight: resource.type === "note" ? Math.max(80, (markdownPreview.visible ? markdownPreview.implicitHeight : 80) + 20) : 50
    radius: Style.radiusMedium
    color: Style.surface
    border.color: Style.border
    border.width: 1

    function getIconSource(type) {
        switch(type) {
            case "link": return "../../assets/link.svg"
            case "document": return "../../assets/file-text.svg"
            case "folder": return "../../assets/projects.svg"
            case "note": return "../../assets/edit.svg"
            case "markdown": return "../../assets/markdown.svg"
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
            color: Style.secondary

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
                color: Style.textMain
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            MarkdownText {
                id: markdownPreview
                markdownText: root.resource.path_or_content || ""
                Layout.fillWidth: true
                visible: root.resource.type === "note"
            }

            Text {
                text: root.resource.path_or_content || ""
                font.pixelSize: 11
                color: Style.textSecondary
                Layout.fillWidth: true
                elide: Text.ElideRight
                maximumLineCount: 1
                wrapMode: Text.Wrap
                visible: root.resource.type !== "note"
            }
        }

        CustomButton {
            text: "View"
            variant: "secondary"
            implicitWidth: 60
            implicitHeight: 28
            visible: root.resource.type !== "note"
            onClicked: Qt.openUrlExternally(root.resource.path_or_content)
        }

        CustomButton {
            variant: "icon"
            iconSource: "../../assets/link.svg"
            visible: root.resource.type === "link"
            ToolTip.text: "Copy Link"
            ToolTip.visible: hovered
            onClicked: {
                // Copy link to clipboard
                var text = root.resource.path_or_content
                console.log("Copy link to clipboard:", text)
                // Note: Actual clipboard integration requires Qt.Clipboard or backend support
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
