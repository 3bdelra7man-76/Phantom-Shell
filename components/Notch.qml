import QtQuick
import QtQuick.Shapes
import qs.core

Item {
    id: root

    default property alias content: contentContainer.data
    readonly property alias contentItem: contentContainer
    property color color: Theme.surfaceBackground
    property real minimumHeight: Theme.notchHeight
    property real horizontalPadding: Theme.notchHorizontalPadding
    property real verticalPadding: Theme.notchVerticalPadding
    property real bottomCornerRadius: Theme.notchBottomRadius
    property real shoulderWidth: Theme.notchShoulderWidth
    property real shoulderHeight: Theme.notchShoulderHeight
    property real shoulderCurve: Theme.notchShoulderCurve
    property real outlineSpan: width
    readonly property real topInset: Theme.screenFrameWidth / 2
    property Component background: null
    property bool backgroundActive: false
    readonly property alias backgroundItem: backdrop.item

    readonly property real shoulder: Math.max(0, shoulderWidth)
    readonly property real shoulderDepth: Math.max(0, shoulderHeight)
    readonly property real bottomRadius: {
        const availableWidth = (width - shoulder * 2) / 2;
        const availableHeight = height - shoulderDepth;
        return Math.max(0, Math.min(bottomCornerRadius, availableWidth, availableHeight));
    }

    // Both shoulders are inside these bounds, outside the padded content body.
    implicitWidth: Math.max(contentContainer.implicitWidth + horizontalPadding * 2,
                            bottomCornerRadius * 2) + shoulder * 2
    implicitHeight: Math.max(minimumHeight, contentContainer.implicitHeight + verticalPadding * 2,
                             shoulderDepth + bottomCornerRadius)

    Rectangle {
        id: paintLayer
        anchors.fill: parent
        color: root.color
        visible: backdrop.active
        Loader {
            id: backdrop
            anchors.fill: parent
            active: root.backgroundActive && root.background !== null
            sourceComponent: root.background
        }
    }

    ShaderEffectSource {
        id: backgroundTexture
        width: root.width
        height: root.height
        sourceItem: backdrop.active ? paintLayer : null
        hideSource: true
        visible: false
        smooth: true
    }

    // Black underlay joins the fixed frame across the changing top connectors.
    // The open outline still leaves the notch body attached to the screen.
    Rectangle {
        x: (root.width - width) / 2
        width: root.outlineSpan
        height: Theme.screenFrameWidth
        color: root.color
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        NotchContour {
            surfaceWidth: root.width
            surfaceHeight: root.height
            shoulderWidth: root.shoulder
            shoulderHeight: root.shoulderDepth
            shoulderCurve: root.shoulderCurve
            bottomRadius: root.bottomRadius
            topInset: root.topInset
            fillColor: root.color
            fillItem: backdrop.active ? backgroundTexture : null
            strokeColor: "transparent"
        }
    }

    // Only this local contour changes. The rest of the screen frame is static.
    Shape {
        x: (root.width - width) / 2
        width: root.outlineSpan
        height: root.height + Theme.screenFrameWidth
        preferredRendererType: Shape.CurveRenderer
        NotchContour {
            surfaceWidth: root.width
            surfaceHeight: root.height
            shoulderWidth: root.shoulder
            shoulderHeight: root.shoulderDepth
            shoulderCurve: root.shoulderCurve
            bottomRadius: root.bottomRadius
            topInset: root.topInset
            offsetX: (root.outlineSpan - root.width) / 2
            leftExtension: offsetX
            rightExtension: offsetX
            closeTop: false
            fillColor: "transparent"
            strokeColor: Qt.alpha(Theme.screenFrameColor, Theme.screenFrameOpacity)
            strokeWidth: Theme.screenFrameWidth
        }
    }

    Item {
        id: contentContainer
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
    }
}
