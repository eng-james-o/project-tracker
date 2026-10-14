import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    Layout.fillWidth: true
    implicitHeight: 80
    radius: 6
    color: {
        switch(modelData.severity) {
            case "critical": return "#FCE8E6"
            case "high": return "#FFEBEE"
            case "medium": return "#FFF9C4"
            case "low": return "#E8F5E8"
            default: return "#F8F9FA"
        }
    }
    border.color: "#E0E0E0"
    border.width: 1

    property var blocker: ({})
    signal toggled(bool completed)
    signal editClicked()
    signal deleted()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        ColumnLayout {
            spacing: 4

            Text {
                text: blocker.title || "Untitled Blocker"
                font.pixelSize: 14
                font.bold: true
                color: {
                    switch(blocker.severity) {
                        case "critical": return "#C5221F"
                        case "high": return "#B71C1C"
                        case "medium": return "#F57F17"
                        case "low": return "#2E7D32"
                        default: return "#202124"
                    }
                }
                elide: Text.ElideRight
            }

            Text {
                text: blocker.description || "No description"
                font.pixelSize: 11
                color: "#5F6368"
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                spacing: 8

                Rectangle {
                    radius: 4
                    color: {
                        switch(blocker.status) {
                            case "open": return "#FCE8E6"
                            case "in_progress": return "#FFF176"
                            case "resolved": return "#E8F5E8"
                            default: return "#E0E0E0"
                        }
                    }
                    implicitWidth: 80
                    implicitHeight: 20

                    Text {
                        text: blocker.status.toUpperCase()
                        font.pixelSize: 10
                        font.bold: true
                        color: {
                            switch(blocker.status) {
                                case "open": return "#C5221F"
                                case "in_progress": return "#F57F17"
                                case "resolved": return "#2E7D32"
                                default: return "#202124"
                            }
                        }
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    radius: 4
                    color: "#E0E0E0"
                    implicitWidth: 60
                    implicitHeight: 20

                    Text {
                        text: blocker.severity.toUpperCase()
                        font.pixelSize: 10
                        font.bold: true
                        color: "#202124"
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            spacing: 4
            Layout.alignment: Qt.AlignRight

            CustomButton {
                text: "Edit"
                variant: "ghost"
                implicitWidth: 60
                onClicked: editClicked()
            }

            CustomButton {
                text: "Delete"
                variant: "danger"
                implicitWidth: 60
                onClicked: deleted()
            }

            CustomButton {
                text: blocker.status === "resolved" ? "Reopen" : "Resolve"
                variant: blocker.status === "resolved" ? "secondary" : "primary"
                implicitWidth: 80
                onClicked: {
                    var newStatus = blocker.status === "resolved" ? "open" : "resolved"
                    projectController.update_blocker(blocker.id, blocker.title, blocker.description, blocker.severity, newStatus)
                }
            }
        }
    }
}
