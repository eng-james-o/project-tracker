import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

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
        ColumnLayout {
            spacing: 4
            Text {
                text: "Application Settings"
                font.pixelSize: 24
                font.bold: true
                color: "#202124"
            }
            Text {
                text: "Configure audit trail row limits and application preferences"
                font.pixelSize: 13
                color: "#5F6368"
            }
        }

        // Settings Section Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: settingsCol.implicitHeight + 32
            radius: 10
            color: "#FFFFFF"
            border.color: "#E0E0E0"

            ColumnLayout {
                id: settingsCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Audit Database Configuration"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#202124"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Max Audit Log Rows Cap"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#202124"
                        }

                        Text {
                            text: "Prevents database bloat by automatically purging oldest entries when threshold is reached."
                            font.pixelSize: 11
                            color: "#70757A"
                        }
                    }

                    SpinBox {
                        id: maxRowsSpinBox
                        from: 50
                        to: 10000
                        stepSize: 50
                        value: projectController.maxAuditRows
                        onValueChanged: projectController.setMaxAuditRows(value)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#E0E0E0"
                }

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Database Management"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#202124"
                        }

                        Text {
                            text: "Clear stored audit log history from audit_tracker.db."
                            font.pixelSize: 11
                            color: "#70757A"
                        }
                    }

                    CustomButton {
                        text: "Purge Audit Logs"
                        variant: "secondary"
                        onClicked: projectController.clearAuditLogs()
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
