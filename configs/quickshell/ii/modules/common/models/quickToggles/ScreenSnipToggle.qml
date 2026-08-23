import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: "Screen snip"
    hasStatusText: false
    toggled: false
    icon: "screenshot_region"

    mainAction: () => {
        GlobalStates.sidebarRightOpen = false;
        const savePath = Config.options.screenSnip.savePath;
        const command = savePath.length > 0
            ? `sleep 0.3; grim -g "$(slurp)" "$1/screenshot_$(date '+%Y-%m-%d_%H.%M.%S').png"`
            : `sleep 0.3; grim -g "$(slurp)" - | wl-copy`;
        Quickshell.execDetached(["bash", "-c", command, "screensnip", savePath]);
    }

    tooltipText: "Screen snip"
}
