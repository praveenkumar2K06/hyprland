import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root
    property bool vertical: false
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
    property bool focusingThisMonitor: HyprlandData.activeWorkspace?.monitor == monitor?.name
    property var biggestWindow: HyprlandData.biggestWindowForWorkspace(HyprlandData.monitors[root.monitor?.id]?.activeWorkspace.id)

    property real padding: 5
    implicitWidth: vertical ? Appearance.sizes.baseVerticalBarWidth : (gridLayout.implicitWidth + padding * 2)
    implicitHeight: vertical ? (gridLayout.implicitHeight + padding * 2) : Appearance.sizes.baseBarHeight

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.colLayer0Base
         border.color: Appearance.colors.colLayer1Hover
         border.width: 1
         radius: Appearance.rounding.small
         visible: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow
    }

    GridLayout {
        id: gridLayout
        columns: 2
        rows: 1
        anchors {
            verticalCenter: root.vertical ? undefined : parent.verticalCenter
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
            left: root.vertical ? undefined : parent.left
            right: root.vertical ? undefined : parent.right
            top: root.vertical ? parent.top : undefined
            bottom: root.vertical ? parent.bottom : undefined
            margins: root.padding
        }
        columnSpacing: 4
        rowSpacing: 12

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
                root.activeWindow?.appId :
                (root.biggestWindow?.class) ?? "Desktop"

        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
                root.activeWindow?.title :
                (root.biggestWindow?.title) ?? `${"Workspace"} ${monitor?.activeWorkspace?.id ?? 1}`
        }
    }

    // ColumnLayout {
    //     id: colLayout

    //     anchors.verticalCenter: parent.verticalCenter
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //     anchors.top: parent.top
    //     anchors.bottom: parent.bottom
    //     spacing: -4

    //     StyledText {
    //         Layout.fillWidth: true
    //         font.pixelSize: Appearance.font.pixelSize.smallest
    //         color: Appearance.colors.colSubtext
    //         elide: Text.ElideRight
    //         text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
    //             root.activeWindow?.appId :
    //             (root.biggestWindow?.class) ?? "Desktop"

    //     }

    //     StyledText {
    //         Layout.fillWidth: true
    //         font.pixelSize: Appearance.font.pixelSize.smaller
    //         color: Appearance.colors.colOnLayer0
    //         elide: Text.ElideRight
    //         text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? 
    //             root.activeWindow?.title :
    //             (root.biggestWindow?.title) ?? `${"Workspace"} ${monitor?.activeWorkspace?.id ?? 1}`
    //     }

    // }

}
