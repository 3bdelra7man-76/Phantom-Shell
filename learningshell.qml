import QtQuick 
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
PanelWindow {
    anchors.top: true
    implicitWidth: 600
    implicitHeight: 50
    color: "transparent"
    mask: Region {item: bar}
    property string ramUsage: " "
    property string cpuUsage: " "
    property string dskUsage: " "
    property string pi: ``
    property bool showVol: false
    PwObjectTracker {
      objects: [Pipewire.defaultAudioSink]
    }
    property var audio: Pipewire.defaultAudioSink?.audio
    Process {
        id: sysStats
        running: true
        command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%.0f%% \", $3/$2 * 100}'; top -bn1 | awk '/Cpu\\(s\\)/ {printf \"%.0f%% \", 100 - $8}'; df -h / | awk 'NR==2 {printf \"%s\", $5}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(" ")
                ramUsage = parts[0]
                cpuUsage = parts[1]
                dskUsage = parts[2]
            }
        }

    }
    property bool expanded: false
    property string currentTime: "Loading..."
    Timer {
      id: volTimer
      interval: 1400
      repeat: false
      onTriggered: {
        showVol = false
      }
    }
    Timer{
        interval: 1000
        running:true
        repeat: true
        onTriggered: {
            currentTime= new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
            sysStats.running = true
        }
    }
    Component.onCompleted: {
        currentTime = new Date().toLocaleTimeString(Qt.locale(), "hh:mm AP")
    }
    Connections {
      target: audio
      function onVolumeChanged() {
        showVol = true
        volTimer.restart()
      }
      function onMutedChanged() {
        showVol = true
        volTimer.restart()
      }
    }

    Rectangle {
        id: bar
        clip: true
        radius: 30
        width: (expanded || showVol) ? 400 : 180
        height: 45
        anchors.centerIn: parent
        color: "#1e1e2e"
        border.color: '#dfaef6'
        Behavior on width {NumberAnimation{duration: 400; easing.type: Easing.OutBack}}
            Text {
                opacity: showVol ? 0.0 : 1.0
                anchors.left: parent.left
                anchors.verticalCenter: bar.verticalCenter
                anchors.margins: 15
                text: currentTime
                color: "#cba6f7"
                font.pixelSize: 14
                Behavior on opacity {NumberAnimation {duration: 200; easing.type: Easing.OutBack}}
            }
            Rectangle {
                id: powericon
                opacity: showVol ? 0.0 : 1.0
                color: myMouseArea.containsMouse ? "#cba6f7" : "#1e1e2e"
                scale: myMouseArea.containsMouse ? 1.1 : 1.0
                border.color: "#cba6f7"
                border.width: 1.2
                radius: 11
                width: myMouseArea.containsMouse ? 37 : 27
                height: 27
                anchors.margins: 12
                anchors.right: bar.right
                anchors.verticalCenter: bar.verticalCenter
                Behavior on color {ColorAnimation {duration: 200}}
                Behavior on scale {NumberAnimation{duration: 150; easing.type: Easing.OutBack}}
                Behavior on width {NumberAnimation{duration: 300; easing.type: Easing.OutBack}}
                Behavior on opacity {NumberAnimation{duration: 200; easing.type: Easing.OutBack}}
                Text {
                  text: pi
                  font.pixelSize: 12
                  anchors.centerIn: parent
                  color: myMouseArea.containsMouse ? "#1e1e2e" : "#cba6f7"
                  Behavior on color {ColorAnimation {duration: 200}}
                }
            }
            MouseArea {
                id: myMouseArea
                anchors.fill: powericon
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {expanded = !expanded}
            }
            Row {
                spacing: 10
                anchors.right: bar.right
                anchors.margins: 60
                anchors.verticalCenter: parent.verticalCenter
                opacity: (expanded && !showVol) ? 1.0 : 0.0
                Behavior on opacity {NumberAnimation{duration: 150; easing.type: Easing.OutBack}}
                Repeater {
                    model: [{icon:" ", val:ramUsage}, {icon:" ", val:cpuUsage}, {icon:" ", val:dskUsage}]
                    Rectangle {
                        width: 64
                        height: 27
                        border.color: '#8673ef'
                        color: '#9b68687e'
                        radius: 11
                        Row {
                            spacing: 6
                            anchors.centerIn: parent 
                            Text{
                                text: modelData.icon
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#cba6f7"
                            }
                            Text{
                                text: modelData.val
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#cba6f7"
                            }
                        }
 
                    }
                }
              }
              Text {
                  text: audio?.muted ? `󰖁` : ((audio?.volume ?? 0) > 0.6 ? `󰕾` : ((audio?.volume ?? 0) < 0.3 ? `󰕿` : `󰖀`))
                  opacity: showVol ? 1.0 : 0.0
                  font.pixelSize: showVol ? 21 : 10
                  font.family: 'JetBrainsMono Nerd Font'
                  color: "#cba6f7"
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 13
                  Behavior on font.pixelSize {NumberAnimation{duration: 300; easing.type: Easing.OutBack}}
                  Behavior on opacity{NumberAnimation{duration: 400; easing.type: Easing.OutQuad}}
              }
              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 15
                anchors.right: parent.right
                width: (expanded || showVol) ? 340 : 180
                height: 30
                radius: 20
                opacity: showVol ? 1.0 : 0.0
                Behavior on width {NumberAnimation{duration:300; easing.type: Easing.OutBack}}
                Behavior on opacity {NumberAnimation{duration: 200; easing.type: Easing.OutQuad}}
                color: "#1e1e2e"
                border.color: "#cba6f7"
                Rectangle {
                  id: fill
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.left: parent.left
                  anchors.leftMargin: 6
                  property real level: audio?.muted? 0 : Math.max(0, Math.min(1, audio?.volume ?? 0))
                  width: (parent.width-12) * level
                  height: parent.height-8
                  radius: 10
                  color: "#cba6f7"
                  Behavior on level {enabled:showVol;NumberAnimation{duration: 300; easing.type: Easing.OutCubic}}
                  Behavior on opacity{NumberAnimation{duration: 150; easing.type: Easing.OutQuad}}
                } 
              }
    }

} 
