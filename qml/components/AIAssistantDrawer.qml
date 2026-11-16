import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Drawer {
    id: drawer
    width: Math.min(400, parent.width)
    height: parent.height
    edge: Qt.RightEdge
    property bool waiting: false
    ListModel { id: messages }

    function sendMessage() {
        const prompt = input.text.trim()
        if (!prompt || waiting) return
        messages.append({body: prompt, fromUser: true})
        input.clear()
        waiting = true
        aiController.generateAsync(prompt, "")
    }

    function finish(text) {
        waiting = false
        messages.append({body: text, fromUser: false})
    }

    Connections {
        target: aiController
        function onGenerationFinished(text) { drawer.finish(text) }
        function onGenerationFailed(error) { drawer.finish(error) }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        RowLayout {
            Text {
                text: "AI Assistant"
                color: Style.textMain
                font.bold: true
                font.pixelSize: 18
                Layout.fillWidth: true
            }
            CustomButton {
                variant: "icon"
                iconSource: "../../assets/sidebar.svg"
                Accessible.name: "Close AI Assistant"
                onClicked: drawer.close()
            }
        }
        ListView {
            id: history
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12
            model: messages
            onContentHeightChanged: positionViewAtEnd()
            delegate: Label {
                required property string body
                required property bool fromUser
                width: history.width
                text: body
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                color: fromUser ? Style.primary : Style.textMain
            }
        }
        Label { text: "Waiting for response…"; visible: drawer.waiting; color: Style.textSecondary }
        RowLayout {
            CustomTextField {
                id: input
                Layout.fillWidth: true
                placeholderText: "Ask about your project…"
                onAccepted: drawer.sendMessage()
            }
            CustomButton {
                text: "Send"
                enabled: input.text.trim().length > 0 && !drawer.waiting
                onClicked: drawer.sendMessage()
            }
        }
    }
}
