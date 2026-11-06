pragma Singleton

import Quickshell

Singleton {
    property string timeFormat: "HH:mm"
    property string dateFormat: "ddd, d MMM"

    property int topMargin: 12
    // Empty uses the platform's default screen. Otherwise use e.g. "eDP-1".
    property string screenName: ""
    property int progressRefreshInterval: 1000
}
