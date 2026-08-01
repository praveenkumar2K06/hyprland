pragma Singleton
pragma ComponentBehavior: Bound

// From https://github.com/caelestia-dots/shell with modifications.
// License: GPLv3

import qs.modules.common
import qs.modules.common.functions
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

/**
 * For managing brightness of monitors using brightnessctl.
 */
Singleton {
    id: root
    signal brightnessChanged()

    readonly property list<BrightnessMonitor> monitors: Quickshell.screens.map(screen => monitorComp.createObject(root, {
        screen
    }))

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.screen === screen);
    }

    function increaseBrightness(): void {
        // If gamma is not yet 100, first increase gamma
        if (Hyprsunset.gamma !== 100) {
            Hyprsunset.setGamma(Hyprsunset.gamma + 5);
            return;
        }

        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.screen.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.05);
    }

    function decreaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.screen.name);
        if (monitor && monitor.brightness > 0) 
            monitor.setBrightness(monitor.brightness - 0.05);
        // If brightness is 0, then decrease gamma
        else {
            Hyprsunset.setGamma(Hyprsunset.gamma - 5);
        }
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        initializeMonitor(0);
    }

    function initializeMonitor(i: int): void {
        if (i >= monitors.length)
            return;
        monitors[i].initialize();
    }

    Process {
        id: setProc
    }

    component BrightnessMonitor: QtObject {
        id: monitor

        required property ShellScreen screen
        property int rawMaxBrightness: 100
        property real brightness
        property real brightnessMultiplier: 1.0
        property real multipliedBrightness: Math.max(0, Math.min(1, brightness * (Config.options.light.antiFlashbang.enable ? brightnessMultiplier : 1)))
        property bool ready: false

        onBrightnessChanged: {
            if (!monitor.ready) return;
            root.brightnessChanged();
        }

        Behavior on multipliedBrightness {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveEffects
            }
        }

        onMultipliedBrightnessChanged: {
            if (monitor.ready) {
                syncBrightness();
            }
        }

        function initialize() {
            monitor.ready = false;
            initProc.command = ["sh", "-c", "echo $(brightnessctl g) $(brightnessctl m)"];
            initProc.running = true;
        }

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const [current, max] = data.trim().split(" ");
                    monitor.rawMaxBrightness = parseInt(max);
                    monitor.brightness = parseInt(current) / monitor.rawMaxBrightness;
                    monitor.ready = true;
                }
            }
            onExited: (exitCode, exitStatus) => {
                initializeMonitor(root.monitors.indexOf(monitor) + 1);
            }
        }

        function syncBrightness() {
            const brightnessValue = Math.max(monitor.multipliedBrightness, 0);
            const valuePercentNumber = Math.floor(brightnessValue * 100);
            let valuePercent = `${valuePercentNumber}%`;
            if (valuePercentNumber == 0) valuePercent = "1"; // Prevent fully black
            
            setProc.exec(["brightnessctl", "--class", "backlight", "s", valuePercent, "--quiet"]);
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            monitor.brightness = value;
        }

        function setBrightnessMultiplier(value: real): void {
            monitor.brightnessMultiplier = value;
        }
    }

    Component {
        id: monitorComp

        BrightnessMonitor {}
    }

    // Anti-flashbang
    property int workspaceAnimationDelay: 500
    property int contentSwitchDelay: 30
    property string screenshotDir: "/tmp/quickshell/brightness/antiflashbang"
    
    function brightnessMultiplierForLightness(x: real): real {
        return (6.600135 + 216.360356 * Math.pow(Math.E, -0.0811129189 * x)) / 100.0;
    }
    
    Variants {
        model: Quickshell.screens
        Scope {
            id: screenScope
            required property var modelData
            property string screenName: modelData.name
            property string screenshotPath: `${root.screenshotDir}/screenshot-${screenName}.png`
            
            Connections {
                enabled: Config.options.light.antiFlashbang.enable && Appearance.m3colors.darkmode
                target: Hyprland
                function onRawEvent(event) {
                    if (["activewindowv2", "windowtitlev2"].includes(event.name)) {
                        screenshotTimer.interval = root.contentSwitchDelay;
                        screenshotTimer.restart();
                    } else if (["workspacev2"].includes(event.name)) {
                        screenshotTimer.interval = root.workspaceAnimationDelay;
                        screenshotTimer.restart();
                    }
                }
            }

            Timer {
                id: screenshotTimer
                interval: 700 
                onTriggered: {
                    screenshotProc.running = false;
                    screenshotProc.running = true;
                }
            }

            Process {
                id: screenshotProc
                command: ["bash", "-c",
                    `mkdir -p '${StringUtils.shellSingleQuoteEscape(root.screenshotDir)}'`
                    + ` && grim -o '${StringUtils.shellSingleQuoteEscape(screenScope.screenName)}' -`
                    + ` | magick png:- -colorspace Gray -format "%[fx:mean*100]" info:`
                ]
                stdout: StdioCollector {
                    id: lightnessCollector
                    onStreamFinished: {
                        Quickshell.execDetached(["rm", screenScope.screenshotPath]); 
                        const lightness = lightnessCollector.text;
                        const newMultiplier = root.brightnessMultiplierForLightness(parseFloat(lightness));
                        const targetMonitor = root.getMonitorForScreen(screenScope.modelData);
                        if (targetMonitor) targetMonitor.setBrightnessMultiplier(newMultiplier);
                    }
                }
            }
        }
    }

    // External trigger points
    IpcHandler {
        target: "brightness"

        function increment() {
            onPressed: root.increaseBrightness()
        }

        function decrement() {
            onPressed: root.decreaseBrightness()
        }
    }

    GlobalShortcut {
        name: "brightnessIncrease"
        description: "Increase brightness"
        onPressed: root.increaseBrightness()
    }

    GlobalShortcut {
        name: "brightnessDecrease"
        description: "Decrease brightness"
        onPressed: root.decreaseBrightness()
    }
}