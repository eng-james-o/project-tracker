import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string variant: "primary" // "primary", "secondary", "danger", "ghost"

    implicitWidth: Math.max(100, buttonText.implicitWidth + 32)
    implicitHeight: 36

    background: Rectangle {
        radius: 6
        color: {
            if (!control.enabled) return "#E0E0E0"
            if (control.pressed) {
                switch(variant) {
                    case "primary": return "#1557B0"
                    case "secondary": return "#D0D0D0"
                    case "danger": return "#B31412"
                    case "ghost": return "#E8EAED"
                    default: return "#1557B0"
                }
            }
            if (control.hovered) {
                switch(variant) {
                    case "primary": return "#1765CC"
                    case "secondary": return "#E2E4E7"
                    case "danger": return "#D93025"
                    case "ghost": return "#F1F3F4"
                    default: return "#1765CC"
                }
            }
            switch(variant) {
                case "primary": return "#1A73E8"
                case "secondary": return "#F1F3F4"
                case "danger": return "#EA4335"
                case "ghost": return "transparent"
                default: return "#1A73E8"
            }
        }
        border.color: variant === "secondary" ? "#DADCE0" : "transparent"
        border.width: variant === "secondary" ? 1 : 0
    }

    contentItem: Text {
        id: buttonText
        text: control.text
        font.pixelSize: 13
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: {
            if (!control.enabled) return "#9AA0A6"
            switch(variant) {
                case "primary": return "#FFFFFF"
                case "secondary": return "#3C4043"
                case "danger": return "#FFFFFF"
                case "ghost": return "#1A73E8"
                default: return "#FFFFFF"
            }
        }
    }
}
