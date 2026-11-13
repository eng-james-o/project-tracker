import QtQuick
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property string text: ""
    property string color: Style.primary
    property bool clickable: false
    property int radius: Style.radiusSmall
    
    implicitWidth: content.width + 24
    implicitHeight: 24
    
    color: Qt.alpha(root.color, 0.12)
    border.color: root.color
    border.width: 1
    radius: root.radius
    
    Text {
        id: content
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: Style.fontSizeSmall
        font.bold: true
        color: root.color
        elide: Text.ElideRight
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.clickable) root.clicked()
    }
    
    signal clicked()
}
