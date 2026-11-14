import QtQuick
import QtQuick.Controls
import "../../"

Column {
    id: root
    property string iconSource: ""
    property string title: "No Items"
    property string description: "There are no items to display."
    property int iconSize: 64
    
    spacing: 16
    horizontalAlignment: AlignHCenter
    verticalAlignment: AlignVCenter
    
    Image {
        source: iconSource
        width: iconSize
        height: iconSize
        fillMode: Image.PreserveAspectFit
        visible: iconSource !== ""
        color: Style.textSecondary
    }
    
    Text {
        text: title
        font.pixelSize: 18
        font.bold: true
        color: Style.textMain
        horizontalAlignment: Text.AlignHCenter
    }
    
    Text {
        text: description
        font.pixelSize: 13
        color: Style.textSecondary
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
    }
}
