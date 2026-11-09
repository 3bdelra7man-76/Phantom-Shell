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
    property real notchHorizontalPadding: 22
    property real notchVerticalPadding: 6
    property real notchBottomRadius: 30
    property real notchShoulderWidth: 30
    property real notchShoulderHeight: 20
    property real notchShoulderCurve: 0.55
    property real musicShoulderWidth: 76
    property real musicShoulderHeight: 50
    property real musicShoulderCurve: 0.62
    // Measured from the compact body, not the outer top shoulder tip.
    property real notchWidgetsGap: 16
    property real screenFrameWidth: 2.0
    property real screenFrameOpacity: 0.20
    property color screenFrameColor: textPrimary

    // Generic pill defaults are independent of the compact widgets pill.
    property real pillHeight: 42
    property real pillPadding: 12
    property real pillVerticalPadding: 2
    property real widgetsPillHeight: 36
    property real widgetsHorizontalPadding: 4
    property real widgetsVerticalPadding: 4
    property real dateTimeGap: 12
    property real widgetGap: 8
    property real artworkDiameter: 30
    property int artworkDecodedSize: 96
    property real progressWidth: 1.95
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
    property real controlIconSize: 20
    property real controlIconButtonSize: 38
    property real controlGlyphIdleOpacity: 0.85
    property real controlGlyphPressedOpacity: 0.60
    property real disabledOpacity: 0.35
    property real timelineHeight: 42
    property real timelineHitHeight: 20
    property real timelineTrackHeight: 3
    property real timelineThumbDiameter: 10
    property int transitionDuration: 240
    property real contentRevealStart: 0.65
    property int hoverFeedbackDuration: 90
    property real backgroundArtworkOpacity: 0.40
    property int backgroundDecodedSize: 1024
    property real backgroundScrimOpacity: 0.12
    property real headerShadowOpacity: 0.85
    property real headerShadowExtraHeight: 8
    property real graphOpacity: 0.20
    property color graphColor: accentSecondary
    property int graphBarCount: 32
    property real graphHeight: 54
    property real graphBarGap: 3
    property int graphUpdateInterval: 80
    property real artworkGlowOpacity: 0.18
    property real artworkGlowBlur: 12
    property real artworkGlowSpread: 1

    // New feature settings; existing tuned geometry and timing stay independent.
    property real screenFrameInnerRadius: 18
    property real todoWidgetSize: artworkDiameter
    property real todoContentWidth: 504
    property real todoPadding: 20
    property real todoTopGap: 10
    property real todoBottomPadding: 16
    property real todoSectionGap: 10
    property real todoListHeight: 220
    property real todoScrollBarWidth: 3
    property real todoRowHeight: 40
    property real todoActionSize: 30
    property real todoFieldHeight: 36
    property real todoFieldPadding: 10
    property real todoFieldRadius: 8
    property int todoFontSize: 13
    property color todoSurface: "#111114"
    property color todoText: "#EDEBF2"
    property color todoMutedText: "#96929E"
    property color todoFieldBackground: todoSurface
    property color todoCompletedText: todoMutedText
    property color todoSeparator: "#16FFFFFF"
    property color todoHoverTint: Qt.alpha(accentForeground, 0.05)
    property color todoSelectedTint: Qt.alpha(accentPrimary, 0.16)
    property real todoRowPadding: 12
    property real todoSurfaceRadius: 10
    property real todoHeaderHeight: 28
    property real todoFilterHeight: 32
    property real todoStatusHeight: 32
    property real todoScreenMargin: 20
    property real todoTooltipWidth: 440
    property int panelSwitchFadeDuration: 90
    property int tooltipDelay: 500
    property real tooltipGap: 4
    property color screenFrameFill: surfaceBackground
}
