import QtQuick
import Qt.labs.settings 1.0

QtObject {
    readonly property Settings settings: Settings {
        category: "sidebar"
        property string expandedGroup: ""
    }

    property string group: "projects"
    readonly property bool projectsExpanded: group === "projects"
    readonly property bool planningExpanded: group === "planning"
    readonly property bool managementExpanded: group === "management"
    readonly property bool toolsExpanded: group === "tools"

    Component.onCompleted: {
        if (settings.expandedGroup) {
            group = settings.expandedGroup
        } else {
            for (const previous of ["planning", "management", "tools", "projects"]) {
                if (settings.value(previous + "Expanded", false)) {
                    group = previous
                    break
                }
            }
        }
    }

    function toggle(name) {
        group = group === name ? "none" : name
        settings.expandedGroup = group
    }
}
