import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

T.CheckBox {
    id: control
    
    implicitWidth: implicitContentWidth + leftInset + rightInset
    implicitHeight: Math.max(implicitContentHeight, 24) + topInset + bottomInset
    
    spacing: 8
    
    indicator: Rectangle {
        id: indicator
        implicitWidth: 20
        implicitHeight: 20
        radius: Style.radiusSmall
        border.color: control.checked ? Style.primary : Style.border
        border.width: 2
        color: control.checked ? Style.primary : "transparent"
        
        Image {
            anchors.centerIn: parent
            width: 12
            height: 12
            source: "../../assets/check.svg"
            visible: control.checked
            fillMode: Image.PreserveAspectFit
            color: Style.surface
        }
    }
    
    contentItem: T.Text {
        text: control.text
        font: control.font
        color: control.enabled ? Style.textMain : Style.textLight
        verticalAlignment: Text.AlignVCenter
    }
    
    T.Padding {
        left: control.leftInset
        right: control.rightInset
        top: control.topInset
        bottom: control.bottomInset
    }
}
