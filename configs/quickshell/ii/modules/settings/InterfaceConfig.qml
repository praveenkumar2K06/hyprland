import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.widgets.settings
import Quickshell
import Quickshell.Io

ContentPage {
    id: page
    readonly property int index: 4
    property bool register: parent.register ?? false
    forceWidth: true

    ContentSection {
        icon: "notifications"
        title: "Notifications"

        ConfigSpinBox {
            icon: "av_timer"
            text: "Timeout duration (if not defined by notification) (ms)"
            value: Config.options.notifications.timeout
            from: 1000
            to: 60000
            stepSize: 1000
            onValueChanged: {
                Config.options.notifications.timeout = value;
            }
        }
    }

    ContentSection {
        icon: "side_navigation"
        title: "Sidebars"

        ConfigSwitch {
            buttonIcon: "memory"
            text: 'Keep right sidebar loaded'
            checked: Config.options.sidebar.keepRightSidebarLoaded
            onCheckedChanged: {
                Config.options.sidebar.keepRightSidebarLoaded = checked;
            }
            StyledToolTip {
                text: "When enabled keeps the content of the right sidebar loaded to reduce the delay when opening,\nat the cost of around 15MB of consistent RAM usage. Delay significance depends on your system's performance.\nUsing a custom kernel like linux-cachyos might help"
            }
        }

        ConfigRow {
            ContentSubsection {
                title: "Sidebar position"

                ConfigSelectionArray {
                    currentValue: Config.options.sidebar.position
                    onSelected: newValue => {
                        Config.options.sidebar.position = newValue;
                    }
                    options: [
                        {
                            displayName: "Default",
                            icon: "side_navigation",
                            value: "default"
                        },
                        {
                            displayName: "Inverted",
                            icon: "swap_horiz",
                            value: "inverted"
                        },
                        {
                            displayName: "Left",
                            icon: "align_horizontal_left",
                            value: "left"
                        },
                        {
                            displayName: "Right",
                            icon: "align_horizontal_right",
                            value: "right"
                        }
                    ]
                }
            }
        }

        ContentSubsection {
            title: "Quick toggles"

            ConfigSpinBox {
                enabled: Config.options.sidebar.quickToggles.style === "android"
                icon: "splitscreen_left"
                text: "Columns"
                value: Config.options.sidebar.quickToggles.android.columns
                from: 1
                to: 8
                stepSize: 1
                onValueChanged: {
                    Config.options.sidebar.quickToggles.android.columns = value;
                }
            }
        }

        ContentSubsection {
            title: "Sliders"

            ConfigSwitch {
                buttonIcon: "check"
                text: "Enable"
                checked: Config.options.sidebar.quickSliders.enable
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.enable = checked;
                }
            }
            
            ConfigSwitch {
                buttonIcon: "brightness_6"
                text: "Brightness"
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showBrightness
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showBrightness = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "backlight_low"
                text: "Gamma"
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showGamma
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showGamma = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "volume_up"
                text: "Volume"
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showVolume
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showVolume = checked;
                }
            }

            ConfigSwitch {
                buttonIcon: "mic"
                text: "Microphone"
                enabled: Config.options.sidebar.quickSliders.enable
                checked: Config.options.sidebar.quickSliders.showMic
                onCheckedChanged: {
                    Config.options.sidebar.quickSliders.showMic = checked;
                }
            }
        }

        ContentSubsection {
            title: "Corner open"
            tooltip: "Allows you to open sidebars by clicking or hovering screen corners regardless of bar position"
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "check"
                    text: "Enable"
                    checked: Config.options.sidebar.cornerOpen.enable
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.enable = checked;
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "highlight_mouse_cursor"
                text: "Hover to trigger"
                checked: Config.options.sidebar.cornerOpen.clickless
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.clickless = checked;
                }

                StyledToolTip {
                    text: "When this is off you'll have to click"
                }
            }
            Row {
                ConfigSwitch {
                    enabled: !Config.options.sidebar.cornerOpen.clickless
                    text: "Force hover open at absolute corner"
                    checked: Config.options.sidebar.cornerOpen.clicklessCornerEnd
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerEnd = checked;
                    }

                    StyledToolTip {
                        text: "When the previous option is off and this is on,\nyou can still hover the corner's end to open sidebar,\nand the remaining area can be used for volume/brightness scroll"
                    }
                }
                ConfigSpinBox {
                    icon: "arrow_cool_down"
                    text: "with vertical offset"
                    value: Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset
                    from: 0
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.clicklessCornerVerticalOffset = value;
                    }
                }
            }
            
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "vertical_align_bottom"
                    text: "Place at bottom"
                    checked: Config.options.sidebar.cornerOpen.bottom
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.bottom = checked;
                    }

                    StyledToolTip {
                        text: "Place the corners to trigger at the bottom"
                    }
                }
                ConfigSwitch {
                    buttonIcon: "unfold_more_double"
                    text: "Value scroll"
                    checked: Config.options.sidebar.cornerOpen.valueScroll
                    onCheckedChanged: {
                        Config.options.sidebar.cornerOpen.valueScroll = checked;
                    }

                    StyledToolTip {
                        text: "Brightness and volume"
                    }
                }
            }
            ConfigSwitch {
                buttonIcon: "visibility"
                text: "Visualize region"
                checked: Config.options.sidebar.cornerOpen.visualize
                onCheckedChanged: {
                    Config.options.sidebar.cornerOpen.visualize = checked;
                }
            }
            ConfigRow {
                ConfigSpinBox {
                    icon: "arrow_range"
                    text: "Region width"
                    value: Config.options.sidebar.cornerOpen.cornerRegionWidth
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionWidth = value;
                    }
                }
                ConfigSpinBox {
                    icon: "height"
                    text: "Region height"
                    value: Config.options.sidebar.cornerOpen.cornerRegionHeight
                    from: 1
                    to: 300
                    stepSize: 1
                    onValueChanged: {
                        Config.options.sidebar.cornerOpen.cornerRegionHeight = value;
                    }
                }
            }
        }
    }

    ContentSection {
        icon: "voting_chip"
        title: "On-screen display"

        ConfigSpinBox {
            icon: "av_timer"
            text: "Timeout (ms)"
            value: Config.options.osd.timeout
            from: 100
            to: 3000
            stepSize: 100
            onValueChanged: {
                Config.options.osd.timeout = value;
            }
        }
    }

    ContentSection {
        icon: "overview_key"
        title: "Overview"

        ConfigRow {
            ConfigSwitch {
                buttonIcon: "check"
                text: "Enable"
                checked: Config.options.overview.enable
                onCheckedChanged: {
                    Config.options.overview.enable = checked;
                }
            }
        }
        
        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "visibility"
                text: "Show icons"
                checked: Config.options.overview.showIcons
                onCheckedChanged: {
                    Config.options.overview.showIcons = checked;
                }
            }
            ConfigSwitch {
                enabled: Config.options.overview.showIcons
                buttonIcon: "center_focus_strong"
                text: "Center icons"
                checked: Config.options.overview.centerIcons
                onCheckedChanged: {
                    Config.options.overview.centerIcons = checked;
                }
            }
        }
        
        ConfigSwitch {
            buttonIcon: "grid_3x3"
            text: "Use workspace map"
            checked: Config.options.overview.useWorkspaceMap
            onCheckedChanged: {
                Config.options.overview.useWorkspaceMap = checked;
            }
            StyledToolTip {
                text: "Only for multi-monitor setups, you must edit the workspace map manually in config.json\n Refer to the repo wiki for more information"
            }
        }

        ConfigSpinBox {
            icon: "loupe"
            text: "Scale (%)"
            value: Config.options.overview.scale * 100
            from: 1
            to: 100
            stepSize: 1
            onValueChanged: {
                Config.options.overview.scale = value / 100;
            }
        }

        ConfigRow {
            ConfigSwitch {
                buttonIcon: "high_density"
                text: "Enable zoom animation"
                checked: Config.options.overview.showOpeningAnimation
                onCheckedChanged: {
                    Config.options.overview.showOpeningAnimation = checked;
                }
                StyledToolTip {
                    text: "Using zoom-in style zoomes the wallpaper in default state, may look pixelated on crisp wallpapers"
                }
            }
            Item {
                Layout.fillWidth: true
            }
            ConfigSelectionArray {
                Layout.fillWidth: false
                enabled: Config.options.overview.showOpeningAnimation
                currentValue: Config.options.overview.scrollingStyle.zoomStyle
                onSelected: newValue => {
                    Config.options.overview.scrollingStyle.zoomStyle = newValue
                }
                options: [
                    {
                        displayName: "In",
                        icon: "zoom_in_map",
                        value: "in"
                    },
                    {
                        displayName: "Out",
                        icon: "zoom_out_map",
                        value: "out"
                    }
                ]
            }
        }
        
        ContentSubsection {
            title: "Classic overview style"
            ConfigRow {
                uniform: true
                ConfigSpinBox {
                    icon: "splitscreen_bottom"
                    text: "Rows"
                    value: Config.options.overview.rows
                    from: 1
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.overview.rows = value;
                    }
                }
                ConfigSpinBox {
                    icon: "splitscreen_right"
                    text: "Columns"
                    value: Config.options.overview.columns
                    from: 1
                    to: 20
                    stepSize: 1
                    onValueChanged: {
                        Config.options.overview.columns = value;
                    }
                }
            }

            ConfigRow {
                uniform: true
                ConfigSelectionArray {
                    currentValue: Config.options.overview.orderRightLeft
                    onSelected: newValue => {
                        Config.options.overview.orderRightLeft = newValue
                    }
                    options: [
                        {
                            displayName: "Left to right",
                            icon: "arrow_forward",
                            value: 0
                        },
                        {
                            displayName: "Right to left",
                            icon: "arrow_back",
                            value: 1
                        }
                    ]
                }
                ConfigSelectionArray {
                    Layout.leftMargin: 50
                    currentValue: Config.options.overview.orderBottomUp
                    onSelected: newValue => {
                        Config.options.overview.orderBottomUp = newValue
                    }
                    options: [
                        {
                            displayName: "Top-down",
                            icon: "arrow_downward",
                            value: 0
                        },
                        {
                            displayName: "Bottom-up",
                            icon: "arrow_upward",
                            value: 1
                        }
                    ]
                }
            }
        }

        ConfigSpinBox {
            enabled: Config.options.overview.scrollingStyle.backgroundStyle === "dim"
            icon: "backlight_low"
            text: "Dim percentage"
            value: Config.options.overview.scrollingStyle.dimPercentage
            from: 0
            to: 75
            stepSize: 5
            onValueChanged: {
                Config.options.overview.scrollingStyle.dimPercentage = value;
            }
        }


        ContentSubsection {
            title: "Scrolling overview style"
            ConfigSelectionArray {
                currentValue: Config.options.overview.scrollingStyle.backgroundStyle
                onSelected: newValue => {
                    Config.options.overview.scrollingStyle.backgroundStyle = newValue
                }
                options: [
                    {
                        displayName: "Blur",
                        icon: "blur_on",
                        value: "blur"
                    },
                    {
                        displayName: "Dim",
                        icon: "ev_shadow",
                        value: "dim"
                    },
                    {
                        displayName: "Transparent",
                        icon: "opacity",
                        value: "transparent"
                    }
                ]
            }
        }
    }

    ContentSection {
        icon: "wallpaper_slideshow"
        title: "Wallpaper selector"

        ConfigSwitch {
            buttonIcon: "ad"
            text: 'Use system file picker'
            checked: Config.options.wallpaperSelector.useSystemFileDialog
            onCheckedChanged: {
                Config.options.wallpaperSelector.useSystemFileDialog = checked;
            }
        }
    }
}