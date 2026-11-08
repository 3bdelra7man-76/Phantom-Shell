pragma ComponentBehavior: Bound

import QtQuick
import qs.core

Item {
    id: root

    required property bool active
    required property bool playing
    required property bool hasSamples
    required property real peak
    property list<real> _levels: []
    property int _phase: 0
    readonly property string mode: hasSamples ? "spotify-peak-history" : "decorative"
    opacity: Theme.graphOpacity

    Timer {
        interval: Theme.graphUpdateInterval
        repeat: true
        running: root.active && root.playing
        onTriggered: {
            const count = Theme.graphBarCount;
            if (root.hasSamples) {
                const history = root._levels.slice(1);
                while (history.length < count - 1)
                    history.unshift(0);
                history.push(Math.sqrt(root.peak));
                root._levels = history;
            } else {
                // Explicitly decorative: no frequency or beat measurement implied.
                root._phase = (root._phase + 1) % 10000;
                const levels = [];
                for (let i = 0; i < count; ++i)
                    levels.push(0.15 + 0.7 * Math.abs(Math.sin(i * 0.7 + root._phase * 0.23)
                                                      * Math.sin(i * 0.21 - root._phase * 0.13)));
                root._levels = levels;
            }
        }
    }

    Repeater {
        model: Theme.graphBarCount
        Rectangle {
            required property int index
            x: index * root.width / Theme.graphBarCount
            anchors.bottom: parent.bottom
            width: Math.max(1, root.width / Theme.graphBarCount - Theme.graphBarGap)
            height: Math.max(2, root.height * (root._levels[index] || 0))
            radius: width / 2
            color: Theme.graphColor
            Behavior on height {
                NumberAnimation {
                    duration: Theme.graphUpdateInterval
                }
            }
        }
    }
}
