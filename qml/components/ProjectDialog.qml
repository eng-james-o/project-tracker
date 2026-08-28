import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    title: isEdit ? "Edit Project" : "New Project"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: 480

    property bool isEdit: false
    property int projectId: 0

    property alias projectTitle: titleInput.text
    property alias clientName: clientNameInput.text
    property alias clientEmail: clientEmailInput.text
    property alias deadline: deadlineInput.text
    property alias description: descInput.text
    property string status: statusCombo.currentText.toLowerCase()

    function setProject(p) {
        if (p && p.id) {
            isEdit = true
            projectId = p.id
            titleInput.text = p.title || ""
            clientNameInput.text = p.client_name || ""
            clientEmailInput.text = p.client_email || ""
            deadlineInput.text = p.deadline || ""
            descInput.text = p.description || ""
            var stat = (p.status || "active").toLowerCase()
            if (stat === "active") statusCombo.currentIndex = 0
            else if (stat === "paused") statusCombo.currentIndex = 1
            else if (stat === "completed") statusCombo.currentIndex = 2
        } else {
            isEdit = false
            projectId = 0
            titleInput.text = ""
            clientNameInput.text = ""
            clientEmailInput.text = ""
            deadlineInput.text = ""
            descInput.text = ""
            statusCombo.currentIndex = 0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        CustomTextField {
            id: titleInput
            label: "Project Title *"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CustomTextField {
                id: clientNameInput
                label: "Client Name"
                Layout.fillWidth: true
            }

            CustomTextField {
                id: clientEmailInput
                label: "Client Email"
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CustomTextField {
                id: deadlineInput
                label: "Deadline (YYYY-MM-DD)"
                placeholderText: "2026-12-31"
                Layout.fillWidth: true
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

                ComboBox {
                    id: statusCombo
                    Layout.fillWidth: true
                    model: ["Active", "Paused", "Completed"]
                }
            }
        }

        ColumnLayout {
            spacing: 4
            Layout.fillWidth: true

            Text {
                text: "Description / Notes"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#5F6368"
            }

            TextArea {
                id: descInput
                Layout.fillWidth: true
                implicitHeight: 80
                wrapMode: TextArea.Wrap
                background: Rectangle {
                    radius: 6
                    color: "#F8F9FA"
                    border.color: descInput.activeFocus ? "#1A73E8" : "#DADCE0"
                }
            }
        }
    }
}
