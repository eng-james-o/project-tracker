import QtQuick
import QtQuick.Controls
import "../"

CheckBox {
    id: control

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: Style.radiusSmall
        border.color: control.checked ? Style.primary : Style.border
        border.width: 1
        color: control.checked ? Style.primary : Style.surface

        Image {
            anchors.centerIn: parent
            source: "../../assets/check-circle.svg"
            sourceSize.width: 12
            sourceSize.height: 12
            visible: control.checked
        }
    }

    contentItem: Text {
        leftPadding: control.indicator.width + control.spacing
        text: control.text
        font: control.font
        color: Style.textMain
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        color: "transparent"
    }
}
