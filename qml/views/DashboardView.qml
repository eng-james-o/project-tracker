import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

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

        // Header (No quick project button as requested)
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4
                Text {
                    text: "Dashboard Overview"
                    font.pixelSize: 24
                    font.bold: true
                    color: Style.textMain
                }
                Text {
                    text: "Track active projects, recent deliverables, and upcoming deadlines"
                    font.pixelSize: 13
                    color: Style.textSecondary
                }
            }

            Item { Layout.fillWidth: true }
        }

        // Stat Cards Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            StatCard {
                title: "Total Projects"
                value: (projectController.dashboardStats.total || 0).toString()
                accentColor: Style.primary
                iconSource: "../../assets/projects.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Active Projects"
                value: (projectController.dashboardStats.active || 0).toString()
                accentColor: Style.success
                iconSource: "../../assets/play.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Paused Projects"
                value: (projectController.dashboardStats.paused || 0).toString()
                accentColor: Style.warning
                iconSource: "../../assets/pause.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Completed"
                value: (projectController.dashboardStats.completed || 0).toString()
                accentColor: Style.info
                iconSource: "../../assets/check-circle.svg"
                Layout.fillWidth: true
            }
        }

        // Financial Stats Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            StatCard {
                title: "Total Revenue"
                value: projectController.get_financial_stats().total_revenue ? "$" + projectController.get_financial_stats().total_revenue.toFixed(2) : "$0.00"
                accentColor: "#34A853"
                iconSource: "../../assets/dollar.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Total Paid"
                value: projectController.get_financial_stats().total_paid ? "$" + projectController.get_financial_stats().total_paid.toFixed(2) : "$0.00"
                accentColor: "#1A73E8"
                iconSource: "../../assets/payment.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Outstanding"
                value: projectController.get_financial_stats().total_outstanding ? "$" + projectController.get_financial_stats().total_outstanding.toFixed(2) : "$0.00"
                accentColor: projectController.get_financial_stats().total_outstanding > 0 ? "#EA4335" : "#34A853"
                iconSource: "../../assets/outstanding.svg"
                Layout.fillWidth: true
            }

            StatCard {
                title: "Goals Completed"
                value: projectController.goals.filter(function(g) { return g.status === "completed" }).length.toString()
                accentColor: "#174EA6"
                iconSource: "../../assets/goals.svg"
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
                        color: Style.textMain
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
                    color: Style.textLight
                    visible: projectController.projects.filter(function(p){ return p.status === 'active'; }).length === 0
                }
            }

            // Right Column: Upcoming & Close Deadlines
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 40
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Upcoming Deadlines"
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.textMain
                    }
                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: deadlineList.implicitHeight + 20
                    radius: Style.radiusLarge
                    color: Style.surface
                    border.color: Style.border
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
                                radius: Style.radiusMedium
                                color: Style.background

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
                                            color: Style.textMain
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.project_title + " (" + modelData.item_type + ")"
                                            font.pixelSize: 11
                                            color: Style.textSecondary
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        radius: Style.radiusSmall
                                        color: "#FCE8E6"
                                        implicitWidth: Math.min(deadlineRow.implicitWidth + 12, 120)
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
                                                color: Style.danger
                                                elide: Text.ElideRight
                                                maximumLineCount: 1
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
                            color: Style.textLight
                            visible: projectController.upcomingDeadlines.length === 0
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
