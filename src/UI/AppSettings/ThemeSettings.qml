/****************************************************************************
 *
 * Tactical Themes Management Page
 * Designed for DJI RC Plus 2 (Android 11)
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.FactSystem
import QGroundControl.FactControls
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

SettingsPage {
    property var    _settingsManager:   QGroundControl.settingsManager
    property var    _appSettings:       _settingsManager.appSettings
    property Fact   _indoorPalette:     _appSettings.indoorPalette

    QGCPalette { id: qgcPal }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Theme & Color Scheme")
        headingDescription: qsTr("Select display theme for DJI RC Plus 2 high-contrast visibility")

        LabelledFactComboBox {
            Layout.fillWidth:   true
            label:              qsTr("Active Theme")
            fact:               _indoorPalette
            indexModel:         false
            visible:            _indoorPalette.visible
        }

        // Visual Theme Selector Cards
        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth

            // Card 1: Standard Dark
            Rectangle {
                Layout.fillWidth:   true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 4.5
                radius:             ScreenTools.defaultFontPixelWidth / 2
                color:              "#222222"
                border.color:       _indoorPalette.rawValue === 1 ? qgcPal.colorBlue : "#444444"
                border.width:       _indoorPalette.rawValue === 1 ? 3 : 1

                ColumnLayout {
                    anchors.centerIn:   parent
                    spacing:            4

                    QGCLabel {
                        text:           qsTr("Dark Standard")
                        color:          "#ffffff"
                        font.bold:      true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width:          30
                        height:         6
                        radius:         3
                        color:          "#8cb3be"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    _indoorPalette.rawValue = 1
                }
            }

            // Card 2: Tactical Red
            Rectangle {
                Layout.fillWidth:   true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 4.5
                radius:             ScreenTools.defaultFontPixelWidth / 2
                color:              "#0a0a0a"
                border.color:       _indoorPalette.rawValue === 2 ? "#ff2222" : "#331111"
                border.width:       _indoorPalette.rawValue === 2 ? 3 : 1

                ColumnLayout {
                    anchors.centerIn:   parent
                    spacing:            4

                    QGCLabel {
                        text:           qsTr("Tactical Red")
                        color:          "#ff3b30"
                        font.bold:      true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width:          30
                        height:         6
                        radius:         3
                        color:          "#ff2222"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    _indoorPalette.rawValue = 2
                }
            }

            // Card 3: Military Green
            Rectangle {
                Layout.fillWidth:   true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 4.5
                radius:             ScreenTools.defaultFontPixelWidth / 2
                color:              "#0d140d"
                border.color:       _indoorPalette.rawValue === 3 ? "#39ff14" : "#1b331b"
                border.width:       _indoorPalette.rawValue === 3 ? 3 : 1

                ColumnLayout {
                    anchors.centerIn:   parent
                    spacing:            4

                    QGCLabel {
                        text:           qsTr("Military Green")
                        color:          "#39ff14"
                        font.bold:      true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width:          30
                        height:         6
                        radius:         3
                        color:          "#39ff14"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    _indoorPalette.rawValue = 3
                }
            }

            // Card 4: Light (Outdoor)
            Rectangle {
                Layout.fillWidth:   true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 4.5
                radius:             ScreenTools.defaultFontPixelWidth / 2
                color:              "#f0f0f0"
                border.color:       _indoorPalette.rawValue === 0 ? qgcPal.colorBlue : "#cccccc"
                border.width:       _indoorPalette.rawValue === 0 ? 3 : 1

                ColumnLayout {
                    anchors.centerIn:   parent
                    spacing:            4

                    QGCLabel {
                        text:           qsTr("Light Outdoor")
                        color:          "#000000"
                        font.bold:      true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        width:          30
                        height:         6
                        radius:         3
                        color:          "#8cb3be"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked:    _indoorPalette.rawValue = 0
                }
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Font & Scale")

        LabelledFactComboBox {
            Layout.fillWidth:   true
            label:              qsTr("Application Font Size")
            fact:               _appSettings.appFontPointSize
            indexModel:         false
            visible:            _appSettings.appFontPointSize.visible
        }
    }
}
