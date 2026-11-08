pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
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
    property color pauseIcon: "#FFFFFF"
    property color buttonBackground: "#1C1025"
    property color buttonHover: "#341448"
    property color buttonPressed: "#501D70"

    property string fontFamily: "Sharphy"
    property string fallbackFontFamily: "Noto Sans"
    // Optional project-relative font URL; keep licensed font files in the project.
    property url fontSource: ""
    readonly property string installedFontFamily: {
        const preferred = fontFamily.toLowerCase();
        return Qt.fontFamilies().find(name => name.toLowerCase() === preferred) || "";
    }
    readonly property string effectiveFontFamily: {
        if (bundledFont.status === FontLoader.Ready)
            return bundledFont.name;
        return installedFontFamily || fallbackFontFamily;
    }
    FontLoader {
        id: bundledFont
        source: root.fontSource
    }
    property int timeFontSize: 14
    property int dateFontSize: 12
    property int fallbackFontSize: 16
    property int titleFontSize: 16
    property int artistFontSize: 12
    property int timelineFontSize: 11
    property int buttonFontSize: 12

    // Reduce the old 44px height once: one pixel above and below the header.
    property real notchHeight: 42
    property real notchHorizontalPadding: 18
    property real notchVerticalPadding: 6
    property real notchBottomRadius: 12
    property real notchShoulderWidth: 26
    property real notchShoulderHeight: 14
    property real notchShoulderCurve: 0.55
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

    property real musicContentWidth: 360
    property real musicPadding: 20
    property real musicTopGap: 10
    property real musicBottomPadding: 16
    property real musicArtworkDiameter: 72
    property int musicArtworkDecodedSize: 216
    property real musicMetadataGap: 16
    property real musicSectionGap: 12
    property real musicProgressWidth: 2
    property real musicArtworkRingGap: 2
    property real controlHeight: 32
    property real controlMinimumWidth: 60
    property real controlPadding: 12
    property real controlGap: 8
    property real controlRadius: 10
    property real disabledOpacity: 0.35
    property real timelineHeight: 42
    property real timelineHitHeight: 20
    property real timelineTrackHeight: 3
    property real timelineThumbDiameter: 10
    property int transitionDuration: 260
    property int contentFadeDuration: 90
    property int contentExitDuration: 40
    property int hoverFeedbackDuration: 90
    property int pointerExitDelay: 120
    property int openingGraceDuration: 400
}
