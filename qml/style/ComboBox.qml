import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.ComboBox {
    id: control
    
    implicitWidth: Math.max(implicitContentWidth + leftInset + rightInset, 
                          implicitContentHeight + topInset + bottomInset)
    implicitHeight: implicitContentHeight + topInset + bottomInset
    
    padding: 12
    spacing: 8
    
    contentItem: Row {
        spacing: 8
        
        T.Text {
            id: textItem
            text: control.displayText
            font: control.font
            color: control.enabled ? Style.textMain : Style.textLight
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        
        Image {
            visible: control.editable
            width: 16
            height: 16
            source: "../../assets/arrow-left.svg"
            fillMode: Image.PreserveAspectFit
            color: Style.textSecondary
            rotation: 90
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
    
    popup: Popup {
        id: popup
        parent: control
        x: control.width - width
        y: control.height
        width: control.width
        height: Math.min(contentItem.implicitHeight, 300)
        
        contentItem: ListView {
            id: listView
            implicitWidth: popup.width
            implicitHeight: contentHeight
            model: control.popup.model
            delegate: ItemDelegate {
                text: modelData
                width: popup.width
                onClicked: control.popup.close()
            }
        }
        
        background: Rectangle {
            color: Style.surface
            border.color: Style.border
            border.width: 1
            radius: Style.radiusMedium
        }
    }
    
    T.Padding {
        left: control.leftInset
        right: control.rightInset
        top: control.topInset
        bottom: control.bottomInset
    }
}
