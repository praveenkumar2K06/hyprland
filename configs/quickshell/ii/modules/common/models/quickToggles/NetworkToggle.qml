import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: "Internet"
    statusText: NetworkV2.networkName
    tooltipText: "%1 | Right-click to configure".arg(NetworkV2.networkName)
    icon: NetworkV2.materialSymbol

    toggled: NetworkV2.wifiEnabled
    mainAction: () => Network.toggleWifi()
    hasMenu: true
}
