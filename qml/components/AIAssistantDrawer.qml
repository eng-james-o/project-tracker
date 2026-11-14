import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Drawer {
    id: aiDrawer
    width: 400
    height: parent.height
    edge: Qt.RightEdge
    
    property var aiController: null
    property var projectController: null
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "AI Assistant"
                font.pixelSize: 18
                font.bold: true
                color: Style.textMain
            }
            
            Item { Layout.fillWidth: true }
            
            CustomButton {
                variant: "icon"
                iconSource: "../../assets/sidebar.svg"
                onClicked: aiDrawer.close()
            }
        }
        
        // Provider selection
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Provider:"
                font.pixelSize: 12
                color: Style.textSecondary
                Layout.alignment: Qt.AlignVCenter
            }
            
            CustomComboBox {
                Layout.fillWidth: true
                model: aiController ? aiController.availableProviders : []
                currentText: aiController ? aiController.currentProvider : "groq"
                onCurrentTextChanged: aiController ? aiController.setProvider(currentText) : null
            }
        }
        
        // API Key input
        CustomTextField {
            id: apiKeyInput
            label: "API Key (optional, can use environment variable)"
            placeholderText: "Enter your API key..."
            Layout.fillWidth: true
            onTextChanged: {
                if (aiController) {
                    aiController.setProvider(
                        aiController.currentProvider,
                        text
                    )
                }
            }
        }
        
        // Chat area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 8
                
                id: chatLayout
                
                // Chat messages will be added here dynamically
            }
        }
        
        // Input area
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            CustomTextField {
                id: messageInput
                Layout.fillWidth: true
                placeholderText: "Ask AI for help..."
                onAccepted: sendMessage()
            }
            
            CustomButton {
                text: "Send"
                variant: "primary"
                onClicked: sendMessage()
            }
        }
    }
    
    function sendMessage() {
        var message = messageInput.text
        if (!message || !aiController) return
        
        // Add user message to chat
        addMessage(message, true)
        messageInput.text = ""
        
        // Show typing indicator
        var typingItem = typingIndicatorComponent.createObject(chatLayout, {"width": chatLayout.width})
        chatLayout.addItem(typingItem)
        
        // Get AI response
        aiController.generateAsync(message, "")
    }
    
    function addMessage(text, isUser) {
        var messageItem = messageComponent.createObject(
            chatLayout,
            {
                "text": text,
                "isUser": isUser,
                "width": chatLayout.width
            }
        )
        chatLayout.addItem(messageItem)
        chatScroll.ensureVisible(messageItem)
    }
    
    Component {
        id: messageComponent
        Rectangle {
            property string text
            property bool isUser
            
            width: parent.width
            implicitHeight: content.implicitHeight + 24
            color: isUser ? Style.primary : Style.background
            radius: Style.radiusMedium
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4
                
                id: content
                
                Text {
                    text: text
                    font.pixelSize: 13
                    color: isUser ? Style.surface : Style.textMain
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                }
            }
            
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 8
        }
    }
    
    Component {
        id: typingIndicatorComponent
        RowLayout {
            spacing: 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 8
            
            Repeater {
                model: 3
                Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 4
                    color: Style.textLight
                    
                    SequentialAnimation {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { target: parent; property: "opacity"; from: 0.3; to: 1.0; duration: 500 }
                        NumberAnimation { target: parent; property: "opacity"; from: 1.0; to: 0.3; duration: 500 }
                    }
                }
            }
        }
    }
    
    Connections {
        target: aiController
        function onGenerationStarted() {
            // Typing indicator already shown
        }
        
        function onGenerationFinished(text) {
            // Remove typing indicator
            if (chatLayout.count > 0) {
                var lastItem = chatLayout.itemAt(chatLayout.count - 1)
                if (lastItem && lastItem.objectName === "typing") {
                    chatLayout.removeItem(lastItem)
                    lastItem.destroy()
                }
            }
            
            // Add AI response
            addMessage(text, false)
        }
        
        function onGenerationFailed(error) {
            // Remove typing indicator
            if (chatLayout.count > 0) {
                var lastItem = chatLayout.itemAt(chatLayout.count - 1)
                if (lastItem && lastItem.objectName === "typing") {
                    chatLayout.removeItem(lastItem)
                    lastItem.destroy()
                }
            }
            
            // Show error
            addMessage("Error: " + error, false)
        }
    }
    
    ScrollView {
        id: chatScroll
        anchors.fill: parent
    }
}
