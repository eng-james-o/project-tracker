import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.Slider {
    id: control
    
    implicitWidth: 200
    implicitHeight: 24
    
    padding: 0
    
    handle: Rectangle {
        id: handle
        width: 20
        height: 20
        radius: 10
        color: control.pressed ? Style.primaryPressed : Style.primary
        border.color: Style.primaryHover
        border.width: 2
        
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: Style.surface
        }
    }
    
    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: 4
        radius: 2
        color: Style.secondaryBorder
        
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Style.primary
        }
    }
}
