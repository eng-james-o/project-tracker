import QtQuick
import QtQuick.Controls
import "../../"

Rectangle {
    id: root
    property string text: ""
    property int timeout: 500
    
    width: Math.min(implicitWidth + 32, 300)
    height: implicitHeight + 16
    color: Style.textMain
    radius: Style.radiusSmall
    
    Text {
        id: textItem
        text: root.text
        font.pixelSize: 12
        color: Style.surface
        padding: 8
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    
    // Arrow pointing to the target
    Rectangle {
        width: 8
        height: 8
        color: root.color
        rotation: 45
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height
        z: -1
    }
}
