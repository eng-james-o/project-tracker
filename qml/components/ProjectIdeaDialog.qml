import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

CustomModal {
    id: root

    width: 500
    title: isEdit ? "Edit Idea" : "New Project Idea"
    saveButtonText: isEdit ? "Update" : "Add"
    canSave: titleInput.text.trim().length > 0

    property bool isEdit: false
    property int ideaId: 0

    function setIdea(idea) {
        if (idea && idea.id) {
            isEdit = true
            ideaId = idea.id
            titleInput.text = idea.title || ""
            descInput.text = idea.description || ""
            statusCombo.currentIndex = statusCombo.model.indexOf(
                formatChoice(idea.status, "Idea")
            )
            priorityCombo.currentIndex = priorityCombo.model.indexOf(
                formatChoice(idea.priority, "Medium")
            )
            budgetInput.text = idea.estimated_budget
                    ? idea.estimated_budget.toString() : ""
            timelineInput.text = idea.estimated_timeline || ""
            tagsInput.text = idea.tags || ""
        } else {
            isEdit = false
            ideaId = 0
            titleInput.text = ""
            descInput.text = ""
            statusCombo.currentIndex = 0
            priorityCombo.currentIndex = 1
            budgetInput.text = ""
            timelineInput.text = ""
            tagsInput.text = ""
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
        var budget = parseFloat(budgetInput.text) || 0
        var status = statusCombo.currentText.toLowerCase().replace(/ /g, "_")
        var priority = priorityCombo.currentText.toLowerCase()
        if (isEdit) {
            planningController.update_project_idea(
                ideaId, titleInput.text, descInput.text, status, priority,
                tagsInput.text, budget, timelineInput.text
            )
        } else {
            planningController.add_project_idea(
                titleInput.text, descInput.text, status, priority,
                tagsInput.text, budget, timelineInput.text
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
            placeholderText: "Describe your project idea..."
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
                    text: "Status"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Style.textSecondary
                }

                CustomComboBox {
                    id: statusCombo
                    Layout.fillWidth: true
                    model: ["Idea", "Planned", "In Progress", "Completed", "Rejected"]
                }
            }

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
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CustomTextField {
                id: budgetInput
                label: "Estimated Budget"
                placeholderText: "0.00"
                Layout.fillWidth: true
            }

            CustomTextField {
                id: timelineInput
                label: "Timeline"
                placeholderText: "e.g., 2 weeks"
                Layout.fillWidth: true
            }
        }

        CustomTextField {
            id: tagsInput
            label: "Tags (comma separated)"
            placeholderText: "e.g., web, mobile, design"
            Layout.fillWidth: true
        }
    }
}
