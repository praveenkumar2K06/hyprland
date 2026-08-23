import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import qs.modules.common.widgets.window_dialog

Item {
    id: root

    readonly property bool usePasswordChars: !(PolkitService.flow?.responseVisible ?? true)
    readonly property bool authenticating: PolkitService.active && !PolkitService.interactionAvailable
    property bool revealPassword: false
    readonly property string feedbackText: {
        const supplementary = PolkitService.supplementaryMessage;
        if (supplementary.length > 0) return supplementary;
        return PolkitService.isError ? "Authentication failed" : "";
    }
    readonly property bool feedbackIsError: PolkitService.supplementaryIsError || PolkitService.isError
    readonly property color feedbackColor: root.feedbackIsError ? Appearance.colors.colError : Appearance.colors.colPrimary
    readonly property string headerIcon: {
        const iconName = PolkitService.flow?.iconName ?? "";
        if (iconName.includes("changes-allow") || iconName.includes("unlock")) return "lock_open";
        if (iconName.includes("fingerprint") || iconName.includes("password")) return "password";
        return "lock";
    }

    Keys.onPressed: event => { // Esc to close
        if (event.key === Qt.Key_Escape) {
            PolkitService.cancel();
        }
    }

    function submit() {
        PolkitService.submit(inputField.text);
    }

    Connections {
        target: PolkitService
        function onInteractionAvailableChanged() {
            if (!PolkitService.interactionAvailable) return;
            root.revealPassword = false;
            inputField.text = "";
            inputField.forceActiveFocus();
        }
        function onIsErrorChanged() {
            if (PolkitService.isError) shakeAnimation.start();
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Appearance.colors.colScrim
        opacity: 0
        Component.onCompleted: {
            opacity = 1
        }
        Behavior on opacity {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }

    WindowDialog {
        id: dialog
        anchors.centerIn: parent
        backgroundWidth: 430
        show: false
        Component.onCompleted: {
            show = true
        }
        onDismiss: PolkitService.cancel()

        transform: Translate { id: shakeTranslate }

        SequentialAnimation { // Shake on failure
            id: shakeAnimation
            NumberAnimation { target: shakeTranslate; property: "x"; to: 14; duration: 55; easing.type: Easing.OutCubic }
            NumberAnimation { target: shakeTranslate; property: "x"; to: -11; duration: 95; easing.type: Easing.InOutCubic }
            NumberAnimation { target: shakeTranslate; property: "x"; to: 7; duration: 85; easing.type: Easing.InOutCubic }
            NumberAnimation { target: shakeTranslate; property: "x"; to: -3; duration: 75; easing.type: Easing.InOutCubic }
            NumberAnimation { target: shakeTranslate; property: "x"; to: 0; duration: 65; easing.type: Easing.InOutCubic }
        }

        Rectangle { // Icon badge
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 72
            implicitHeight: 72
            radius: Appearance.rounding.full
            color: PolkitService.isError ? Appearance.colors.colErrorContainer : Appearance.colors.colPrimaryContainer
            scale: dialog.show ? 1 : 0
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.animation.clickBounce.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.expressiveDefaultSpatial
                }
            }

            MaterialSymbol {
                anchors.centerIn: parent
                iconSize: 34
                text: root.headerIcon
                fill: 1
                color: PolkitService.isError ? Appearance.colors.colOnErrorContainer : Appearance.colors.colOnPrimaryContainer
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        WindowDialogTitle {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Authentication"
        }

        WindowDialogParagraph {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            visible: PolkitService.cleanMessage.length > 0
            text: PolkitService.cleanMessage
        }

        Item { // Supplementary message (error / info), collapses when empty
            Layout.fillWidth: true
            implicitHeight: root.feedbackText === "" ? 0 : feedbackRow.implicitHeight
            clip: true
            Behavior on implicitHeight {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            RowLayout {
                id: feedbackRow
                anchors.centerIn: parent
                spacing: 6

                MaterialSymbol {
                    text: root.feedbackIsError ? "error" : "info"
                    iconSize: Appearance.font.pixelSize.normal
                    color: root.feedbackColor
                }

                StyledText {
                    text: root.feedbackText
                    color: root.feedbackColor
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    Layout.maximumWidth: feedbackRow.parent.width - 40
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        RowLayout { // Input
            Layout.fillWidth: true
            spacing: 8

            MaterialTextField {
                id: inputField
                Layout.fillWidth: true
                focus: true
                enabled: PolkitService.interactionAvailable
                placeholderText: PolkitService.cleanPrompt
                echoMode: root.usePasswordChars && !root.revealPassword ? TextInput.Password : TextInput.Normal
                onAccepted: root.submit();

                Keys.onPressed: event => { // Esc to close
                    if (event.key === Qt.Key_Escape) {
                        PolkitService.cancel();
                    }
                }
            }

            RippleButton {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignVCenter
                visible: root.usePasswordChars
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer1Hover
                colRipple: Appearance.colors.colLayer1Active
                onClicked: root.revealPassword = !root.revealPassword

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.revealPassword ? "visibility_off" : "visibility"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        WindowDialogButtonRow {
            Item {
                Layout.fillWidth: true
            }
            MaterialButtonE {
                type: MaterialButtonE.ButtonType.Text
                buttonText: "Cancel"
                onClicked: PolkitService.cancel();
            }
            MaterialButtonE {
                enabled: PolkitService.interactionAvailable
                type: MaterialButtonE.ButtonType.Filled
                buttonText: "Confirm"
                onClicked: root.submit();
            }
        }
    }
}
