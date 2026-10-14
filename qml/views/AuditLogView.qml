import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Item { implicitHeight: 10 }

        // Header
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4
                Text {
                    text: "Activity & Audit Logs"
                    font.pixelSize: 24
                    font.bold: true
                    color: Style.textMain
                }
                Text {
                    text: "Complete auditability trail of system activities and changes"
                    font.pixelSize: 13
                    color: Style.textSecondary
                }
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "Purge Logs"
                variant: "secondary"
                onClicked: projectController.clearAuditLogs()
            }
        }

        // Audit Logs List Container
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: logsColumn.implicitHeight + 32
            radius: Style.radiusLarge
            color: Style.surface
            border.color: Style.border

            ColumnLayout {
                id: logsColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Repeater {
                    model: projectController.auditLogs

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: Style.radiusMedium
                        color: Style.background

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Rectangle {
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
                                color: modelData.action === "DELETE" ? "#FCE8E6" : "#E8F0FE"

                                Image {
                                    anchors.centerIn: parent
                                    source: modelData.action === "DELETE" ? "../../assets/trash.svg" : "../../assets/file-text.svg"
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: modelData.details + (modelData.repeat_count > 1 ? (" (x" + modelData.repeat_count + ")") : "")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: Style.textMain
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: "Action: " + modelData.action + " | Entity: " + modelData.entity_type
                                    font.pixelSize: 11
                                    color: Style.textLight
                                }
                            }

                            Text {
                                text: modelData.timestamp
                                font.pixelSize: 11
                                color: Style.textSecondary
                            }
                        }
                    }
                }

                Text {
                    text: "No audit logs available."
                    font.pixelSize: 13
                    color: "#70757A"
                    visible: projectController.auditLogs.length === 0
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
