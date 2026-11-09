pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import qs.core

TextButton {
    id: root

    required property string glyph
    required property string actionName
    property string tooltipText: ""
    property color glyphColor: Theme.accentForeground
    property color glyphHoverColor: Theme.accentPrimary
    text: actionName
    Accessible.name: actionName
    implicitWidth: Theme.controlIconButtonSize
    implicitHeight: Theme.controlIconButtonSize

    // Floating controls: feedback belongs to the glyph, never a button surface.
    background: Item {}

    Loader {
        active: root.tooltipText.length > 0
        sourceComponent: Controls.ToolTip {
            parent: root
            visible: root.hovered && root.enabled
            delay: Theme.tooltipDelay
            y: root.height + Theme.tooltipGap
            contentItem: SharedText {
                text: root.tooltipText
            }
            background: Rectangle {
                color: Theme.surfaceBackground
                radius: Theme.controlRadius
                border.color: Theme.accentMuted
            }
        }
    }

    contentItem: Item {
        PlaybackIcon {
            anchors.centerIn: parent
            icon: root.glyph
            color: {
                if (root.glyph === "pause")
                    return Theme.pauseIcon;
                return root.hovered ? root.glyphHoverColor : root.glyphColor;
            }
            opacity: root.down ? Theme.controlGlyphPressedOpacity : root.hovered ? 1 :
                                                                                   Theme.controlGlyphIdleOpacity
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.hoverFeedbackDuration
                }
            }
        }
    }
}
