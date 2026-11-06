import QtQuick
import qs.components
import qs.core

Pill {
    id: root

    default property alias widgets: widgetsRow.data
    horizontalPadding: Theme.widgetPadding
    // Collapse to zero width so the outer Row also drops its gap. Hiding this
    // parent would hide its children and feed back into Row's size calculation.
    implicitWidth: {
        return widgetsRow.implicitWidth > 0 ? widgetsRow.implicitWidth + horizontalPadding * 2 : 0;
    }

    Row {
        id: widgetsRow
        spacing: Theme.widgetGap
    }
}
