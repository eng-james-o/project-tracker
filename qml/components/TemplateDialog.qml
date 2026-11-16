import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

CustomModal {
    id: root
    title: isEdit ? "Edit Template" : "New Template"
    width: 500

    property bool isEdit: false
    property int templateId: 0

    property alias templateName: nameInput.text
    property alias templateDescription: descInput.text
    property alias templateStructure: structureInput.text

    function setTemplate(t) {
        if (t && t.id) {
            isEdit = true
            templateId = t.id
            nameInput.text = t.name || ""
            descInput.text = t.description || ""
            structureInput.text = t.structure || ""
        } else {
            isEdit = false
            templateId = 0
            nameInput.text = ""
            descInput.text = ""
            structureInput.text = ""
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 12

        CustomTextField {
            id: nameInput
            label: "Template Name *"
            placeholderText: "e.g., Web Development Project"
            Layout.fillWidth: true
        }

        CustomTextField {
            id: descInput
            label: "Description"
            placeholderText: "e.g., Standard template for web development projects"
            Layout.fillWidth: true
        }

        Text {
            text: "Template Structure (JSON)"
            font.pixelSize: 12
            font.weight: Font.Medium
            color: Style.textSecondary
        }

        TextArea {
            id: structureInput
            Layout.fillWidth: true
            implicitHeight: 200
            placeholderText: "Enter JSON structure for the template..."
            wrapMode: TextArea.Wrap
            color: Style.textMain
            selectionColor: Style.primaryHover
            selectedTextColor: Style.surface
            placeholderTextColor: Style.textSecondary
            font.family: "Consolas,Monaco,monospace"
            font.pixelSize: Style.fontSizeSmall
            background: Rectangle {
                radius: Style.radiusMedium
                color: Style.background
                border.color: structureInput.activeFocus ? Style.primary : Style.border
            }
        }
    }
}
