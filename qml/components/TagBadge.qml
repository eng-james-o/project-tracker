import QtQuick
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property string text: ""
    property color badgeColor: Style.primary
    property bool clickable: false
    
    implicitWidth: content.width + 24
    implicitHeight: 24
    
    color: Qt.alpha(root.badgeColor, 0.12)
    border.color: root.badgeColor
    border.width: 1
    radius: Style.radiusSmall
    
    Text {
        id: content
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: Style.fontSizeSmall
        font.bold: true
        color: root.badgeColor
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
