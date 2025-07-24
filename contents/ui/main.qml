import QtQuick 2.15
import org.kde.plasma.plasma5support 2.0 as Plasma5Support
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    width: 32
    height: 32
    
    // Configuration properties
    property color activeColor: plasmoid.configuration.activeColor || "#4ade80"
    property int pollInterval: plasmoid.configuration.pollInterval || 2000

    Plasma5Support.DataSource {
        id: dataSource
        engine: "executable"
        onNewData: function(sourceName, data) {
            console.log("DataSource data received:", JSON.stringify(data))
            if (data && data.stdout !== undefined) {
                var out = data.stdout.trim()
                controller.isActive = out === "active"
                console.log("Script output:", out, "Game mode active:", controller.isActive)
            } else if (data && data.stderr) {
                console.log("Script error:", data.stderr)
            }
        }
        onSourceAdded: function(source) {
            console.log("Source added:", source)
        }
    }

    Item {
        id: controller
        anchors.centerIn: parent
        width: 24
        height: 24
        
        property bool isActive: false
        
        // Gaming controller icon
        Kirigami.Icon {
            id: baseIcon
            anchors.fill: parent
            source: "input-gamepad-symbolic"
            
            // Simple color change - use configured color when active, normal when inactive
            color: parent.isActive ? activeColor : Kirigami.Theme.textColor
            isMask: true
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }

    Timer {
        id: pollTimer
        interval: pollInterval
        repeat: true
        running: true
        triggeredOnStart: true
        
        property string lastSource: ""
        
        onTriggered: {
            var scriptPath = Qt.resolvedUrl("../code/check.sh").toString().replace("file://", "")
            
            // Disconnect previous source to prevent memory leaks
            if (lastSource !== "") {
                dataSource.disconnectSource(lastSource)
            }
            
            // Use a wrapper command that includes timestamp for uniqueness
            var timestamp = Date.now()
            var uniqueSource = "bash -c 'echo \"# Timestamp: " + timestamp + "\" >&2; " + scriptPath + "'"
            console.log("Timer triggered, executing:", uniqueSource)
            dataSource.connectSource(uniqueSource)
            
            // Store for cleanup next time
            lastSource = uniqueSource
        }
    }
}
