import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

Popup {
    id: root

    modal: true
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: parent
    width: Math.min(parent.width - 64, 860)
    height: parent.height - 64
    padding: 0

    property bool isEditing: false

    ListModel {
        id: employmentRows
    }

    background: Rectangle {
        radius: Style.radiusXLarge
        color: Style.background
        border.color: Style.border
        border.width: 1
    }

    function prefill() {
        var p = profileController.userProfile || {}
        firstNameInput.text = p.first_name || ""
        lastNameInput.text = p.last_name || ""
        nicknameInput.text = p.nickname || ""
        emailInput.text = p.email || ""
        employmentRows.clear()
        var employment = p.employment_history || []
        for (var i = 0; i < employment.length; ++i) {
            employmentRows.append({
                "job": employment[i].job || "",
                "company": employment[i].company || ""
            })
        }
        if (employmentRows.count === 0) {
            employmentRows.append({"job": "", "company": ""})
        }
        var idx = genderCombo.model.indexOf(p.gender || "")
        genderCombo.currentIndex = idx >= 0 ? idx : 0
        nameError.visible = false
    }

    function getEmploymentHistory() {
        var employment = []
        for (var i = 0; i < employmentRows.count; ++i) {
            var row = employmentRows.get(i)
            var job = row.job.trim()
            var company = row.company.trim()
            if (job && company) {
                employment.push({"job": job, "company": company})
            }
        }
        return employment
    }

    function clearNameErrorWhenValid() {
        if (firstNameInput.text.trim().length > 0
                && lastNameInput.text.trim().length > 0) {
            nameError.visible = false
        }
    }

    function openForSetup() {
        isEditing = false
        open()
    }

    function openForEdit() {
        isEditing = true
        open()
    }

    onOpened: prefill()

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width - 48
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Item { implicitHeight: 24 }

            // Header
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: root.isEditing ? "Edit Your Profile" : "Welcome to Project Tracker"
                    font.pixelSize: 26
                    font.bold: true
                    color: Style.textMain
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: root.isEditing
                          ? "Update your personal details below"
                          : "Let's set up your profile to get started"
                    font.pixelSize: 14
                    color: Style.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // Profile Form Card
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: formLayout.implicitHeight + 40
                radius: Style.radiusXLarge
                color: Style.surface
                border.color: Style.border

                ColumnLayout {
                    id: formLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Text {
                        text: "Your Information"
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.textMain
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        CustomTextField {
                            id: firstNameInput
                            label: "First Name *"
                            placeholderText: "First name"
                            Layout.fillWidth: true
                            onTextChanged: root.clearNameErrorWhenValid()
                        }

                        CustomTextField {
                            id: lastNameInput
                            label: "Last Name *"
                            Layout.fillWidth: true
                            placeholderText: "Last name"
                            onTextChanged: root.clearNameErrorWhenValid()
                        }

                        CustomTextField {
                            id: nicknameInput
                            label: "Nickname"
                            placeholderText: "Optional"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: "Gender"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: Style.textSecondary
                            }

                            CustomComboBox {
                                id: genderCombo
                                Layout.fillWidth: true
                                model: ["", "Male", "Female", "Prefer not to say"]
                            }
                        }

                        CustomTextField {
                            id: emailInput
                            label: "Email Address"
                            placeholderText: "your.email@example.com"
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        id: nameError
                        text: "First and last name are required."
                        font.pixelSize: 12
                        color: Style.danger
                        visible: false
                    }

                    Text {
                        text: "Work"
                        font.pixelSize: 16
                        font.bold: true
                        color: Style.textMain
                    }

                    Repeater {
                        id: employmentRepeater
                        model: employmentRows

                        delegate: RowLayout {
                            id: employmentRow
                            Layout.fillWidth: true
                            spacing: 12

                            property alias jobText: jobInput.text
                            property alias companyText: companyInput.text

                            CustomTextField {
                                id: jobInput
                                label: "Job"
                                placeholderText: "e.g., Software Engineer"
                                text: model.job
                                Layout.fillWidth: true
                                onTextChanged: employmentRows.setProperty(index, "job", text)
                            }

                            CustomTextField {
                                id: companyInput
                                label: "Company"
                                placeholderText: "e.g., Acme Corp"
                                text: model.company
                                Layout.fillWidth: true
                                onTextChanged: employmentRows.setProperty(index, "company", text)
                            }

                            CustomButton {
                                text: "+"
                                variant: "secondary"
                                implicitWidth: 42
                                visible: index === employmentRows.count - 1
                                         && jobInput.text.trim().length > 0
                                         && companyInput.text.trim().length > 0
                                onClicked: employmentRows.append({
                                    "job": "",
                                    "company": ""
                                })
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        CustomButton {
                            text: root.isEditing ? "Cancel" : "Skip for Now"
                            variant: "ghost"
                            onClicked: {
                                if (!root.isEditing) {
                                    profileController.setOnboardingCompleted(true)
                                }
                                root.close()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        CustomButton {
                            text: root.isEditing ? "Save Changes" : "Save & Continue"
                            variant: "primary"
                            onClicked: {
                                if (firstNameInput.text.trim().length === 0
                                        || lastNameInput.text.trim().length === 0) {
                                    nameError.visible = true
                                    return
                                }
                                var p = profileController.userProfile || {}
                                var employmentJson = JSON.stringify(getEmploymentHistory())
                                if (root.isEditing && p.id !== undefined) {
                                    profileController.save_profile(
                                        p.id,
                                        firstNameInput.text,
                                        lastNameInput.text,
                                        nicknameInput.text,
                                        genderCombo.currentText,
                                        emailInput.text,
                                        employmentJson
                                    )
                                } else {
                                    profileController.create_profile(
                                        firstNameInput.text,
                                        lastNameInput.text,
                                        nicknameInput.text,
                                        genderCombo.currentText,
                                        emailInput.text,
                                        employmentJson
                                    )
                                }
                                profileController.setOnboardingCompleted(true)
                                root.close()
                            }
                        }
                    }
                }
            }

            Item { implicitHeight: 24 }
        }
    }
}
