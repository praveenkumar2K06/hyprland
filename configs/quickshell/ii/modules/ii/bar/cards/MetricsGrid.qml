import QtQuick
import QtQuick.Layouts

import qs.services
import qs.modules.common
import qs.modules.common.widgets

GridLayout {

    MetricCard {
        title: "Sunrise"
        symbol: "wb_twilight"
        value: Weather.data.sunrise
        accentColor: Appearance.colors.colTertiaryContainer
        symbolColor: Appearance.colors.colOnTertiaryContainer
    }
    MetricCard {
        title: "Sunset"
        symbol: "bedtime"
        value: Weather.data.sunset
        accentColor: Appearance.colors.colSecondaryContainer
        symbolColor: Appearance.colors.colOnSecondaryContainer
    }
    MetricCard {
        title: "Precipitation"
        symbol: "rainy_light"
        value: Weather.data.precip
        accentColor: Appearance.colors.colPrimaryContainer
        symbolColor: Appearance.colors.colOnPrimaryContainer
    }
    MetricCard {
        title: "Humidity"
        symbol: "humidity_low"
        value: Weather.data.humidity
        accentColor: Appearance.colors.colTertiaryContainer
        symbolColor: Appearance.colors.colOnTertiaryContainer
    }
}