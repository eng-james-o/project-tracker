import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal navigateToProjects()
    signal selectProject(int projectId)

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        Item { implicitHeight: 10 } // Spacer

        // Header
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4
                Text {
                    text: "Dashboard Overview"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#202124"
                }
                Text {
                    text: "Track active projects, recent deliverables, and upcoming deadlines"
                    font.pixelSize: 13
                    color: "#5F6368"
                }
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "+ Quick Project"
                onClicked: projectDialog.open()
            }
        }

        // Stat Cards Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            StatCard {
                title: "Total Projects"
                value: (projectController.dashboardStats.total || 0).toString()
                accentColor: "#1A73E8"
                iconSource: "../../assets/projects.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Active Projects"
                value: (projectController.dashboardStats.active || 0).toString()
                accentColor: "#34A853"
                iconSource: "../../assets/play.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Paused Projects"
                value: (projectController.dashboardStats.paused || 0).toString()
                accentColor: "#FBBC04"
                iconSource: "../../assets/pause.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Completed"
                value: (projectController.dashboardStats.completed || 0).toString()
                accentColor: "#174EA6"
                iconSource: "../../assets/check-circle.svg"
                Layout.fillWidth: true
            }
        }

        // Two Column Content Section
        RowLayout {
            Layout.fillWidth: true
            spacing: 24
            Layout.alignment: Qt.AlignTop

            // Left Column: Active Projects
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 60
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Active Projects"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#202124"
                    }
                    Item { Layout.fillWidth: true }
                    Button {
                        text: "View All ->"
                        flat: true
                        onClicked: root.navigateToProjects()
                    }
                }

                Repeater {
                    model: projectController.projects.filter(function(p){ return p.status === 'active'; }).slice(0, 4)

                    delegate: ProjectCard {
                        Layout.fillWidth: true
                        project: modelData
                        onClicked: {
                            projectController.load_project_details(modelData.id)
                            root.selectProject(modelData.id)
                        }
                    }
                }

                Text {
                    text: "No active projects currently."
                    font.pixelSize: 13
                    color: "#70757A"
                    visible: projectController.projects.filter(function(p){ return p.status === 'active'; }).length === 0
                }
            }

            // Right Column: Upcoming & Close Deadlines
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 40
                spacing: 12

                Text {
                    text: "Upcoming Deadlines"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#202124"
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: deadlineList.implicitHeight + 20
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"
                    border.width: 1

                    ColumnLayout {
                        id: deadlineList
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Repeater {
                            model: projectController.upcomingDeadlines

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 50
                                radius: 6
                                color: "#F8F9FA"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 10

                                    Image {
                                        source: modelData.item_type === "project" ? "../../assets/projects.svg" : (modelData.item_type === "step" ? "../../assets/edit.svg" : "../../assets/package.svg")
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: modelData.item_title
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#202124"
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.project_title + " (" + modelData.item_type + ")"
                                            font.pixelSize: 11
                                            color: "#5F6368"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        radius: 4
                                        color: "#FCE8E6"
                                        implicitWidth: deadlineRow.implicitWidth + 12
                                        implicitHeight: 22

                                        RowLayout {
                                            id: deadlineRow
                                            anchors.centerIn: parent
                                            spacing: 4

                                            Image {
                                                source: "../../assets/calendar.svg"
                                                sourceSize.width: 12
                                                sourceSize.height: 12
                                            }

                                            Text {
                                                text: modelData.deadline
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#C5221F"
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        projectController.load_project_details(modelData.project_id)
                                        root.selectProject(modelData.project_id)
                                    }
                                }
                            }
                        }

                        Text {
                            text: "No upcoming deadlines."
                            font.pixelSize: 13
                            color: "#70757A"
                            visible: projectController.upcomingDeadlines.length === 0
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
