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
                        onTextChanged: planningController.setProjectIdeasSearch(text)
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
                        onCurrentTextChanged: planningController.setProjectIdeasFilter(currentText)
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
                model: planningController.projectIdeas

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
                                    planningController.delete_project_idea(modelData.id)
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
            visible: planningController.projectIdeas.length === 0
        }

        Item { implicitHeight: 20 }
    }

    ProjectIdeaDialog {
        id: ideaDialog
        anchors.centerIn: parent
    }
}
