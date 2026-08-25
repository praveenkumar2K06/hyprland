# ii-vynx Extensions

Extensions allow third-party QML components to be dynamically loaded into various shell surfaces — the bar, sidebar, background, overlay canvas — and to run background services. Everything is managed live from the Extensions settings page with no shell restart required.

---

## Quick Start

Create a directory with an `extension.json` and your QML files:

```
my-extension/
├── extension.json
├── MyOverlay.qml
├── bar/
│   └── MyWidget.qml
└── services/
    └── MyService.qml
```

**Minimal `extension.json`:**

```json
{
  "name": "My Extension",
  "description": "Does cool things",
  "version": "1.0.0",
  "author": "YourName",
  "contributes": {
    "cheatsheet": [
      {
        "identifier": "myWidget",
        "title": "My Widget",
        "icon": "widgets",
        "component": "bar/MyWidget.qml"
      }
    ]
  }
}
```

**Test locally:** Open Extensions settings, paste the absolute path to your extension directory, click Install. The extension appears instantly — toggle it on to see your widget in the bar.

For rapid iteration, use the **Reload** button (local extensions only) to pick up changes without reinstalling.

---

## extension.json Schema

| Field | Type | Required | Description |
|---|---|---|---|
| `name` | string | **Yes** | Display name. Also used as extension ID (derived from directory/repo name). |
| `description` | string | No | Short description shown in extension cards. |
| `version` | string | No | Semantic version (e.g. `"1.0.0"`). |
| `author` | string | No | Author display name. |
| `icon` | string | No | [Material Symbols](https://fonts.google.com/icons) icon codepoint name. Default: `"extension"`. |
| `shapeString` | string | No | Shape override for the icon container (e.g. `"RoundedRect"`). Empty = default shape. |
| `configDefaults` | object | No | Default key-value config. Applied on install and reload. See [Persistence](#persistence). |
| `contributes` | object | No | Declares which shell surfaces this extension integrates with. See below. |

### `contributes` object

Each key is a contribution point name. The value is always an **array of contribution descriptors**.

```json
{
  "contributes": {
    "services":           [...],
    "cheatsheet":         [...]
  }
}
```

---

## Contribution Points

### 1. `services`

Long-running background processes that live for the lifetime of the extension.

**Descriptor fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | **Yes** | Unique service identifier within this extension. |
| `qml` | string | **Yes** | Relative path to the QML file. |

**Lifecycle:**

- Loaded when extension is enabled or installed.
- Destroyed when extension is disabled or uninstalled.
- Created with no parent (`createObject(null)`).

**QML contract:**

The root item receives an `extensionId` property injected at runtime:

```qml
// services/MyService.qml
import QtQuick

QtObject {
    id: root
    // Injected automatically:
    // property string extensionId: "..."

    property int randomNumber: 45
    property bool testBool: true
    property var testArray: [1, 2, 3, 4, 5]
    property var testObject: { "key1": "value1", "key2": "value2" }

    Component.onCompleted: {
        console.log("Service started for", extensionId)
    }
}
```

**Example:**

```json
{
  "contributes": {
    "services": [
      {
        "id": "myService",
        "qml": "services/MyService.qml"
      }
    ]
  }
}
```

---

### 1. `cheatsheet`

Custom tabs in the cheatsheet overlay, alongside Timetable, Keybinds, and Elements tabs.

**Descriptor fields:**

| Field | Type | Required | Description |
|---|---|---|---|
| `identifier` | string | **Yes** | Unique ID within this extension. |
| `title` | string | **Yes** | Tab label text shown in the cheatsheet toolbar. |
| `icon` | string | **Yes** | Material Symbols icon codepoint name. |
| `component` | string | **Yes** | Relative path to the QML page file. |

**QML contract:**

Use `anchors.fill: parent` or bind to the implicit size of your content to fill the available space:

```qml
// cheatsheet/MyCheatsheetTab.qml
import QtQuick

Item {
    id: root
    anchors.fill: parent
    // Injected automatically:
    // property string extensionId: "..."

    Text {
        anchors.centerIn: parent
        text: "My Cheatsheet Tab"
    }
}
```

**Example:**

```json
{
  "contributes": {
    "cheatsheet": [
      {
        "identifier": "myCheatsheetTab",
        "title": "My Shortcuts",
        "icon": "keyboard",
        "component": "cheatsheet/MyCheatsheetTab.qml"
      }
    ]
  }
}
```

---

## Best Practices

### Importing QML files

You can directly use qml files in the file if they are in the folder as the main qml file. If not, you can use `import "./folderName"` to import a folder and use the files in that folder. 

You can check official plugin to see an example for it from [here](https://github.com/vaguesyntax/vynx-wallpaper-browser/blob/main/src/WallpaperBrowserUI.qml).

### Naming

- Use kebab-case for directory/repo names (e.g. `my-extension`, `awesome-widgets`). The directory name becomes the extension ID.
- Place `extension.json` at the repository root.

### Testing Locally

1. Create your extension directory anywhere on your filesystem.
2. Open Extensions settings → click the link icon at the top to reveal the URL/path input.
3. Paste the absolute path to your extension directory.
4. The extension appears in the Installed list. Enable it to test.
5. For rapid iteration: use the **Reload** button (local extensions only) to pick up changes without reinstalling.

### Config Defaults

Use `configDefaults` to provide initial values for your extension's config. These are applied automatically on install and reload:

```json
{
  "configDefaults": {
    "refreshInterval": 30,
    "theme": "dark",
    "maxItems": 10
  }
}
```

Users can change these from an extension settings UI (if you provide one) and they persist in `plugins.json`.

### Config Schema

Use `configSchema` to define a typed settings UI that is automatically rendered in the extension's card. Each key maps to a control:

```json
{
  "configSchema": {
    "refreshInterval": {
      "type": "int",
      "label": "Refresh Interval",
      "default": 30,
      "min": 5,
      "max": 120
    },
    "theme": {
      "type": "enum",
      "label": "Theme",
      "default": "dark",
      "values": ["light", "dark", "system"]
    },
    "showBadges": {
      "type": "bool",
      "label": "Show Badges",
      "default": true
    },
    "opacity": {
      "type": "slider",
      "label": "Opacity",
      "default": 0.8,
      "min": 0.1,
      "max": 1.0
    },
    "apiKey": {
      "type": "string",
      "label": "API Key",
      "default": ""
    }
  }
}
```

| Type     | Control              | Extra properties       |
|----------|----------------------|------------------------|
| `bool`   | Switch               | —                      |
| `int`    | SpinBox              | `min`, `max`           |
| `slider` | Slider (float)       | `min`, `max`           |
| `float`  | SpinBox (decimal)    | `min`, `max`           |
| `enum`   | Dropdown             | `values` (string[])    |
| `string` | Text field           | —                      |

Values are stored per-extension in `plugins.json` and accessible at runtime via `ExtensionManager.getExtensionConfig(extId, key, defaultValue)`.

---

## Publishing

To make your extension discoverable through Browse Extensions:

1. Push your repository to GitHub.
2. Add the topic `ii-vynx-extension` to your repository.
3. Ensure `extension.json` is at the repository root.
4. The system will automatically find your repo via the GitHub API.

Report any issues you faced while developing an extension [here](https://github.com/vaguesyntax/ii-vynx/issues).