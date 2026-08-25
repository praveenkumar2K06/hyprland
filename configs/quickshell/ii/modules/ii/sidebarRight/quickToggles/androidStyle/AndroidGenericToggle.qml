pragma ComponentBehavior: Bound
import QtQuick
import qs.modules.common.models.quickToggles
import qs.modules.ii.sidebarRight.quickToggles

AndroidQuickToggleButton {
    id: root

    readonly property string toggleType: buttonData?.type ?? ""
    readonly property var entry: toggleType !== "" ? (ToggleRegistry.toggles[toggleType] ?? null) : null

    signal openDialog(string name)

    toggleModel: modelLoader.item

    onOpenMenu: {
        const dialog = entry?.dialog ?? "";
        if (dialog !== "")
            openDialog(dialog);
    }

    Loader {
        id: modelLoader
        active: root.entry !== null
        sourceComponent: root.entry?.model ?? null
    }
}
