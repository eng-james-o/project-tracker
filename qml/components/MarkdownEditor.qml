import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

ColumnLayout {
    id: root
    property string text: ""
    property bool showPreview: true
    
    spacing: 12
    Layout.fillWidth: true

    // Tabs for Edit/Preview
    RowLayout {
        Layout.fillWidth: true
        spacing: 0
        
        CustomButton {
            Layout.fillWidth: true
            text: "Edit"
            variant: !showPreview ? "primary" : "ghost"
            onClicked: showPreview = false
        }
        
        CustomButton {
            Layout.fillWidth: true
            text: "Preview"
            variant: showPreview ? "primary" : "ghost"
            onClicked: showPreview = true
        }
    }
    
    // Editor
    TextArea {
        id: editor
        Layout.fillWidth: true
        implicitHeight: 150
        text: root.text
        visible: !showPreview
        wrapMode: TextArea.Wrap
        color: Style.textMain
        selectionColor: Style.primaryHover
        selectedTextColor: Style.surface
        placeholderTextColor: Style.textSecondary
        font.family: "Consolas,Monaco,monospace"
        font.pixelSize: Style.fontSizeSmall
        onTextChanged: root.text = text
        
        background: Rectangle {
            radius: Style.radiusMedium
            color: Style.background
            border.color: editor.activeFocus ? Style.primary : Style.border
        }
    }
    
    // Preview
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 150
        visible: showPreview
        color: Style.background
        border.color: Style.border
        border.width: 1
        radius: Style.radiusMedium
        
        ScrollView {
            anchors.fill: parent
            anchors.margins: 12
            clip: true
            
            MarkdownText {
                markdownText: root.text
                width: parent.width
            }
        }
    }
}
