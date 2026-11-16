import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.TextField {
    id: control
    
    property alias leftIconSource: leftIcon.source
    property alias rightIconSource: rightIcon.source
    
    implicitWidth: Math.max(implicitContentWidth + leftInset + rightInset, 
                          implicitContentHeight + topInset + bottomInset)
    implicitHeight: implicitContentHeight + topInset + bottomInset
    
    padding: 12
    spacing: 8
    
    contentItem: Row {
        spacing: 8
        
        Image {
            id: leftIcon
            visible: control.leftIconSource !== undefined && control.leftIconSource !== ""
            width: 16
            height: 16
            source: control.leftIconSource
            fillMode: Image.PreserveAspectFit
            color: Style.textSecondary
        }
        
        T.Text {
            id: textItem
            text: control.text
            font: control.font
            color: control.enabled ? Style.textMain : Style.textLight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: leftIcon.visible ? 8 : 0
            rightPadding: rightIcon.visible ? 8 : 0
        }
        
        Image {
            id: rightIcon
            visible: control.rightIconSource !== undefined && control.rightIconSource !== ""
            width: 16
            height: 16
            source: control.rightIconSource
            fillMode: Image.PreserveAspectFit
            color: Style.textSecondary
        }
    }
    
    background: Rectangle {
        implicitWidth: control.implicitWidth
        implicitHeight: control.implicitHeight
        color: control.enabled ? Style.surface : Style.secondary
        border.color: control.pressed ? Style.primary : 
                      control.activeFocus ? Style.primary : 
                      Style.border
        border.width: 1
        radius: Style.radiusMedium
    }
    
    T.Padding {
        left: control.leftInset
        right: control.rightInset
        top: control.topInset
        bottom: control.bottomInset
    }
}
