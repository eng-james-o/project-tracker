import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Dialog {
    id: root

    default property alias contentData: contentColumn.data

    property string saveButtonText: "Save"
    property string cancelButtonText: "Cancel"
    property bool canSave: true
    property int contentMargins: 20
    property int contentSpacing: 12

    modal: true
    anchors.centerIn: parent

    header: Rectangle {
        color: Style.background
        implicitHeight: 60
        radius: Style.radiusLarge

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Style.radiusLarge
            color: Style.background
        }

        Text {
            anchors.centerIn: parent
            text: root.title
            font.pixelSize: 18
            font.bold: true
            color: Style.textMain
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Style.border
        }
    }

    background: Rectangle {
        color: Style.surface
        radius: Style.radiusLarge
        border.color: Style.border
    }

    contentItem: Item {
        implicitWidth: contentColumn.implicitWidth + root.contentMargins * 2
        implicitHeight: contentColumn.implicitHeight + root.contentMargins * 2

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: root.contentMargins
            spacing: root.contentSpacing
        }
    }

    footer: Rectangle {
        implicitHeight: 68
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16

            Item { Layout.fillWidth: true }

            CustomButton {
                text: root.cancelButtonText
                variant: "ghost"
                onClicked: root.reject()
            }

            CustomButton {
                text: root.saveButtonText
                variant: "primary"
                enabled: root.canSave
                onClicked: {
                    if (root.canSave) {
                        root.accept()
                    }
                }
            }
        }
    }
}
