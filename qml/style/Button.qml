import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.Button {
    id: control
    
    property alias iconSource: icon.source
    property alias iconColor: icon.color
    
    implicitWidth: Math.max(implicitContentWidth + leftInset + rightInset, 
                          implicitContentHeight + topInset + bottomInset)
    implicitHeight: implicitContentHeight + topInset + bottomInset
    
    padding: 12
    spacing: 8
    
    contentItem: Row {
        spacing: 8
        
        Image {
            id: icon
            visible: control.iconSource !== undefined && control.iconSource !== ""
            width: 16
            height: 16
            source: control.iconSource
            fillMode: Image.PreserveAspectFit
            color: control.iconColor || Style.textMain
        }
        
        T.Text {
            id: textItem
            text: control.text
            font: control.font
            color: control.enabled ? Style.textMain : Style.textLight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
    
    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        color: control.enabled ? Style.secondary : Style.secondaryPressed
        border.color: control.enabled ? Style.secondaryBorder : Style.border
        border.width: 1
        radius: Style.radiusMedium
        
        Rectangle {
            anchors.fill: parent
            color: control.pressed ? Style.secondaryPressed : 
                   control.hovered ? Style.secondaryHover : 
                   control.enabled ? Style.secondary : Style.secondaryPressed
            radius: parent.radius
            visible: control.variant !== "ghost"
        }
    }
    
    T.Padding {
        left: control.leftInset
        right: control.rightInset
        top: control.topInset
        bottom: control.bottomInset
    }
}
