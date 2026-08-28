import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    title: "Select Date"
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    width: 320

    signal dateSelected(string selectedDate)

    property int currentYear: new Date().getFullYear()
    property int currentMonth: new Date().getMonth() + 1 // 1-12
    property int selectedDay: new Date().getDate()

    function getDaysInMonth(year, month) {
        return new Date(year, month, 0).getDate()
    }

    function getFirstDayOfWeek(year, month) {
        return new Date(year, month - 1, 1).getDay()
    }

    function formatFormattedDate() {
        var m = currentMonth < 10 ? "0" + currentMonth : currentMonth
        var d = selectedDay < 10 ? "0" + selectedDay : selectedDay
        return currentYear + "-" + m + "-" + d
    }

    onAccepted: {
        root.dateSelected(formatFormattedDate())
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Month & Year Header
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "◄"
                flat: true
                onClicked: {
                    if (root.currentMonth === 1) {
                        root.currentMonth = 12
                        root.currentYear--
                    } else {
                        root.currentMonth--
                    }
                }
            }

            Text {
                text: Qt.formatDate(new Date(root.currentYear, root.currentMonth - 1, 1), "MMMM yyyy")
                font.pixelSize: 14
                font.bold: true
                color: "#202124"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Button {
                text: "►"
                flat: true
                onClicked: {
                    if (root.currentMonth === 12) {
                        root.currentMonth = 1
                        root.currentYear++
                    } else {
                        root.currentMonth++
                    }
                }
            }
        }

        // Days Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                delegate: Text {
                    text: modelData
                    font.pixelSize: 11
                    font.bold: true
                    color: "#70757A"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }

        // Days Grid
        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: root.getFirstDayOfWeek(root.currentYear, root.currentMonth)
                delegate: Item {
                    Layout.fillWidth: true
                    implicitHeight: 30
                }
            }

            Repeater {
                model: root.getDaysInMonth(root.currentYear, root.currentMonth)

                delegate: Rectangle {
                    property int dayNum: index + 1
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 15
                    color: dayNum === root.selectedDay ? "#1A73E8" : (mouseArea.containsMouse ? "#E8F0FE" : "transparent")

                    Text {
                        anchors.centerIn: parent
                        text: dayNum.toString()
                        font.pixelSize: 12
                        font.bold: dayNum === root.selectedDay
                        color: dayNum === root.selectedDay ? "#FFFFFF" : "#202124"
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedDay = dayNum
                        }
                    }
                }
            }
        }
    }
}
