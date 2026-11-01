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

    // Constant source name. The "executable" engine re-runs the command every
    // `interval` milliseconds, so there is no need to create a new source per
    // poll. Creating uniquely named sources (e.g. with a timestamp) leaks a
    // dynamic property into the QML metaobject on every poll, forcing a full
    // QMetaObject rebuild and making plasmashell burn a whole CPU core.
    readonly property string checkCommand: Qt.resolvedUrl("../code/check.sh").toString().replace("file://", "")

    Plasma5Support.DataSource {
        id: dataSource
        engine: "executable"
        // The executable engine enforces a 1000 ms minimum polling interval.
        interval: Math.max(1000, pollInterval)
        connectedSources: [checkCommand]
        onNewData: function(sourceName, data) {
            if (data && data.stdout !== undefined) {
                controller.isActive = data.stdout.trim() === "active"
            }
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
}
