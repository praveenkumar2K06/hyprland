import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.bar
import qs.modules.ii.bar.cards
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    popupRadius: Appearance.rounding.large

    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        if (h > 0)
            return `${h}h, ${m}m`;
        else
            return `${m}m`;
    }

    animate: false
    contentItem: HeroCard {
        id: mediaHero
        compactMode: true
        adaptiveWidth: true
        anchors.centerIn: parent
        icon: "battery_android_full"

        title: {
            if (Battery.chargeState == 4) {
                return "Fully charged";
            } else if (Battery.chargeState == 1) {
                return "Charging: " + ` ${Battery.energyRate.toFixed(2)}W`;
            } else {
                return "Discharging: " + ` ${Battery.energyRate.toFixed(2)}W`;
            }
        }
        subtitle: { 
            Battery.isCharging ? "Time to full: " + ` ${formatTime(Battery.timeToFull)}` : "Time to empty: " + ` ${formatTime(Battery.timeToEmpty)}`;
        }

        pillText: `${(Battery.health).toFixed(1)}%`
        pillIcon: "battery_android_full"
    }
}