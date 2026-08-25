# ii Quick Toggles

Quick toggles are the round "tiles" in the quick panel of the right sidebar (network, dark mode, game mode, etc.). This document explains how the system is structured and how to add a new toggle. Everything below refers to the **android** panel style (`Config.options.sidebar.quickToggles.style === "android"`), which is the only implemented style.

---

## Architecture

Each toggle is split across three layers:

| Layer | Location | Role |
|---|---|---|
| **Model** | `modules/common/models/quickToggles/*.qml` | State and logic. Extends `QuickToggleModel`. Contains no visuals. |
| **View** | `modules/ii/sidebarRight/quickToggles/androidStyle/AndroidGenericToggle.qml` | A single generic component used for every tile. Looks up the type in the registry, lazily instantiates the model via a `Loader`, and hands it to `AndroidQuickToggleButton`, which renders icon, status text, tooltip, and handles clicks/edit-mode gestures. |
| **Registry** | `modules/ii/sidebarRight/quickToggles/ToggleRegistry.qml` | Maps each config `type` string to a lazy model `Component` plus optional dialog routing. Adding a new toggle means adding one entry here. |

### Data flow

```
Config.options.sidebar.quickToggles.android.toggles   // [{ type, size }, ...]
        ↓
AndroidQuickPanel  →  toggleRowsForList()  →  rows of { type, size }
        ↓
Repeater → ScriptModel (objectProp: "type")
        ↓
AndroidGenericToggle → ToggleRegistry.toggles[type].model (Loader)
        ↓
AndroidQuickToggleButton ← toggleModel
```

- The tile list is user-editable: edit mode (pencil button) lets you enable/disable tiles, alternate their size between 1 and 2 columns, and reorder them by scrolling. All changes write straight back into `Config.options.sidebar.quickToggles.android.toggles`.
- Types present in the registry but not in the saved config appear under the divider at the bottom of the panel while edit mode is active.

---

## `QuickToggleModel` reference

Defined in `modules/common/models/quickToggles/QuickToggleModel.qml`:

