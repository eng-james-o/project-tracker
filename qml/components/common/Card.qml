import QtQuick
import QtQuick.Controls
import "../../"

Rectangle {
    id: root
    property string title: ""
    property bool hasHeader: title !== ""
    property color headerColor: Style.surface
    property color borderColor: Style.border
    
    implicitWidth: 300
    implicitHeight: 200
    color: Style.surface
    border.color: borderColor
    border.width: 1
    radius: Style.radiusLarge
    
    Column {
        anchors.fill: parent
        anchors.margins: hasHeader ? 0 : 16
        spacing: 0
        
        // Header section
        Rectangle {
            visible: hasHeader
            width: parent.width
            height: 48
            color: headerColor
            border.bottom.color: borderColor
            border.bottom.width: 1
            
            Text {
                anchors.centerIn: parent
                text: title
                font.pixelSize: 14
                font.bold: true
                color: Style.textMain
            }
        }
        
        // Content area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            property alias content: contentItem
            
            Item {
                id: contentItem
                anchors.fill: parent
                anchors.margins: 16
            }
        }
    }
}
