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
    
    // Navigation group expanded states (persisted between sessions)
    SidebarSettings {
        id: sidebarSettings
    }

    // Onboarding / profile editor, shown as a modal on first launch
    OnboardingView {
        id: onboardingView
        objectName: "onboardingView"
    }

    Component.onCompleted: {
        if (!profileController.onboardingCompleted) {
            onboardingView.openForSetup()
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

    // Command Palette (Ctrl+K)
    CommandPalette {
        id: commandPalette
        projectController: projectController
        templateController: templateController
        profileController: profileController
    }

    // Shortcut for opening command palette
    Shortcut {
        sequence: "Ctrl+K"
        onActivated: commandPalette.open()
    }

    // Additional keyboard shortcuts
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: {
            projectDialog.setProject(null)
            projectDialog.open()
        }
    }

    Shortcut {
        sequence: "Ctrl+F"
        onActivated: {
            mainWindow.mainStack.currentIndex = 1
            mainWindow.projectsView.searchBox.focus = true
        }
    }

    Shortcut {
        sequence: "Ctrl+1"
        onActivated: mainWindow.mainStack.currentIndex = 0
    }

    Shortcut {
        sequence: "Ctrl+2"
        onActivated: mainWindow.mainStack.currentIndex = 1
    }

    Shortcut {
        sequence: "Ctrl+3"
        onActivated: mainWindow.mainStack.currentIndex = 2
    }

    Shortcut {
        sequence: "Esc"
        onActivated: {
            // Close any open dialogs
            projectDialog.close()
            templateDialog.close()
            commandPalette.close()
        }
    }

    // Notification Center
    NotificationCenter {
        id: notificationCenter
        notificationController: notificationController
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 60
        visible: false
    }

    // AI Assistant Drawer
    AIAssistantDrawer {
        id: aiAssistantDrawer
        objectName: "assistantDrawer"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Collapsible Sidebar Navigation
        Flickable {
            id: sidebarFlick
            Layout.fillHeight: true
            implicitWidth: mainWindow.isSidebarCollapsed ? 64 : 220
            contentHeight: sidebarContent.height
            flickableDirection: Flickable.VerticalFlick
            clip: true

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

            Rectangle {
                id: sidebarContent
                width: sidebarFlick.width
                height: Math.max(sidebarFlick.height, navigation.implicitHeight + 40)
                color: Style.surface
                border.color: Style.border
                border.width: 1

                ColumnLayout {
                    id: navigation
                    anchors.fill: parent
                    anchors.topMargin: 20
                    anchors.leftMargin: mainWindow.isSidebarCollapsed ? 10 : 16
                    anchors.rightMargin: mainWindow.isSidebarCollapsed ? 10 : 16
                    anchors.bottomMargin: 20
                    spacing: 16

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
                        ToolTip.text: "Toggle Sidebar"
                        ToolTip.delay: 300
                        onClicked: mainWindow.isSidebarCollapsed = !mainWindow.isSidebarCollapsed
                    }
                }

                // ===== PROJECTS GROUP =====
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Group header with highlight
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: mainWindow.isSidebarCollapsed ? "transparent" : 
                               (mainStack.currentIndex === 0 || mainStack.currentIndex === 1 || 
                                mainStack.currentIndex === 2 || mainStack.currentIndex === 3) ? 
                               Qt.alpha(Style.primary, 0.1) : "transparent"
                        radius: Style.radiusSmall

                        CustomButton {
                            anchors.fill: parent
                            text: mainWindow.isSidebarCollapsed ? "" : "Projects"
                            iconSource: "../../assets/projects.svg"
                            variant: "ghost"
                            onClicked: sidebarSettings.toggle("projects")
                            ToolTip.text: "Projects - Dashboard, All Projects, Project Board"
                            ToolTip.delay: 300

                            // Expand/collapse indicator
                            Image {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize.width: 14
                                sourceSize.height: 14
                                source: "../assets/arrow-left.svg"
                                rotation: sidebarSettings.projectsExpanded ? -90 : 180
                                visible: !mainWindow.isSidebarCollapsed
                            }
                        }
                    }

                    // Group items (collapsed by default)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: sidebarSettings.projectsExpanded

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "Dashboard"
                            iconSource: "../../assets/dashboard.svg"
                            variant: mainStack.currentIndex === 0 ? "primary" : "ghost"
                            onClicked: mainStack.currentIndex = 0
                            ToolTip.text: "Dashboard - Overview of your projects and metrics"
                            ToolTip.delay: 300
                        }

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "All Projects"
                            iconSource: "../../assets/projects.svg"
                            variant: mainStack.currentIndex === 1 ? "primary" : "ghost"
                            onClicked: mainStack.currentIndex = 1
                            ToolTip.text: "All Projects - View and manage all your projects"
                            ToolTip.delay: 300
                        }

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "Project Board"
                            iconSource: "../../assets/board.svg"
                            variant: mainStack.currentIndex === 3 ? "primary" : "ghost"
                            onClicked: mainStack.currentIndex = 3
                            ToolTip.text: "Project Board - Kanban-style view of your projects"
                            ToolTip.delay: 300
                        }

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "New Project"
                            iconSource: "../../assets/plus.svg"
                            variant: "secondary"
                            onClicked: {
                                projectDialog.setProject(null)
                                projectDialog.open()
                            }
                            ToolTip.text: "New Project - Create a new project"
                            ToolTip.delay: 300
                        }
                    }
                }

                // Divider between groups
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Style.border
                    visible: !mainWindow.isSidebarCollapsed
                }

                // ===== PLANNING GROUP =====
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Group header with highlight
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: mainWindow.isSidebarCollapsed ? "transparent" : 
                               mainStack.currentIndex === 4 ? 
                               Qt.alpha(Style.success, 0.1) : "transparent"
                        radius: Style.radiusSmall

                        CustomButton {
                            anchors.fill: parent
                            text: mainWindow.isSidebarCollapsed ? "" : "Planning"
                            iconSource: "../../assets/goals.svg"
                            variant: "ghost"
                            onClicked: sidebarSettings.toggle("planning")
                            ToolTip.text: "Planning - Goals and objectives"
                            ToolTip.delay: 300

                            Image {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize.width: 14
                                sourceSize.height: 14
                                source: "../assets/arrow-left.svg"
                                rotation: sidebarSettings.planningExpanded ? -90 : 180
                                visible: !mainWindow.isSidebarCollapsed
                            }
                        }
                    }

                    // Group items
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: sidebarSettings.planningExpanded

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "Goals"
                            iconSource: "../../assets/goals.svg"
                            variant: mainStack.currentIndex === 4 ? "primary" : "ghost"
                            onClicked: mainStack.currentIndex = 4
                            ToolTip.text: "Goals - Set and track your goals"
                            ToolTip.delay: 300
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Style.border
                    visible: !mainWindow.isSidebarCollapsed
                }

                // ===== MANAGEMENT GROUP =====
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Group header with highlight
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: mainWindow.isSidebarCollapsed ? "transparent" : 
                               mainStack.currentIndex === 5 ? 
                               Qt.alpha(Style.warning, 0.1) : "transparent"
                        radius: Style.radiusSmall

                        CustomButton {
                            anchors.fill: parent
                            text: mainWindow.isSidebarCollapsed ? "" : "Management"
                            iconSource: "../../assets/audit.svg"
                            variant: "ghost"
                            onClicked: sidebarSettings.toggle("management")
                            ToolTip.text: "Management - Activity and audit logs"
                            ToolTip.delay: 300

                            Image {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize.width: 14
                                sourceSize.height: 14
                                source: "../assets/arrow-left.svg"
                                rotation: sidebarSettings.managementExpanded ? -90 : 180
                                visible: !mainWindow.isSidebarCollapsed
                            }
                        }
                    }

                    // Group items
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: sidebarSettings.managementExpanded

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "Activity & Audit"
                            iconSource: "../../assets/audit.svg"
                            variant: mainStack.currentIndex === 5 ? "primary" : "ghost"
                            onClicked: mainStack.currentIndex = 5
                            ToolTip.text: "Activity & Audit - View project history and audit logs"
                            ToolTip.delay: 300
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Style.border
                    visible: !mainWindow.isSidebarCollapsed
                }

                // ===== TOOLS GROUP =====
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    // Group header with highlight
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: mainWindow.isSidebarCollapsed ? "transparent" : 
                               mainStack.currentIndex === 7 || mainStack.currentIndex === 8 ? 
                               Qt.alpha(Style.info, 0.1) : "transparent"
                        radius: Style.radiusSmall

                        CustomButton {
                            anchors.fill: parent
                            text: mainWindow.isSidebarCollapsed ? "" : "Tools"
                            iconSource: "../../assets/package.svg"
                            variant: "ghost"
                            onClicked: sidebarSettings.toggle("tools")
                            ToolTip.text: "Tools - AI Assistant and Notifications"
                            ToolTip.delay: 300

                            Image {
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize.width: 14
                                sourceSize.height: 14
                                source: "../assets/arrow-left.svg"
                                rotation: sidebarSettings.toolsExpanded ? -90 : 180
                                visible: !mainWindow.isSidebarCollapsed
                            }
                        }
                    }

                    // Group items
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: sidebarSettings.toolsExpanded

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "AI Assistant"
                            iconSource: "../../assets/outstanding.svg"
                            variant: "ghost"
                            onClicked: aiAssistantDrawer.open()
                            ToolTip.text: "AI Assistant - Get help from AI for project planning and more"
                            ToolTip.delay: 300
                        }

                        CustomButton {
                            Layout.fillWidth: true
                            text: mainWindow.isSidebarCollapsed ? "" : "Notifications"
                            iconSource: "../../assets/outstanding.svg"
                            variant: notificationController.notifications.length > 0 ? "primary" : "ghost"
                            onClicked: notificationCenter.visible = !notificationCenter.visible
                            ToolTip.text: "Notifications - View your notifications"
                            ToolTip.delay: 300

                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                width: 18
                                height: 18
                                radius: 9
                                color: Style.danger
                                visible: notificationController.notifications.length > 0

                                Text {
                                    anchors.centerIn: parent
                                    text: notificationController.notifications.length
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Style.surface
                                }
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Style.border
                    visible: !mainWindow.isSidebarCollapsed
                }

                // ===== SETTINGS (Always visible) =====
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: mainWindow.isSidebarCollapsed ? "transparent" : 
                           mainStack.currentIndex === 6 ? 
                           Qt.alpha(Style.secondary, 0.1) : "transparent"
                    radius: Style.radiusSmall

                    CustomButton {
                        anchors.fill: parent
                        text: mainWindow.isSidebarCollapsed ? "" : "Settings"
                        iconSource: "../../assets/settings.svg"
                        variant: mainStack.currentIndex === 6 ? "primary" : "ghost"
                        onClicked: mainStack.currentIndex = 6
                        ToolTip.text: "Settings - Configure application settings"
                        ToolTip.delay: 300
                    }
                }

                Item { Layout.fillHeight: true }

            }
        }
        }

        // Main StackView / Content Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

        StackLayout {
            id: mainStack
            objectName: "mainStack"
            anchors.fill: parent
            currentIndex: 0

            DashboardView {
                onNavigateToProjects: mainStack.currentIndex = 1
                onSelectProject: function(pid) {
                    mainStack.currentIndex = 2
                }
            }

            ProjectsView {
                id: projectsView
                onSelectProject: function(pid) {
                    mainStack.currentIndex = 2
                }
            }

            ProjectDetailView {
                onBackClicked: mainStack.currentIndex = 1
                onNavigateToAuditView: mainStack.currentIndex = 5
            }

            ProjectBoardView {}

            GoalsView {}

            AuditLogView {}

            SettingsView {
                onEditProfileRequested: onboardingView.openForEdit()
            }
        }

        ToolButton {
            objectName: "openAssistant"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            z: 9
            icon.source: "../assets/sidebar.svg"
            Accessible.name: "Open AI Assistant"
            ToolTip.visible: hovered
            ToolTip.text: Accessible.name
            onClicked: aiAssistantDrawer.open()
        }

        RoundButton {
            id: scrollTop
            objectName: "scrollToTop"
            readonly property var page: mainStack.children[mainStack.currentIndex]
            readonly property var viewport: page ? page.contentItem : null
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            width: 40
            height: 40
            radius: width / 2
            z: 10
            text: "↑"
            font.pixelSize: 22
            Accessible.name: "Back to top"
            visible: viewport && !viewport.atYBeginning && (viewport.moving || activity.running || down)
            onViewportChanged: activity.stop()
            onClicked: {
                viewport.cancelFlick()
                viewport.contentY = viewport.originY
                activity.stop()
            }
            // Wheel steps and scrollbar drags can change contentY without a flick.
            Timer { id: activity; interval: 350 }
            Connections {
                target: scrollTop.viewport
                function onContentYChanged() { activity.restart() }
            }
        }
        }
    }
}
