pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    function networkIcon(network): string {
        const s = network?.signalStrength ?? 0;
        if (s >= 0.75) return "signal_wifi_4_bar";
        if (s >= 0.5) return "network_wifi_3_bar";
        if (s >= 0.25) return "network_wifi_2_bar";
        if (s > 0) return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }

    readonly property string icon: {
        if (ethernetConnected) return "network-wired-symbolic";
        if (activeWifi) return networkIcon(activeWifi);
        if (!wifiEnabled) return "signal_wifi_statusbar_not_connected";
        return "signal_wifi_statusbar_not_connected";
    }


    function findDevice(type) {
        return Networking.devices.values.find(d => d.type === type) ?? null;
    }

    readonly property var wifiDevice: findDevice(DeviceType.Wifi)
    readonly property var wiredDevice: findDevice(DeviceType.Wired)

    // WiFi
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property var networks: wifiDevice?.networks?.values ?? []
    readonly property var friendlyNetworks: networks.filter(n => n.name.length > 0).sort((a, b) => {
        if (a.connected && !b.connected) return -1;
        if (!a.connected && b.connected) return 1;
        return b.signalStrength - a.signalStrength;
    }) ?? []
    readonly property WifiNetwork activeWifi: networks.find(n => n.connected) ?? null
    readonly property int networkStrength: activeWifi?.signalStrength ? Math.round(activeWifi.signalStrength * 100) : 0

    // Ethernet
    readonly property bool ethernetConnected: wiredDevice?.connected ?? false
    readonly property string ethernetDevice: wiredDevice?.name ?? ""

    // Combined state
    readonly property bool connected: ethernetConnected || activeWifi !== null
    readonly property string connectionType: ethernetConnected ? "ethernet" : (activeWifi ? "wifi" : "none")

    readonly property string networkName: activeWifi?.name ?? "Disconnected"

    // Scanning is expensive; the UI sets this true only while showing the list.
    property bool scanning: false
    onScanningChanged: {
        if (wifiDevice) wifiDevice.scannerEnabled = scanning
    }
    onWifiDeviceChanged: if (wifiDevice) wifiDevice.scannerEnabled = scanning

    function enableWifi() {
        if(!Networking.wifiEnabled) {
            Networking.wifiEnabled = true;
        }
    }

    function toggleWifi() {
        if (Networking.wifiEnabled) {
            Networking.wifiEnabled = false;
        } else {
            Networking.wifiEnabled = true;
        }
    }

    function openPublicWifiPortal() {
        Quickshell.execDetached(["xdg-open", "https://nmcheck.gnome.org/"])
    }
    
}