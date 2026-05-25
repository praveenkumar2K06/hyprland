import QtQuick

Rectangle {
  id: root

  Behavior on color {
    enabled: true
    ColorAnimation {
      duration: Metrics.chronoDuration(600)
      easing.type: Easing.BezierSpline
    }
  }
}