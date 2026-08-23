pragma Singleton
import QtQuick
import Quickshell
import qs.services

Singleton {
    id: root

    readonly property var builtinComponents: [
        { id: "active_window", icon: "label", title: "Active window" },
        { id: "battery", icon: "battery_android_6", title: "Battery" },
        { id: "clock", icon: "nest_clock_farsight_analog", title: "Clock" },
        { id: "dashboard_panel_button", icon: "notifications", title: "Dashboard panel button" },
        { id: "date", icon: "date_range", title: "Date" },
        { id: "music_player", icon: "music_note", title: "Music player" },
        { id: "network_speed", icon: "speed", title: "Network speed" },
        { id: "record_indicator", icon: "screen_record", title: "Record indicator" },
        { id: "screen_share_indicator", icon: "screen_share", title: "Screen share indicator" },
        { id: "system_monitor", icon: "monitor_heart", title: "System monitor" },
        { id: "system_tray", icon: "system_update_alt", title: "System tray" },
        { id: "timer", icon: "timer", title: "Timer & Pomodoro" },
        { id: "utility_buttons", icon: "build", title: "Utility buttons" },
        { id: "weather", icon: "weather_mix", title: "Weather" },
        { id: "workspaces", icon: "workspaces", title: "Workspaces" },
    ]

    property var allComponents: root.builtinComponents

    function getComponent(id) {
        return root.allComponents.find(c => c.id === id) || null
    }

    function getAvailableComponents(usedIds) {
        return root.allComponents.filter(c => !usedIds.includes(c.id))
    }
}
