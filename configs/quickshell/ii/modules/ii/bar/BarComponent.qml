import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.modules.ii.bar.active_window
import qs.modules.ii.bar.battery
import qs.modules.ii.bar.clock
import qs.modules.ii.bar.dashboard
import qs.modules.ii.bar.logo
import qs.modules.ii.bar.music_player
import qs.modules.ii.bar.network
import qs.modules.ii.bar.record
import qs.modules.ii.bar.screen_share
import qs.modules.ii.bar.system_monitor
import qs.modules.ii.bar.timer
import qs.modules.ii.bar.tray
import qs.modules.ii.bar.utility_buttons
import qs.modules.ii.bar.weather
import qs.modules.ii.bar.workspaces

import qs.modules.ii.verticalBar as Vertical

Item {
    id: rootItem

    property int barSection // 0: left, 1: center, 2: right
    property var list
    required property var modelData
    required property int index
    property var originalIndex: index
    property bool vertical: false
    property bool highlighted: false

    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight

    function toggleVisible(visibility) {
        visible = visibility
        if (barSection == 0) Config.options.bar.layouts.left[originalIndex].visible = visibility
        else if (barSection == 1) Config.options.bar.layouts.center[originalIndex].visible = visibility
        else if (barSection == 2) Config.options.bar.layouts.right[originalIndex].visible = visibility
    }

    function toggleHighlight(highlight) {
        rootItem.highlighted = highlight
    }

    property var compMap: ({ // [horizontal, vertical]
        "active_window": [activeWindowComp, activeWindowComp],
        "battery": [batteryComp, batteryCompVert],
        "clock": [clockComp, clockCompVert],
        "dashboard_panel_button": [dashboardPanelButton, dashboardPanelButtonVert],
        "date": [dateCompVert, dateCompVert],
        "logo": [logoComp, logoComp],
        "music_player": [musicPlayerComp, musicPlayerCompVert],
        "network_speed": [networkSpeedComp, networkSpeedComp],
        "record_indicator": [recordIndicatorComp, recordIndicatorComp],
        "screen_share_indicator": [screenshareIndicatorComp, screenshareIndicatorComp],
        "system_monitor": [systemMonitorComp, systemMonitorCompVert],
        "system_tray": [systemTrayComp, systemTrayComp],
        "timer": [timerComp, timerCompVert],
        "utility_buttons": [utilityButtonsComp, utilityButtonsComp],
        "weather": [weatherComp, weatherComp],
        "workspaces": [workspaceComp, workspaceComp],
    })

    property real startRadius: {
        if (barSection === 0) {
            if (originalIndex == 0) return Appearance.rounding.full
            return Appearance.rounding.verysmall
        } else if (barSection === 2) {
            let hasVisibleLeft = list.slice(0, originalIndex).some(item => item.visible !== false)
            return hasVisibleLeft ? Appearance.rounding.verysmall : Appearance.rounding.full
        } else { // barSection 1 
            if (list.length === 1) return Appearance.rounding.full
            let hasVisibleLeft = list.slice(0, originalIndex).some(item => item.visible !== false)
            return hasVisibleLeft ? Appearance.rounding.verysmall : Appearance.rounding.full
        }
    }

    property real endRadius: {
        if (barSection === 2) {
            if (originalIndex == list.length - 1) return Appearance.rounding.full
            return Appearance.rounding.verysmall
        } else if (barSection === 0) {
            let hasVisibleRight = list.slice(originalIndex + 1).some(item => item.visible !== false)
            return hasVisibleRight ? Appearance.rounding.verysmall : Appearance.rounding.full
        } else { // barSection 1 
            if (list.length === 1) return Appearance.rounding.full
            let hasVisibleRight = list.slice(originalIndex + 1).some(item => item.visible !== false)
            return hasVisibleRight ? Appearance.rounding.verysmall : Appearance.rounding.full
        }
    }

    readonly property int barGroupStyle: Config.options.bar.barGroupStyle
    readonly property int barBackgroundStyle: Config.options.bar.barBackgroundStyle
    property color colBackground: barGroupStyle == 0 ? Appearance.colors.colLayer1 :
                                   (barGroupStyle == 1 && barBackgroundStyle == 1) ? Appearance.colors.colLayer1 :
                                   (barGroupStyle == 1) ? Appearance.m3colors.m3surfaceContainerLow :
                                   "transparent";
    
    property color colBackgroundHighlight: Appearance.colors.colPrimary

    BarGroup {
        id: wrapper
        vertical: rootItem.vertical
        anchors {
            verticalCenter: rootItem.vertical ? rootItem.verticalCenter : undefined
            horizontalCenter: rootItem.vertical ? undefined : rootItem.horizontalCenter
        }
        
        startRadius: rootItem.startRadius
        endRadius: rootItem.endRadius
        colBackground: rootItem.highlighted ? rootItem.colBackgroundHighlight : rootItem.colBackground

        readonly property var _currentComp: {
            let builtin = compMap[modelData.id]
            return builtin[vertical ? 1 : 0]
        }

        Loader {
            id: itemLoader
            active: true
            sourceComponent: wrapper._currentComp
        }
    }

    Component { id: workspaceComp; Workspaces { vertical: rootItem.vertical } }
    
    Component { id: musicPlayerCompVert; Vertical.VerticalMedia {} }
    Component { id: musicPlayerComp; Media {} }

    Component { id: systemMonitorComp; Resources {} }
    Component { id: systemMonitorCompVert; Vertical.Resources {} }

    Component { id: clockCompVert; Vertical.VerticalClockWidget { barItem: rootItem } }
    Component { id: clockComp; ClockWidget { barItem: rootItem } }

    Component { id: batteryComp; BatteryIndicator {} }
    Component { id: batteryCompVert; Vertical.BatteryIndicator {} }
    
    Component { id: utilityButtonsComp; UtilButtons { vertical: rootItem.vertical } }

    Component { id: systemTrayComp; SysTray { barItem: rootItem; vertical: rootItem.vertical } }

    Component { id: activeWindowComp; ActiveWindow { vertical: rootItem.vertical } }

    Component { id: dateCompVert; Vertical.VerticalDateWidget {} }
    
    Component { id: recordIndicatorComp; RecordIndicator { barItem: rootItem; vertical: rootItem.vertical } }

    Component { id: screenshareIndicatorComp; ScreenShareIndicator { barItem: rootItem } }

    Component { id: timerComp; TimerWidget { barItem: rootItem } }
    Component { id: timerCompVert; Vertical.VerticalTimerWidget { barItem: rootItem } }

    Component { id: logoComp; Logo {} }
    
    Component { id: dashboardPanelButton; DashboardPanelButton {} }
    Component { id: dashboardPanelButtonVert; VerticalDashboardPanelButton {} }
    
    Component { id: networkSpeedComp; NetworkSpeed { barItem: rootItem; vertical: rootItem.vertical } }

    Component { id: weatherComp; WeatherBar { vertical: rootItem.vertical } }
}
