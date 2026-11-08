import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    required property bool active
    required property bool playing
    required property string trackTitle
    property bool _receivedSamples: false
    readonly property list<PwNode> streams: {
        return Pipewire.nodes.values.filter(isOutputStream);
    }
    readonly property PwNode node: {
        if (!active)
            return null;
        const matches = streams.filter(isSpotify).sort((a, b) => a.id - b.id);
        const current = matches.find(n => n.properties["media.title"] === trackTitle
                                          || n.properties["media.name"] === trackTitle);
        return current || matches[0] || null;
    }
    readonly property bool hasSamples: node !== null && _receivedSamples
    readonly property real peak: hasSamples ? Math.max(0, Math.min(1, monitor.peak)) : 0

    function isOutputStream(candidate: PwNode): bool {
        // Quickshell marks playback streams as sinks; capture streams are sources.
        return candidate.isStream && candidate.audio !== null && candidate.isSink;
    }

    function isSpotify(candidate: PwNode): bool {
        // Bound properties identify an application stream, never desktop mix/mic.
        if (!candidate.ready)
            return false;
        // The native monitor cannot map an Unknown channel to FL/FR samples.
        // Reject incomplete maps before capture instead of logging every buffer.
        const channels = candidate.audio.channels;
        if (channels.length === 0 || channels.some(channel => channel === PwAudioChannel.Unknown
                                                              || channel === PwAudioChannel.NA))
            return false;
        const properties = candidate.properties;
        const name = String(properties["application.name"] || "").toLowerCase();
        const binary = String(properties["application.process.binary"] || "").toLowerCase();
        return name === "spotify" || binary === "spotify";
    }

    PwObjectTracker {
        objects: root.active ? root.streams : []
    }
    PwNodePeakMonitor {
        id: monitor
        node: root.node
        enabled: root.active && root.playing && node !== null
        onPeaksChanged: {
            if (peaks.length > 0)
                root._receivedSamples = true;
        }
    }
    onNodeChanged: _receivedSamples = false
}
