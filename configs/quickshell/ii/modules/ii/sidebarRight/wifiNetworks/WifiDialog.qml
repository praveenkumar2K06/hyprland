import qs
import qs.services
import qs.services.network
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import QtQuick
import QtQuick.Layouts
import Quickshell

WindowDialog {
    id: root
    backgroundHeight: 600

    WindowDialogTitle {
        text: "Connect to Wi-Fi"
    }
    WindowDialogSeparator {
        visible: !NetworkV2.wifiScanning
    }
    StyledIndeterminateProgressBar {
        visible: NetworkV2.wifiScanning
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

        model: ScriptModel {
            values: Network.friendlyWifiNetworks
        }
        delegate: WifiNetworkItem {
            required property WifiAccessPoint modelData
            wifiNetwork: modelData
            width: ListView.view.width
        }
    }
    WindowDialogSeparator {}
    WindowDialogButtonRow {
        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Text
            buttonText: "Details"
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${Network.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Filled
            buttonText: "Done"
            onClicked: root.dismiss()
        }
    }
}