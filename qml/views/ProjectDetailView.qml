import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

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

    // Resource Modal
    ResourceModal {
        id: resourceModal
        anchors.centerIn: parent
    }

    // Clipboard Handler
    ClipboardHandler {
        id: clipboardHandler
    }

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
                else if (root.itemToDeleteType === "blocker")
                    return "Are you sure you want to delete this blocker?"
                else if (root.itemToDeleteType === "payment")
                    return "Are you sure you want to delete this payment record?"
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
            } else if (root.itemToDeleteType === "blocker") {
                projectController.delete_blocker(root.itemToDeleteId)
            } else if (root.itemToDeleteType === "payment") {
                projectController.delete_payment(root.itemToDeleteId)
            }
        }
    }

    // Blocker Dialog
    Dialog {
        id: blockerDialog
        title: isEdit ? "Edit Blocker" : "Add Blocker"
        modal: true
        width: 420
        anchors.centerIn: parent

        property bool isEdit: false
        property int blockerId: 0
        property int projectId: 0

        function setBlocker(blocker, pid) {
            projectId = pid
            if (blocker && blocker.id) {
                isEdit = true
                blockerId = blocker.id
                titleInput.text = blocker.title || ""
                descInput.text = blocker.description || ""
                severityCombo.currentText = blocker.severity ? blocker.severity.charAt(0).toUpperCase() + blocker.severity.slice(1) : "Medium"
                statusCombo.currentText = blocker.status ? blocker.status.charAt(0).toUpperCase() + blocker.status.slice(1) : "Open"
            } else {
                isEdit = false
                blockerId = 0
                titleInput.text = ""
                descInput.text = ""
                severityCombo.currentIndex = 0
                statusCombo.currentIndex = 0
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
                placeholderText: "Describe the blocker..."
                wrapMode: TextArea.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true

                    Text {
                        text: "Severity"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#5F6368"
                    }

                    CustomComboBox {
                        id: severityCombo
                        Layout.fillWidth: true
                        model: ["Low", "Medium", "High", "Critical"]
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
                        model: ["Open", "In Progress", "Resolved"]
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CustomButton {
                    text: "Cancel"
                    variant: "ghost"
                    Layout.fillWidth: true
                    onClicked: blockerDialog.close()
                }

                CustomButton {
                    text: isEdit ? "Update" : "Add"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: {
                        if (titleInput.text.trim().length > 0) {
                            if (isEdit) {
                                projectController.update_blocker(
                                    blockerId, titleInput.text, descInput.text,
                                    severityCombo.currentText.toLowerCase(),
                                    statusCombo.currentText.toLowerCase()
                                )
                            } else {
                                projectController.add_blocker(
                                    projectId, -1, titleInput.text, descInput.text,
                                    severityCombo.currentText.toLowerCase(),
                                    statusCombo.currentText.toLowerCase()
                                )
                            }
                            blockerDialog.close()
                        }
                    }
                }
            }
        }
    }

    // Payment Dialog
    Dialog {
        id: paymentDialog
        title: isEdit ? "Edit Payment" : "Add Payment"
        modal: true
        width: 420
        anchors.centerIn: parent

        property bool isEdit: false
        property int paymentId: 0
        property int projectId: 0

        function setPayment(payment, pid) {
            projectId = pid
            if (payment && payment.id) {
                isEdit = true
                paymentId = payment.id
                amountInput.text = payment.amount ? payment.amount.toString() : "0"
                currencyCombo.currentText = payment.currency || "USD"
                dateInput.text = payment.payment_date || ""
                methodInput.text = payment.payment_method || ""
                descInput.text = payment.description || ""
            } else {
                isEdit = false
                paymentId = 0
                amountInput.text = "0"
                currencyCombo.currentIndex = 0
                dateInput.text = ""
                methodInput.text = ""
                descInput.text = ""
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            CustomTextField {
                id: amountInput
                label: "Amount *"
                placeholderText: "0.00"
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CustomTextField {
                    id: currencyCombo
                    label: "Currency"
                    Layout.fillWidth: true
                    model: ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY"]
                }

                CustomTextField {
                    id: dateInput
                    label: "Payment Date"
                    placeholderText: "YYYY-MM-DD"
                    Layout.fillWidth: true
                }
            }

            CustomTextField {
                id: methodInput
                label: "Payment Method"
                placeholderText: "e.g., Bank Transfer, PayPal, Cash"
                Layout.fillWidth: true
            }

            TextArea {
                id: descInput
                Layout.fillWidth: true
                implicitHeight: 60
                placeholderText: "Payment description or reference..."
                wrapMode: TextArea.Wrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CustomButton {
                    text: "Cancel"
                    variant: "ghost"
                    Layout.fillWidth: true
                    onClicked: paymentDialog.close()
                }

                CustomButton {
                    text: isEdit ? "Update" : "Add"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: {
                        if (amountInput.text.trim().length > 0) {
                            var amount = parseFloat(amountInput.text) || 0
                            if (isEdit) {
                                projectController.update_payment(
                                    paymentId, amount, currencyCombo.currentText,
                                    dateInput.text, methodInput.text, descInput.text
                                )
                            } else {
                                projectController.add_payment(
                                    projectId, amount, currencyCombo.currentText,
                                    dateInput.text, methodInput.text, descInput.text
                                )
                            }
                            paymentDialog.close()
                        }
                    }
                }
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

        // Financial Summary Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: financialLayout.implicitHeight + 32
            radius: 10
            color: "#FFFFFF"
            border.color: "#E0E0E0"

            ColumnLayout {
                id: financialLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Financial Summary"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#202124"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Total Price"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }

                        Text {
                            text: (root.project.currency || "USD") + " " + (root.project.price ? root.project.price.toFixed(2) : "0.00")
                            font.pixelSize: 18
                            font.bold: true
                            color: "#202124"
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Amount Paid"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }

                        Text {
                            text: (root.project.currency || "USD") + " " + (root.project.paid_amount ? root.project.paid_amount.toFixed(2) : "0.00")
                            font.pixelSize: 18
                            font.bold: true
                            color: "#34A853"
                        }
                    }

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Remaining"
                            font.pixelSize: 12
                            color: "#5F6368"
                        }

                        Text {
                            text: (root.project.currency || "USD") + " " + (root.project.price_remaining ? root.project.price_remaining.toFixed(2) : "0.00")
                            font.pixelSize: 18
                            font.bold: true
                            color: root.project.price_remaining > 0 ? "#EA4335" : "#34A853"
                        }
                    }
                }

                Text {
                    text: "Tags: " + (root.project.tags_list && root.project.tags_list.length > 0 ? root.project.tags_list.join(", ") : "None")
                    font.pixelSize: 12
                    color: "#5F6368"
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

                // Blockers Section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: blockersColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: blockersColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Blockers (" + (root.project.blockers ? root.project.blockers.length : 0) + ")"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                            }

                            Item { Layout.fillWidth: true }

                            CustomButton {
                                text: "+ Add Blocker"
                                variant: "secondary"
                                onClicked: {
                                    blockerDialog.setBlocker(null, root.project.id)
                                    blockerDialog.open()
                                }
                            }
                        }

                        // Blockers List
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: root.project.blockers || []

                                delegate: BlockerItem {
                                    Layout.fillWidth: true
                                    blocker: modelData
                                    onEditClicked: {
                                        blockerDialog.setBlocker(modelData, root.project.id)
                                        blockerDialog.open()
                                    }
                                    onDeleted: {
                                        root.itemToDeleteType = "blocker"
                                        root.itemToDeleteId = modelData.id
                                        confirmDeleteDialog.open()
                                    }
                                }
                            }
                        }

                        Text {
                            text: "No blockers. Great!"
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.blockers && root.project.blockers.length > 0)
                        }
                    }
                }

                // Payments Section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: paymentsColumn.implicitHeight + 32
                    radius: 10
                    color: "#FFFFFF"
                    border.color: "#E0E0E0"

                    ColumnLayout {
                        id: paymentsColumn
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Payment Trail (" + (root.project.payments ? root.project.payments.length : 0) + ")"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                            }

                            Item { Layout.fillWidth: true }

                            CustomButton {
                                text: "+ Add Payment"
                                variant: "secondary"
                                onClicked: {
                                    paymentDialog.setPayment(null, root.project.id)
                                    paymentDialog.open()
                                }
                            }
                        }

                        // Payments List
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Repeater {
                                model: root.project.payments || []

                                delegate: PaymentItem {
                                    Layout.fillWidth: true
                                    payment: modelData
                                    onEditClicked: {
                                        paymentDialog.setPayment(modelData, root.project.id)
                                        paymentDialog.open()
                                    }
                                    onDeleted: {
                                        root.itemToDeleteType = "payment"
                                        root.itemToDeleteId = modelData.id
                                        confirmDeleteDialog.open()
                                    }
                                }
                            }
                        }

                        Text {
                            text: "No payments recorded yet."
                            font.pixelSize: 12
                            color: "#70757A"
                            visible: !(root.project.payments && root.project.payments.length > 0)
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

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: "Resources & Notes"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#202124"
                            }

                            Item { Layout.fillWidth: true }

                            CustomButton {
                                text: "+ Add Resource"
                                variant: "secondary"
                                onClicked: {
                                    resourceModal.setResource(null, root.project.id)
                                    resourceModal.open()
                                }
                            }
                        }

                        // Clipboard paste hint
                        Text {
                            text: clipboardHandler.isClipboardTextAUrl() ? "URL detected in clipboard - click to paste" : ""
                            font.pixelSize: 11
                            color: "#34A853"
                            visible: clipboardHandler.isClipboardTextAUrl()
                        }

                        // Drag and drop area
                        DropArea {
                            Layout.fillWidth: true
                            implicitHeight: 80
                            onFilesDropped: function(files) {
                                for (var i = 0; i < files.length; i++) {
                                    var file = files[i]
                                    var fileName = file.split("/").pop()
                                    var ext = fileName.split(".").pop().toLowerCase()
                                    
                                    var type = "document"
                                    if (ext === "md" || ext === "markdown" || ext === "txt") {
                                        type = "markdown"
                                    } else if (ext === "pdf" || ext === "doc" || ext === "docx") {
                                        type = "document"
                                    } else if (file.startsWith("http")) {
                                        type = "link"
                                    }
                                    
                                    projectController.add_resource(root.project.id, type, fileName, file)
                                }
                            }
                            onTextDropped: function(text) {
                                var type = "note"
                                var formattedText = text
                                
                                if (clipboardHandler.isValidUrl(text)) {
                                    type = "link"
                                    formattedText = clipboardHandler.formatUrl(text)
                                }
                                
                                projectController.add_resource(root.project.id, type, "Dropped Text", formattedText)
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
                                        resourceModal.setResource(modelData, root.project.id)
                                        resourceModal.isEditing = true
                                        resourceModal.open()
                                    }
                                    onViewClicked: {
                                        resourceModal.setResource(modelData, root.project.id)
                                        resourceModal.isEditing = false
                                        resourceModal.open()
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
                            text: "No resources attached yet. Drag & drop files or links, or click '+ Add Resource'"
                            font.pixelSize: 12
                            color: "#70757A"
                            Layout.alignment: Qt.AlignHCenter
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
