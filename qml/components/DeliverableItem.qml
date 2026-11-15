import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../"

Rectangle {
    id: root
    property var deliverable: ({})
    signal toggled(bool completed)
    signal editClicked()
    signal deleted()
    signal reorderRequested(int draggedDeliverableId, int targetDeliverableId)

    implicitHeight: 44
    radius: Style.radiusMedium
    color: dragActive ? Style.secondary : Style.background
    border.color: Style.border
    border.width: 1
    readonly property bool dragActive: dropZone.containsDrag

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Space) {
                chk.checked = !chk.checked
                root.toggled(chk.checked)
                event.accepted = true
            }
        }

        CustomCheckBox {
            id: chk
            checked: root.deliverable.completed || false
            onToggled: root.toggled(chk.checked)
        }

        Image {
            source: "../../assets/package.svg"
            sourceSize.width: 16
            sourceSize.height: 16
        }

        Text {
            text: root.deliverable.title || ""
            font.pixelSize: 13
            font.bold: true
            font.strikeout: root.deliverable.completed
            color: root.deliverable.completed ? Style.textLight : Style.textMain
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        RowLayout {
            spacing: 4
            visible: root.deliverable.deadline && root.deliverable.deadline.length > 0

            Image {
                source: "../../assets/calendar.svg"
                sourceSize.width: 12
                sourceSize.height: 12
            }

            Text {
                text: root.deliverable.deadline || ""
                font.pixelSize: 11
                color: Style.danger
            }
        }

        CustomButton {
            variant: "icon"
            iconSource: "../../assets/edit.svg"
            onClicked: root.editClicked()
        }

        CustomButton {
            variant: "icon"
            iconSource: "../../assets/trash.svg"
            onClicked: root.deleted()
        }
    }

    DragHandler {
        id: handler
        target: null
        onActiveChanged: {
            if (active) marker.Drag.start()
            else marker.Drag.drop()
        }
    }
    Item {
        id: marker
        x: handler.centroid.position.x
        y: handler.centroid.position.y
        Drag.source: root
        Drag.keys: ["DeliverableItem"]
    }
    DropArea {
        id: dropZone
        anchors.fill: parent
        keys: ["DeliverableItem"]
        onDropped: function(event) {
            if (event.source !== root)
                root.reorderRequested(event.source.deliverable.id, root.deliverable.id)
        }
    }
}
