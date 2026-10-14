import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "views"
import "."

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1100
    height: 750
    title: "Project Tracker Desktop"
    color: Style.background

    property bool isSidebarCollapsed: false
    property bool showOnboarding: true

    // Onboarding View (shown first)
    OnboardingView {
        id: onboardingView
        visible: mainWindow.showOnboarding
        anchors.fill: parent
        onOnboardingComplete: {
            mainWindow.showOnboarding = false
        }
    }

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
                    description,
                    price,
                    paidAmount,
                    currency,
                    tags,
                    companyId,
                    isPersonal
                )
            } else {
                projectController.add_project(
                    projectTitle,
                    clientName,
                    clientEmail,
                    status,
                    deadline,
                    description,
                    price,
                    paidAmount,
                    currency,
                    tags,
                    companyId,
                    isPersonal
                )
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Collapsible Sidebar Navigation
        Rectangle {
            Layout.fillHeight: true
            implicitWidth: mainWindow.isSidebarCollapsed ? 64 : 220
            color: Style.surface
            border.color: Style.border
            border.width: 1

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.leftMargin: mainWindow.isSidebarCollapsed ? 10 : 16
                anchors.rightMargin: mainWindow.isSidebarCollapsed ? 10 : 16
                anchors.bottomMargin: 20
                spacing: 20

                // Header Branding & Collapse Toggle Button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: Style.radiusMedium
                        color: Style.primary
                        visible: !mainWindow.isSidebarCollapsed
                        Image {
                            anchors.centerIn: parent
                            source: "../assets/app-icon.svg"
                            sourceSize.width: 22
                            sourceSize.height: 22
                        }
                    }

                    Text {
                        text: "ProjectTracker"
                        font.pixelSize: 17
                        font.bold: true
                        color: Style.textMain
                        visible: !mainWindow.isSidebarCollapsed
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    CustomButton {
                        variant: "icon"
                        iconSource: "../../assets/sidebar.svg"
                        onClicked: mainWindow.isSidebarCollapsed = !mainWindow.isSidebarCollapsed
                    }
                }

                // Nav Buttons
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Dashboard"
                        iconSource: "../../assets/dashboard.svg"
                        variant: mainStack.currentIndex === 0 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 0
                        ToolTip.text: "Dashboard"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "All Projects"
                        iconSource: "../../assets/projects.svg"
                        variant: mainStack.currentIndex === 1 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 1
                        ToolTip.text: "All Projects"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Activity & Audit"
                        iconSource: "../../assets/audit.svg"
                        variant: mainStack.currentIndex === 3 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 3
                        ToolTip.text: "Activity & Audit"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Project Board"
                        iconSource: "../../assets/board.svg"
                        variant: mainStack.currentIndex === 4 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 4
                        ToolTip.text: "Project Board"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Goals"
                        iconSource: "../../assets/goals.svg"
                        variant: mainStack.currentIndex === 5 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 5
                        ToolTip.text: "Goals"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Activity & Audit"
                        iconSource: "../../assets/audit.svg"
                        variant: mainStack.currentIndex === 6 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 6
                        ToolTip.text: "Activity & Audit"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }

                    CustomButton {
                        Layout.fillWidth: true
                        text: mainWindow.isSidebarCollapsed ? "" : "Settings"
                        iconSource: "../../assets/settings.svg"
                        variant: mainStack.currentIndex === 7 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 7
                        ToolTip.text: "Settings"
                        ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                        ToolTip.delay: 300
                    }
                }

                Item { Layout.fillHeight: true }

                // Quick Add Project Button
                CustomButton {
                    Layout.fillWidth: true
                    text: mainWindow.isSidebarCollapsed ? "" : "New Project"
                    iconSource: "../../assets/plus.svg"
                    variant: "secondary"
                    ToolTip.text: "New Project"
                    ToolTip.visible: hovered && mainWindow.isSidebarCollapsed
                    ToolTip.delay: 300
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
                onNavigateToAuditView: mainStack.currentIndex = 6
            }

            ProjectBoardView {}

            GoalsView {}

            AuditLogView {}

            SettingsView {}
        }
    }
}
