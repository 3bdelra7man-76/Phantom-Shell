import QtQuick
import qs.core

Item {
    id: root

    required property real position
    required property real duration
    required property bool seekable
    required property string contextKey
    signal seekRequested(real seconds)

    property real _dragPosition: 0
    property string _dragContext: ""
    readonly property bool validDuration: Number.isFinite(duration) && duration > 0
    readonly property bool dragging: seekArea.pressed && seekArea.enabled
    readonly property real safePosition: Number.isFinite(position) ? Math.max(0, position) : 0
    readonly property real displayPosition: dragging ? _dragPosition : safePosition
    readonly property real fraction: validDuration ? Math.min(1, displayPosition / duration) : 0
    implicitHeight: Theme.timelineHeight
    implicitWidth: Theme.musicContentWidth

    function formatTime(seconds: real): string {
        if (!Number.isFinite(seconds) || seconds < 0)
            return "--:--";
        const whole = Math.floor(seconds);
        const hours = Math.floor(whole / 3600);
        const minutes = Math.floor(whole / 60) % 60;
        const tail = String(whole % 60).padStart(2, "0");
        return hours > 0 ? hours + ":" + String(minutes).padStart(2, "0") + ":" + tail : Math.floor(
                               whole / 60) + ":" + tail;
    }

    function secondsAt(x: real): real {
        const span = Math.max(1, width - Theme.timelineThumbDiameter);
        const ratio = (x - Theme.timelineThumbDiameter / 2) / span;
        return Math.max(0, Math.min(1, ratio)) * duration;
    }

    Item {
        id: trackArea
        width: parent.width
        height: Theme.timelineHitHeight
        opacity: root.validDuration ? 1 : Theme.disabledOpacity

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            x: Theme.timelineThumbDiameter / 2
            width: Math.max(0, parent.width - Theme.timelineThumbDiameter)
            height: Theme.timelineTrackHeight
            radius: height / 2
            color: Theme.progressTrack

            Rectangle {
                width: parent.width * root.fraction
                height: parent.height
                radius: height / 2
                color: Theme.progressAccent
            }
        }

        Rectangle {
            x: track.x + track.width * root.fraction - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.timelineThumbDiameter
            height: width
            radius: width / 2
            color: Theme.accentForeground
            visible: root.validDuration
            opacity: root.seekable ? 1 : Theme.disabledOpacity
        }

        MouseArea {
            id: seekArea
            anchors.fill: parent
            enabled: root.enabled && root.seekable && root.validDuration
            cursorShape: root.seekable ? Qt.SizeHorCursor : Qt.ArrowCursor
            onPressed: mouse => {
                root._dragContext = root.contextKey;
                root._dragPosition = root.secondsAt(mouse.x);
            }
            onPositionChanged: mouse => {
                if (pressed)
                    root._dragPosition = root.secondsAt(mouse.x);
            }
            onReleased: mouse => {
                // A different track or player must never receive an old drag.
                if (root._dragContext === root.contextKey)
                    root.seekRequested(root.secondsAt(mouse.x));
            }
        }
    }

    SharedText {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: root.formatTime(root.displayPosition)
        font.pixelSize: Theme.timelineFontSize
        color: Theme.textSecondary
    }

    SharedText {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: root.validDuration ? root.formatTime(root.duration) : "--:--"
        font.pixelSize: Theme.timelineFontSize
        color: Theme.textSecondary
    }
}
