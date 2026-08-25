pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.modules.common.models.quickToggles

Singleton {
    id: root

    readonly property Component networkToggle: NetworkToggle {}
    readonly property Component bluetoothToggle: BluetoothToggle {}
    readonly property Component idleInhibitorToggle: IdleInhibitorToggle {}
    readonly property Component nightLightToggle: NightLightToggle {}
    readonly property Component darkModeToggle: DarkModeToggle {}
    readonly property Component cloudflareWarpToggle: CloudflareWarpToggle {}
    readonly property Component gameModeToggle: GameModeToggle {}
    readonly property Component colorPickerToggle: ColorPickerToggle {}
    readonly property Component micToggle: MicToggle {}
    readonly property Component audioToggle: AudioToggle {}
    readonly property Component notificationToggle: NotificationToggle {}
    readonly property Component powerProfileToggle: PowerProfilesToggle {}
    readonly property Component antiFlashbangToggle: AntiFlashbangToggle {}
    readonly property Component screenSnipToggle: ScreenSnipToggle {}
    readonly property Component screenRecordToggle: ScreenRecordToggle {}

    readonly property var toggles: ({
        "network": {
            "model": root.networkToggle,
            "dialog": "wifi"
        },
        "bluetooth": {
            "model": root.bluetoothToggle,
            "dialog": "bluetooth"
        },
        "idleInhibitor": {
            "model": root.idleInhibitorToggle
        },
        "nightLight": {
            "model": root.nightLightToggle,
            "dialog": "nightLight"
        },
        "darkMode": {
            "model": root.darkModeToggle
        },
        "cloudflareWarp": {
            "model": root.cloudflareWarpToggle
        },
        "gameMode": {
            "model": root.gameModeToggle
        },
        "colorPicker": {
            "model": root.colorPickerToggle
        },
        "mic": {
            "model": root.micToggle,
            "dialog": "audioInput"
        },
        "audio": {
            "model": root.audioToggle,
            "dialog": "audioOutput"
        },
        "notifications": {
            "model": root.notificationToggle
        },
        "powerProfile": {
            "model": root.powerProfileToggle
        },
        "antiFlashbang": {
            "model": root.antiFlashbangToggle,
            "dialog": "nightLight"
        },
        "screenSnip": {
            "model": root.screenSnipToggle
        },
        "screenRecord": {
            "model": root.screenRecordToggle
        }
    })

    readonly property list<string> types: Object.keys(toggles)
}
