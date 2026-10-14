import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Dialog {
    id: root
    property var resource: ({})
    property int projectId: 0
    property bool isEditing: false
    property bool hasUnsavedChanges: false
    
    title: isEditing ? "Edit Resource" : (resource.title || "View Resource")
    modal: true
    width: 600
    height: 500
    
    standardButtons: isEditing ? (Dialog.Save | Dialog.Cancel) : Dialog.Close
    
    background: Rectangle {
        color: Style.surface
        radius: Style.radiusLarge
        border.color: Style.border
    }

    // Track if form has unsaved changes
    function checkUnsavedChanges() {
        if (isEditing) {
            var changed = false
            if (titleInput.text !== (resource.title || "")) changed = true
            if (typeCombo.currentText !== (resource.type || "note")) changed = true
            if (contentInput.text !== (resource.path_or_content || "")) changed = true
            root.hasUnsavedChanges = changed
        }
    }

    // Close handler - prevent closing with unsaved changes
    onRejected: {
        if (isEditing && hasUnsavedChanges) {
            unsavedDialog.open()
        } else {
            root.close()
        }
    }

    onAccepted: {
        if (isEditing) {
            projectController.update_resource(
                resource.id,
                typeCombo.currentText,
                titleInput.text,
                contentInput.text
            )
            resource.title = titleInput.text
            resource.type = typeCombo.currentText
            resource.path_or_content = contentInput.text
        }
        root.close()
    }

    // Confirm unsaved changes dialog
    Dialog {
        id: unsavedDialog
        title: "Unsaved Changes"
        modal: true
        standardButtons: Dialog.Yes | Dialog.No | Dialog.Cancel
        anchors.centerIn: parent
        
        Text {
            text: "You have unsaved changes. Do you want to save them before closing?"
            font.pixelSize: 13
            color: "#202124"
        }
        
        onAccepted: {
            root.onAccepted()
            unsavedDialog.close()
        }
        
        onRejected: {
            isEditing = false
            root.close()
            unsavedDialog.close()
        }
    }

    // Click outside to close (only if no unsaved changes)
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (!isEditing || !hasUnsavedChanges) {
                root.close()
            } else {
                unsavedDialog.open()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header with type badge
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: resource.title || "Untitled Resource"
                font.pixelSize: 18
                font.bold: true
                color: Style.textMain
                Layout.fillWidth: true
            }

            Rectangle {
                radius: 4
                color: {
                    switch(resource.type || typeCombo.currentText) {
                        case "link": return "#E8F0FE"
                        case "document": return "#E8F5E8"
                        case "folder": return "#FFF176"
                        case "note": return "#F3E5F5"
                        case "markdown": return "#E0F2F1"
                        default: return "#E0E0E0"
                    }
                }
                implicitWidth: 80
                implicitHeight: 24

                Text {
                    text: resource.type || typeCombo.currentText
                    font.pixelSize: 11
                    font.bold: true
                    color: {
                        switch(resource.type || typeCombo.currentText) {
                            case "link": return "#1A73E8"
                            case "document": return "#2E7D32"
                            case "folder": return "#F57F17"
                            case "note": return "#7B1FA2"
                            case "markdown": return "#006064"
                            default: return "#202124"
                        }
                    }
                    anchors.centerIn: parent
                }
            }
        }

        // Type selector (visible in edit mode)
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            visible: isEditing

            Text {
                text: "Type"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Style.textMain
            }

            CustomComboBox {
                id: typeCombo
                Layout.fillWidth: true
                model: ["note", "markdown", "link", "document", "folder"]
                currentText: resource.type || "note"
                onCurrentTextChanged: checkUnsavedChanges()
            }
        }

        // Title field (visible in edit mode)
        CustomTextField {
            id: titleInput
            label: "Title"
            Layout.fillWidth: true
            text: resource.title || ""
            visible: isEditing
            onTextChanged: checkUnsavedChanges()
        }

        // Content area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Text {
                text: "Content"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: Style.textMain
                visible: isEditing
            }

            // Different input based on type
            TextArea {
                id: contentInput
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: resource.path_or_content || ""
                placeholderText: {
                    switch(typeCombo.currentText) {
                        case "link": return "Enter URL or paste link from clipboard..."
                        case "document": return "Enter file path or drag and drop document..."
                        case "folder": return "Enter folder path or drag and drop folder..."
                        case "note": return "Type your notes here..."
                        case "markdown": return "Type markdown content here..."
                        default: return ""
                    }
                }
                wrapMode: TextArea.Wrap
                visible: isEditing
                onTextChanged: checkUnsavedChanges()
                
                background: Rectangle {
                    radius: Style.radiusMedium
                    color: Style.background
                    border.color: contentInput.activeFocus ? Style.primary : Style.border
                }
            }

            // Display area (when not editing)
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !isEditing
                clip: true

                ColumnLayout {
                    width: parent.width - 20
                    spacing: 8

                    // For markdown
                    Text {
                        id: markdownDisplay
                        text: root.parseMarkdown(resource.path_or_content || "")
                        font.pixelSize: 13
                        color: Style.textMain
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        visible: (resource.type === "markdown" || resource.type === "note") && !isEditing
                    }

                    // For links
                    Text {
                        id: linkDisplay
                        text: resource.path_or_content || ""
                        font.pixelSize: 13
                        color: "#1A73E8"
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        visible: resource.type === "link" && !isEditing
                    }

                    // For documents and folders
                    Text {
                        id: fileDisplay
                        text: resource.path_or_content || ""
                        font.pixelSize: 13
                        color: Style.textMain
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        visible: (resource.type === "document" || resource.type === "folder") && !isEditing
                    }
                }
            }
        }

        // Action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CustomButton {
                text: isEditing ? "Cancel" : "Close"
                variant: "ghost"
                Layout.fillWidth: true
                onClicked: {
                    if (isEditing && hasUnsavedChanges) {
                        unsavedDialog.open()
                    } else {
                        isEditing = false
                        root.close()
                    }
                }
            }

            CustomButton {
                text: isEditing ? "Save" : "Edit"
                variant: isEditing ? "primary" : "secondary"
                Layout.fillWidth: true
                onClicked: {
                    if (isEditing) {
                        root.onAccepted()
                    } else {
                        isEditing = true
                    }
                }
            }

            // Open button for links
            CustomButton {
                text: "Open"
                variant: "secondary"
                visible: resource.type === "link" && !isEditing
                onClicked: Qt.openUrlExternally(resource.path_or_content)
            }

            // Open button for folders/documents
            CustomButton {
                text: "Open"
                variant: "secondary"
                visible: (resource.type === "document" || resource.type === "folder") && !isEditing
                onClicked: Qt.openUrlExternally("file:///" + resource.path_or_content)
            }
        }
    }

    // Markdown parsing function
    function parseMarkdown(md) {
        if (!md) return "No content"
        
        var result = md
        
        // Headers
        result = result.replace(/^#\s+(.*$)/gm, function(match, p1) {
            return "\n" + p1.toUpperCase() + "\n"
        })
        result = result.replace(/^##\s+(.*$)/gm, function(match, p1) {
            return "\n**" + p1 + "**\n"
        })
        result = result.replace(/^###\s+(.*$)/gm, function(match, p1) {
            return "\n*" + p1 + "*\n"
        })
        
        // Bold
        result = result.replace(/\*\*(.*?)\*\*/g, function(match, p1) {
            return "<b>" + p1 + "</b>"
        })
        
        // Italic
        result = result.replace(/\*(.*?)\*/g, function(match, p1) {
            return "<i>" + p1 + "</i>"
        })
        
        // Code blocks
        result = result.replace(/`(.*?)`/g, function(match, p1) {
            return "<code>" + p1 + "</code>"
        })
        
        // Lists
        result = result.replace(/^\s*-\s+(.*)/gm, function(match, p1) {
            return "  • " + p1
        })
        
        // Blockquotes
        result = result.replace(/^>\s+(.*)/gm, function(match, p1) {
            return "    " + p1
        })
        
        // Links
        result = result.replace(/\[(.*?)\]\((.*?)\)/g, function(match, p1, p2) {
            return p1 + " (" + p2 + ")"
        })
        
        return result
    }
}
