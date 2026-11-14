import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.DragAndDrop 1.0
import "../"

Rectangle {
    id: root
    property var step: ({})
    signal toggled(bool completed)
    signal editClicked()
    signal deleted()
    signal reorderRequested(int draggedStepId, int targetStepId)

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
            checked: root.step.completed || false
            onToggled: root.toggled(chk.checked)
        }

        Text {
            text: root.step.title || ""
            font.pixelSize: 13
            font.strikeout: root.step.completed
            color: root.step.completed ? Style.textLight : Style.textMain
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        RowLayout {
            spacing: 4
            visible: root.step.deadline && root.step.deadline.length > 0

            Image {
                source: "../../assets/calendar.svg"
                sourceSize.width: 12
                sourceSize.height: 12
            }

            Text {
                text: root.step.deadline || ""
                font.pixelSize: 11
                color: Style.textLight
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
                dragItem.data = root.step
            }
        }
    }

    Drag.source: DragObject {
        id: dragItem
        dragType: "StepItem"
    }

    DropArea {
        anchors.fill: parent
        onEntered: function(drag) {
            if (drag.hasFormat("StepItem")) {
                root.dragActive = true
            }
        }
        onExited: function(drag) {
            root.dragActive = false
        }
        onDropped: function(drag) {
            if (drag.hasFormat("StepItem")) {
                var draggedStep = drag.getDataAsVariant("StepItem")
                if (draggedStep && draggedStep.id !== root.step.id) {
                    root.reorderRequested(draggedStep.id, root.step.id)
                }
                root.dragActive = false
            }
        }
    }
}
