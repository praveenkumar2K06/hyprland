import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.models.hyprland
import qs.modules.common.widgets
import qs.modules.common.widgets.expressive
import qs.modules.common.widgets.settings

ContentPage {
    id: page
    readonly property int index: 5
    readonly property var managedKeys: [
        "general:layout",
        "general:gaps_in",
        "general:gaps_out",
        "general:border_size",
        "decoration:rounding",
        "animations:enabled",
        "decoration:blur:enabled",
        "decoration:shadow:enabled"
    ]
    forceWidth: true

    // Spin box row bound to a live Hyprland option
    component HyprSpinRow: ConfigSpinBox {
        id: hyprSpinRow

        property string hyprKey: ""
        property int fallbackValue: 0
        property bool ready: false

        readonly property HyprlandConfigOption option: HyprlandConfigOption {
            key: hyprSpinRow.hyprKey
            onValueChanged: {
                if (hyprSpinRow.value !== hyprSpinRow.option.value)
                    hyprSpinRow.value = hyprSpinRow.option.value;
            }
        }

        from: 0
        stepSize: 1
        value: fallbackValue

        Component.onCompleted: hyprSpinRow.ready = true

        onValueChanged: {
            if (!hyprSpinRow.ready)
                return;
            if (hyprSpinRow.option.value === hyprSpinRow.value)
                return;
            hyprSpinRow.option.setValue(hyprSpinRow.value);
        }
    }

    // Switch row bound to a live Hyprland option
    component HyprSwitchRow: ConfigSwitch {
        id: hyprSwitchRow

        property string hyprKey: ""
        property bool fallbackValue: false

        readonly property HyprlandConfigOption option: HyprlandConfigOption {
            key: hyprSwitchRow.hyprKey
            onValueChanged: {
                const boolValue = !!hyprSwitchRow.option.value;
                if (hyprSwitchRow.checked !== boolValue)
                    hyprSwitchRow.checked = boolValue;
            }
        }

        checked: fallbackValue

        onCheckedChanged: {
            if (!!hyprSwitchRow.option.value === hyprSwitchRow.checked)
                return;
            hyprSwitchRow.option.setValue(hyprSwitchRow.checked);
        }
    }

    ContentSection {
        icon: "dashboard"
        title: "Layout"

        ConfigSelectionArray {
            id: layoutSelector

            readonly property HyprlandConfigOption option: HyprlandConfigOption {
                key: "general:layout"
            }

            currentValue: option.value
            onSelected: newValue => {
                HyprlandSettings.setLayout(newValue);
            }
            options: [
                {
                    displayName: "Dwindle",
                    icon: "space_dashboard",
                    value: "dwindle"
                },
                {
                    displayName: "Master",
                    icon: "view_agenda",
                    value: "master"
                },
                {
                    displayName: "Scrolling",
                    icon: "swap_horiz",
                    value: "scrolling"
                },
                {
                    displayName: "Monocle",
                    icon: "crop_square",
                    value: "monocle"
                },
                {
                    displayName: "Default",
                    icon: "grid_view",
                    value: "default"
                }
            ]
        }
    }

    ContentSection {
        icon: "aspect_ratio"
        title: "Gaps & borders"
        stringMap: ["gaps", "spacing", "border", "rounding"]

        HyprSpinRow {
            icon: "space_bar"
            text: "Gaps in"
            hyprKey: "general:gaps_in"
            fallbackValue: 8
            to: 100
        }

        HyprSpinRow {
            icon: "padding"
            text: "Gaps out"
            hyprKey: "general:gaps_out"
            fallbackValue: 8
            to: 100
        }

        HyprSpinRow {
            icon: "border_style"
            text: "Border size"
            hyprKey: "general:border_size"
            fallbackValue: 2
            to: 20
        }

        HyprSpinRow {
            icon: "rounded_corner"
            text: "Corner rounding"
            hyprKey: "decoration:rounding"
            fallbackValue: 12
            to: 100
        }
    }

    ContentSection {
        icon: "auto_awesome"
        title: "Effects"
        stringMap: ["blur", "shadow", "animation"]

        HyprSwitchRow {
            buttonIcon: "animation"
            text: "Animations"
            hyprKey: "animations:enabled"
        }

        HyprSwitchRow {
            buttonIcon: "blur_on"
            text: "Blur"
            hyprKey: "decoration:blur:enabled"
        }

        HyprSwitchRow {
            buttonIcon: "ev_shadow"
            text: "Shadows"
            hyprKey: "decoration:shadow:enabled"
        }
    }

    ContentSection {
        id: monitorSection
        icon: "desktop_windows"
        title: "Monitors"
        visible: HyprlandData.monitors.length > 0

        property var monitors: HyprlandData.monitors
        property string selectedOutput: ""
        property var selectedMonitor: monitors.find(m => m.name === selectedOutput) ?? null
        property string selectedMode: "preferred"
        property string selectedPosition: "auto"
        property real selectedScale: 1

        // Closest available mode to what the monitor currently runs
        function bestMode(m) {
            if (!m)
                return "preferred";
            const res = `${m.width}x${m.height}@`;
            const modes = m.availableModes ?? [];
            let candidates = modes.filter(mode => mode.startsWith(res));
            if (candidates.length === 0)
                candidates = modes;
            if (candidates.length === 0)
                return `${res}${Number(m.refreshRate).toFixed(2)}Hz`;
            let best = candidates[0];
            let bestDiff = Math.abs(parseFloat(best.split("@")[1]) - m.refreshRate);
            for (let i = 1; i < candidates.length; ++i) {
                const diff = Math.abs(parseFloat(candidates[i].split("@")[1]) - m.refreshRate);
                if (diff < bestDiff) {
                    best = candidates[i];
                    bestDiff = diff;
                }
            }
            return best;
        }

        function selectOutput(name) {
            selectedOutput = name;
            const mon = monitors.find(m => m.name === name);
            if (!mon)
                return;
            selectedMode = bestMode(mon);
            selectedScale = mon.scale ?? 1;
        }

        // Writes the current selection to the config; only called on user interaction
        function apply() {
            if (!selectedOutput || !selectedMonitor)
                return;
            HyprlandSettings.setMonitor(selectedOutput, selectedMode, selectedPosition, String(selectedScale));
        }

        Component.onCompleted: {
            if (!selectedOutput && monitors.length > 0)
                selectOutput(monitors[0].name);
        }

        Connections {
            target: HyprlandData

            function onMonitorsChanged() {
                if (monitorSection.selectedOutput && monitorSection.monitors.find(m => m.name === monitorSection.selectedOutput))
                    return;
                if (monitorSection.monitors.length === 0)
                    return;
                monitorSection.selectOutput(monitorSection.monitors[0].name);
            }
        }

        ContentSubsection {
            title: "Output"

            ConfigSelectionArray {
                currentValue: monitorSection.selectedOutput
                onSelected: newValue => {
                    monitorSection.selectOutput(newValue);
                    monitorSection.apply();
                }
                options: monitorSection.monitors.map(m => ({
                    displayName: m.name,
                    icon: "monitor",
                    value: m.name
                }))
            }
        }

        ContentSubsection {
            title: "Mode"

            ConfigSelectionArray {
                currentValue: monitorSection.selectedMode
                onSelected: newValue => {
                    monitorSection.selectedMode = newValue;
                    monitorSection.apply();
                }
                options: [
                    {
                        displayName: "Preferred",
                        icon: "auto_awesome",
                        value: "preferred"
                    },
                    ...(monitorSection.selectedMonitor?.availableModes ?? []).map(mode => ({
                        displayName: mode,
                        icon: "aspect_ratio",
                        value: mode
                    }))
                ]
            }
        }

        ContentSubsection {
            title: "Position & scale"

            ConfigRow {
                uniform: true

                ConfigSelectionArray {
                    currentValue: monitorSection.selectedPosition
                    onSelected: newValue => {
                        monitorSection.selectedPosition = newValue;
                        monitorSection.apply();
                    }
                    options: [
                        {
                            displayName: "Auto",
                            icon: "open_with",
                            value: "auto"
                        },
                        {
                            displayName: "Left",
                            icon: "arrow_back",
                            value: "auto-left"
                        },
                        {
                            displayName: "Right",
                            icon: "arrow_forward",
                            value: "auto-right"
                        },
                        {
                            displayName: "Up",
                            icon: "arrow_upward",
                            value: "auto-up"
                        },
                        {
                            displayName: "Down",
                            icon: "arrow_downward",
                            value: "auto-down"
                        }
                    ]
                }

                ConfigSelectionArray {
                    currentValue: monitorSection.selectedScale
                    onSelected: newValue => {
                        monitorSection.selectedScale = newValue;
                        monitorSection.apply();
                    }
                    options: [0.5, 1, 1.25, 1.5, 1.75, 2].map(scale => ({
                        displayName: `${scale}x`,
                        icon: "zoom_out_map",
                        value: scale
                    }))
                }
            }
        }
    }

    RowLayout {
        Layout.leftMargin: 8
        Layout.rightMargin: 8

        MaterialButtonE {
            buttonText: "Reset page overrides"
            materialIcon: "restart_alt"
            type: MaterialButtonE.ButtonType.Error
            onClicked: {
                HyprlandSettings.resetKeys(page.managedKeys);
            }

            StyledToolTip {
                text: "Remove the overrides set by this page and go back\n to whatever is in the Hyprland config files"
            }
        }
    }
}
