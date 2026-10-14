import QtQuick
import QtQuick.Controls
import "../"

Button {
    id: control
    property string variant: "primary" // "primary", "secondary", "danger", "ghost", "icon"
    property string iconSource: ""

    implicitWidth: variant === "icon" ? 34 : (control.text.length === 0 ? buttonContent.implicitWidth + 20 : Math.max(90, buttonContent.implicitWidth + 28))
    implicitHeight: 36

    hoverEnabled: true

    background: Rectangle {
        radius: Style.radiusMedium
        color: {
            if (!control.enabled) return Style.border
            if (control.pressed) {
                switch(variant) {
                    case "primary": return Style.primaryPressed
                    case "secondary": return Style.secondaryPressed
                    case "danger": return Style.dangerPressed
                    case "ghost": return Style.ghostPressed
                    case "icon": return Style.iconPressed
                    default: return Style.primaryPressed
                }
            }
            if (control.hovered) {
                switch(variant) {
                    case "primary": return Style.primaryHover
                    case "secondary": return Style.secondaryHover
                    case "danger": return Style.dangerHover
                    case "ghost": return Style.ghostHover
                    case "icon": return Style.iconHover
                    default: return Style.primaryHover
                }
            }
            switch(variant) {
                case "primary": return Style.primary
                case "secondary": return Style.secondary
                case "danger": return Style.danger
                case "ghost": return "transparent"
                case "icon": return "transparent"
                default: return Style.primary
            }
        }
        border.color: {
            if (control.hovered && variant === "icon") return Style.primary
            return variant === "secondary" ? Style.secondaryBorder : "transparent"
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
                if (!control.enabled) return Style.textLight
                switch(variant) {
                    case "primary": return Style.surface
                    case "secondary": return Style.textMain
                    case "danger": return Style.surface
                    case "ghost": return Style.primary
                    case "icon": return Style.primary
                    default: return Style.surface
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
