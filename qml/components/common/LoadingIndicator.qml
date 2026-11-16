import QtQuick
import QtQuick.Controls
import "../../"

Rectangle {
    id: root
    property bool running: true
    property int size: 32
    property color color: Style.primary
    
    implicitWidth: size * 2
    implicitHeight: size * 2
    color: "transparent"
    
    Rectangle {
        anchors.centerIn: parent
        width: size
        height: size
        radius: size / 2
        color: "transparent"
        border.color: color
        border.width: 3
        
        Rectangle {
            id: spinner
            width: size / 2
            height: size / 2
            radius: width / 2
            color: color
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            
            RotationAnimator {
                target: spinner
                from: 0
                to: 360
                duration: 1000
                running: root.running
                loops: Animation.Infinite
            }
        }
    }
}
