import QtQuick
import qs.core

TextButton {
    id: root

    required property string glyph
    required property string actionName
    text: actionName
    Accessible.name: actionName
    implicitWidth: Theme.controlIconButtonSize
    implicitHeight: Theme.controlIconButtonSize

    // Floating controls: feedback belongs to the glyph, never a button surface.
    background: Item {}

    contentItem: Item {
        PlaybackIcon {
            anchors.centerIn: parent
            icon: root.glyph
            color: {
                if (root.glyph === "pause")
                    return Theme.pauseIcon;
                return root.hovered ? Theme.accentPrimary : Theme.accentForeground;
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
