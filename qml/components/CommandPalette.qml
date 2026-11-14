import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Popup {
    id: root
    width: 600
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property var projectController: null
    property var templateController: null
    property var profileController: null
    
    background: Rectangle {
        color: Style.surface
        border.color: Style.border
        border.width: 1
        radius: Style.radiusLarge
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Search input
        CustomTextField {
            id: searchInput
            Layout.fillWidth: true
            placeholderText: "Type a command or search... (Ctrl+K)"
            onTextChanged: filterCommands()
            focus: true
            
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Down) {
                    listView.focus = true
                    listView.currentIndex = 0
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    listView.focus = true
                    listView.currentIndex = listView.count - 1
                    event.accepted = true
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    if (listView.currentIndex >= 0) {
                        executeCommand(listView.currentIndex)
                    }
                    event.accepted = true
                }
            }
        }
        
        // Results list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ListView {
                id: listView
                width: parent.width
                height: contentHeight
                model: filteredCommands
                delegate: CommandItem {
                    width: parent.width
                    command: modelData
                    onSelected: executeCommand(index)
                }
                
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        executeCommand(currentIndex)
                        event.accepted = true
                    }
                }
            }
        }
    }
    
    property list<string> allCommands: [
        "New Project",
        "All Projects",
        "Dashboard",
        "Project Board",
        "Goals",
        "Audit Log",
        "Settings",
        "New Template",
        "Profile",
        "Search Projects"
    ]
    
    property list<var> filteredCommands: []
    
    function filterCommands() {
        var query = searchInput.text.toLowerCase()
        if (!query) {
            filteredCommands = allCommands
            return
        }
        
        filteredCommands = allCommands.filter(function(cmd) {
            return cmd.toLowerCase().includes(query)
        })
    }
    
    function executeCommand(index) {
        var command = filteredCommands[index]
        
        switch (command) {
            case "New Project":
                projectDialog.setProject(null)
                projectDialog.open()
                break
            case "All Projects":
                mainWindow.mainStack.currentIndex = 1
                break
            case "Dashboard":
                mainWindow.mainStack.currentIndex = 0
                break
            case "Project Board":
                mainWindow.mainStack.currentIndex = 3
                break
            case "Goals":
                mainWindow.mainStack.currentIndex = 4
                break
            case "Audit Log":
                mainWindow.mainStack.currentIndex = 5
                break
            case "Settings":
                mainWindow.mainStack.currentIndex = 6
                break
            case "New Template":
                templateDialog.setTemplate(null)
                templateDialog.open()
                break
            case "Profile":
                onboardingView.openForEdit()
                break
            case "Search Projects":
                mainWindow.mainStack.currentIndex = 1
                mainWindow.projectsView.searchBox.focus = true
                break
        }
        
        root.close()
    }
    
    Component.onCompleted: {
        searchInput.forceActiveFocus()
        filterCommands()
    }
}

// Command item component
component CommandItem: Rectangle {
    id: root
    property var command: ""
    signal selected()
    
    height: 40
    color: "transparent"
    
    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        text: command
        font.pixelSize: Style.fontSizeMedium
        color: Style.textMain
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.selected()
        
        Rectangle {
            anchors.fill: parent
            color: root.hovered ? Style.secondary : "transparent"
            radius: Style.radiusSmall
        }
    }
}
