import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: "Dark Mode"
    statusText: Appearance.m3colors.darkmode ? "Dark" : "Light"

    toggled: Appearance.m3colors.darkmode
    icon: "contrast"
    
    mainAction: () => {
        if (Appearance.m3colors.darkmode) {
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPathv2,"--light"]);
        } else {
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPathv2, "--dark"]);
        }
    }

    tooltipText: "Dark Mode"
}
