import QtQuick

MouseArea {
    id: root

    signal scrollUp(delta: int)
    signal scrollDown(delta: int)
    signal movedAway()

    property bool hovered: false
    property real lastScrollX: 0
    property real lastScrollY: 0
    property bool trackingScroll: false
    property real moveThreshold: 20

    // throttle
    property bool wheelReady: true
    property int throttleInterval: 40

    acceptedButtons: Qt.LeftButton
    hoverEnabled: true

    Timer {
        id: wheelThrottle
        interval: root.throttleInterval
        repeat: false

        onTriggered: {
            root.wheelReady = true;
        }
    }

    onEntered: {
        root.hovered = true;
    }

    onExited: {
        root.hovered = false;
        root.trackingScroll = false;
    }

    onWheel: event => {
        // THROTTLE
        if (!root.wheelReady)
            return;

        root.wheelReady = false;
        wheelThrottle.start();

        if (event.angleDelta.y < 0)
            root.scrollUp(event.angleDelta.y);
        else if (event.angleDelta.y > 0)
            root.scrollDown(event.angleDelta.y);

        root.lastScrollX = event.x;
        root.lastScrollY = event.y;
        root.trackingScroll = true;
    }

    onPositionChanged: mouse => {
        if (root.trackingScroll) {
            const dx = mouse.x - root.lastScrollX;
            const dy = mouse.y - root.lastScrollY;

            if (Math.sqrt(dx * dx + dy * dy) > root.moveThreshold) {
                root.movedAway();
                root.trackingScroll = false;
            }
        }
    }

    onContainsMouseChanged: {
        if (!root.containsMouse && root.trackingScroll) {
            root.movedAway();
            root.trackingScroll = false;
        }
    }
}