import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"
import "."

RowLayout {
    id: root
    spacing: 8
    
    Repeater {
        model: projectController.allTags
        
        TagBadge {
            id: tagBadge
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
            text: modelData
            badgeColor: tagController ? tagController.get_tag_color(modelData) : Style.primary
            clickable: true
            
            onClicked: {
                if (projectController.tagFilter.indexOf(modelData) >= 0) {
                    projectController.removeTagFilter(modelData)
                } else {
                    projectController.addTagFilter(modelData)
                }
            }
            
            Rectangle {
                anchors.fill: parent
                color: projectController.tagFilter.indexOf(modelData) >= 0 ? Qt.alpha(Style.primary, 0.2) : "transparent"
                radius: parent.radius
                visible: projectController.tagFilter.indexOf(modelData) >= 0
            }
        }
    }
    
    Item { Layout.fillWidth: true }
    
    CustomButton {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        variant: "icon"
        iconSource: "../../assets/plus.svg"
        ToolTip.text: "Clear Tag Filter"
        onClicked: projectController.clearTagFilter()
    }
}
