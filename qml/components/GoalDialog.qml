import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

CustomModal {
    id: root

    width: 500
    title: isEdit ? "Edit Goal" : "New Goal"
    saveButtonText: isEdit ? "Update" : "Add"
    canSave: titleInput.text.trim().length > 0

    property bool isEdit: false
    property int goalId: 0

    function setGoal(goal) {
        if (goal && goal.id) {
            isEdit = true
            goalId = goal.id
            titleInput.text = goal.title || ""
            descInput.text = goal.description || ""
            typeCombo.currentIndex = typeCombo.model.indexOf(
                formatChoice(goal.goal_type, "Daily")
            )
            dateInput.text = goal.target_date || ""
            statusCombo.currentIndex = statusCombo.model.indexOf(
                formatChoice(goal.status, "Pending")
            )
            priorityCombo.currentIndex = priorityCombo.model.indexOf(
                formatChoice(goal.priority, "Medium")
            )
            tagsInput.text = goal.tags || ""
            recurringCheck.checked = goal.is_recurring === 1
                    || goal.is_recurring === true
        } else {
            isEdit = false
            goalId = 0
            titleInput.text = ""
            descInput.text = ""
            typeCombo.currentIndex = 0
            dateInput.text = ""
            statusCombo.currentIndex = 0
            priorityCombo.currentIndex = 1
            tagsInput.text = ""
            recurringCheck.checked = false
        }
    }

    function formatChoice(value, fallback) {
        if (!value) {
            return fallback
        }
        var words = value.replace(/_/g, " ").split(" ")
        for (var i = 0; i < words.length; ++i) {
            words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1)
        }
        return words.join(" ")
    }

    onAccepted: {
        var goalType = typeCombo.currentText.toLowerCase().replace(/ /g, "_")
        var status = statusCombo.currentText.toLowerCase().replace(/ /g, "_")
        var priority = priorityCombo.currentText.toLowerCase()
        if (isEdit) {
            planningController.update_goal(
                goalId, titleInput.text, descInput.text, goalType,
                dateInput.text, status, priority, tagsInput.text,
                recurringCheck.checked
            )
        } else {
            planningController.add_goal(
                titleInput.text, descInput.text, goalType,
                dateInput.text, status, priority, tagsInput.text,
                recurringCheck.checked
            )
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
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
            color: Style.textMain
            selectionColor: Style.primaryHover
            selectedTextColor: Style.surface
            placeholderTextColor: Style.textSecondary
            background: Rectangle {
                radius: Style.radiusMedium
                color: Style.background
                border.color: descInput.activeFocus ? Style.primary : Style.border
            }
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
                    color: Style.textSecondary
                }

                CustomComboBox {
                    id: typeCombo
                    Layout.fillWidth: true
                    model: ["Daily", "Weekly", "Monthly"]
                }
                visible: recurringCheck.checked
            }

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                Text {
                    text: "Status"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Style.textSecondary
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
                    color: Style.textSecondary
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

        CustomCheckBox {
            id: recurringCheck
            text: "Recurring Goal"
        }
    }
}
