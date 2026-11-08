import QtQuick
import qs.core

Text {
    font.family: Theme.effectiveFontFamily
    font.pixelSize: Theme.artistFontSize
    font.features: ({
                        "tnum": 1
                    })
    color: Theme.textPrimary
    textFormat: Text.PlainText
    maximumLineCount: 1
    verticalAlignment: Text.AlignVCenter
}
