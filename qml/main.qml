import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "."

ApplicationWindow {
    width: 560
    height: 700
    minimumWidth: 390
    minimumHeight: 420
    title: "Project Tracker"
    color: Style.background
    visible: accountController.email === ""

    Component.onCompleted: accountController.restore()

    onVisibleChanged: {
        if (visible)
            form.registering = false
    }

    component AccountTab: TabButton {
        id: tab
        hoverEnabled: true
        implicitHeight: 40
        contentItem: Label {
            text: tab.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: tab.checked ? Style.info : Style.textSecondary
            font.bold: tab.checked
        }
        background: Rectangle {
            radius: 9
            color: tab.checked ? Style.surface : (tab.hovered ? Style.ghostHover : "transparent")
            border.color: tab.activeFocus ? Style.primary : (tab.checked ? Style.border : "transparent")
        }
    }

    component PasswordEntry: CustomTextField {
        id: field
        property bool revealed: false

        echoMode: revealed ? TextInput.Normal : TextInput.Password
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhHiddenText | Qt.ImhNoPredictiveText
        rightPadding: 72

        onTextChanged: {
            if (text === "")
                revealed = false
        }

        CustomButton {
            objectName: field.objectName + "Visibility"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 3
            width: 64
            height: 32
            variant: "ghost"
            text: field.revealed ? "Hide" : "Show"
            Accessible.name: (field.revealed ? "Hide " : "Show ") + field.label.toLowerCase()
            onClicked: field.revealed = !field.revealed
        }
    }

    WorkspaceWindow { objectName: "workspaceWindow" }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            id: form
            width: Math.min(parent.width - 48, 448)
            x: (parent.width - width) / 2
            spacing: 18
            property bool registering: false
            readonly property bool mismatch: registering && confirmation.text !== "" && confirmation.text !== password.text
            readonly property bool ready: !accountController.busy && email.text.trim() !== "" && password.text !== ""
                                          && (!registering || password.text === confirmation.text)

            function switchMode(register) {
                registering = register
                password.clear()
                confirmation.clear()
                password.revealed = false
                confirmation.revealed = false
                accountController.clearMessage()
            }

            function submit() {
                if (!ready)
                    return
                if (registering)
                    accountController.signUp(email.text, password.text)
                else
                    accountController.signIn(email.text, password.text)
                password.clear()
                confirmation.clear()
                password.revealed = false
                confirmation.revealed = false
            }

            Item { implicitHeight: 18 }

            RowLayout {
                spacing: 12
                Image {
                    source: "../assets/app-icon.svg"
                    sourceSize.width: 44
                    sourceSize.height: 44
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                }
                Label {
                    text: "Project Tracker"
                    color: Style.textMain
                    font.pixelSize: 20
                    font.bold: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: card.implicitHeight + 52
                color: Style.surface
                border.color: Style.border
                radius: 22

                ColumnLayout {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 26
                    spacing: 14

                    Label {
                        Layout.fillWidth: true
                        text: accountController.hasSession ? "Restore your session"
                              : form.registering ? "Create your account" : "Welcome back"
                        color: Style.textMain
                        font.pixelSize: 30
                        font.bold: true
                        wrapMode: Text.Wrap
                    }

                    Label {
                        visible: !accountController.hasSession
                        Layout.fillWidth: true
                        text: form.registering ? "Confirm your email to start using Project Tracker."
                                               : "Sign in to open your workspace."
                        color: Style.textSecondary
                        font.pixelSize: 14
                        wrapMode: Text.Wrap
                    }

                    TabBar {
                        objectName: "accountTabs"
                        Layout.fillWidth: true
                        padding: 4
                        spacing: 4
                        visible: !accountController.hasSession
                        enabled: !accountController.busy
                        currentIndex: form.registering ? 1 : 0
                        onCurrentIndexChanged: {
                            if ((currentIndex === 1) !== form.registering)
                                form.switchMode(currentIndex === 1)
                        }
                        background: Rectangle { color: Style.secondary; radius: 12 }
                        AccountTab { text: "Sign in" }
                        AccountTab { text: "Sign up" }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        visible: !accountController.hasSession
                        enabled: !accountController.busy
                        spacing: 12

                        CustomTextField {
                            id: email
                            Layout.fillWidth: true
                            label: "Email address"
                            Accessible.name: label
                            inputMethodHints: Qt.ImhEmailCharactersOnly
                            onAccepted: password.forceActiveFocus()
                        }
                        PasswordEntry {
                            id: password
                            objectName: "accountPassword"
                            Layout.fillWidth: true
                            label: "Password"
                            Accessible.name: label
                            onAccepted: {
                                if (form.registering)
                                    confirmation.forceActiveFocus()
                                else
                                    form.submit()
                            }
                        }
                        PasswordEntry {
                            id: confirmation
                            objectName: "passwordConfirmation"
                            Layout.fillWidth: true
                            visible: form.registering
                            label: "Confirm password"
                            Accessible.name: label
                            onAccepted: form.submit()
                        }
                        Label {
                            visible: form.mismatch
                            text: "Passwords do not match."
                            color: Style.danger
                        }
                        CustomButton {
                            id: submitButton
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            text: form.registering ? "Create account" : "Sign in"
                            enabled: form.ready
                            contentItem: Label {
                                text: submitButton.text
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: true
                                color: submitButton.enabled ? Style.surface : Style.textLight
                            }
                            onClicked: form.submit()
                        }
                        CustomButton {
                            Layout.alignment: Qt.AlignHCenter
                            visible: email.text.trim() !== ""
                            text: "Resend confirmation"
                            variant: "ghost"
                            onClicked: accountController.resendConfirmation(email.text)
                        }
                    }

                    RowLayout {
                        visible: accountController.hasSession
                        enabled: !accountController.busy
                        CustomButton {
                            text: "Retry session"
                            onClicked: accountController.restore()
                        }
                        CustomButton {
                            text: "Sign out"
                            variant: "secondary"
                            onClicked: accountController.signOut()
                        }
                    }

                    ProgressBar {
                        Layout.fillWidth: true
                        visible: accountController.busy
                        indeterminate: true
                        Accessible.name: "Connecting"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: feedback.text !== ""
                        implicitHeight: feedback.implicitHeight + 20
                        color: Style.secondary
                        radius: 10

                        Label {
                            id: feedback
                            anchors.fill: parent
                            anchors.margins: 10
                            text: accountController.message
                            textFormat: Text.PlainText
                            color: Style.textSecondary
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }

            Item { implicitHeight: 18 }
        }
    }
}
