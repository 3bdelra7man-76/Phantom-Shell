import QtQuick
import qs.core

Rectangle {
    id: root

    default property alias content: contentContainer.data
    property real minimumHeight: Theme.pillHeight
    property real horizontalPadding: Theme.pillPadding
    property real verticalPadding: Theme.pillVerticalPadding
    readonly property alias contentItem: contentContainer

    implicitWidth: contentContainer.childrenRect.width + horizontalPadding * 2
    implicitHeight: Math.max(minimumHeight, contentContainer.childrenRect.height + verticalPadding
                             * 2)
    radius: height / 2
    color: Theme.surfaceBackground
    antialiasing: true

    Item {
        id: contentContainer
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
    }
}
