import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.settings.bar
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.settings

import QtQml.Models

ContentPage {
    id: page
    forceWidth: true
    readonly property int index: 2 
    property bool register: parent.register ?? false

    property var componentMap: ({
        "active_window": activeWindow,
        "music_player": musicPlayer,
        "utility_buttons": utilityButtons,
        "system_tray": systemTray,
        "workspaces": workspaces,
        "timer": indicators,
        "record_indicator": indicators,
        "network_speed": networkSpeed
    })

    function scrollTo(stringId) {
        const item = componentMap[stringId]
        page.contentY = item.y
    }

    ContentSection {
        icon: "touch_app"
        title: "Interactive Placement"
        tooltip: "Visually preview and select shell bar positioning"

        BarVisualSelector {}
    }


    ContentSection {
        icon: "mobile_layout"
        title: "Bar layout"
        ContentSubsection {
            title: "Left layout"
            tooltip: "Top layout in vertical mode"
            ConfigListView {
                barSection: 0
                listModel: Config.options.bar.layouts.left
                onUpdated: (newList) => {
                    Config.options.bar.layouts.left = newList
                }
            }
        }
        ContentSubsection {
            title: "Center layout"
            tooltip: "Center the component with the button"
            ConfigListView {
                barSection: 1
                listModel: Config.options.bar.layouts.center
                onUpdated: (newList) => {
                    Config.options.bar.layouts.center = newList
                }
            }
        }
        ContentSubsection {
            title: "Right layout"
            tooltip: "Bottom layout in vertical mode"
            ConfigListView {
                barSection: 2
                listModel: Config.options.bar.layouts.right
                onUpdated: (newList) => {
                    Config.options.bar.layouts.right = newList
                }
            }
        }
    }

    ContentSection {
        icon: "open_in_full"
        title: "Bar sizes"

        ConfigSpinBox {
            icon: "height"
            text: "Bar height"
            value: Config.options.bar.sizes.height
            from: 30
            to: 50
            stepSize: 1
            onValueChanged: {
                Config.options.bar.sizes.height = value;
            }
        }
        ConfigSpinBox {
            icon: "width"
            text: "Bar width"
            value: Config.options.bar.sizes.width
            from: 30
            to: 50
            stepSize: 1
            onValueChanged: {
                Config.options.bar.sizes.width = value;
            }
        }
    }

    ContentSection {
        icon: "spoke"
        title: "Positioning & appearance"

        ConfigRow {
            ContentSubsection {
                title: "Bar position"
                Layout.fillWidth: true

                ConfigSelectionArray {
                    currentValue: (Config.options.bar.bottom ? 1 : 0) | (Config.options.bar.vertical ? 2 : 0)
                    onSelected: newValue => {
                        const newVertical = (newValue & 2) !== 0;
                        if (newVertical && !Config.options.bar.vertical) {
                            if (Config.options.bar.networkSpeed.displayMode < 4) {
                                Config.options.bar.networkSpeed.displayMode = 4;
                            }
                        }
                        Config.options.bar.bottom = (newValue & 1) !== 0;
                        Config.options.bar.vertical = newVertical;
                    }
                    options: [
                        {
                            displayName: "Top",
                            icon: "arrow_upward",
                            value: 0 // bottom: false, vertical: false
                        },
                        {
                            displayName: "Left",
                            icon: "arrow_back",
                            value: 2 // bottom: false, vertical: true
                        },
                        {
                            displayName: "Bottom",
                            icon: "arrow_downward",
                            value: 1 // bottom: true, vertical: false
                        },
                        {
                            displayName: "Right",
                            icon: "arrow_forward",
                            value: 3 // bottom: true, vertical: true
                        }
                    ]
                }
            }
            ContentSubsection {
                title: "Automatically hide"
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.bar.autoHide.enable
                    onSelected: newValue => {
                        Config.options.bar.autoHide.enable = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: "No",
                            icon: "close",
                            value: false
                        },
                        {
                            displayName: "Yes",
                            icon: "check",
                            value: true
                        }
                    ]
                }
            }
        }

        ConfigRow {
            Layout.fillHeight: false
            ContentSubsection {
                title: "Corner style"
                Layout.fillWidth: true

                ConfigSelectionArray {
                    currentValue: Config.options.bar.cornerStyle
                    onSelected: newValue => {
                        Config.options.bar.cornerStyle = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: "Hug",
                            icon: "line_curve",
                            value: 0
                        },
                        {
                            displayName: "Float",
                            icon: "page_header",
                            value: 1
                        },
                        {
                            displayName: "Rect",
                            icon: "toolbar",
                            value: 2
                        }
                    ]
                }
            }

            ContentSubsection {
                title: "Group style"
                tooltip: "Island style makes the group background opaque when bar is transparent"
                Layout.fillWidth: false

                ConfigSelectionArray {
                    currentValue: Config.options.bar.barGroupStyle
                    onSelected: newValue => {
                        Config.options.bar.barGroupStyle = newValue; // Update local copy
                    }
                    options: [
                        {
                            displayName: "Pills",
                            icon: "location_chip",
                            value: 0
                        },
                        {
                            displayName: "Island",
                            icon: "shadow",
                            value: 1
                        },
                        {
                            displayName: "Transparent",
                            icon: "opacity",
                            value: 2
                        }
                    ]
                }
            }
        }

        ContentSubsection {
            title: "Bar background style"
            tooltip: "Adaptive style makes the bar background transparent when there are no active windows"
            Layout.fillWidth: false

            ConfigSelectionArray {
                currentValue: Config.options.bar.barBackgroundStyle
                onSelected: newValue => {
                    Config.options.bar.barBackgroundStyle = newValue;
                }
                options: [ 
                    {
                        displayName: "Visible",
                        icon: "visibility",
                        value: 1
                    }, 
                    {
                        displayName: "Adaptive",
                        icon: "masked_transitions",
                        value: 2
                    },        
                    {
                        displayName: "Transparent",
                        icon: "opacity",
                        value: 0
                    }
                ]
            }
        }
    }
    
    ContentSection {
        id: activeWindow
        icon: "ad"
        title: "Active window"
        ConfigSwitch {
            buttonIcon: "crop_free"
            text: "Use fixed size"
            checked: Config.options.bar.activeWindow.fixedSize
            onCheckedChanged: {
                Config.options.bar.activeWindow.fixedSize = checked;
            }
        }
    }

    ContentSection {
        id: musicPlayer
        icon: "music_cast"
        title: "Media player"

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "crop_free"
                text: "Use fixed size"
                checked: Config.options.bar.mediaPlayer.useFixedSize
                onCheckedChanged: {
                    Config.options.bar.mediaPlayer.useFixedSize = checked;
                }
            }   

            ConfigSpinBox {
                enabled: !Config.options.bar.vertical && Config.options.bar.mediaPlayer.useFixedSize
                icon: "width_full"
                text: "Custom size"
                value: Config.options.bar.mediaPlayer.customSize
                from: 100
                to: 500
                stepSize: 25
                onValueChanged: {
                    Config.options.bar.mediaPlayer.customSize = value;
                }
            }
        }

        ContentSubsection {
            title: "Artwork"

            ConfigSwitch {
                enabled: !Config.options.bar.vertical
                buttonIcon: "image"
                text: "Enable artwork"
                checked: Config.options.bar.mediaPlayer.artwork.enable
                onCheckedChanged: {
                    Config.options.bar.mediaPlayer.artwork.enable = checked;
                }
            }
        }

    }
    

    ContentSection {
        icon: "notifications"
        title: "Notifications"
        ConfigSwitch {
            buttonIcon: "counter_2"
            text: "Unread indicator: show count"
            checked: Config.options.bar.indicators.notifications.showUnreadCount
            onCheckedChanged: {
                Config.options.bar.indicators.notifications.showUnreadCount = checked;
            }
        }
    }

    ContentSection {
        id: systemTray
        icon: "shelf_auto_hide"
        title: "Tray"

        ConfigSwitch {
            buttonIcon: "keep"
            text: 'Make icons pinned by default'
            checked: Config.options.tray.invertPinnedItems
            onCheckedChanged: {
                Config.options.tray.invertPinnedItems = checked;
            }
        }
        
        ConfigSwitch {
            buttonIcon: "colors"
            text: 'Tint icons'
            checked: Config.options.tray.monochromeIcons
            onCheckedChanged: {
                Config.options.tray.monochromeIcons = checked;
            }
        }
    }

    ContentSection {
        id: indicators
        icon: "ad"
        title: "Indicators"

        ContentSubsection {
            title: "Timer and pomodoro"

            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "timer"
                    text: "Show stopwatch"
                    checked: Config.options.bar.timers.showStopwatch
                    onCheckedChanged: {
                        Config.options.bar.timers.showStopwatch = checked;
                    }
                }
                ConfigSwitch {
                    buttonIcon: "search_activity"
                    text: "Show pomodoro"
                    checked: Config.options.bar.timers.showPomodoro
                    onCheckedChanged: {
                        Config.options.bar.timers.showPomodoro = checked;
                    }
                }
            }
        }
        
        ContentSubsection {
            title: "Record"

            ConfigSwitch {
                buttonIcon: "check_indeterminate_small"
                text: "Minimal mode"
                checked: Config.options.bar.indicators.record.minimal
                onCheckedChanged: {
                    Config.options.bar.indicators.record.minimal = checked;
                }
            }
        }
    }

    ContentSection {
        id: networkSpeed
        icon: "speed"
        title: "Network speed"
        
        ContentSubsection {
            title: "Mode selector"
            ConfigSelectionArray {
                currentValue: Config.options.bar.networkSpeed.displayMode
                onSelected: newValue => {
                    Config.options.bar.networkSpeed.displayMode = newValue;
                }
                options: [
                    { displayName: "Total", icon: "expand", value: 0, enabled: !Config.options.bar.vertical },
                    { displayName: "Download", icon: "arrow_downward", value: 1, enabled: !Config.options.bar.vertical },
                    { displayName: "Upload", icon: "arrow_upward", value: 2, enabled: !Config.options.bar.vertical },
                    { displayName: "Both", icon: "unfold_more", value: 3, enabled: !Config.options.bar.vertical },
                    { displayName: "Icon", icon: "wifi", value: 4 }
                ]
            }
        }

        ContentSubsection {
            title: "Icon settings"
            
            ConfigSwitch {
                buttonIcon: "vertical_align_center"
                text: "Show speed indicators (↑↓)"
                enabled: Config.options.bar.networkSpeed.displayMode !== 4
                opacity: enabled ? 1.0 : 0.5
                checked: Config.options.bar.networkSpeed.showIcons
                onCheckedChanged: {
                    Config.options.bar.networkSpeed.showIcons = checked;
                }
            }

            ContentSubsection {
                title: "Icon position"
                enabled: Config.options.bar.networkSpeed.showIcons
                opacity: enabled ? 1.0 : 0.5
                ConfigSelectionArray {
                    currentValue: Config.options.bar.networkSpeed.iconPosition
                    onSelected: newValue => {
                        Config.options.bar.networkSpeed.iconPosition = newValue;
                    }
                    options: [
                        { displayName: "Left", icon: "align_horizontal_left", value: 0 },
                        { displayName: "Right", icon: "align_horizontal_right", value: 1 }
                    ]
                }
            }
            }

            ContentSubsection {
                title: "Performance & Layout"
                ConfigSpinBox {
                    icon: "timer"
                    text: "Update interval (ms)"
                    value: Config.options.bar.networkSpeed.updateInterval
                    from: 100
                    to: 5000
                    stepSize: 100
                    onValueChanged: {
                        Config.options.bar.networkSpeed.updateInterval = value; 
                    }
                }
                ConfigSwitch {
                    buttonIcon: "visibility_off"
                    text: "Auto-hide when idle"
                    checked: Config.options.bar.networkSpeed.autoHide
                    onCheckedChanged: { 
                        Config.options.bar.networkSpeed.autoHide = checked; 
                    }
                }
            }
    }

    ContentSection {
        id: utilityButtons
        icon: "widgets"
        title: "Utility buttons"

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "content_cut"
                text: "Screen snip"
                checked: Config.options.bar.utilButtons.showScreenSnip
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenSnip = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "colorize"
                text: "Color picker"
                checked: Config.options.bar.utilButtons.showColorPicker
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showColorPicker = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "keyboard"
                text: "Keyboard toggle"
                checked: Config.options.bar.utilButtons.showKeyboardToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showKeyboardToggle = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "mic"
                text: "Mic toggle"
                checked: Config.options.bar.utilButtons.showMicToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showMicToggle = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "dark_mode"
                text: "Dark/Light toggle"
                checked: Config.options.bar.utilButtons.showDarkModeToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showDarkModeToggle = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "speed"
                text: "Performance Profile toggle"
                checked: Config.options.bar.utilButtons.showPerformanceProfileToggle
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showPerformanceProfileToggle = checked;
                }
            }
        }
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "videocam"
                text: "Record"
                checked: Config.options.bar.utilButtons.showScreenRecord
                onCheckedChanged: {
                    Config.options.bar.utilButtons.showScreenRecord = checked;
                }
            }
        }
    }

    ContentSection {
        id: workspaces
        icon: "workspaces"
        title: "Workspaces"

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "grid_3x3"
                text: 'Use workspace map'
                checked: Config.options.bar.workspaces.useWorkspaceMap
                onCheckedChanged: {
                    Config.options.bar.workspaces.useWorkspaceMap = checked;
                }
                StyledToolTip {
                    text: "Only for multi-monitor setups, you must edit the workspace map manually in config.json\n Refer to the repo wiki for more information"
                }
            }

            ConfigSwitch {
                buttonIcon: "counter_1"
                text: 'Always show numbers'
                checked: Config.options.bar.workspaces.alwaysShowNumbers
                onCheckedChanged: {
                    Config.options.bar.workspaces.alwaysShowNumbers = checked;
                }
            }
        }

        ConfigRow {
            uniform: true

            ConfigSwitch {
                buttonIcon: "award_star"
                text: 'Show app icons'
                checked: Config.options.bar.workspaces.showAppIcons
                onCheckedChanged: {
                    Config.options.bar.workspaces.showAppIcons = checked;
                }
            }

            ConfigSwitch {
                enabled: Config.options.bar.workspaces.showAppIcons
                buttonIcon: "colors"
                text: 'Tint app icons'
                checked: Config.options.bar.workspaces.monochromeIcons
                onCheckedChanged: {
                    Config.options.bar.workspaces.monochromeIcons = checked;
                }
            }
        }

        ConfigSwitch {
            buttonIcon: "hdr_weak"
            text: "Dynamic workspaces"
            checked: Config.options.bar.workspaces.dynamicWorkspaces
            onCheckedChanged: {
                Config.options.bar.workspaces.dynamicWorkspaces = checked;
            }
            StyledToolTip {
                text: "Hides the empty workspaces and only shows the ones with windows"
            }
        }

        ConfigSpinBox {
            enabled: !Config.options.bar.workspaces.dynamicWorkspaces
            icon: "view_column"
            text: "Workspaces shown"
            value: Config.options.bar.workspaces.shown
            from: 1
            to: 30
            stepSize: 1
            onValueChanged: {
                Config.options.bar.workspaces.shown = value;
            }
        }

        ConfigSpinBox {
            icon: "select_window"
            text: "Maximum window count per workspace"
            value: Config.options.bar.workspaces.maxWindowCount
            from: 1
            to: 20
            stepSize: 1
            onValueChanged: {
                Config.options.bar.workspaces.maxWindowCount = value;
            }
        }

        ConfigSpinBox {
            icon: "touch_long"
            text: "Number show delay when pressing Super (ms)"
            value: Config.options.bar.workspaces.showNumberDelay
            from: 0
            to: 1000
            stepSize: 50
            onValueChanged: {
                Config.options.bar.workspaces.showNumberDelay = value;
            }
        }

        ContentSubsection {
            title: "Number style"

            ConfigSelectionArray {
                currentValue: JSON.stringify(Config.options.bar.workspaces.numberMap)
                onSelected: newValue => {
                    Config.options.bar.workspaces.numberMap = JSON.parse(newValue)
                }
                options: [
                    {
                        displayName: "Normal",
                        icon: "timer_10",
                        value: '[]'
                    },
                    {
                        displayName: "Han chars",
                        icon: "square_dot",
                        value: '["一","二","三","四","五","六","七","八","九","十","十一","十二","十三","十四","十五","十六","十七","十八","十九","二十"]'
                    },
                    {
                        displayName: "Roman",
                        icon: "account_balance",
                        value: '["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV","XVI","XVII","XVIII","XIX","XX"]'
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "tooltip"
        title: "Tooltips"
        ConfigRow {
            ConfigSwitch {
                buttonIcon: "ads_click"
                text: "Click to show"
                Layout.fillWidth: true
                checked: Config.options.bar.tooltips.clickToShow
                onCheckedChanged: {
                    Config.options.bar.tooltips.clickToShow = checked;
                }
                StyledToolTip {
                    text: "You will not be able to use the buttons on some popups if you enable this option."
                }
            }
            ConfigSwitch {
                buttonIcon: "compress"
                text: "Compact popups"
                Layout.fillWidth: true
                checked: Config.options.bar.tooltips.compactPopups
                onCheckedChanged: {
                    Config.options.bar.tooltips.compactPopups = checked;
                }
            }
        }

        ContentSubsection {
            title: "Resources"
            ConfigSwitch {
                buttonIcon: "swap_horiz"
                text: "Show Swap"
                Layout.fillWidth: true
                checked: Config.options.bar.tooltips.showSwap
                onCheckedChanged: {
                    Config.options.bar.tooltips.showSwap = checked;
                }
            }
        }
    }

    
}