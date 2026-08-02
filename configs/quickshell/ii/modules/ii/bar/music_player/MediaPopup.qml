import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.bar
import qs.modules.ii.bar.cards
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

StyledPopup {
    id: root
    popupRadius: Appearance.rounding.large

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || "No media"

    animate: false // We have to disable the animation if we have only one card
    contentItem: HeroCard {
        id: mediaHero
        compactMode: true
        adaptiveWidth: true
        anchors.centerIn: parent
        icon: "music_note"

        title: activePlayer?.trackArtist || "Unknown Artist"
        subtitle: activePlayer ? activePlayer.trackTitle : "No media"

        pillText: activePlayer ? (activePlayer.playbackState == MprisPlaybackState.Playing ? "Playing" : "Paused") : ""
        pillIcon: activePlayer ? (activePlayer.playbackState == MprisPlaybackState.Playing ? "play_arrow" : "pause") : ""
    }
}
