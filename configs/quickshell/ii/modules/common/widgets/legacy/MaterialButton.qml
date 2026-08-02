import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

/**
 * Material 3 button supporting the three standard button types:
 * Text, Tonal and Filled.
 * See https://m3.material.io/components/buttons/overview
 */
RippleButton {
    id: root

    enum ButtonType {
        Text,
        Tonal,
        Filled
    }

    /// One of MaterialButton.ButtonType.Text, .Tonal or .Filled
    property int type: MaterialButton.ButtonType.Tonal
    /// Optional Material Symbols icon (e.g. "add").
    property string materialIcon: ""
    /// Optional Nerd Font icon, takes precedence over materialIcon.
    property string nerdIcon: ""
    /// Foreground color of the label & icon.
    property color colText: root.enabled ?
        (root.type === MaterialButton.ButtonType.Text ?
            (root.toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colPrimary) :
         root.type === MaterialButton.ButtonType.Tonal ?
            Appearance.colors.colOnSecondaryContainer :
            Appearance.colors.colOnPrimary) :
        Appearance.m3colors.m3outline

    implicitHeight: 40
    horizontalPadding: 20
    buttonRadius: Appearance.rounding.full

    colBackground: root.type === MaterialButton.ButtonType.Filled ?
        Appearance.colors.colPrimary :
        root.type === MaterialButton.ButtonType.Tonal ?
            Appearance.colors.colSecondaryContainer :
            (root.toggled ? Appearance.colors.colSecondaryContainer : "transparent")
    colBackgroundHover: root.type === MaterialButton.ButtonType.Filled ?
        Appearance.colors.colPrimaryHover :
        root.type === MaterialButton.ButtonType.Tonal ?
            Appearance.colors.colSecondaryContainerHover :
            (root.toggled ? Appearance.colors.colSecondaryContainerHover : Appearance.colors.colSecondaryContainer)
    colBackgroundToggled: root.type === MaterialButton.ButtonType.Text ?
        Appearance.colors.colSecondaryContainer : root.colBackground
    colBackgroundToggledHover: root.type === MaterialButton.ButtonType.Text ?
        Appearance.colors.colSecondaryContainerHover : root.colBackgroundHover
    colRipple: root.type === MaterialButton.ButtonType.Filled ?
        Appearance.colors.colPrimaryActive : Appearance.colors.colSecondaryContainerActive

    contentItem: RowLayout {
        id: contentRow
        spacing: root.materialIcon.length > 0 || root.nerdIcon.length > 0 ? 8 : 0

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Math.max(materialIconLoader.implicitWidth, nerdIconLoader.implicitWidth)
            Loader {
                id: materialIconLoader
                anchors.centerIn: parent
                active: !root.nerdIcon
                sourceComponent: MaterialSymbol {
                    text: root.materialIcon
                    iconSize: Appearance.font.pixelSize.normal
                    color: root.colText
                }
            }
            Loader {
                id: nerdIconLoader
                anchors.centerIn: parent
                active: root.nerdIcon.length > 0
                sourceComponent: StyledText {
                    text: root.nerdIcon
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.family: Appearance.font.family.iconNerd
                    color: root.colText
                }
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            text: root.buttonText
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: 500
            color: root.colText

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
}
