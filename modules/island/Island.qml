import QtQuick
import qs.core
import qs.services

Item {
    id: root

    required property bool active
    implicitHeight: Math.max(notch.implicitHeight, widgets.y + widgets.implicitHeight)

    DateTimeNotch {
        id: notch
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.alignWhenCentered: false
    }

    WidgetsPill {
        id: widgets
        anchors.left: notch.right
        anchors.leftMargin: Theme.notchWidgetsGap
        y: Config.widgetsTopInset

        SpotifyWidget {
            visible: SpotifyService.available
            active: root.active
            artworkSource: SpotifyService.artworkSource
            progress: SpotifyService.progress
            playing: SpotifyService.playing
            paused: SpotifyService.paused
            progressSupported: SpotifyService.progressSupported
            onRefreshRequested: SpotifyService.refreshPosition()
        }
    }
}
