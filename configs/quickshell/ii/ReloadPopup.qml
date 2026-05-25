import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    property bool failed: false
    property string errorString: ""

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            failed = false
            popupLoader.active = true
        }

        function onReloadFailed(error) {
            popupLoader.active = false

            failed = true
            errorString = error

            popupLoader.active = true
        }
    }

    LazyLoader {
        id: popupLoader
        active: false

        PanelWindow {
            id: popup

            exclusiveZone: 0

            anchors.top: true
            margins.top: 0

            color: "transparent"

            WlrLayershell.namespace: "quickshell:reloadPopup"

            implicitWidth: rect.implicitWidth
            implicitHeight: rect.implicitHeight

            Rectangle {
                id: rect

                anchors.centerIn: parent

                color: failed ? '#CCE99195' : "#BFD1E8D5"

                radius: 12

                implicitWidth: layout.implicitWidth + 30
                implicitHeight: layout.implicitHeight + 30

                border.color: "#22000000"
                border.width: 1

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true

                    onPressed: popupLoader.active = false
                }

                ColumnLayout {
                    id: layout

                    spacing: 10

                    anchors {
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        font.family: "Google Sans Flex"
                        font.pointSize: 14

                        renderType: Text.QtRendering

                        text: failed
                            ? "Quickshell: Reload failed"
                            : "Quickshell reloaded"

                        color: failed
                            ? "#ff93000A"
                            : "#ff0C1F13"
                    }

                    Text {
                        visible: errorString !== ""

                        font.family: "JetBrains Mono NF"
                        font.pointSize: 11

                        renderType: Text.QtRendering

                        text: errorString

                        color: failed
                            ? "#ff93000A"
                            : "#ff0C1F13"
                    }
                }

                Rectangle {
                    id: progressBg

                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: 10
                    }

                    width: rect.width - 20
                    height: 5

                    radius: 9999

                    color: failed
                        ? "#30af1b25"
                        : "#4027643e"
                }

                Rectangle {
                    id: progressBar

                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: 10
                    }

                    width: rect.width - 20
                    height: 5

                    radius: 9999

                    color: failed
                        ? "#ff93000A"
                        : "#ff0C1F13"

                    transformOrigin: Item.Left

                    property real progress: 1.0

                    scale: progress

                    NumberAnimation on progress {
                        from: 1
                        to: 0

                        duration: failed ? 10000 : 1000

                        paused: mouseArea.containsMouse

                        onFinished: popupLoader.active = false
                    }
                }
            }
        }
    }
}