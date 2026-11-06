import QtQuick
import qs.components
import qs.core

Pill {
    id: root

    default property alias widgets: widgetsRow.data
    minimumHeight: Theme.widgetsPillHeight
    horizontalPadding: Theme.widgetsHorizontalPadding
    verticalPadding: Theme.widgetsVerticalPadding
    // Hiding this parent would also hide its children, feeding back into Row's
    // measurement. A zero-width surface collapses without hiding the content.
    implicitWidth: {
        return widgetsRow.implicitWidth > 0 ? widgetsRow.implicitWidth + horizontalPadding * 2 : 0;
    }

    Row {
        id: widgetsRow
        spacing: Theme.widgetGap
    }
}
