import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common

QuickToggleModel {
    id: root
    name: "Record screen"
    toggled: Persistent.states.screenRecord.active
    icon: "screen_record"
    statusText: root.toggled ? root.formatTime(Persistent.states.screenRecord.seconds) : ""

    function formatTime(totalSeconds) {
        const mins = Math.floor(totalSeconds / 60);
        const secs = totalSeconds % 60;
        return String(mins).padStart(2, '0') + ":" + String(secs).padStart(2, '0');
    }

    mainAction: () => {
        GlobalStates.sidebarRightOpen = false;
        Quickshell.execDetached(["bash", "-c", `sleep 0.3; exec '${Directories.recordScriptPath}'`]);
    }

    tooltipText: "Record screen"
}
