pragma Singleton

import QtQuick
import Quickshell

Singleton {
    property color surfaceBackground: "#000000"
    property color accentPrimary: "#9D00FF"
    property color accentForeground: "#D9A6FF"
    property color accentSecondary: "#B87AE6"
    property color accentMuted: "#3E2052"
    property color textPrimary: accentForeground
    property color textSecondary: accentSecondary
    property color progressAccent: accentPrimary
    property color progressTrack: accentMuted
    property color artworkFallback: "#17111C"
    property color artworkGlyph: accentSecondary
    property color artworkShade: "#000000"
    property color pauseIcon: accentForeground

    property string fontFamily: "monospace"
    property int timeFontSize: 14
    property int dateFontSize: 12
    property int fallbackFontSize: 16

    property real notchHeight: 44
    property real notchHorizontalPadding: 18
    property real notchVerticalPadding: 6
    property real notchBottomRadius: 12
    property real notchShoulderRadius: 14
    property real notchWidgetsGap: 8

    // Generic pill defaults are independent of the compact widgets pill.
    property real pillHeight: 44
    property real pillPadding: 16
    property real pillVerticalPadding: 5
    property real widgetsPillHeight: 38
    property real widgetsHorizontalPadding: 5
    property real widgetsVerticalPadding: 4
    property real dateTimeGap: 12
    property real widgetGap: 8
    property real artworkDiameter: 30
    property int artworkDecodedSize: 96
    property real progressWidth: 1.75
    property real artworkRingGap: 1.5
    property real pausedOverlayOpacity: 0.30
    property real pauseBarWidth: 2
    property real pauseBarHeight: 10
    property real pauseBarGap: 3
    property int artworkFadeDuration: 120
    property int pauseFadeDuration: 120
}
