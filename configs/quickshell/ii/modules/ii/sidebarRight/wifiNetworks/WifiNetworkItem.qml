import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

DialogListItem {
    id: root
    required property WifiNetwork wifiNetwork
    property bool isActive: NetworkV2.networkName === root.wifiNetwork?.name
    property bool isConnecting: Networking.connectivity === NetworkConnectivity.Connecting
    property bool requiresPassword: root.wifiNetwork?.security !== WifiSecurityType.Open && root.wifiNetwork?.security !== WifiSecurityType.Unknown && root.wifiNetwork?.security !== WifiSecurityType.Owe
    property bool askPassword: false
    property bool requiresPublicPortal: Networking.connectivity === NetworkConnectivity.Portal
    property bool expanded: false
    readonly property int signalStrength: root.wifiNetwork?.signalStrength ? Math.round(root.wifiNetwork.signalStrength * 100) : 0

    onClicked: {
        if (wifiNetwork?.connected) {
            expanded = !expanded;
            return;
        }
        if(wifiNetwork?.known) {
            wifiNetwork.connect();
        } else {
            askPassword = true;
        }
    }

    Connections {
        target: wifiNetwork

        function onConnectionFailed(reason) {
            if(reason === ConnectionFailReason.NoSecrets) {
                askPassword = true;
            }
        }
    }

    Connections {
        target: Network

        function onNetworkChanged() {
            if (NetworkV2.networkName !== root.wifiNetwork?.name) {
                root.expanded = false;
            }
        }
    }

    buttonRadius: Appearance.rounding.normal

    contentItem: ColumnLayout {
        anchors {
            fill: parent
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Signal strength icon in subtle container
            Item {
                Layout.alignment: Qt.AlignVCenter
                width: 30
                height: 30

                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colPrimaryContainer
                    opacity: root.isActive ? 1 : 0
                    Behavior on opacity {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    iconSize: 20
                    text: NetworkV2.networkIcon(root.wifiNetwork)
                    color: root.isActive ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnSurfaceVariant
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: -2

                StyledText {
                    Layout.fillWidth: true
                    color: root.isActive ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
                    elide: Text.ElideRight
                    text: root.wifiNetwork?.name ?? "Unknown"
                    textFormat: Text.PlainText
                }

                StyledText {
                    Layout.fillWidth: true
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.isActive ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                    elide: Text.ElideRight
                    text: {
                        if (root.isConnecting) return "Connecting…";
                        if (root.isActive) return "Connected" + " • " + root.signalStrength + "%";
                        const sec = root.requiresPassword ? "Secured" : "Open";
                        return sec + " • " + root.signalStrength + "%";
                    }
                    animateChange: true
                }
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                visible: root.isActive || root.isConnecting || root.requiresPassword
                text: root.isActive ? "check_circle" : root.isConnecting ? "more_horiz" : "lock"
                iconSize: Appearance.font.pixelSize.large
                color: root.isActive ? Appearance.colors.colPrimary : Appearance.colors.colOnSurfaceVariant
            }
        }

        ColumnLayout { // Password
            id: passwordPrompt
            Layout.topMargin: 10
            visible: root.askPassword

            MaterialTextField {
                id: passwordField
                Layout.fillWidth: true
                placeholderText: "Password"

                // Password
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                onAccepted: {
                    root.wifiNetwork.connectWithPsk(passwordField.text);
                    root.askPassword = false;
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                MaterialButtonE {
                    type: MaterialButtonE.ButtonType.Text
                    buttonText: "Cancel"
                    onClicked: {
                        root.wifiNetwork.askPassword = false;
                    }
                }

                MaterialButtonE {
                    type: MaterialButtonE.ButtonType.Text
                    buttonText: "Connect"
                    onClicked: {
                        root.wifiNetwork.connectWithPsk(passwordField.text);
                        root.askPassword = false;
                    }
                }
            }
        }

        ColumnLayout { // Public wifi login page
            id: publicWifiPortal
            Layout.topMargin: 8
            visible: root.isActive && root.requiresPublicPortal

            MaterialButtonE {
                type: MaterialButtonE.ButtonType.Filled
                Layout.fillWidth: true
                buttonText: "Open network portal"
                onClicked: {
                    NetworkV2.openPublicWifiPortal()
                    GlobalStates.sidebarRightOpen = false
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
