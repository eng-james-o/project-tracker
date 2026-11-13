import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.DragAndDrop 1.0
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
    property bool dragActive: false

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

    Drag.handler: DragHandler {
        id: dragHandler
        onActiveChanged: {
            if (active) {
                dragItem.source = root
                dragItem.data = root.deliverable
            }
        }
    }

    Drag.source: DragObject {
        id: dragItem
        dragType: "DeliverableItem"
    }

    DropArea {
        anchors.fill: parent
        onEntered: function(drag) {
            if (drag.hasFormat("DeliverableItem")) {
                root.dragActive = true
            }
        }
        onExited: function(drag) {
            root.dragActive = false
        }
        onDropped: function(drag) {
            if (drag.hasFormat("DeliverableItem")) {
                var draggedDeliverable = drag.getDataAsVariant("DeliverableItem")
                if (draggedDeliverable && draggedDeliverable.id !== root.deliverable.id) {
                    root.reorderRequested(draggedDeliverable.id, root.deliverable.id)
                }
                root.dragActive = false
            }
        }
    }
}
