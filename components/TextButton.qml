import QtQuick
import QtQuick.Templates as T
import qs.core

T.Button {
    id: root

    implicitWidth: Math.max(Theme.controlMinimumWidth, label.implicitWidth + Theme.controlPadding
                            * 2)
    implicitHeight: Theme.controlHeight
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    font.family: Theme.effectiveFontFamily
    font.pixelSize: Theme.buttonFontSize
    opacity: enabled ? 1 : Theme.disabledOpacity

    contentItem: SharedText {
        id: label
        text: root.text
        font: root.font
        horizontalAlignment: Text.AlignHCenter
    }

    background: Rectangle {
        radius: Theme.controlRadius
        color: root.down ? Theme.buttonPressed : root.hovered ? Theme.buttonHover :
                                                                Theme.buttonBackground

        Behavior on color {
            ColorAnimation {
                duration: Theme.hoverFeedbackDuration
            }
        }
    }
}
