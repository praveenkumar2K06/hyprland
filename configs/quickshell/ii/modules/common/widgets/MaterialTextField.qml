import qs.modules.common
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls

/**
 * Material 3 styled TextField (filled style)
 * https://m3.material.io/components/text-fields/overview
 * Note: Implemented manually because this shell runs with the Basic QQC2 style,
 * where the Material attached properties have no effect.
 * Note: We don't use NativeRendering because it makes the small placeholder text look weird
 */
TextField {
    id: root

    // Container: surfaceContainerHighest, darkens on hover/focus, fades when disabled
    readonly property color containerColor: !enabled
        ? ColorUtils.transparentize(Appearance.colors.colSurfaceContainerHighest, 0.6)
        : activeFocus ? Appearance.colors.colSurfaceContainerHighestActive
        : hovered ? Appearance.colors.colSurfaceContainerHighestHover
        : Appearance.colors.colSurfaceContainerHighest

    renderType: Text.QtRendering
    hoverEnabled: true
    clip: true

    color: Appearance.m3colors.m3onSurface
    selectedTextColor: Appearance.m3colors.m3onSecondaryContainer
    selectionColor: Appearance.colors.colSecondaryContainer
    placeholderTextColor: Appearance.m3colors.m3onSurfaceVariant

    leftPadding: 16
    rightPadding: 16
    topPadding: 8
    bottomPadding: 8

    font {
        family: Appearance.font.family.main
        pixelSize: Appearance?.font.pixelSize.small ?? 15
        hintingPreference: Font.PreferFullHinting
        variableAxes: Appearance.font.variableAxes.main
    }
    wrapMode: TextEdit.Wrap

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40

        radius: 16
        color: root.containerColor
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
    }
}