| Property | Type | Description |
|---|---|---|
| `name` | string (**required**) | Display name shown on expanded (size 2) tiles. |
| `statusText` | string | Second line on expanded tiles. Defaults to `"Active"` / `"Inactive"` when left empty. Hidden entirely if `hasStatusText` is false. |
| `tooltipText` | string | Hover tooltip text. Tooltip is hidden when empty. |
| `icon` | string | [Material Symbols](https://fonts.google.com/icons) icon name. Default: `"close"`. |
| `hasStatusText` | bool | Whether the status line is rendered at all. Default: `true`. |
| `available` | bool | Disabled (dimmed) tile when false — e.g. Cloudflare WARP when `warp-cli` is missing. Default: `true`. |
| `toggled` | bool | Current on/off state. Bind it to real state where possible. |
| `mainAction` | var (**required**) | Called on click. A JS function, e.g. `() => { ... }`. |
| `hasMenu` | bool | Set true if right-click / long-press should open a dialog (see [Dialog integration](#4-optional-dialog-integration)). |
| `altAction` | var | Alternative action for right-click when no dialog is used. |

Because `QuickToggleModel` declares `default property list<QtObject> data`, you can embed helper objects directly inside your model instance — `Process`, `Timer`, file views, etc. See `CloudflareWarpToggle.qml` for an example.

---

## Adding a new toggle

This walkthrough creates a toggle with the type string `myToggle`. Use lowerCamelCase for the type string; it must be unique across all toggles.

### 1. Create the model

Create `modules/common/models/quickToggles/MyToggle.qml`:

```qml
import QtQuick
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles

QuickToggleModel {
    id: root

    name: "My Toggle"
    statusText: toggled ? "On" : "Off"
    toggled: false
    icon: "toggle_on"

    mainAction: () => {
        root.toggled = !root.toggled;
        // Do the actual work here
    }

    tooltipText: "My toggle"
}
```

Prefer binding `toggled` to real state instead of flipping it manually — see [Examples](#examples).

### 2. Register it in the registry

Open `modules/ii/sidebarRight/quickToggles/ToggleRegistry.qml`. Add a lazy component property for your model, then one entry in the `toggles` map:

```qml
readonly property Component myToggleToggle: MyToggle {}

readonly property var toggles: ({
    // ...
    "myToggle": {
        "model": root.myToggleToggle
    }
})
```

That's all — no view file is needed. Sizing, colors, animations, tooltips, and edit-mode interactions come from `AndroidGenericToggle` + `AndroidQuickToggleButton`, the panel's tile list is derived automatically (`Object.keys(toggles)`), and the tile shows up in edit mode's unused section. Users can enable it from there.

If the model should open a dialog on right-click / long-press, add a `"dialog"` key — see [Dialog integration](#4-optional-dialog-integration).

### 3. Optional: enable by default

Add it to the defaults in `modules/common/Config.qml` under `options.sidebar.quickToggles.android.toggles`:

```qml
property list<var> toggles: [
    ...
    {
        "size": 1,
        "type": "myToggle"
    }
]
```

> **Note:** this only affects fresh configs. Existing users' saved config files already contain a toggles list, so they will not receive new default entries automatically.

### 4. Optional: dialog integration

If clicking the tile (or long-pressing an expanded one) should open a popup dialog — like the WiFi or Bluetooth panels:

1. Set `"dialog": "myDialog"` on your registry entry. The dialog key routes the model's `hasMenu` action (see `AbstractQuickPanel.qml` for the existing signal set; `openMappedDialog()` in `AndroidQuickPanel.qml` maps names to signals).
2. If you need a brand-new dialog, follow the existing chain: declare a signal in `modules/ii/sidebarRight/quickToggles/AbstractQuickPanel.qml`, add a case to `openMappedDialog()` in `AndroidQuickPanel.qml`, connect it in `SidebarRightContent.qml`'s `LoaderedQuickPanelImplementation` `Connections` block, and add a `ToggleDialog { ... }` entry there mirroring the `showWifiDialog` pattern.
3. In your model set `hasMenu: true` so right-clicks and clicks on expanded tiles route through `openMenu`.

If you only need a secondary click behavior without a dialog, skip all of this and just set `altAction` in the model.

---

## Examples

Three common patterns, all found in `modules/common/models/quickToggles/`:

### Bound state — `DarkModeToggle.qml`

State comes from elsewhere in the shell; the action triggers a script that changes it:

```qml
QuickToggleModel {
    name: "Dark Mode"
    statusText: Appearance.m3colors.darkmode ? "Dark" : "Light"
    toggled: Appearance.m3colors.darkmode
    icon: "contrast"
    mainAction: () => {
        if (Appearance.m3colors.darkmode)
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPathv2, "--light"]);
        else
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPathv2, "--dark"]);
    }
    tooltipText: "Dark Mode"
}
```

### Process-driven state — `CloudflareWarpToggle.qml`

Embeds `Process` objects as child items to run commands and derive state from their output:

```qml
QuickToggleModel {
    id: root
    name: "Cloudflare WARP"
    toggled: false
    icon: "cloud_lock"
    mainAction: () => { /* warp-cli connect/disconnect */ }

    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", "warp-cli status"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.includes("Connected")) root.toggled = true;
                else if (text.includes("Disconnected")) root.toggled = false;
            }
        }
    }
}
```

It also sets `available` based on whether the command succeeded, which greys the tile out when `warp-cli` isn't installed.

### Menu/dialog integration — `AudioToggle.qml`

```qml
QuickToggleModel {
    name: "Audio output"
    statusText: toggled ? "Unmuted" : "Muted"
    tooltipText: "Audio output | Right-click for volume mixer & device selector"
    toggled: !Audio.sink?.audio?.muted
    icon: Audio.sink?.audio?.muted ? "volume_off" : "volume_up"
    mainAction: () => Audio.toggleMute()
    hasMenu: true
}
```

With `hasMenu: true`, right-clicks and clicks on expanded tiles route through `openMenu`, which the generic delegate maps via the registry entry's `"dialog": "audioOutput"` key to the dialog signal chain described above.

---

## Verification checklist

1. Reload the shell (the restart button in the sidebar, or `Super+Shift+\`).
2. Open the right sidebar and confirm no errors appear.
3. Click the pencil (edit mode): your tile should appear in the unused section below the divider if it wasn't added to the defaults.
4. Left-click it to move it into the grid; test size toggle (right-click / press-and-hold) and reordering (scroll).
5. Exit edit mode and test the main action plus any menu/dialog behavior.
