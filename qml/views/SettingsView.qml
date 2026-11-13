import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal editProfileRequested()

    readonly property var profile: profileController.userProfile
    readonly property bool hasProfile: profile !== undefined && profile !== null && profile.id !== undefined
    readonly property string profileDisplayName: profile.nickname
                                                   || ((profile.first_name || profile.last_name)
                                                       ? ((profile.first_name || "") + " " + (profile.last_name || "")).trim()
                                                       : (profile.name || "Unnamed"))

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Item { implicitHeight: 10 }

        // Header
        ColumnLayout {
            spacing: 4
            Text {
                text: "Application Settings"
                font.pixelSize: 24
                font.bold: true
                color: Style.textMain
            }
            Text {
                text: "Configure audit trail row limits and application preferences"
                font.pixelSize: 13
                color: Style.textSecondary
            }
        }

        // Your Profile Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: profileCol.implicitHeight + 32
            radius: Style.radiusLarge
            color: Style.surface
            border.color: Style.border

            ColumnLayout {
                id: profileCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Your Profile"
                        font.pixelSize: 16
                        font.bold: true
                        color: Style.textMain
                    }

                    Item { Layout.fillWidth: true }

                    CustomButton {
                        text: root.hasProfile ? "Edit Details" : "Set Up Profile"
                        variant: "secondary"
                        onClicked: root.editProfileRequested()
                    }
                }

                Text {
                    text: root.hasProfile
                          ? root.profileDisplayName + (root.profile.email ? "    " + root.profile.email : "")
                          : "No profile saved yet. Set up your details to personalise the app."
                    font.pixelSize: 12
                    color: Style.textSecondary
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
        }

        // Settings Section Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: settingsCol.implicitHeight + 32
            radius: Style.radiusLarge
            color: Style.surface
            border.color: Style.border

            ColumnLayout {
                id: settingsCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    text: "Appearance"
                    font.pixelSize: 16
                    font.bold: true
                    color: Style.textMain
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Dark Mode"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Style.textMain
                        }

                        Text {
                            text: "Toggle between light and dark theme."
                            font.pixelSize: 11
                            color: Style.textLight
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        checked: Style.isDarkMode
                        onCheckedChanged: Style.isDarkMode = checked
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.border
                }

                Text {
                    text: "Audit Database Configuration"
                    font.pixelSize: 16
                    font.bold: true
                    color: Style.textMain
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Max Audit Log Rows Cap"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Style.textMain
                        }

                        Text {
                            text: "Prevents database bloat by automatically purging oldest entries when threshold is reached."
                            font.pixelSize: 11
                            color: Style.textLight
                        }
                    }

                    Item { Layout.fillWidth: true }

                    SpinBox {
                        id: maxRowsSpinBox
                        from: 50
                        to: 10000
                        stepSize: 50
                        value: dashboardController.maxAuditRows
                        onValueModified: dashboardController.setMaxAuditRows(value)

                        contentItem: TextInput {
                            z: 2
                            text: maxRowsSpinBox.textFromValue(maxRowsSpinBox.value, maxRowsSpinBox.locale)
                            font: maxRowsSpinBox.font
                            color: Style.textMain
                            selectionColor: Style.primary
                            selectedTextColor: Style.surface
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !maxRowsSpinBox.editable
                            validator: maxRowsSpinBox.validator
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        up.indicator: Rectangle {
                            x: maxRowsSpinBox.mirrored ? 0 : parent.width - width
                            height: parent.height
                            implicitWidth: 36
                            implicitHeight: 36
                            color: maxRowsSpinBox.up.pressed ? Style.secondaryPressed : Style.secondary
                            border.color: Style.border
                            radius: Style.radiusMedium

                            Text {
                                text: "+"
                                font.pixelSize: 16
                                color: Style.textMain
                                anchors.centerIn: parent
                            }
                        }

                        down.indicator: Rectangle {
                            x: maxRowsSpinBox.mirrored ? parent.width - width : 0
                            height: parent.height
                            implicitWidth: 36
                            implicitHeight: 36
                            color: maxRowsSpinBox.down.pressed ? Style.secondaryPressed : Style.secondary
                            border.color: Style.border
                            radius: Style.radiusMedium

                            Text {
                                text: "-"
                                font.pixelSize: 16
                                color: Style.textMain
                                anchors.centerIn: parent
                            }
                        }

                        background: Rectangle {
                            implicitWidth: 140
                            border.color: Style.border
                            radius: Style.radiusMedium
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.border
                }

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Database Management"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Style.textMain
                        }

                        Text {
                            text: "Clear stored audit log history from audit_tracker.db."
                            font.pixelSize: 11
                            color: Style.textLight
                        }
                    }

                    Item { Layout.fillWidth: true }

                    CustomButton {
                        text: "Purge Audit Logs"
                        variant: "secondary"
                        onClicked: dashboardController.clearAuditLogs()
                    }
                }
            }
        }

        // Templates Section
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: templatesCol.implicitHeight + 32
            radius: Style.radiusLarge
            color: Style.surface
            border.color: Style.border

            ColumnLayout {
                id: templatesCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Project Templates"
                        font.pixelSize: 16
                        font.bold: true
                        color: Style.textMain
                    }

                    Item { Layout.fillWidth: true }

                    CustomButton {
                        text: "+ New Template"
                        variant: "primary"
                        onClicked: {
                            templateDialog.setTemplate(null)
                            templateDialog.open()
                        }
                    }
                }

                Text {
                    text: "Create reusable project templates to quickly start new projects with predefined structures."
                    font.pixelSize: 12
                    color: Style.textSecondary
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Style.border
                }

                // Template List
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: templateController.templates

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 56
                            radius: Style.radiusMedium
                            color: Style.background
                            border.color: Style.border
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 12

                                ColumnLayout {
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: Style.textMain
                                    }

                                    Text {
                                        text: modelData.description || "No description"
                                        font.pixelSize: 11
                                        color: Style.textSecondary
                                        elide: Text.ElideRight
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                RowLayout {
                                    spacing: 8

                                    CustomButton {
                                        variant: "ghost"
                                        iconSource: "../../assets/edit.svg"
                                        ToolTip.text: "Edit Template"
                                        onClicked: {
                                            templateDialog.setTemplate(modelData)
                                            templateDialog.open()
                                        }
                                    }

                                    CustomButton {
                                        variant: "ghost"
                                        iconSource: "../../assets/trash.svg"
                                        ToolTip.text: "Delete Template"
                                        onClicked: templateController.delete_template(modelData.id)
                                    }

                                    CustomButton {
                                        variant: "primary"
                                        text: "Use Template"
                                        onClicked: {
                                            var projectData = templateController.clone_project_from_template(modelData.id)
                                            if (projectData) {
                                                projectDialog.setProject(projectData)
                                                projectDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: templateController.templates.length === 0 ? "No templates created yet." : ""
                        font.pixelSize: 12
                        color: Style.textLight
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        Item { implicitHeight: 20 }
    }

    // Template Dialog
    TemplateDialog {
        id: templateDialog
        anchors.centerIn: parent
        onAccepted: {
            if (isEdit) {
                templateController.update_template(
                    templateId,
                    templateName,
                    templateDescription,
                    templateStructure
                )
            } else {
                templateController.add_template(
                    templateName,
                    templateDescription,
                    templateStructure
                )
            }
        }
    }
}
