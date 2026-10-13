import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal onboardingComplete()

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24

        Item { implicitHeight: 20 }

        // Header
        ColumnLayout {
            spacing: 4
            Text {
                text: "Welcome to Project Tracker"
                font.pixelSize: 28
                font.bold: true
                color: "#202124"
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Let's set up your profile to get started"
                font.pixelSize: 14
                color: "#5F6368"
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Profile Form Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: formLayout.implicitHeight + 32
            radius: 10
            color: "#FFFFFF"
            border.color: "#E0E0E0"

            ColumnLayout {
                id: formLayout
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Text {
                    text: "Your Information"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#202124"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    CustomTextField {
                        id: nameInput
                        label: "Full Name *"
                        placeholderText: "Enter your full name"
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Gender"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#5F6368"
                        }

                        CustomComboBox {
                            id: genderCombo
                            Layout.fillWidth: true
                            model: ["", "Male", "Female", "Non-binary", "Other", "Prefer not to say"]
                        }
                    }
                }

                CustomTextField {
                    id: emailInput
                    label: "Email Address *"
                    placeholderText: "your.email@example.com"
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Job(s)"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#5F6368"
                        }

                        CustomTextField {
                            id: jobsInput
                            placeholderText: "e.g., Software Engineer, Designer"
                            Layout.fillWidth: true
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Layout.fillWidth: true

                        Text {
                            text: "Company(ies)"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#5F6368"
                        }

                        CustomTextField {
                            id: companiesInput
                            placeholderText: "e.g., Acme Corp, Freelance"
                            Layout.fillWidth: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    CustomButton {
                        text: "Skip for Now"
                        variant: "ghost"
                        Layout.fillWidth: true
                        onClicked: root.onboardingComplete()
                    }

                    CustomButton {
                        text: "Save & Continue"
                        variant: "primary"
                        Layout.fillWidth: true
                        onClicked: {
                            if (nameInput.text.trim().length > 0) {
                                projectController.add_user_profile(
                                    nameInput.text,
                                    genderCombo.currentText,
                                    emailInput.text,
                                    jobsInput.text,
                                    companiesInput.text
                                )
                                root.onboardingComplete()
                            } else {
                                // Show error
                            }
                        }
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }
}
