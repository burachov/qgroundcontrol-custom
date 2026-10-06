/****************************************************************************
 *
 * Tactical Video OSD Overlay Settings Page
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
    id: osdSettingsPage

    QGCPalette { id: qgcPal }

    // Read stored settings
    property bool   showOSD:        QGroundControl.loadBoolGlobalSetting("OSD_Enabled", true)
    property bool   showCrosshair:  QGroundControl.loadBoolGlobalSetting("OSD_ShowCrosshair", true)
    property bool   showHorizon:    QGroundControl.loadBoolGlobalSetting("OSD_ShowHorizon", true)
    property bool   showBattery:    QGroundControl.loadBoolGlobalSetting("OSD_ShowBattery", true)
    property bool   showAltitude:   QGroundControl.loadBoolGlobalSetting("OSD_ShowAltitude", true)
    property bool   showSpeed:      QGroundControl.loadBoolGlobalSetting("OSD_ShowSpeed", true)
    property bool   showDistance:   QGroundControl.loadBoolGlobalSetting("OSD_ShowDistance", true)
    property bool   showGps:        QGroundControl.loadBoolGlobalSetting("OSD_ShowGps", true)
    property bool   showFlightMode: QGroundControl.loadBoolGlobalSetting("OSD_ShowFlightMode", true)
    property int    crosshairStyle: QGroundControl.loadIntGlobalSetting("OSD_CrosshairStyle", 1)
    property string osdColor:       QGroundControl.loadStringGlobalSetting("OSD_Color", "#00ff66")

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Video OSD Overlay (Betaflight / iNav Style)")
        headingDescription: qsTr("Real-time telemetry and flight symbology overlay directly on live video stream")

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Enable Tactical Video OSD")
            checked:            osdSettingsPage.showOSD
            onClicked: {
                osdSettingsPage.showOSD = checked
                QGroundControl.saveBoolGlobalSetting("OSD_Enabled", checked)
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Flight Symbology")
        visible:            osdSettingsPage.showOSD

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Center Crosshair / Bore Sight")
            checked:            osdSettingsPage.showCrosshair
            onClicked: {
                osdSettingsPage.showCrosshair = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowCrosshair", checked)
            }
        }

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth
            visible:            osdSettingsPage.showCrosshair

            QGCLabel {
                text:           qsTr("Crosshair Style:")
                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 16
            }

            QGCComboBox {
                Layout.fillWidth: true
                model: [
                    qsTr("Center Dot (•)"),
                    qsTr("Aircraft Cross (+)"),
                    qsTr("Tactical Chevron (^)"),
                    qsTr("Targeting Brackets ([ ])"),
                    qsTr("Full Reticle (⌖)")
                ]
                currentIndex: osdSettingsPage.crosshairStyle
                onActivated: (index) => {
                    osdSettingsPage.crosshairStyle = index
                    QGroundControl.saveIntGlobalSetting("OSD_CrosshairStyle", index)
                }
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Artificial Horizon & Pitch Ladder")
            checked:            osdSettingsPage.showHorizon
            onClicked: {
                osdSettingsPage.showHorizon = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowHorizon", checked)
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("Telemetry Elements")
        visible:            osdSettingsPage.showOSD

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Battery Voltage & Percentage (Top Left)")
            checked:            osdSettingsPage.showBattery
            onClicked: {
                osdSettingsPage.showBattery = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowBattery", checked)
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Flight Mode & Armed Status (Top Center)")
            checked:            osdSettingsPage.showFlightMode
            onClicked: {
                osdSettingsPage.showFlightMode = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowFlightMode", checked)
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("GPS Satellites & Lock (Top Right)")
            checked:            osdSettingsPage.showGps
            onClicked: {
                osdSettingsPage.showGps = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowGps", checked)
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Ground Speed (Left Tape)")
            checked:            osdSettingsPage.showSpeed
            onClicked: {
                osdSettingsPage.showSpeed = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowSpeed", checked)
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Relative Altitude (Right Tape)")
            checked:            osdSettingsPage.showAltitude
            onClicked: {
                osdSettingsPage.showAltitude = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowAltitude", checked)
            }
        }

        QGCCheckBox {
            Layout.fillWidth:   true
            text:               qsTr("Distance to Home / Operator (Bottom Center)")
            checked:            osdSettingsPage.showDistance
            onClicked: {
                osdSettingsPage.showDistance = checked
                QGroundControl.saveBoolGlobalSetting("OSD_ShowDistance", checked)
            }
        }
    }

    SettingsGroupLayout {
        Layout.fillWidth:   true
        heading:            qsTr("OSD Color")
        visible:            osdSettingsPage.showOSD

        RowLayout {
            Layout.fillWidth:   true
            spacing:            ScreenTools.defaultFontPixelWidth * 1.5

            Repeater {
                model: [
                    { name: qsTr("Tactical Green"), color: "#00ff66" },
                    { name: qsTr("Warning Amber"),   color: "#ffaa00" },
                    { name: qsTr("Night Red"),       color: "#ff3333" },
                    { name: qsTr("High-Vis White"),  color: "#ffffff" },
                    { name: qsTr("Cyan HUD"),        color: "#00eeff" }
                ]

                Rectangle {
                    width:              ScreenTools.defaultFontPixelHeight * 2.5
                    height:             width
                    radius:             width / 2
                    color:              modelData.color
                    border.color:       osdSettingsPage.osdColor === modelData.color ? "#ffffff" : "#333333"
                    border.width:       osdSettingsPage.osdColor === modelData.color ? 3 : 1

                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            osdSettingsPage.osdColor = modelData.color
                            QGroundControl.saveStringGlobalSetting("OSD_Color", modelData.color)
                        }
                    }
                }
            }
        }
    }
}
