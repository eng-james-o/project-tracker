import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "views"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1100
    height: 750
    title: "Project Tracker Desktop"
    color: "#F8F9FA"

    // Dialog for creating / editing projects
    ProjectDialog {
        id: projectDialog
        anchors.centerIn: parent
        onAccepted: {
            if (isEdit) {
                projectController.update_project(
                    projectId,
                    projectTitle,
                    clientName,
                    clientEmail,
                    status,
                    deadline,
                    description
                )
            } else {
                projectController.add_project(
                    projectTitle,
                    clientName,
                    clientEmail,
                    status,
                    deadline,
                    description
                )
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar Navigation
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 220
            color: "#FFFFFF"
            border.color: "#E0E0E0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 24
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 24
                spacing: 24

                // App Branding
                RowLayout {
                    spacing: 10
                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 8
                        color: "#1A73E8"
                        Text {
                            anchors.centerIn: parent
                            text: "📊"
                            font.pixelSize: 18
                        }
                    }
                    Text {
                        text: "ProjectTracker"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#202124"
                    }
                }

                // Nav Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    CustomButton {
                        Layout.fillWidth: true
                        text: "📊 Dashboard"
                        variant: mainStack.currentIndex === 0 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 0
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: "📂 All Projects"
                        variant: mainStack.currentIndex === 1 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 1
                    }
                }

                Item { Layout.fillHeight: true }

                // Quick Add Project Button
                CustomButton {
                    Layout.fillWidth: true
                    text: "+ New Project"
                    variant: "secondary"
                    onClicked: {
                        projectDialog.setProject(null)
                        projectDialog.open()
                    }
                }
            }
        }

        // Main StackView / Content Area
        StackLayout {
            id: mainStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            DashboardView {
                onNavigateToProjects: mainStack.currentIndex = 1
                onSelectProject: function(pid) {
                    mainStack.currentIndex = 2
                }
            }

            ProjectsView {
                onSelectProject: function(pid) {
                    mainStack.currentIndex = 2
                }
            }

            ProjectDetailView {
                onBackClicked: mainStack.currentIndex = 1
            }
        }
    }
}
