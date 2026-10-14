import QtQuick
import QtQuick.Controls
import "../"

Column {
    id: root
    property string markdownText: ""
    spacing: 8

    function parseMarkdown(text) {
        if (!text) return []

        var lines = text.split('\n')
        var blocks = []
        var currentList = []
        var inCodeBlock = false
        var codeContent = ""

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]

            // Code block detection
            if (line.trim().startsWith('```')) {
                if (inCodeBlock) {
                    blocks.push({ type: 'code', content: codeContent })
                    codeContent = ""
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                }
                continue
            }

            if (inCodeBlock) {
                codeContent += line + '\n'
                continue
            }

            // Headers
            if (line.startsWith('# ')) {
                if (currentList.length > 0) {
                    blocks.push({ type: 'list', items: currentList })
                    currentList = []
                }
                blocks.push({ type: 'h1', content: line.substring(2).trim() })
            } else if (line.startsWith('## ')) {
                if (currentList.length > 0) {
                    blocks.push({ type: 'list', items: currentList })
                    currentList = []
                }
                blocks.push({ type: 'h2', content: line.substring(3).trim() })
            } else if (line.startsWith('### ')) {
                if (currentList.length > 0) {
                    blocks.push({ type: 'list', items: currentList })
                    currentList = []
                }
                blocks.push({ type: 'h3', content: line.substring(4).trim() })
            }
            // Checkboxes
            else if (line.trim().startsWith('- [ ]') || line.trim().startsWith('- [x]')) {
                var checked = line.trim().startsWith('- [x]')
                var itemText = line.trim().substring(line.trim().indexOf(']') + 1).trim()
                currentList.push({ type: 'checkbox', checked: checked, content: itemText })
            }
            // Bullet points
            else if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
                var bulletText = line.trim().substring(2).trim()
                currentList.push({ type: 'bullet', content: bulletText })
            }
            // Regular text
            else if (line.trim().length > 0) {
                if (currentList.length > 0) {
                    blocks.push({ type: 'list', items: currentList })
                    currentList = []
                }
                blocks.push({ type: 'text', content: line.trim() })
            }
        }

        // Push remaining list items
        if (currentList.length > 0) {
            blocks.push({ type: 'list', items: currentList })
        }

        return blocks
    }

    Repeater {
        model: root.parseMarkdown(root.markdownText)

        delegate: Loader {
            sourceComponent: {
                switch (modelData.type) {
                    case 'h1': return header1Component
                    case 'h2': return header2Component
                    case 'h3': return header3Component
                    case 'text': return textComponent
                    case 'list': return listComponent
                    case 'code': return codeComponent
                    default: return textComponent
                }
            }

            property var blockData: modelData
        }
    }

    Component {
        id: header1Component
        Text {
            text: blockData.content
            font.pixelSize: 20
            font.bold: true
            color: Style.textMain
            wrapMode: Text.Wrap
            width: root.width
        }
    }

    Component {
        id: header2Component
        Text {
            text: blockData.content
            font.pixelSize: 18
            font.bold: true
            color: Style.textMain
            wrapMode: Text.Wrap
            width: root.width
        }
    }

    Component {
        id: header3Component
        Text {
            text: blockData.content
            font.pixelSize: 16
            font.bold: true
            color: Style.textMain
            wrapMode: Text.Wrap
            width: root.width
        }
    }

    Component {
        id: textComponent
        Text {
            text: blockData.content
            font.pixelSize: 13
            color: Style.textMain
            wrapMode: Text.Wrap
            width: root.width
        }
    }

    Component {
        id: listComponent
        Column {
            spacing: 4
            width: root.width
            Repeater {
                model: blockData.items
                delegate: Row {
                    spacing: 8
                    width: parent.width
                    CustomCheckBox {
                        visible: modelData.type === 'checkbox'
                        checked: modelData.checked
                        enabled: false
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: modelData.type === 'checkbox' ? modelData.content : (modelData.type === 'bullet' ? '• ' + modelData.content : modelData.content)
                        font.pixelSize: 13
                        color: Style.textMain
                        wrapMode: Text.Wrap
                        width: parent.width - 32
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Component {
        id: codeComponent
        Rectangle {
            width: root.width
            color: Style.background
            radius: Style.radiusSmall
            implicitHeight: codeText.implicitHeight + 16

            Text {
                id: codeText
                anchors.fill: parent
                anchors.margins: 8
                text: blockData.content
                font.pixelSize: 12
                font.family: "monospace"
                color: Style.textMain
                wrapMode: Text.Wrap
            }
        }
    }
}
