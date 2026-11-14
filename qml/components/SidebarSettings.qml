import QtQuick
import QtQuick.Controls
import Qt.labs.settings 1.0

// Singleton for managing sidebar settings
QtObject {
    id: root
    
    // Navigation group expanded states
    property bool projectsExpanded: false
    property bool planningExpanded: false
    property bool managementExpanded: false
    property bool toolsExpanded: false
    
    Settings {
        id: settings
        category: "sidebar"
    }
    
    Component.onCompleted: {
        // Load saved state
        projectsExpanded = settings.value("projectsExpanded", false)
        planningExpanded = settings.value("planningExpanded", false)
        managementExpanded = settings.value("managementExpanded", false)
        toolsExpanded = settings.value("toolsExpanded", false)
    }
    
    function saveProjectsExpanded(value) {
        projectsExpanded = value
        settings.setValue("projectsExpanded", value)
    }
    
    function savePlanningExpanded(value) {
        planningExpanded = value
        settings.setValue("planningExpanded", value)
    }
    
    function saveManagementExpanded(value) {
        managementExpanded = value
        settings.setValue("managementExpanded", value)
    }
    
    function saveToolsExpanded(value) {
        toolsExpanded = value
        settings.setValue("toolsExpanded", value)
    }
}
