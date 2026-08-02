import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

/**
 * Material 3 Expressive Button Component
 */
Button {
    id: root

    enum ButtonType {
        Text,
        Tonal,
        Filled,
        Error
    }

    property int type: root.ButtonType.Tonal
    property int iconSize: Appearance.font.pixelSize.normal
    property real iconFilled: 0
    property string materialIcon: ""
    property string nerdIcon: ""
    
    property alias buttonText: root.text

    readonly property bool hasIcon: materialIcon !== "" || nerdIcon !== ""
    leftPadding: hasIcon ? 16 : 24
    rightPadding: 24
    topPadding: 0
    bottomPadding: 0

    implicitHeight: 40
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    hoverEnabled: true
    scale: down ? 0.98 : 1.0
    opacity: enabled ? 1.0 : 0.38

    property color colText: {
        switch (root.type) {
        case MaterialButtonE.ButtonType.Filled:
            return root.checked ? Appearance.colors.colOnSecondaryContainer 
                                : Appearance.colors.colOnPrimary
        case MaterialButtonE.ButtonType.Tonal:
            return Appearance.colors.colOnSecondaryContainer
        case MaterialButtonE.ButtonType.Error:
            return Appearance.colors.colOnError
        default: // MaterialButtonE.ButtonType.Text
            return Appearance.colors.colPrimary
        }
    }

    background: Rectangle {
        id: bg
        anchors.fill: parent

        color: {
            switch (root.type) {
            case MaterialButtonE.ButtonType.Filled:
                if (root.down) return Appearance.colors.colPrimaryActive
                if (root.hovered) return Appearance.colors.colPrimaryHover
                return Appearance.colors.colPrimary

            case MaterialButtonE.ButtonType.Tonal:
                if (root.down) return Appearance.colors.colSecondaryContainerActive
                if (root.hovered) return Appearance.colors.colSecondaryContainerHover
                return Appearance.colors.colSecondaryContainer

            case MaterialButtonE.ButtonType.Error:
                if (root.down) return Appearance.colors.colErrorActive
                if (root.hovered) return Appearance.colors.colErrorHover
                return Appearance.colors.colError

            default: // Text Button
                if (root.down) return Appearance.colors.colSecondaryContainerActive
                if (root.hovered) return Appearance.colors.colSecondaryContainerHover
                if (root.checked) return Appearance.colors.colSecondaryContainer
                return "transparent"
            }
        }

        // Expressive Morphing Radius
        radius: root.down ? Appearance.rounding.small : Appearance.rounding.full
        y: root.down ? 1 : 0

        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation { duration: 140 }
        }

        Behavior on y {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }

    contentItem: RowLayout {
        id: contentRow
        spacing: root.hasIcon ? 8 : 0

        Loader {
            id: iconLoader
            visible: root.hasIcon
            Layout.alignment: Qt.AlignVCenter

            sourceComponent: {
                if (root.materialIcon !== "") return materialComp
                if (root.nerdIcon !== "") return nerdComp
                return null
            }

            Component {
                id: materialComp
                MaterialSymbol {
                    text: root.materialIcon
                    iconSize: root.iconSize
                    color: root.colText
                    fill: root.iconFilled
                }
            }

            Component {
                id: nerdComp
                StyledText {
                    text: root.nerdIcon
                    font.family: Appearance.font.family.iconNerd
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: root.colText
                }
            }
        }

        StyledText {
            visible: root.text !== ""
            Layout.alignment: Qt.AlignVCenter

            text: root.text
            color: root.colText

            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.Medium

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }
}