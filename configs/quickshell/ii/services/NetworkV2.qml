pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    property NetworkDevice adapter: Networking.devices?.values[0] ?? null
    readonly property string networkType: adapter?.type === DeviceType.Wifi ? "Wi-Fi" : adapter?.type === DeviceType.Ethernet ? "Ethernet" : "Unknown"

    readonly property WifiNetwork activeNetwork: adapter?.networks?.values.find(network => network.connected) ?? null

    property bool wifiScanning: adapter?.scannerEnabled ?? false

    readonly property bool wifiEnabled: Networking.wifiEnabled

    readonly property string materialSymbol: {
        if (!Networking.wifiHardwareEnabled)
            return "signal_wifi_statusbar_not_connected";
        else if (!Networking.wifiEnabled)
            return "signal_wifi_off";
        else if (adapter?.state == ConnectionState.Connecting || adapter?.state == ConnectionState.Disconnecting)
            return "wifi_find";
        else if (adapter?.connected) {
            let strength = "signal_wifi_0_bar";
            if(activeNetwork?.signalStrength >= 0.85) {
                strength = "signal_wifi_4_bar";
            } else if (activeNetwork?.signalStrength >= 0.66) {
                strength = "network_wifi_3_bar";
            } else if (activeNetwork?.signalStrength >= 0.33) {
                strength = "network_wifi_2_bar";
            } else {
                strength = "network_wifi_1_bar";
            }

            return strength;
        }
        return "signal_wifi_statusbar_not_connected";
    }

    readonly property real networksLength: adapter?.networks.values.length ?? 0

    readonly property string networkName: activeNetwork?.name ?? "Disconnected"
    
}