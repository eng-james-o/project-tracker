import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property var project: ({})
    signal clicked()
    signal statusChanged(string newStatus)

    implicitHeight: 180
    radius: Style.radiusLarge
    color: Style.surface
    border.color: mouseArea.containsMouse ? Style.primary : Style.border
    border.width: mouseArea.containsMouse ? 2 : 1

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.project.title || "Untitled Project"
                font.pixelSize: 16
                font.bold: true
                color: Style.textMain
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StatusBadge {
                status: root.project.status || "active"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                spacing: 6
                Layout.fillWidth: true

                Image {
                    source: "../../assets/user.svg"
                    sourceSize.width: 14
                    sourceSize.height: 14
                }

                Text {
                    text: (root.project.client_name || "No Client") + (root.project.client_email ? (" (" + root.project.client_email + ")") : "")
                    font.pixelSize: 12
                    color: Style.textSecondary
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                spacing: 6

                Image {
                    source: "../../assets/calendar.svg"
                    sourceSize.width: 14
                    sourceSize.height: 14
                }

                Text {
                    text: root.project.deadline || "No deadline"
                    font.pixelSize: 12
                    color: Style.textSecondary
                }
            }
        }

        Text {
            text: root.project.description || "No description."
            font.pixelSize: 12
            color: Style.textLight
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                property int done: root.project.steps_completed || 0
                property int total: root.project.steps_total || 0
                text: "Steps: " + done + "/" + total
                font.pixelSize: 11
                color: Style.textSecondary
            }

            Text {
                property int done: root.project.deliverables_completed || 0
                property int total: root.project.deliverables_total || 0
                text: "Deliverables: " + done + "/" + total
                font.pixelSize: 11
                color: Style.textSecondary
            }
        }

        // Progress Bar
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: Style.radiusSmall
            color: Style.secondaryBorder

            Rectangle {
                property int done: root.project.steps_completed || 0
                property int total: root.project.steps_total || 0
                width: total > 0 ? parent.width * (done / total) : 0
                height: parent.height
                radius: Style.radiusSmall
                color: root.project.status === "completed" ? Style.success : Style.primary
            }
        }
    }
}
