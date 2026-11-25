import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "."

ApplicationWindow {
    width: 520
    height: 560
    minimumWidth: 420
    minimumHeight: 460
    title: "Project Tracker"
    color: Style.background
    visible: accountController.email === ""

    Component.onCompleted: accountController.restore()

    onVisibleChanged: {
        if (visible)
            form.registering = false
    }

    WorkspaceWindow { objectName: "workspaceWindow" }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: Math.min(parent.width - 48, 420)
            x: (parent.width - width) / 2
            spacing: 16
            property bool registering: false

            function switchMode(register) {
                registering = register
                password.clear()
                confirmation.clear()
                accountController.clearMessage()
            }

            id: form

            Item { implicitHeight: 12 }

            Label {
                text: "Project Tracker"
                color: Style.textMain
                font.pixelSize: 28
                font.bold: true
            }

            TabBar {
                objectName: "accountTabs"
                Layout.fillWidth: true
                visible: !accountController.hasSession
                enabled: !accountController.busy
                currentIndex: form.registering ? 1 : 0
                onCurrentIndexChanged: {
                    if ((currentIndex === 1) !== form.registering)
                        form.switchMode(currentIndex === 1)
                }
                TabButton { text: "Sign in" }
                TabButton { text: "Sign up" }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: !accountController.hasSession
                enabled: !accountController.busy
                spacing: 12

                CustomTextField {
                    id: email
                    Layout.fillWidth: true
                    label: "Email"
                    inputMethodHints: Qt.ImhEmailCharactersOnly
                }
                CustomTextField {
                    id: password
                    Layout.fillWidth: true
                    label: "Password"
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData
                }
                CustomTextField {
                    id: confirmation
                    objectName: "passwordConfirmation"
                    Layout.fillWidth: true
                    visible: form.registering
                    label: "Confirm password"
                    echoMode: TextInput.Password
                    inputMethodHints: Qt.ImhSensitiveData
                }
                Label {
                    visible: form.registering && confirmation.text !== "" && confirmation.text !== password.text
                    text: "Passwords do not match."
                    color: Style.textSecondary
                }
                CustomButton {
                    text: form.registering ? "Create account" : "Sign in"
                    variant: "primary"
                    enabled: email.text.trim() !== "" && password.text !== ""
                             && (!form.registering || password.text === confirmation.text)
                    onClicked: {
                        if (form.registering)
                            accountController.signUp(email.text, password.text)
                        else
                            accountController.signIn(email.text, password.text)
                        password.clear()
                        confirmation.clear()
                    }
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
                    onClicked: accountController.signOut()
                }
            }

            Label {
                visible: text !== ""
                text: accountController.busy ? "Connecting…" : accountController.message
                textFormat: Text.PlainText
                color: Style.textSecondary
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            Item { implicitHeight: 12 }
        }
    }
}
