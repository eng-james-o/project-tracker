import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"
import "."

RowLayout {
    id: root
    property var tagController: null
    spacing: 8
    
    Repeater {
        model: tagController ? tagController.allTags : []
        
        TagBadge {
            id: tagBadge
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
            text: modelData
            color: tagController ? tagController.get_tag_color(modelData) : Style.primary
            clickable: true
            
            onClicked: {
                if (tagController.is_tag_selected(modelData)) {
                    tagController.remove_tag_filter(modelData)
                } else {
                    tagController.add_tag_filter(modelData)
                }
            }
            
            Rectangle {
                anchors.fill: parent
                color: tagController && tagController.is_tag_selected(modelData) ? Qt.alpha(Style.primary, 0.2) : "transparent"
                radius: parent.radius
                visible: tagController && tagController.is_tag_selected(modelData)
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
        onClicked: tagController ? tagController.clear_tag_filter() : null
    }
}
