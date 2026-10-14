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
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 4
                Text {
                    text: "My Goals"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#202124"
                }
                Text {
                    text: "Track your daily, weekly, and monthly goals"
                    font.pixelSize: 13
                    color: "#5F6368"
                }
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "+ New Goal"
                onClicked: {
                    goalDialog.setGoal(null)
                    goalDialog.open()
                }
            }
        }

        // Filter and Search Bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 80
            radius: 8
            color: "#FFFFFF"
            border.color: "#E0E0E0"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "../../assets/search.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                    }

                    CustomTextField {
                        id: searchBox
                        placeholderText: "Search goals..."
                        Layout.fillWidth: true
                        onTextChanged: projectController.setGoalsSearch(text)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    RowLayout {
                        spacing: 8

                        Text {
                            text: "Type:"
                            font.pixelSize: 13
                            color: "#5F6368"
                        }

                        CustomComboBox {
                            id: typeFilter
                            model: ["All", "Daily", "Weekly", "Monthly"]
                            onCurrentTextChanged: projectController.setGoalsTypeFilter(currentText)
                        }
                    }

                    RowLayout {
                        spacing: 8

                        Text {
                            text: "Status:"
                            font.pixelSize: 13
                            color: "#5F6368"
                        }

                        CustomComboBox {
                            id: statusFilter
                            model: ["All", "Pending", "In Progress", "Completed", "Failed"]
                            onCurrentTextChanged: projectController.setGoalsStatusFilter(currentText)
                        }
                    }
                }
            }
        }

        // Goals List by Type
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20

            // Daily Goals
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: dailyLayout.implicitHeight + 32
                radius: 10
                color: "#FFFFFF"
                border.color: "#E0E0E0"

                ColumnLayout {
                    id: dailyLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Daily Goals"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: projectController.goals.filter(function(g) { return g.goal_type === 'daily' && g.status === 'completed' }).length + "/" + projectController.goals.filter(function(g) { return g.goal_type === 'daily' }).length + " completed"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }
                    }

                    Repeater {
                        model: projectController.goals.filter(function(g) { return g.goal_type === 'daily' })

                        delegate: GoalItem {
                            Layout.fillWidth: true
                            goal: modelData
                            onStatusChanged: projectController.refresh_goals()
                            onEditClicked: {
                                goalDialog.setGoal(modelData)
                                goalDialog.open()
                            }
                            onDeleted: projectController.delete_goal(modelData.id)
                        }
                    }

                    Text {
                        text: "No daily goals. Add one to get started!"
                        font.pixelSize: 12
                        color: "#70757A"
                        visible: projectController.goals.filter(function(g) { return g.goal_type === 'daily' }).length === 0
                    }
                }
            }

            // Weekly Goals
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: weeklyLayout.implicitHeight + 32
                radius: 10
                color: "#FFFFFF"
                border.color: "#E0E0E0"

                ColumnLayout {
                    id: weeklyLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Weekly Goals"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: projectController.goals.filter(function(g) { return g.goal_type === 'weekly' && g.status === 'completed' }).length + "/" + projectController.goals.filter(function(g) { return g.goal_type === 'weekly' }).length + " completed"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }
                    }

                    Repeater {
                        model: projectController.goals.filter(function(g) { return g.goal_type === 'weekly' })

                        delegate: GoalItem {
                            Layout.fillWidth: true
                            goal: modelData
                            onStatusChanged: projectController.refresh_goals()
                            onEditClicked: {
                                goalDialog.setGoal(modelData)
                                goalDialog.open()
                            }
                            onDeleted: projectController.delete_goal(modelData.id)
                        }
                    }

                    Text {
                        text: "No weekly goals. Add one to get started!"
                        font.pixelSize: 12
                        color: "#70757A"
                        visible: projectController.goals.filter(function(g) { return g.goal_type === 'weekly' }).length === 0
                    }
                }
            }

            // Monthly Goals
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: monthlyLayout.implicitHeight + 32
                radius: 10
                color: "#FFFFFF"
                border.color: "#E0E0E0"

                ColumnLayout {
                    id: monthlyLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Monthly Goals"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: projectController.goals.filter(function(g) { return g.goal_type === 'monthly' && g.status === 'completed' }).length + "/" + projectController.goals.filter(function(g) { return g.goal_type === 'monthly' }).length + " completed"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }
                    }

                    Repeater {
                        model: projectController.goals.filter(function(g) { return g.goal_type === 'monthly' })

                        delegate: GoalItem {
                            Layout.fillWidth: true
                            goal: modelData
                            onStatusChanged: projectController.refresh_goals()
                            onEditClicked: {
                                goalDialog.setGoal(modelData)
                                goalDialog.open()
                            }
                            onDeleted: projectController.delete_goal(modelData.id)
                        }
                    }

                    Text {
                        text: "No monthly goals. Add one to get started!"
                        font.pixelSize: 12
                        color: "#70757A"
                        visible: projectController.goals.filter(function(g) { return g.goal_type === 'monthly' }).length === 0
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }

    // Goal Item Component
    component GoalItem: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 50
        radius: 6
        color: "#F8F9FA"
        border.color: "#E0E0E0"

        property var goal: ({})
        signal statusChanged()
        signal editClicked()
        signal deleted()

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            CheckBox {
                checked: goal.status === "completed"
                onClicked: {
                    var newStatus = checked ? "completed" : "pending"
                    projectController.update_goal(goal.id, goal.title, goal.description, goal.goal_type, goal.target_date, newStatus, goal.priority, goal.tags, goal.is_recurring === 1)
                    statusChanged()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: goal.title || "Untitled Goal"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#202124"
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 12

                    Text {
                        text: "Due: " + (goal.target_date || "None")
                        font.pixelSize: 11
                        color: "#5F6368"
                    }

                    Text {
                        text: "Priority: " + goal.priority
                        font.pixelSize: 11
                        color: {
                            switch(goal.priority) {
                                case "high": return "#EA4335"
                                case "critical": return "#C5221F"
                                case "low": return "#34A853"
                                default: return "#5F6368"
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 4

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
            }
        }
    }

    // Goal Dialog
    Dialog {
        id: goalDialog
        title: isEdit ? "Edit Goal" : "New Goal"
        modal: true
        width: 500

        property bool isEdit: false
        property int goalId: 0

        function setGoal(goal) {
            if (goal && goal.id) {
                isEdit = true
                goalId = goal.id
                titleInput.text = goal.title || ""
                descInput.text = goal.description || ""
                typeCombo.currentText = goal.goal_type ? goal.goal_type.charAt(0).toUpperCase() + goal.goal_type.slice(1) : "Daily"
                dateInput.text = goal.target_date || ""
                statusCombo.currentText = goal.status ? goal.status.charAt(0).toUpperCase() + goal.status.slice(1) : "Pending"
                priorityCombo.currentText = goal.priority ? goal.priority.charAt(0).toUpperCase() + goal.priority.slice(1) : "Medium"
                tagsInput.text = goal.tags || ""
                recurringCheck.checked = goal.is_recurring === 1
            } else {
                isEdit = false
                goalId = 0
                titleInput.text = ""
                descInput.text = ""
                typeCombo.currentIndex = 0
                dateInput.text = ""
                statusCombo.currentIndex = 0
                priorityCombo.currentIndex = 0
                tagsInput.text = ""
                recurringCheck.checked = false
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            CustomTextField {
                id: titleInput
                label: "Title *"
                Layout.fillWidth: true
            }

            TextArea {
                id: descInput
                Layout.fillWidth: true
                implicitHeight: 80
                placeholderText: "Describe your goal..."
                wrapMode: TextArea.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Type"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#5F6368"
                    }

                    CustomComboBox {
                        id: typeCombo
                        Layout.fillWidth: true
                        model: ["Daily", "Weekly", "Monthly"]
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Status"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#5F6368"
                    }

                    CustomComboBox {
                        id: statusCombo
                        Layout.fillWidth: true
                        model: ["Pending", "In Progress", "Completed", "Failed"]
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Priority"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#5F6368"
                    }

                    CustomComboBox {
                        id: priorityCombo
                        Layout.fillWidth: true
                        model: ["Low", "Medium", "High", "Critical"]
                    }
                }

                CustomTextField {
                    id: dateInput
                    label: "Target Date"
                    placeholderText: "YYYY-MM-DD"
                    Layout.fillWidth: true
                }
            }

            CustomTextField {
                id: tagsInput
                label: "Tags (comma separated)"
                placeholderText: "e.g., work, personal"
                Layout.fillWidth: true
            }

            CheckBox {
                id: recurringCheck
                text: "Recurring Goal"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CustomButton {
                    text: "Cancel"
                    variant: "ghost"
                    Layout.fillWidth: true
                    onClicked: goalDialog.close()
                }

                CustomButton {
                    text: isEdit ? "Update" : "Add"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: {
                        if (titleInput.text.trim().length > 0) {
                            if (isEdit) {
                                projectController.update_goal(
                                    goalId, titleInput.text, descInput.text,
                                    typeCombo.currentText.toLowerCase(),
                                    dateInput.text, statusCombo.currentText.toLowerCase(),
                                    priorityCombo.currentText.toLowerCase(),
                                    tagsInput.text, recurringCheck.checked
                                )
                            } else {
                                projectController.add_goal(
                                    titleInput.text, descInput.text,
                                    typeCombo.currentText.toLowerCase(),
                                    dateInput.text, statusCombo.currentText.toLowerCase(),
                                    priorityCombo.currentText.toLowerCase(),
                                    tagsInput.text, recurringCheck.checked
                                )
                            }
                            goalDialog.close()
                        }
                    }
                }
            }
        }
    }
}
