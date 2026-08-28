import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal backClicked()

    property var project: projectController.selectedProject

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Item { implicitHeight: 10 }

        // Top Navigation Bar
        RowLayout {
            Layout.fillWidth: true

            CustomButton {
                text: "← Back to Projects"
                variant: "secondary"
                implicitWidth: 140
                onClicked: root.backClicked()
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "Edit Project"
                variant: "secondary"
                onClicked: {
                    projectDialog.setProject(root.project)
                    projectDialog.open()
                }
            }

            CustomButton {
                text: "Delete"
                variant: "danger"
                onClicked: confirmDeleteDialog.open()
            }
        }

        // Project Header Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerLayout.implicitHeight + 32
            radius: 10
            color: "#FFFFFF"
            border.color: "#E0E0E0"

            ColumnLayout {
                id: headerLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.project.title || "Untitled Project"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#202124"
                        Layout.fillWidth: true
                    }

                    StatusBadge {
                        status: root.project.status || "active"
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    RowLayout {
                        spacing: 6
                        Image {
                            source: "../../assets/user.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                        }
                        Text {
                            text: "Client: " + (root.project.client_name || "N/A") + (root.project.client_email ? (" (" + root.project.client_email + ")") : "")
                            font.pixelSize: 13
                            color: "#5F6368"
                        }
                    }

                    RowLayout {
                        spacing: 6
                        Image {
                            source: "../../assets/calendar.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                        }
                        Text {
                            text: "Deadline: " + (root.project.deadline || "None")
                            font.pixelSize: 13
                            font.bold: true
                            color: root.project.deadline ? "#C5221F" : "#5F6368"
                        }
                    }
                }

                Text {
                    text: root.project.description || "No description provided."
                    font.pixelSize: 13
                    color: "#3C4043"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }

        // Main Content Area: 2 Columns
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            Layout.alignment: Qt.AlignTop

            // Left Column: Steps & Deliverables
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 55
                spacing: 20

                // Steps Section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: stepsColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: stepsColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Project Steps / Tasks"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                                Layout.fillWidth: true
                            }
                        }

                        // Add Step Input Box
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            CustomTextField {
                                id: newStepTitle
                                placeholderText: "Step title..."
                                Layout.fillWidth: true
                            }

                            CustomTextField {
                                id: newStepDeadline
                                placeholderText: "Deadline (YYYY-MM-DD)"
                                implicitWidth: 150
                            }

                            CustomButton {
                                text: "Add Step"
                                onClicked: {
                                    if (newStepTitle.text.trim().length > 0) {
                                        projectController.add_step(root.project.id, newStepTitle.text, newStepDeadline.text)
                                        newStepTitle.text = ""
                                        newStepDeadline.text = ""
                                    }
                                }
                            }
                        }

                        // Steps List
                        Repeater {
                            model: root.project.steps || []

                            delegate: StepItem {
                                Layout.fillWidth: true
                                step: modelData
                                onToggled: function(completed) { projectController.toggle_step(modelData.id, completed) }
                                onDeleted: projectController.delete_step(modelData.id)
                            }
                        }

                        Text {
                            text: "No steps added yet."
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.steps && root.project.steps.length > 0)
                        }
                    }
                }

                // Deliverables Section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: delivColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: delivColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            text: "Project Deliverables"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        // Add Deliverable Input Box
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            CustomTextField {
                                id: newDelivTitle
                                placeholderText: "Deliverable title..."
                                Layout.fillWidth: true
                            }

                            CustomTextField {
                                id: newDelivDeadline
                                placeholderText: "Deadline (YYYY-MM-DD)"
                                implicitWidth: 150
                            }

                            CustomButton {
                                text: "Add"
                                onClicked: {
                                    if (newDelivTitle.text.trim().length > 0) {
                                        projectController.add_deliverable(root.project.id, newDelivTitle.text, newDelivDeadline.text)
                                        newDelivTitle.text = ""
                                        newDelivDeadline.text = ""
                                    }
                                }
                            }
                        }

                        // Deliverables List
                        Repeater {
                            model: root.project.deliverables || []

                            delegate: DeliverableItem {
                                Layout.fillWidth: true
                                deliverable: modelData
                                onToggled: function(completed) { projectController.toggle_deliverable(modelData.id, completed) }
                                onDeleted: projectController.delete_deliverable(modelData.id)
                            }
                        }

                        Text {
                            text: "No deliverables added yet."
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.deliverables && root.project.deliverables.length > 0)
                        }
                    }
                }
            }

            // Right Column: Resources & Notes
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 45
                spacing: 20

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: resColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: resColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            text: "Resources & Notes"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        // Add Resource Form
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                ComboBox {
                                    id: resTypeCombo
                                    model: ["link", "document", "folder", "note"]
                                    implicitWidth: 110
                                }

                                CustomTextField {
                                    id: resTitleInput
                                    placeholderText: "Resource Title..."
                                    Layout.fillWidth: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                CustomTextField {
                                    id: resPathInput
                                    placeholderText: resTypeCombo.currentText === "note" ? "Type note content here..." : "URL or Folder/File Path..."
                                    Layout.fillWidth: true
                                }

                                CustomButton {
                                    text: "Attach"
                                    onClicked: {
                                        if (resTitleInput.text.trim().length > 0 && resPathInput.text.trim().length > 0) {
                                            projectController.add_resource(root.project.id, resTypeCombo.currentText, resTitleInput.text, resPathInput.text)
                                            resTitleInput.text = ""
                                            resPathInput.text = ""
                                        }
                                    }
                                }
                            }
                        }

                        // Resources List
                        Repeater {
                            model: root.project.resources || []

                            delegate: ResourceItem {
                                Layout.fillWidth: true
                                resource: modelData
                                onDeleted: projectController.delete_resource(modelData.id)
                            }
                        }

                        Text {
                            text: "No resources attached yet."
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.resources && root.project.resources.length > 0)
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }

    // Delete confirmation dialog
    Dialog {
        id: confirmDeleteDialog
        title: "Confirm Delete"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Text {
            text: "Are you sure you want to delete this project and all its tasks?"
            font.pixelSize: 13
        }

        onAccepted: {
            projectController.delete_project(root.project.id)
            root.backClicked()
        }
    }
}
