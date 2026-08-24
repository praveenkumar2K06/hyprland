import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import qs.modules.common.widgets.window_dialog
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

WindowDialog {
    id: root
    backgroundHeight: 600

    RowLayout {
        Layout.fillWidth: true

        MaterialShapeWrappedMaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            text: NetworkV2.wifiEnabled
                ? (NetworkV2.connected ? "wifi" : "wifi_find")
                : "wifi_off"
            iconSize: 18
            padding: 7
            shape: MaterialShape.Shape.Cookie7Sided
            color: NetworkV2.wifiEnabled ? Appearance.colors.colPrimaryContainer : Appearance.colors.colSurfaceContainerHighest
            colSymbol: NetworkV2.wifiEnabled ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnSurfaceVariant
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: "Wi-Fi"
                color: Appearance.colors.colOnSurface
                elide: Text.ElideRight
                font {
                    family: Appearance.font.family.title
                    pixelSize: Appearance.font.pixelSize.title
                    variableAxes: Appearance.font.variableAxes.title
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: {
                    if (!NetworkV2.wifiEnabled) return "Off";
                    if (Networking.connectivity === NetworkConnectivity.Connecting) return "Connecting…";
                    if (NetworkV2.connected) return "Connected" + " • " + NetworkV2.networkName;
                    if (NetworkV2.wifiScanning) return "Scanning…";
                    return "Not connected";
                }
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
                elide: Text.ElideRight
                animateChange: true
            }
        }

        StyledSwitch {
            Layout.alignment: Qt.AlignVCenter
            checked: NetworkV2.wifiEnabled
            onToggled: NetworkV2.toggleWifi()
        }
    }
    WindowDialogSeparator {
        visible: !NetworkV2.scanning
    }
    StyledIndeterminateProgressBar {
        visible: NetworkV2.scanning
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large
    }
    StyledListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -10
        Layout.bottomMargin: -10
        Layout.leftMargin: -Appearance.rounding.normal
        Layout.rightMargin: -Appearance.rounding.normal

        clip: true
        spacing: 5
        animateAppearance: true
        animateMovement: true

        model: ScriptModel {
            values: [...NetworkV2.friendlyNetworks]
        }
        delegate: WifiNetworkItem {
            required property WifiNetwork modelData
            wifiNetwork: modelData
            width: ListView.view.width
        }
    }
    WindowDialogSeparator {}
    WindowDialogButtonRow {
        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Text
            buttonText: "Rescan"
            enabled: NetworkV2.wifiEnabled && !NetworkV2.scanning
            onClicked: Network.rescanWifi()
        }

        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Text
            buttonText: "Details"
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${NetworkV2.connectionType === "ethernet" ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Text
            buttonText: "Done"
            onClicked: root.dismiss()
        }
    }
}