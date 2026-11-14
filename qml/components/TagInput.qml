import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    property string text: ""
    property string placeholderText: "Enter tags..."
    property var tagController: null
    property alias input: textInput
    
    implicitWidth: 200
    implicitHeight: 40
    color: Style.surface
    border.color: Style.border
    border.width: 1
    radius: Style.radiusMedium
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4
        
        TextField {
            id: textInput
            Layout.fillWidth: true
            text: root.text
            placeholderText: root.placeholderText
            color: Style.textMain
            selectionColor: Style.primary
            selectedTextColor: Style.surface
            font.pixelSize: Style.fontSizeMedium
            
            onTextChanged: {
                root.text = text
                updateSuggestions()
            }
            
            onAccepted: {
                addCurrentTag()
            }
            
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                
                Repeater {
                    model: getCurrentTags()
                    
                    TagBadge {
                        Layout.preferredWidth: implicitWidth
                        Layout.preferredHeight: implicitHeight
                        text: modelData
                        color: Style.primary
                        clickable: true
                        
                        onClicked: {
                            removeTag(modelData)
                        }
                    }
                }
            }
        }
        
        // Suggestions dropdown
        Rectangle {
            Layout.fillWidth: true
            visible: suggestionsModel.length > 0 && textInput.focus
            implicitHeight: Math.min(suggestionsModel.length * 32, 128)
            color: Style.surface
            border.color: Style.border
            border.width: 1
            radius: Style.radiusSmall
            z: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 2
                
                Repeater {
                    model: suggestionsModel
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        color: "transparent"
                        radius: Style.radiusSmall
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            text: modelData
                            font.pixelSize: Style.fontSizeSmall
                            color: Style.textMain
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                addTag(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    property list<string> suggestionsModel: []
    property list<string> selectedTags: []
    
    function getCurrentTags() {
        if (!textInput.text) return []
        // Parse tags from text (comma-separated)
        var tags = textInput.text.split(',')
        return tags.filter(function(t) { return t.trim() !== '' }).map(function(t) { return t.trim() })
    }
    
    function updateSuggestions() {
        if (!tagController || !textInput.text) {
            suggestionsModel = []
            return
        }
        
        var currentInput = textInput.text
        var lastComma = currentInput.lastIndexOf(',')
        var currentTag = lastComma >= 0 ? currentInput.substring(lastComma + 1) : currentInput
        
        if (currentTag.trim() === '') {
            suggestionsModel = []
            return
        }
        
        // Filter tags that start with current input
        var allTags = tagController.allTags
        var filtered = allTags.filter(function(tag) {
            return tag.toLowerCase().includes(currentTag.toLowerCase()) &&
                   !getCurrentTags().includes(tag)
        })
        
        suggestionsModel = filtered.slice(0, 5)
    }
    
    function addTag(tag) {
        var currentTags = getCurrentTags()
        if (!currentTags.includes(tag)) {
            if (textInput.text && !textInput.text.endsWith(',')) {
                textInput.text += ','
            }
            textInput.text += tag + ','
            root.text = textInput.text
        }
        textInput.forceActiveFocus()
    }
    
    function addCurrentTag() {
        var currentInput = textInput.text
        if (currentInput && !currentInput.endsWith(',')) {
            var lastComma = currentInput.lastIndexOf(',')
            var currentTag = lastComma >= 0 ? currentInput.substring(lastComma + 1) : currentInput
            if (currentTag.trim() !== '') {
                textInput.text += ','
                root.text = textInput.text
            }
        }
    }
    
    function removeTag(tag) {
        var currentTags = getCurrentTags()
        var index = currentTags.indexOf(tag)
        if (index >= 0) {
            currentTags.splice(index, 1)
            textInput.text = currentTags.join(',') + (currentTags.length > 0 ? ',' : '')
            root.text = textInput.text
        }
    }
}
