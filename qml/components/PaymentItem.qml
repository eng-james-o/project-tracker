import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"

Rectangle {
    Layout.fillWidth: true
    implicitHeight: 60
    radius: 6
    color: "#F8F9FA"
    border.color: "#E0E0E0"

    property var payment: ({})
    signal editClicked()
    signal deleted()

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        ColumnLayout {
            spacing: 2

            Text {
                text: payment.payment_method ? payment.payment_method : "Payment"
                font.pixelSize: 13
                font.bold: true
                color: "#202124"
            }

            Text {
                text: payment.description || "No description"
                font.pixelSize: 11
                color: "#5F6368"
                elide: Text.ElideRight
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignRight

            Text {
                text: (payment.currency || "USD") + " " + (payment.amount ? payment.amount.toFixed(2) : "0.00")
                font.pixelSize: 14
                font.bold: true
                color: "#34A853"
                Layout.alignment: Qt.AlignRight
            }

            Text {
                text: payment.payment_date || "N/A"
                font.pixelSize: 11
                color: "#70757A"
                Layout.alignment: Qt.AlignRight
            }
        }

        ColumnLayout {
            spacing: 4
            Layout.alignment: Qt.AlignRight

            CustomButton {
                text: "Edit"
                variant: "ghost"
                implicitWidth: 60
                onClicked: editClicked()
            }

            CustomButton {
                text: "Delete"
                variant: "danger"
                implicitWidth: 60
                onClicked: deleted()
            }
        }
    }
}
