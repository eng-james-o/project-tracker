import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    id: root
    property var notificationController: null
    
    width: 320
    height: parent.height - 100
    color: Style.surface
    border.color: Style.border
    border.width: 1
    radius: Style.radiusLarge
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Notifications"
                font.pixelSize: 16
                font.bold: true
                color: Style.textMain
            }
            
            Item { Layout.fillWidth: true }
            
            RowLayout {
                spacing: 8
                
                CustomButton {
                    variant: "ghost"
                    text: "Mark All Read"
                    onClicked: notificationController ? notificationController.mark_all_as_read() : null
                }
                
                CustomButton {
                    variant: "ghost"
                    iconSource: "../../assets/trash.svg"
                    ToolTip.text: "Clear All"
                    onClicked: notificationController ? notificationController.clear_notifications() : null
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.border
        }
        
        // Notifications list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 8
                
                Repeater {
                    model: notificationController ? notificationController.notifications : []
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 72
                        color: modelData.read ? Style.background : Qt.alpha(Style.primary, 0.05)
                        border.color: Style.border
                        border.width: 1
                        radius: Style.radiusMedium
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            ColumnLayout {
                                spacing: 4
                                
                                Text {
                                    text: modelData.title
                                    font.pixelSize: 14
                                    font.bold: !modelData.read
                                    color: Style.textMain
                                }
                                
                                Text {
                                    text: modelData.message
                                    font.pixelSize: 12
                                    color: Style.textSecondary
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: modelData.timestamp
                                    font.pixelSize: 10
                                    color: Style.textLight
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notificationController ? notificationController.mark_as_read(index) : null
                        }
                    }
                }
            }
        }
    }
}
