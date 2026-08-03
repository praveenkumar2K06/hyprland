import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.models.hyprland
import qs.services
import qs

QuickToggleModel {
    id: root
    name: "Game mode"
    toggled: !confOpt.value
    icon: "gamepad"

    mainAction: () => {
        root.toggled = !root.toggled;
        if (root.toggled) {
            HyprlandSettings.setKeys({
                "animations:enabled": false,
                "decoration:shadow:enabled": false,
                "decoration:blur:enabled": false,
                "general:gaps_in": 0,
                "general:gaps_out": 0,
                "general:border_size": 1,
                "general:allow_tearing": true,
                "windowrule:Blur": false
            });
        } else {
            HyprlandSettings.resetKeys([
                "animations:enabled",
                "decoration:shadow:enabled",
                "decoration:blur:enabled",
                "general:gaps_in",
                "general:gaps_out",
                "general:border_size",
                "general:allow_tearing",
                "windowrule:Blur"
            ]);
        }
    }

    HyprlandConfigOption {
        id: confOpt
        key: "animations:enabled"
    }

    tooltipText: "Game mode"
}
