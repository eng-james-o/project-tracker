import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property string status: "active" // "active", "paused", "completed"

    implicitWidth: statusText.implicitWidth + 20
    implicitHeight: 26
    radius: 13

    color: {
        switch(status.toLowerCase()) {
            case "active": return "#E6F4EA" // soft green
            case "paused": return "#FEF7E0" // soft yellow/amber
            case "completed": return "#E8F0FE" // soft blue
            default: return "#F1F3F4"
        }
    }

    border.color: {
        switch(status.toLowerCase()) {
            case "active": return "#34A853"
            case "paused": return "#FBBC04"
            case "completed": return "#1A73E8"
            default: return "#9AA0A6"
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
                case "active": return "#137333"
                case "paused": return "#B06000"
                case "completed": return "#174EA6"
                default: return "#5F6368"
            }
        }
    }
}
