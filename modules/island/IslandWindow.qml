import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.core
import qs.modules.calendar

PanelWindow {
    id: root
    readonly property alias islandItem: island
    readonly property alias calendarWindow: calendar

    // An empty or unmatched name lets the platform choose its default screen.
    screen: Quickshell.screens.find(output => output.name === Config.screenName) ?? null
    // Full width makes the notch's horizontal center a screen coordinate,
    // independent of the number or width of widgets on its right.
    anchors {
        top: true
        left: true
        right: true
    }
    // Resizing a Wayland surface on every frame stalls configure/commit cycles
    // on Niri. Reserve a fixed transparent canvas; the input mask stays compact.
    implicitHeight: Math.ceil(island.canvasHeight)
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qp-island"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    // Only the compact artwork and expanded solid body receive input. Shoulder
    // cutouts and the unused full-width strip always pass through to the desktop.
    mask: Region {
        Region {
            x: Math.floor(island.calendarInputX)
            y: Math.floor(island.calendarInputY)
            width: Math.ceil(island.calendarTrigger.width)
            height: Math.ceil(island.calendarTrigger.height)
        }
        Region {
            x: Math.floor(island.musicPresentation.x)
            y: Math.floor(island.musicPresentation.y)
            width: island.compactInputEnabled ? Math.ceil(island.musicPresentation.width) : 0
            height: width
            shape: RegionShape.Ellipse
        }
        Region {
            x: Math.ceil(island.panelBody.x)
            width: {
                if (!island.panelInputEnabled)
                    return 0;
                const right = Math.floor(island.panelBody.x + island.panelBody.width);
                return Math.max(0, right - x);
            }
            height: island.panelInputEnabled ? Math.floor(island.panelBody.height) : 0
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: Math.ceil(island.notchSurface.bottomRadius)
            bottomRightRadius: bottomLeftRadius
        }
    }

    Island {
        id: island
        anchors.fill: parent
        active: root.visible && root.backingWindowVisible
    }

    ScreenFrameWindow {
        screen: root.screen
        visible: root.visible
        openingWidth: island.frameOpeningWidth
    }

    CalendarWindow {
        id: calendar
        screen: root.screen
        opened: island.calendarOpen && root.backingWindowVisible
        onDismissRequested: island.closePanel()
    }

    OutsideClickCatcher {
        screen: root.screen
        armed: root.backingWindowVisible && island.activePanel !== ""
        dragging: island.dragging
        onDismissRequested: island.closePanel()
    }
}
