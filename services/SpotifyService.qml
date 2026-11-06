pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // Selection is the only mutable state. All presentation data stays bound.
    property MprisPlayer _selectedPlayer: null
    readonly property MprisPlayer player: _selectedPlayer
    readonly property bool available: player !== null
    readonly property bool playing: available && player.isPlaying
    readonly property string title: available ? player.trackTitle : ""
    readonly property string artist: available ? player.trackArtist : ""
    readonly property url artworkSource: available ? player.trackArtUrl : ""

    // Quickshell normalizes BOTH of these to seconds (MPRIS uses microseconds).
    readonly property real position: available && player.positionSupported ? player.position : 0
    readonly property real duration: available && player.lengthSupported ? player.length : 0
    readonly property bool progressSupported: {
        return available && player.positionSupported && Number.isFinite(duration) && duration > 0;
    }
    readonly property real progress: {
        if (!progressSupported || !Number.isFinite(position))
            return 0;
        return Math.max(0, Math.min(1, position / duration));
    }

    readonly property list<MprisPlayer> spotifyPlayers: {
        const candidates = Mpris.players.values.filter(isSpotify);
        return candidates.sort(comparePlayers);
    }
    readonly property list<MprisPlayer> playingPlayers: {
        return spotifyPlayers.filter(candidate => candidate.isPlaying);
    }

    function isSpotify(candidate: MprisPlayer): bool {
        // Require a native Spotify service name AND Spotify identity/desktop info.
        // A browser playing open.spotify.com must never qualify by track metadata.
        const serviceMatches = /^org\.mpris\.MediaPlayer2\.spotify(?:[._-]|$)/i.test(
                  candidate.dbusName);
        const identityMatches = candidate.identity.trim().toLowerCase() === "spotify";
        const desktopMatches = /^(?:com\.spotify\.)?spotify(?:\.desktop)?$/i.test(
                  candidate.desktopEntry);
        return serviceMatches && (identityMatches || desktopMatches);
    }

    function comparePlayers(a: MprisPlayer, b: MprisPlayer): int {
        return a.dbusName < b.dbusName ? -1 : a.dbusName > b.dbusName ? 1 : 0;
    }

    function selectPlayer(): void {
        const candidates = playingPlayers.length > 0 ? playingPlayers : spotifyPlayers;
        // Retain the current player within the best tier; break new ties by bus name.
        if (candidates.indexOf(_selectedPlayer) === -1)
            _selectedPlayer = candidates.length > 0 ? candidates[0] : null;
    }

    function refreshPosition(): void {
        // Documented MprisPlayer approach: reading position extrapolates locally;
        // emitting its notification refreshes bindings without polling D-Bus.
        if (player !== null && player.positionSupported)
            player.positionChanged();
    }

    onSpotifyPlayersChanged: selectPlayer()
    onPlayingPlayersChanged: selectPlayer()
    Component.onCompleted: selectPlayer()
}
