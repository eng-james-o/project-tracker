import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    property var aiController: null
    property var projectDialog: null
    
    width: 400
    height: 300
    color: Style.surface
    border.color: Style.border
    border.width: 1
    radius: Style.radiusLarge
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        Text {
            text: "AI Step Generator"
            font.pixelSize: 16
            font.bold: true
            color: Style.textMain
            Layout.alignment: Qt.AlignHCenter
        }
        
        Text {
            text: "Describe your project and AI will generate suggested steps and deliverables."
            font.pixelSize: 12
            color: Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.Wrap
        }
        
        CustomTextField {
            id: descriptionInput
            Layout.fillWidth: true
            placeholderText: "e.g., Build a responsive e-commerce website with payment integration..."
            implicitHeight: 60
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            CustomButton {
                text: "Generate"
                variant: "primary"
                Layout.fillWidth: true
                onClicked: generateSteps()
            }
            
            CustomButton {
                text: "Cancel"
                variant: "secondary"
                Layout.fillWidth: true
                onClicked: root.visible = false
            }
        }
        
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            TextArea {
                id: resultArea
                Layout.fillWidth: true
                readOnly: true
                wrapMode: TextArea.Wrap
                font.family: "Consolas,Monaco,monospace"
                font.pixelSize: Style.fontSizeSmall
                color: Style.textMain
                background: Rectangle {
                    radius: Style.radiusMedium
                    color: Style.background
                    border.color: Style.border
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            CustomButton {
                text: "Apply Steps"
                variant: "primary"
                Layout.fillWidth: true
                visible: resultArea.text !== ""
                onClicked: applySteps()
            }
        }
    }
    
    function generateSteps() {
        if (!aiController || !descriptionInput.text) return
        
        resultArea.text = "Generating..."
        aiController.generateProjectSteps(descriptionInput.text)
    }
    
    function applySteps() {
        if (!projectDialog || !resultArea.text) return
        
        try {
            var data = JSON.parse(resultArea.text)
            
            // Apply steps
            if (data.steps && data.steps.length > 0) {
                var stepsText = data.steps.map(function(step) {
                    return step.title
                }).join('\n')
                // TODO: Set steps in project dialog
            }
            
            // Apply deliverables
            if (data.deliverables && data.deliverables.length > 0) {
                var deliverablesText = data.deliverables.map(function(del) {
                    return del.title
                }).join('\n')
                // TODO: Set deliverables in project dialog
            }
            
            root.visible = false
        } catch (e) {
            resultArea.text = "Error parsing response: " + e.message
        }
    }
    
    Connections {
        target: aiController
        function onGenerationFinished(text) {
            resultArea.text = text
        }
        function onGenerationFailed(error) {
            resultArea.text = "Error: " + error
        }
    }
}
