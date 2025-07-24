import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.core as PlasmaCore

KCM.SimpleKCM {
    id: configGeneral
    
    // Set up translation context
    property string translationDomain: "plasma_applet_gamemodechecker"
    
    property color cfg_activeColor: "#4ade80"
    property int cfg_pollInterval: 2000
    
    // Add default properties to satisfy configuration system
    property color cfg_activeColorDefault: "#4ade80"
    property int cfg_pollIntervalDefault: 2000

    Kirigami.FormLayout {
        anchors.fill: parent

        RowLayout {
            Kirigami.FormData.label: i18n("Active color:")
            
            Button {
                id: colorButton
                width: 80
                height: 30
                
                property color selectedColor: configGeneral.cfg_activeColor || "#4ade80"
                
                onSelectedColorChanged: {
                    if (selectedColor.valid) {
                        configGeneral.cfg_activeColor = selectedColor
                    }
                }
                
                background: Rectangle {
                    color: colorButton.selectedColor
                    border.color: colorButton.hovered ? Kirigami.Theme.highlightColor : Kirigami.Theme.buttonBackground
                    border.width: colorButton.hovered ? 3 : 2
                    radius: 4
                    
                    // Add hover glow effect
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -2
                        color: "transparent"
                        border.color: colorButton.hovered ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3) : "transparent"
                        border.width: 2
                        radius: parent.radius + 2
                        z: -2
                    }
                    
                    // Subtle shadow
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 1
                        color: "transparent"
                        border.color: Qt.rgba(0, 0, 0, 0.1)
                        border.width: 1
                        radius: parent.radius
                        z: -1
                    }
                    
                    // Scale animation on hover
                    scale: colorButton.hovered ? 1.05 : 1.0
                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                    }
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }
                }
                
                contentItem: Item {
                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: "color-picker"
                        color: {
                            // Calculate contrast for visibility
                            var r = colorButton.selectedColor.r
                            var g = colorButton.selectedColor.g
                            var b = colorButton.selectedColor.b
                            var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
                            return luminance > 0.5 ? Qt.rgba(0, 0, 0, 0.8) : Qt.rgba(1, 1, 1, 0.9)
                        }
                        isMask: true
                        
                        // Icon bounce animation on hover
                        scale: colorButton.hovered ? 1.1 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutBack }
                        }
                    }
                }
                
                onClicked: colorDialog.open()
                
                ToolTip.visible: hovered
                ToolTip.text: i18n("Click to choose color")
                ToolTip.delay: 500
            }
            
            Label {
                text: colorButton.selectedColor.toString().toUpperCase()
                color: Kirigami.Theme.disabledTextColor
                font.family: "monospace"
            }
        }

        SpinBox {
            id: pollIntervalSpinBox
            Kirigami.FormData.label: i18n("Update interval:")
            from: 500
            to: 10000
            stepSize: 500
            value: configGeneral.cfg_pollInterval
            
            onValueChanged: {
                configGeneral.cfg_pollInterval = value
            }
            
            textFromValue: function(value, locale) {
                return Number(value / 1000).toLocaleString(locale, 'f', 1) + " s"
            }
            
            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, text.replace(" s", "")) * 1000
            }
        }
        
        Item {
            Layout.fillHeight: true
            Layout.preferredHeight: Kirigami.Units.largeSpacing * 2
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            
            Item { Layout.fillWidth: true }
            
            Button {
                id: resetToDefaultsButton
                text: i18n("Reset to Defaults")
                icon.name: "edit-reset"
                
                onClicked: resetDialog.open()
                
                ToolTip.visible: hovered
                ToolTip.text: i18n("Reset all settings to their default values")
            }
        }
    }

    Kirigami.Dialog {
        id: colorDialog
        title: i18n("Choose Active Color")
        width: 500
        height: 520
        
        property color currentColor: colorButton.selectedColor
        property color initialColor: colorButton.selectedColor
        property bool isValidColor: currentColor.valid && currentColor.a > 0
        property bool hasChanges: currentColor.toString() !== initialColor.toString()
        
        onOpened: {
            initialColor = colorButton.selectedColor
            currentColor = colorButton.selectedColor
        }
        
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            
            // Color preview
            Rectangle {
                id: colorPreview
                Layout.preferredWidth: 460
                Layout.preferredHeight: 60
                Layout.alignment: Qt.AlignHCenter
                color: colorDialog.currentColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: 4
                
                Label {
                    anchors.centerIn: parent
                    text: colorDialog.currentColor.toString().toUpperCase()
                    color: {
                        var r = colorDialog.currentColor.r
                        var g = colorDialog.currentColor.g
                        var b = colorDialog.currentColor.b
                        var luminance = (0.299 * r + 0.587 * g + 0.114 * b)
                        return luminance > 0.5 ? Qt.rgba(0, 0, 0, 0.8) : Qt.rgba(1, 1, 1, 0.9)
                    }
                    font.family: "monospace"
                    font.pixelSize: 14
                }
            }
            
            // RGB Sliders
            Kirigami.FormLayout {
                Layout.fillWidth: true
                
                RowLayout {
                    Kirigami.FormData.label: i18n("Red:")
                    
                    Slider {
                        id: redSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 255
                        stepSize: 1
                        value: Math.round(colorDialog.currentColor.r * 255)
                        
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.r * 255) !== value) {
                                colorDialog.currentColor = Qt.rgba(value / 255, colorDialog.currentColor.g, colorDialog.currentColor.b, 1)
                            }
                        }
                        
                        background: Rectangle {
                            x: redSlider.leftPadding
                            y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 6
                            width: redSlider.availableWidth
                            height: implicitHeight
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(0, colorDialog.currentColor.g, colorDialog.currentColor.b, 1) }
                                GradientStop { position: 1.0; color: Qt.rgba(1, colorDialog.currentColor.g, colorDialog.currentColor.b, 1) }
                            }
                            border.color: Qt.rgba(0, 0, 0, 0.2)
                            border.width: 1
                        }
                        
                        handle: Rectangle {
                            x: redSlider.leftPadding + redSlider.visualPosition * (redSlider.availableWidth - width)
                            y: redSlider.topPadding + redSlider.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: redSlider.pressed ? Qt.rgba(1, 1, 1, 0.9) : "white"
                            border.color: Qt.rgba(0, 0, 0, 0.3)
                            border.width: 2
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: Qt.rgba(redSlider.value / 255, colorDialog.currentColor.g, colorDialog.currentColor.b, 1)
                                border.color: Qt.rgba(0, 0, 0, 0.2)
                                border.width: 1
                            }
                        }
                    }
                    
                    SpinBox {
                        from: 0
                        to: 255
                        value: Math.round(colorDialog.currentColor.r * 255)
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.r * 255) !== value) {
                                redSlider.value = value
                            }
                        }
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18n("Green:")
                    
                    Slider {
                        id: greenSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 255
                        stepSize: 1
                        value: Math.round(colorDialog.currentColor.g * 255)
                        
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.g * 255) !== value) {
                                colorDialog.currentColor = Qt.rgba(colorDialog.currentColor.r, value / 255, colorDialog.currentColor.b, 1)
                            }
                        }
                        
                        background: Rectangle {
                            x: greenSlider.leftPadding
                            y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 6
                            width: greenSlider.availableWidth
                            height: implicitHeight
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(colorDialog.currentColor.r, 0, colorDialog.currentColor.b, 1) }
                                GradientStop { position: 1.0; color: Qt.rgba(colorDialog.currentColor.r, 1, colorDialog.currentColor.b, 1) }
                            }
                            border.color: Qt.rgba(0, 0, 0, 0.2)
                            border.width: 1
                        }
                        
                        handle: Rectangle {
                            x: greenSlider.leftPadding + greenSlider.visualPosition * (greenSlider.availableWidth - width)
                            y: greenSlider.topPadding + greenSlider.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: greenSlider.pressed ? Qt.rgba(1, 1, 1, 0.9) : "white"
                            border.color: Qt.rgba(0, 0, 0, 0.3)
                            border.width: 2
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: Qt.rgba(colorDialog.currentColor.r, greenSlider.value / 255, colorDialog.currentColor.b, 1)
                                border.color: Qt.rgba(0, 0, 0, 0.2)
                                border.width: 1
                            }
                        }
                    }
                    
                    SpinBox {
                        from: 0
                        to: 255
                        value: Math.round(colorDialog.currentColor.g * 255)
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.g * 255) !== value) {
                                greenSlider.value = value
                            }
                        }
                    }
                }
                
                RowLayout {
                    Kirigami.FormData.label: i18n("Blue:")
                    
                    Slider {
                        id: blueSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 255
                        stepSize: 1
                        value: Math.round(colorDialog.currentColor.b * 255)
                        
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.b * 255) !== value) {
                                colorDialog.currentColor = Qt.rgba(colorDialog.currentColor.r, colorDialog.currentColor.g, value / 255, 1)
                            }
                        }
                        
                        background: Rectangle {
                            x: blueSlider.leftPadding
                            y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                            implicitWidth: 200
                            implicitHeight: 6
                            width: blueSlider.availableWidth
                            height: implicitHeight
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Qt.rgba(colorDialog.currentColor.r, colorDialog.currentColor.g, 0, 1) }
                                GradientStop { position: 1.0; color: Qt.rgba(colorDialog.currentColor.r, colorDialog.currentColor.g, 1, 1) }
                            }
                            border.color: Qt.rgba(0, 0, 0, 0.2)
                            border.width: 1
                        }
                        
                        handle: Rectangle {
                            x: blueSlider.leftPadding + blueSlider.visualPosition * (blueSlider.availableWidth - width)
                            y: blueSlider.topPadding + blueSlider.availableHeight / 2 - height / 2
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: blueSlider.pressed ? Qt.rgba(1, 1, 1, 0.9) : "white"
                            border.color: Qt.rgba(0, 0, 0, 0.3)
                            border.width: 2
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                radius: 4
                                color: Qt.rgba(colorDialog.currentColor.r, colorDialog.currentColor.g, blueSlider.value / 255, 1)
                                border.color: Qt.rgba(0, 0, 0, 0.2)
                                border.width: 1
                            }
                        }
                    }
                    
                    SpinBox {
                        from: 0
                        to: 255
                        value: Math.round(colorDialog.currentColor.b * 255)
                        onValueChanged: {
                            if (Math.round(colorDialog.currentColor.b * 255) !== value) {
                                blueSlider.value = value
                            }
                        }
                    }
                }
                
                TextField {
                    id: colorInput
                    Kirigami.FormData.label: i18n("Hex:")
                    text: colorDialog.currentColor.toString().toUpperCase()
                    placeholderText: "#RRGGBB"
                    
                    property bool isValidHex: text.match(/^#[0-9A-Fa-f]{6}$/)
                    property bool updating: false
                    
                    color: isValidHex ? Kirigami.Theme.textColor : Kirigami.Theme.negativeTextColor
                    
                    onTextChanged: {
                        if (!updating && isValidHex && text !== colorDialog.currentColor.toString().toUpperCase()) {
                            colorDialog.currentColor = text
                        }
                    }
                    
                    Connections {
                        target: colorDialog
                        function onCurrentColorChanged() {
                            colorInput.updating = true
                            colorInput.text = colorDialog.currentColor.toString().toUpperCase()
                            colorInput.updating = false
                        }
                    }
                    
                    ToolTip.visible: !isValidHex && activeFocus
                    ToolTip.text: i18n("Please enter a valid hex color (e.g., #FF0000)")
                }
            }
            
            // Common colors
            Label {
                text: i18n("Common Colors:")
                font.bold: true
            }
            
            Grid {
                Layout.alignment: Qt.AlignHCenter
                columns: 8
                spacing: 4
                
                Repeater {
                    model: [
                        "#FF0000", "#FF8000", "#FFFF00", "#80FF00",
                        "#00FF00", "#00FF80", "#00FFFF", "#0080FF",
                        "#0000FF", "#8000FF", "#FF00FF", "#FF0080",
                        "#800000", "#804000", "#808000", "#408000",
                        "#008000", "#008040", "#008080", "#004080",
                        "#000080", "#400080", "#800080", "#800040",
                        "#000000", "#404040", "#808080", "#C0C0C0",
                        "#FFFFFF", "#FFE0E0", "#E0FFE0", "#E0E0FF"
                    ]
                    
                    Rectangle {
                        width: 32
                        height: 32
                        color: modelData
                        border.color: Kirigami.Theme.textColor
                        border.width: 1
                        radius: 3
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorDialog.currentColor = parent.color
                            }
                        }
                        
                        // Highlight if selected
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: Kirigami.Theme.highlightColor
                            border.width: colorDialog.currentColor.toString().toUpperCase() === modelData ? 3 : 0
                            radius: parent.radius
                        }
                    }
                }
            }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                
                Button {
                    id: cancelButton
                    text: i18n("Cancel")
                    icon.name: "dialog-cancel"
                    onClicked: {
                        colorDialog.currentColor = colorDialog.initialColor
                        colorDialog.close()
                    }
                }
                
                Button {
                    id: resetButton
                    text: i18n("Reset")
                    icon.name: "edit-undo"
                    enabled: colorDialog.hasChanges
                    onClicked: {
                        colorDialog.currentColor = colorDialog.initialColor
                    }
                    
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Reset to original color")
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    id: applyButton
                    text: i18n("Apply")
                    icon.name: "dialog-ok-apply"
                    enabled: colorDialog.isValidColor && colorDialog.hasChanges
                    onClicked: {
                        colorButton.selectedColor = colorDialog.currentColor
                        colorDialog.initialColor = colorDialog.currentColor
                    }
                    
                    ToolTip.visible: hovered && !enabled
                    ToolTip.text: !colorDialog.hasChanges ? i18n("No changes to apply") : i18n("Invalid color selected")
                }
                
                Button {
                    id: okButton
                    text: i18n("OK")
                    icon.name: "dialog-ok"
                    highlighted: true
                    enabled: colorDialog.isValidColor
                    onClicked: {
                        colorButton.selectedColor = colorDialog.currentColor
                        colorDialog.close()
                    }
                    
                    ToolTip.visible: hovered && !enabled
                    ToolTip.text: i18n("Invalid color selected")
                }
            }
        }
    }

    // Reset to defaults confirmation dialog
    Kirigami.Dialog {
        id: resetDialog
        title: i18n("Reset to Defaults")
        width: 520
        height: 220
        
        padding: Kirigami.Units.largeSpacing
        
        ColumnLayout {
            anchors.fill: parent
            spacing: Kirigami.Units.largeSpacing
            
            RowLayout {
                spacing: Kirigami.Units.largeSpacing
                
                Kirigami.Icon {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    source: "dialog-warning"
                    color: Kirigami.Theme.neutralTextColor
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    Label {
                        Layout.fillWidth: true
                        text: i18n("Reset all settings to default values?")
                        wrapMode: Text.Wrap
                        font.bold: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.1
                    }
                    
                    Label {
                        Layout.fillWidth: true
                        property string colorText: configGeneral.cfg_activeColorDefault.toString().toUpperCase()
                        property real intervalText: configGeneral.cfg_pollIntervalDefault / 1000
                        text: i18n("This will restore the active color to %1 and the update interval to %2 seconds.", colorText, intervalText)
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.disabledTextColor
                    }
                    
                    Label {
                        Layout.fillWidth: true
                        text: i18n("This action cannot be undone.")
                        wrapMode: Text.Wrap
                        color: Kirigami.Theme.negativeTextColor
                        font.italic: true
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.largeSpacing
                
                Button {
                    text: i18n("Cancel")
                    icon.name: "dialog-cancel"
                    onClicked: resetDialog.close()
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: i18n("Reset to Defaults")
                    icon.name: "edit-reset"
                    highlighted: true
                    onClicked: {
                        // Reset to default values
                        colorButton.selectedColor = configGeneral.cfg_activeColorDefault
                        pollIntervalSpinBox.value = configGeneral.cfg_pollIntervalDefault
                        resetDialog.close()
                    }
                }
            }
        }
    }
}
