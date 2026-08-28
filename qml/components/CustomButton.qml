import QtQuick
import QtQuick.Controls

Button {
    id: control
    property string variant: "primary" // "primary", "secondary", "danger", "ghost", "icon"
    property string iconSource: ""

    implicitWidth: variant === "icon" ? 34 : Math.max(90, buttonContent.implicitWidth + 28)
    implicitHeight: 36

    hoverEnabled: true

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
                    case "icon": return "#D2E3FC"
                    default: return "#1557B0"
                }
            }
            if (control.hovered) {
                switch(variant) {
                    case "primary": return "#1765CC"
                    case "secondary": return "#E2E4E7"
                    case "danger": return "#D93025"
                    case "ghost": return "#F1F3F4"
                    case "icon": return "#E8F0FE" // Visual hover feedback for icon buttons
                    default: return "#1765CC"
                }
            }
            switch(variant) {
                case "primary": return "#1A73E8"
                case "secondary": return "#F1F3F4"
                case "danger": return "#EA4335"
                case "ghost": return "transparent"
                case "icon": return "transparent"
                default: return "#1A73E8"
            }
        }
        border.color: {
            if (control.hovered && variant === "icon") return "#1A73E8"
            return variant === "secondary" ? "#DADCE0" : "transparent"
        }
        border.width: (variant === "secondary" || (control.hovered && variant === "icon")) ? 1 : 0
    }

    contentItem: Row {
        id: buttonContent
        spacing: 6
        anchors.centerIn: parent

        Image {
            source: control.iconSource
            sourceSize.width: 16
            sourceSize.height: 16
            visible: control.iconSource.length > 0
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.text
            visible: control.text.length > 0
            font.pixelSize: 13
            font.bold: true
            color: {
                if (!control.enabled) return "#9AA0A6"
                switch(variant) {
                    case "primary": return "#FFFFFF"
                    case "secondary": return "#3C4043"
                    case "danger": return "#FFFFFF"
                    case "ghost": return "#1A73E8"
                    case "icon": return "#1A73E8"
                    default: return "#FFFFFF"
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
