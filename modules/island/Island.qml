import QtQuick
import qs.core
import qs.services

Row {
    id: root

    required property bool active
    spacing: Theme.pillGap

    DateTimePill {}

    WidgetsPill {
        SpotifyWidget {
            visible: SpotifyService.available
            active: root.active
            artworkSource: SpotifyService.artworkSource
            progress: SpotifyService.progress
            playing: SpotifyService.playing
            progressSupported: SpotifyService.progressSupported
            onRefreshRequested: SpotifyService.refreshPosition()
        }
    }
}
