import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

WindowDialog {
    id: root
    backgroundHeight: 600

    RowLayout {
        Layout.fillWidth: true

        WindowDialogTitle {
            text: "Connect to Wi-Fi"
            Layout.fillWidth: true
        }

        MaterialButtonE {
            type: MaterialButtonE.ButtonType.Text
            materialIcon: "refresh"
            iconSize: Appearance.font.pixelSize.larger
            leftPadding: 8
            rightPadding: 8
            onClicked: {
                NetworkV2.scanning = true;
            }
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
            type: MaterialButtonE.ButtonType.Filled
            buttonText: "Done"
            onClicked: root.dismiss()
        }
    }
}