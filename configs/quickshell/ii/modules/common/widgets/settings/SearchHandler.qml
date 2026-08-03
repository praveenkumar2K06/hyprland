import qs.services
import QtQuick

Item {
    id: searchHandler
    property string searchString

    Connections {
        target: SearchRegistry
        function onCurrentSearchChanged() {
            let search = SearchRegistry.currentSearch
            if (!search || search.toLowerCase() !== searchHandler.searchString.toLowerCase())
                return

            Qt.callLater(() => {
                let p = page.contentItem.mapFromItem(root, 0, 0)
                let targetY = p.y - 100

                let maxContentY = Math.max(0, page.contentHeight - page.height)

                page.contentY = Math.max(0, Math.min(targetY, maxContentY))

                highlightOverlay.startAnimation()
            })
            SearchRegistry.currentSearch = ""
        }
    }
}