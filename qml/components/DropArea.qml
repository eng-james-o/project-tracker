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

    DropArea {
        id: dropAreaHandler
        anchors.fill: parent

        onEntered: function(drag) {
            if (drag.hasUrls || drag.hasText) {
                dropArea.active = true
                dropArea.containsFiles = drag.hasUrls
                drag.acceptProposedAction()
            }
        }

        onPositionChanged: function(drag) {
            if (drag.hasUrls || drag.hasText) {
                drag.acceptProposedAction()
            }
        }

        onExited: function(drag) {
            dropArea.active = false
            dropArea.containsFiles = false
        }

        onDropped: function(drop) {
            dropArea.active = false
            dropArea.containsFiles = false

            if (drop.hasUrls) {
                var files = []
                for (var i = 0; i < drop.urls.length; i++) {
                    files.push(drop.urls[i].toString())
                }
                dropArea.droppedFiles = files
                dropArea.filesDropped(files)
                drop.acceptProposedAction()
            } else if (drop.hasText) {
                var text = drop.text
                dropArea.droppedText = text
                dropArea.textDropped(text)
                drop.acceptProposedAction()
            }
        }
    }

    // Area for dropping
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
    }
}
