import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.settings.extensions

ColumnLayout {
    id: root
    property var model: []
    property string searchText: ""
    property bool loading: false

    spacing: 6

    Repeater {
        model: root.model
        delegate: ExtensionCard {
            listCount: root.model.length
        }
    }

    StyledText {
        Layout.fillWidth: true
        Layout.topMargin: 40
        visible: root.model.length === 0 && !root.loading
        text: root.searchText.trim() ? "No extensions match your search" : "No extensions found. Click refresh to search GitHub."
        horizontalAlignment: Text.AlignHCenter
        color: Appearance.colors.colSubtext
        font.pixelSize: Appearance.font.pixelSize.normal
    }
}
