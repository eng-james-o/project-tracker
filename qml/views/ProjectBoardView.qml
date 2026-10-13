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
                    text: "Project Ideas Board"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#202124"
                }
                Text {
                    text: "Plan and organize your future project ideas"
                    font.pixelSize: 13
                    color: "#5F6368"
                }
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "+ New Idea"
                onClicked: {
                    ideaDialog.setIdea(null)
                    ideaDialog.open()
                }
            }
        }

        // Filter and Search Bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 60
            radius: 8
            color: "#FFFFFF"
            border.color: "#E0E0E0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

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
                        placeholderText: "Search ideas..."
                        Layout.fillWidth: true
                        onTextChanged: projectController.setProjectIdeasSearch(text)
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
                        model: ["All", "Idea", "Planned", "In Progress", "Completed", "Rejected"]
                        onCurrentTextChanged: projectController.setProjectIdeasFilter(currentText)
                    }
                }
            }
        }

        // Ideas Grid
        GridLayout {
            Layout.fillWidth: true
            columns: root.width > 900 ? 3 : (root.width > 600 ? 2 : 1)
            rowSpacing: 16
            columnSpacing: 16

            Repeater {
                model: projectController.projectIdeas

                delegate: Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 180
                    radius: 8
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.title || "Untitled Idea"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: {
                                    switch(modelData.status) {
                                        case "idea": return "#FBBC04"
                                        case "planned": return "#34A853"
                                        case "in_progress": return "#1A73E8"
                                        case "completed": return "#174EA6"
                                        case "rejected": return "#EA4335"
                                        default: return "#5F6368"
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.description || "No description"
                            font.pixelSize: 12
                            color: "#5F6368"
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Priority: " + modelData.priority
                                font.pixelSize: 11
                                color: "#70757A"
                            }

                            Text {
                                text: modelData.estimated_budget > 0 ? "Budget: " + modelData.estimated_budget + " " + (modelData.currency || "USD") : ""
                                font.pixelSize: 11
                                color: "#70757A"
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            CustomButton {
                                text: "Edit"
                                variant: "ghost"
                                implicitWidth: 80
                                onClicked: {
                                    ideaDialog.setIdea(modelData)
                                    ideaDialog.open()
                                }
                            }

                            CustomButton {
                                text: "Delete"
                                variant: "danger"
                                implicitWidth: 80
                                onClicked: {
                                    projectController.delete_project_idea(modelData.id)
                                }
                            }

                            Item { Layout.fillWidth: true }

                            CustomButton {
                                text: "Convert to Project"
                                variant: "primary"
                                onClicked: {
                                    projectDialog.setProject(null)
                                    projectDialog.titleInput.text = modelData.title
                                    projectDialog.descInput.text = modelData.description
                                    projectDialog.open()
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        Text {
            text: "No project ideas yet. Click 'New Idea' to add one!"
            font.pixelSize: 14
            color: "#70757A"
            Layout.alignment: Qt.AlignHCenter
            visible: projectController.projectIdeas.length === 0
        }

        Item { implicitHeight: 20 }
    }

    // Idea Dialog
    Dialog {
        id: ideaDialog
        title: isEdit ? "Edit Idea" : "New Project Idea"
        modal: true
        width: 500

        property bool isEdit: false
        property int ideaId: 0

        function setIdea(idea) {
            if (idea && idea.id) {
                isEdit = true
                ideaId = idea.id
                titleInput.text = idea.title || ""
                descInput.text = idea.description || ""
                statusCombo.currentText = idea.status ? idea.status.charAt(0).toUpperCase() + idea.status.slice(1) : "Idea"
                priorityCombo.currentText = idea.priority ? idea.priority.charAt(0).toUpperCase() + idea.priority.slice(1) : "Medium"
                budgetInput.text = idea.estimated_budget ? idea.estimated_budget.toString() : ""
                timelineInput.text = idea.estimated_timeline || ""
                tagsInput.text = idea.tags || ""
            } else {
                isEdit = false
                ideaId = 0
                titleInput.text = ""
                descInput.text = ""
                statusCombo.currentIndex = 0
                priorityCombo.currentIndex = 0
                budgetInput.text = ""
                timelineInput.text = ""
                tagsInput.text = ""
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
                placeholderText: "Describe your project idea..."
                wrapMode: TextArea.Wrap
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
                        color: "#5F6368"
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
                        color: "#5F6368"
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CustomButton {
                    text: "Cancel"
                    variant: "ghost"
                    Layout.fillWidth: true
                    onClicked: ideaDialog.close()
                }

                CustomButton {
                    text: isEdit ? "Update" : "Add"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: {
                        if (titleInput.text.trim().length > 0) {
                            var budget = parseFloat(budgetInput.text) || 0
                            if (isEdit) {
                                projectController.update_project_idea(
                                    ideaId, titleInput.text, descInput.text,
                                    statusCombo.currentText.toLowerCase(),
                                    priorityCombo.currentText.toLowerCase(),
                                    tagsInput.text, budget, timelineInput.text
                                )
                            } else {
                                projectController.add_project_idea(
                                    titleInput.text, descInput.text,
                                    statusCombo.currentText.toLowerCase(),
                                    priorityCombo.currentText.toLowerCase(),
                                    tagsInput.text, budget, timelineInput.text
                                )
                            }
                            ideaDialog.close()
                        }
                    }
                }
            }
        }
    }
}
