import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configGeneral
    
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
    }

    Kirigami.Dialog {
        id: colorDialog
        title: i18n("Choose Active Color")
        width: 400
        height: 450
        
        property color currentColor: colorButton.selectedColor
        
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing
            
            // Color preview
            Rectangle {
                id: colorPreview
                Layout.preferredWidth: 360
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
                            colorDialog.currentColor = Qt.rgba(value / 255, colorDialog.currentColor.g, colorDialog.currentColor.b, 1)
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
                        value: redSlider.value
                        onValueChanged: redSlider.value = value
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
                            colorDialog.currentColor = Qt.rgba(colorDialog.currentColor.r, value / 255, colorDialog.currentColor.b, 1)
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
                        value: greenSlider.value
                        onValueChanged: greenSlider.value = value
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
                            colorDialog.currentColor = Qt.rgba(colorDialog.currentColor.r, colorDialog.currentColor.g, value / 255, 1)
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
                        value: blueSlider.value
                        onValueChanged: blueSlider.value = value
                    }
                }
                
                TextField {
                    id: colorInput
                    Kirigami.FormData.label: i18n("Hex:")
                    text: colorDialog.currentColor.toString().toUpperCase()
                    placeholderText: "#RRGGBB"
                    
                    onTextChanged: {
                        if (text.match(/^#[0-9A-Fa-f]{6}$/)) {
                            colorDialog.currentColor = text
                        }
                    }
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
                    text: i18n("Cancel")
                    onClicked: {
                        colorDialog.close()
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: i18n("OK")
                    highlighted: true
                    onClicked: {
                        colorButton.selectedColor = colorDialog.currentColor
                        colorDialog.close()
                    }
                }
            }
        }
    }
}
