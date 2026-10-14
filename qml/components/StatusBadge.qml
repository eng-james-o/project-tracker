import QtQuick
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property string status: "active" // "active", "paused", "completed"

    implicitWidth: statusText.implicitWidth + 20
    implicitHeight: 26
    radius: 13

    color: {
        switch(status.toLowerCase()) {
            case "active": return Style.statusActiveBg
            case "paused": return Style.statusPausedBg
            case "completed": return Style.statusCompletedBg
            default: return Style.secondary
        }
    }

    border.color: {
        switch(status.toLowerCase()) {
            case "active": return Style.statusActiveBorder
            case "paused": return Style.statusPausedBorder
            case "completed": return Style.statusCompletedBorder
            default: return Style.textLight
        }
    }
    border.width: 1

    Text {
        id: statusText
        anchors.centerIn: parent
        text: root.status.toUpperCase()
        font.pixelSize: 11
        font.bold: true
        color: {
            switch(root.status.toLowerCase()) {
                case "active": return Style.statusActiveText
                case "paused": return Style.statusPausedText
                case "completed": return Style.statusCompletedText
                default: return Style.textSecondary
            }
        }
    }
}
