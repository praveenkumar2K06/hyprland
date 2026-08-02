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
    property bool requiresPassword: root.wifiNetwork?.security !== WifiSecurityType.Open && root.wifiNetwork?.security !== WifiSecurityType.Unknown && root.wifiNetwork?.security !== WifiSecurityType.Owe
    property bool askPassword: false
    property bool requiresPublicPortal: Networking.connectivity === NetworkConnectivity.Portal
    property bool expanded: false

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
            // Name
            spacing: 10
            MaterialSymbol {
                iconSize: Appearance.font.pixelSize.larger
                property real strength: root.wifiNetwork?.signalStrength ?? 0
                text: NetworkV2.networkIcon(root.wifiNetwork)
                color: Appearance.colors.colOnSurfaceVariant
            }
            StyledText {
                Layout.fillWidth: true
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
                text: root.wifiNetwork?.name ?? "Unknown Network"
                textFormat: Text.PlainText
            }

            MaterialSymbol {
                visible: root.requiresPassword
                text: NetworkV2.networkName === root.wifiNetwork?.name ? "settings_ethernet" : "lock"
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        RowLayout {
            visible: root.expanded
            Layout.topMargin: 8
            Item {
                Layout.fillWidth: true
            }
            MaterialButtonE {
                type: MaterialButtonE.ButtonType.Error
                buttonText: "Forget"
                onClicked: {
                    wifiNetwork.forget();
                }
            }
            MaterialButtonE {
                type: MaterialButtonE.ButtonType.Filled
                buttonText: "Disconnect"

                onClicked: {
                    wifiNetwork.disconnect();
                }
            }
        }

        ColumnLayout { // Password
            id: passwordPrompt
            Layout.topMargin: 8
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
            visible: root.wifiNetwork?.connected && root.requiresPublicPortal

            RowLayout {
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
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
