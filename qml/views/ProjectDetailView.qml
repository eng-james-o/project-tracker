import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal backClicked()
    signal navigateToAuditView()

    property var project: projectController.selectedProject

    property int itemToDeleteId: 0
    property string itemToDeleteType: ""

    // Editing State
    property int editItemId: 0
    property string editItemType: "" // "step", "deliverable", "resource"

    // Edit Item Dialog
    Dialog {
        id: editItemDialog
        title: "Edit " + (root.editItemType === "step" ? "Step" : (root.editItemType === "deliverable" ? "Deliverable" : "Resource"))
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        width: 380

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            CustomTextField {
                id: editTitleInput
                label: "Title *"
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.editItemType !== "resource"

                CustomTextField {
                    id: editDeadlineInput
                    label: "Deadline"
                    placeholderText: "YYYY-MM-DD"
                    Layout.fillWidth: true
                }

                Button {
                    flat: true
                    implicitWidth: 34
                    implicitHeight: 34
                    Layout.alignment: Qt.AlignBottom
                    contentItem: Image {
                        anchors.centerIn: parent
                        source: "../../assets/calendar.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    onClicked: editDatePicker.open()
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.editItemType === "resource"

                ComboBox {
                    id: editResTypeCombo
                    model: ["link", "document", "folder", "note"]
                    Layout.fillWidth: true
                }

                CustomTextField {
                    id: editResPathInput
                    label: "Path or Content"
                    Layout.fillWidth: true
                }
            }
        }

        onAccepted: {
            if (root.editItemType === "step") {
                projectController.update_step(root.editItemId, editTitleInput.text, editDeadlineInput.text)
            } else if (root.editItemType === "deliverable") {
                projectController.update_deliverable(root.editItemId, editTitleInput.text, editDeadlineInput.text)
            } else if (root.editItemType === "resource") {
                projectController.update_resource(root.editItemId, editResTypeCombo.currentText, editTitleInput.text, editResPathInput.text)
            }
        }
    }

    DatePickerDialog {
        id: editDatePicker
        anchors.centerIn: parent
        onDateSelected: function(selectedDate) {
            editDeadlineInput.text = selectedDate
        }
    }

    DatePickerDialog {
        id: stepDatePicker
        anchors.centerIn: parent
        onDateSelected: function(selectedDate) {
            newStepDeadline.text = selectedDate
        }
    }

    DatePickerDialog {
        id: delivDatePicker
        anchors.centerIn: parent
        onDateSelected: function(selectedDate) {
            newDelivDeadline.text = selectedDate
        }
    }

    // Generic Delete Confirmation Dialog
    Dialog {
        id: confirmDeleteDialog
        title: "Confirm Deletion"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent

        Text {
            text: {
                if (root.itemToDeleteType === "project")
                    return "Are you sure you want to delete this project and all its tasks, deliverables, and resources?"
                else if (root.itemToDeleteType === "step")
                    return "Are you sure you want to delete this step?"
                else if (root.itemToDeleteType === "deliverable")
                    return "Are you sure you want to delete this deliverable?"
                else if (root.itemToDeleteType === "resource")
                    return "Are you sure you want to remove this resource?"
                return "Are you sure you want to proceed?"
            }
            font.pixelSize: 13
            color: "#202124"
        }

        onAccepted: {
            if (root.itemToDeleteType === "project") {
                projectController.delete_project(root.project.id)
                root.backClicked()
            } else if (root.itemToDeleteType === "step") {
                projectController.delete_step(root.itemToDeleteId)
            } else if (root.itemToDeleteType === "deliverable") {
                projectController.delete_deliverable(root.itemToDeleteId)
            } else if (root.itemToDeleteType === "resource") {
                projectController.delete_resource(root.itemToDeleteId)
            }
        }
    }

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
                onClicked: {
                    root.itemToDeleteType = "project"
                    confirmDeleteDialog.open()
                }
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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Created: " + (root.project.created_at || "N/A")
                        font.pixelSize: 11
                        color: "#70757A"
                    }

                    Text {
                        text: "Last Updated: " + (root.project.updated_at || "N/A")
                        font.pixelSize: 11
                        color: "#70757A"
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

                        Text {
                            text: "Project Steps / Tasks"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#202124"
                        }

                        // Add Step Input Box
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            CustomTextField {
                                id: newStepTitle
                                placeholderText: "Step title (e.g., Wireframing, API Design)..."
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 4

                                CustomTextField {
                                    id: newStepDeadline
                                    placeholderText: "YYYY-MM-DD"
                                    implicitWidth: 120
                                }

                                Button {
                                    flat: true
                                    implicitWidth: 34
                                    implicitHeight: 34
                                    contentItem: Image {
                                        anchors.centerIn: parent
                                        source: "../../assets/calendar.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                    }
                                    onClicked: stepDatePicker.open()
                                }
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
                                onEditClicked: {
                                    root.editItemType = "step"
                                    root.editItemId = modelData.id
                                    editTitleInput.text = modelData.title || ""
                                    editDeadlineInput.text = modelData.deadline || ""
                                    editItemDialog.open()
                                }
                                onDeleted: {
                                    root.itemToDeleteType = "step"
                                    root.itemToDeleteId = modelData.id
                                    confirmDeleteDialog.open()
                                }
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
                                placeholderText: "Deliverable title (e.g., Final Prototype PDF)..."
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 4

                                CustomTextField {
                                    id: newDelivDeadline
                                    placeholderText: "YYYY-MM-DD"
                                    implicitWidth: 120
                                }

                                Button {
                                    flat: true
                                    implicitWidth: 34
                                    implicitHeight: 34
                                    contentItem: Image {
                                        anchors.centerIn: parent
                                        source: "../../assets/calendar.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                    }
                                    onClicked: delivDatePicker.open()
                                }
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
                                onEditClicked: {
                                    root.editItemType = "deliverable"
                                    root.editItemId = modelData.id
                                    editTitleInput.text = modelData.title || ""
                                    editDeadlineInput.text = modelData.deadline || ""
                                    editItemDialog.open()
                                }
                                onDeleted: {
                                    root.itemToDeleteType = "deliverable"
                                    root.itemToDeleteId = modelData.id
                                    confirmDeleteDialog.open()
                                }
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

            // Right Column: Resources & Audit Trail (Top 6 entries)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: 45
                spacing: 20

                // Resources Section
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
                                    placeholderText: "Resource Title (e.g., Design Brief)..."
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

                        // Resources Scrollable List
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: root.project.resources || []

                                delegate: ResourceItem {
                                    Layout.fillWidth: true
                                    resource: modelData
                                    onEditClicked: {
                                        root.editItemType = "resource"
                                        root.editItemId = modelData.id
                                        editTitleInput.text = modelData.title || ""
                                        editResPathInput.text = modelData.path_or_content || ""
                                        editItemDialog.open()
                                    }
                                    onDeleted: {
                                        root.itemToDeleteType = "resource"
                                        root.itemToDeleteId = modelData.id
                                        confirmDeleteDialog.open()
                                    }
                                }
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

                // Audit Trail Section (Top 6 entries limit + Link to Full View)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: auditColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: auditColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Recent Activity (Top 6)"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                                Layout.fillWidth: true
                            }

                            Button {
                                text: "View All Activity ->"
                                flat: true
                                onClicked: root.navigateToAuditView()
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: (root.project.audit_logs || []).slice(0, 6)

                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 36
                                    radius: 4
                                    color: "#F8F9FA"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Text {
                                            text: modelData.details + (modelData.repeat_count > 1 ? (" (x" + modelData.repeat_count + ")") : "")
                                            font.pixelSize: 11
                                            color: "#202124"
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.timestamp
                                            font.pixelSize: 10
                                            color: "#70757A"
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: "No recent activity recorded."
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.audit_logs && root.project.audit_logs.length > 0)
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
