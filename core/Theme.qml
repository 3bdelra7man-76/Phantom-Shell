pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property color pillBackground: "#000000"
    property color textPrimary: "#ffffff"
    property color textSecondary: "#b5b5b5"
    property color progressAccent: "#1db954"
    property color progressTrack: "#303030"
    property color artworkFallback: "#191919"
    property color artworkGlyph: "#929292"

    property string fontFamily: "monospace"
    property int timeFontSize: 14
    property int dateFontSize: 12
    property int fallbackFontSize: 18

    property real pillHeight: 44
    property real pillPadding: 16
    property real widgetPadding: 6
    property real pillVerticalPadding: 5
    property real pillGap: 8
    property real dateTimeGap: 12
    property real widgetGap: 8
    property real artworkDiameter: 34
    property int artworkDecodedSize: 96
    property real progressWidth: 2
    property real artworkRingGap: 2
    property int artworkFadeDuration: 120
}
