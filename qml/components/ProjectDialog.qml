import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Dialog {
    id: root
    title: isEdit ? "Edit Project" : "New Project"
    modal: true
    width: 480
    
    header: Rectangle {
        color: Style.background
        implicitHeight: 60
        radius: Style.radiusLarge
        
        // This hides the rounding at the bottom by drawing a rectangle over it
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Style.radiusLarge
            color: Style.background
        }
        
        Text {
            anchors.centerIn: parent
            text: root.title
            font.pixelSize: 18
            font.bold: true
            color: Style.textMain
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Style.border
        }
    }

    background: Rectangle {
        color: Style.surface
        radius: Style.radiusLarge
        border.color: Style.border
    }

    footer: Rectangle {
        implicitHeight: 68
        color: "transparent"
        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            Item { Layout.fillWidth: true }
            CustomButton {
                text: "Cancel"
                variant: "ghost"
                onClicked: root.reject()
            }
            CustomButton {
                text: "Save"
                variant: "primary"
                onClicked: root.accept()
            }
        }
    }

    property bool isEdit: false
    property int projectId: 0

    property alias projectTitle: titleInput.text
    property alias clientName: clientNameInput.text
    property alias clientEmail: clientEmailInput.text
    property alias deadline: deadlineInput.text
    property alias description: descInput.text
    property string status: statusCombo.currentText.toLowerCase()

    DatePickerDialog {
        id: datePicker
        anchors.centerIn: parent
        onDateSelected: function(selectedDate) {
            deadlineInput.text = selectedDate
        }
    }

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
            placeholderText: "e.g., E-Commerce Platform Redesign"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CustomTextField {
                id: clientNameInput
                label: "Client Name"
                placeholderText: "e.g., Acme Corporation"
                Layout.fillWidth: true
            }

            CustomTextField {
                id: clientEmailInput
                label: "Client Email"
                placeholderText: "e.g., client@acme.com"
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                CustomTextField {
                    id: deadlineInput
                    label: "Deadline"
                    placeholderText: "YYYY-MM-DD"
                    Layout.fillWidth: true
                }

                Button {
                    flat: true
                    implicitWidth: 38
                    implicitHeight: 38
                    Layout.alignment: Qt.AlignBottom
                    contentItem: Image {
                        anchors.centerIn: parent
                        source: "../../assets/calendar.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                    }
                    onClicked: datePicker.open()
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
                placeholderText: "Add key requirements, scope details, or client preferences..."
                wrapMode: TextArea.Wrap
                background: Rectangle {
                    radius: Style.radiusMedium
                    color: Style.background
                    border.color: descInput.activeFocus ? Style.primary : Style.border
                }
            }
        }
    }
}
