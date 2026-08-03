import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.bar.cards
import qs.modules.ii.bar
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    popupRadius: Appearance.rounding.large

    function formatSpeed(bytesPerSecond) {
        var bits = bytesPerSecond * 8;
        var suffix = "bps";

        if (bits < 1000) {
            return bits.toFixed(0) + " " + suffix;
        } else if (bits < 1000000) {
            return (bits / 1000).toFixed(1) + " K" + suffix;
        } else if (bits < 1000000000) {
            return (bits / 1000000).toFixed(1) + " M" + suffix;
        } else {
            return (bits / 1000000000).toFixed(1) + " G" + suffix;
        }
    }

    function formatTotal(bytes) {
        var bits = bytes * 8;

        if (bits < 1000000) {
            return (bits / 1000).toFixed(1) + " Kb";
        } else if (bits < 1000000000) {
            return (bits / 1000000).toFixed(1) + " Mb";
        } else {
            return (bits / 1000000000).toFixed(1) + " Gb";
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        HeroCard {
            id: networkHero
            icon: NetworkV2.connectionType === "ethernet" ? "lan" : "wifi"
            title: NetworkV2.connectionType === "ethernet" ? "Ethernet" : "Wi-Fi"
            subtitle: NetworkV2.networkName || "Connected"

            compactMode: true
            adaptiveWidth: true
            
            // Show signal strength in the pill if wifi
            pillText: NetworkV2.connectionType !== "ethernet" ? (NetworkV2.networkStrength + "%") : ""
            pillIcon: NetworkV2.connectionType !== "ethernet" ? "signal_wifi_4_bar" : ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            InfoPill {
                icon: "download"
                text: "Download: " + formatSpeed(NetworkUsage.networkDownloadSpeed)
                containerColor: Appearance.colors.colPrimaryContainer
                shapeColor: Appearance.colors.colPrimary
                symbolColor: Appearance.colors.colOnPrimary
                textColor: Appearance.colors.colOnPrimaryContainer
            }

            InfoPill {
                icon: "upload"
                text: "Upload: " + formatSpeed(NetworkUsage.networkUploadSpeed)
                containerColor: Appearance.colors.colSecondaryContainer
                shapeColor: Appearance.colors.colSecondary
                symbolColor: Appearance.colors.colOnSecondary
                textColor: Appearance.colors.colOnSecondaryContainer
            }

            InfoPill {
                visible: !Config.options.bar.tooltips.compactPopups
                icon: "data_usage"
                text: "Usage: " + formatTotal(NetworkUsage.networkDownloadTotal + NetworkUsage.networkUploadTotal)
                containerColor: Appearance.colors.colTertiaryContainer
                shapeColor: Appearance.colors.colTertiary
                symbolColor: Appearance.colors.colOnTertiary
                textColor: Appearance.colors.colOnTertiaryContainer
            }
        }
    }
}
