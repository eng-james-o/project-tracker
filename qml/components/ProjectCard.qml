import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root
    property var project: ({})
    signal clicked()
    signal statusChanged(string newStatus)

    implicitHeight: 140
    radius: 10
    color: "#FFFFFF"
    border.color: mouseArea.containsMouse ? "#1A73E8" : "#E0E0E0"
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
                color: "#202124"
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

            Text {
                text: "👤 " + (root.project.client_name || "No Client")
                font.pixelSize: 12
                color: "#5F6368"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: "📅 " + (root.project.deadline || "No deadline")
                font.pixelSize: 12
                color: "#5F6368"
            }
        }

        // Progress Bar & Count
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Progress"
                    font.pixelSize: 11
                    color: "#70757A"
                }
                Item { Layout.fillWidth: true }
                Text {
                    property int done: root.project.steps_completed || 0
                    property int total: root.project.steps_total || 0
                    text: total > 0 ? (done + "/" + total + " steps (" + Math.round((done/total)*100) + "%)") : "No steps"
                    font.pixelSize: 11
                    color: "#70757A"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: "#E8EAED"

                Rectangle {
                    property int done: root.project.steps_completed || 0
                    property int total: root.project.steps_total || 0
                    width: total > 0 ? parent.width * (done / total) : 0
                    height: parent.height
                    radius: 3
                    color: root.project.status === "completed" ? "#34A853" : "#1A73E8"
                }
            }
        }
    }
}
