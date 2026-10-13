import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Drag and drop area for resource attachment
Rectangle {
    id: dropArea
    
    property bool active: false
    property bool containsFiles: false
    property var droppedFiles: []
    property string droppedText: ""
    
    signal filesDropped(var files)
    signal textDropped(string text)
    
    width: parent ? parent.width : 200
    height: parent ? parent.height : 200
    color: active ? (containsFiles ? "#E8F5E8" : "#E8F0FE") : "transparent"
    border.color: active ? (containsFiles ? "#2E7D32" : "#1A73E8") : "transparent"
    border.width: active ? 2 : 0
    radius: 6
    
    // Visual feedback
    Rectangle {
        anchors.fill: parent
        color: active ? Qt.rgba(0, 0, 0, 0.05) : "transparent"
        visible: active
    }
    
    Text {
        anchors.centerIn: parent
        text: active ? (containsFiles ? "Drop files here" : "Drop text or link here") : ""
        color: active ? (containsFiles ? "#2E7D32" : "#1A73E8") : "transparent"
        font.pixelSize: 14
        font.bold: true
    }
    
    // Handle drag enter
    onDragEnter: function(event) {
        if (event.mimeData.hasUrls || event.mimeData.hasText) {
            active = true
            containsFiles = event.mimeData.hasUrls
            event.acceptProposedAction()
        }
    }
    
    // Handle drag move
    onDragMove: function(event) {
        if (event.mimeData.hasUrls || event.mimeData.hasText) {
            event.acceptProposedAction()
        }
    }
    
    // Handle drag leave
    onDragLeave: function(event) {
        active = false
        containsFiles = false
    }
    
    // Handle drop
    onDrop: function(event) {
        active = false
        containsFiles = false
        
        if (event.mimeData.hasUrls) {
            var files = []
            for (var i = 0; i < event.mimeData.urls.length; i++) {
                files.push(event.mimeData.urls[i].toString())
            }
            droppedFiles = files
            filesDropped(files)
            event.acceptProposedAction()
        } else if (event.mimeData.hasText) {
            var text = event.mimeData.text
            droppedText = text
            textDropped(text)
            event.acceptProposedAction()
        }
    }
    
    // Enable drag and drop
    drag.active: true
    drop.active: true
    
    // Area for dropping
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
}
