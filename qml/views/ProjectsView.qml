import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../"

ScrollView {
    id: root
    contentWidth: availableWidth
    clip: true

    signal selectProject(int projectId)

    ColumnLayout {
        width: parent.width - 40
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20

        Item { implicitHeight: 10 }

        // Top Bar & Controls
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Projects Overview"
                font.pixelSize: 24
                font.bold: true
                color: "#202124"
            }

            Item { Layout.fillWidth: true }

            CustomButton {
                text: "+ New Project"
                onClicked: { projectDialog.setProject(null); projectDialog.open() }
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
                        placeholderText: "Search projects or clients..."
                        Layout.fillWidth: true
                        onTextChanged: projectController.setSearchText(text)
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
                        id: control
                        model: ["All", "Active", "Paused", "Completed"]
                        onCurrentTextChanged: projectController.setStatusFilter(currentText)
                    }
                }
            }
        }

        // Project Grid/List
        GridLayout {
            Layout.fillWidth: true
            columns: root.width > 900 ? 3 : (root.width > 600 ? 2 : 1)
            rowSpacing: 16
            columnSpacing: 16

            Repeater {
                model: projectController.projects

                delegate: ProjectCard {
                    Layout.fillWidth: true
                    project: modelData
                    onClicked: {
                        projectController.load_project_details(modelData.id)
                        root.selectProject(modelData.id)
                    }
                }
            }
        }

        Text {
            text: "No projects match your search/filter criteria."
            font.pixelSize: 14
            color: "#70757A"
            Layout.alignment: Qt.AlignHCenter
            visible: projectController.projects.length === 0
        }

        Item { implicitHeight: 20 }
    }
}
