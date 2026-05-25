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
        Quickshell.execDetached([Directories.gameModeTogglePath]);
        GlobalStates.sidebarRightOpen = false;
    }

    HyprlandConfigOption {
        id: confOpt
        key: "decoration:blur:enabled"
    }

    tooltipText: "Game mode"
}
