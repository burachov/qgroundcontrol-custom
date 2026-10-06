/****************************************************************************
 *
 * Custom Tactical Video OSD Overlay (iNav / Betaflight style)
 * Designed for DJI RC Plus 2 (Android 11)
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls

import QGroundControl
import QGroundControl.Controls
import QGroundControl.ScreenTools
import QGroundControl.Palette

Item {
    id: osdRoot
    anchors.fill: parent

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle

    // Persistent OSD Settings (stored in global settings with sensible defaults)
    property bool   showOSD:            QGroundControl.loadBoolGlobalSetting("OSD_Enabled", true)
    property bool   showCrosshair:      QGroundControl.loadBoolGlobalSetting("OSD_ShowCrosshair", true)
    property bool   showHorizon:        QGroundControl.loadBoolGlobalSetting("OSD_ShowHorizon", true)
    property bool   showBattery:        QGroundControl.loadBoolGlobalSetting("OSD_ShowBattery", true)
    property bool   showAltitude:       QGroundControl.loadBoolGlobalSetting("OSD_ShowAltitude", true)
    property bool   showSpeed:          QGroundControl.loadBoolGlobalSetting("OSD_ShowSpeed", true)
    property bool   showDistance:       QGroundControl.loadBoolGlobalSetting("OSD_ShowDistance", true)
    property bool   showGps:            QGroundControl.loadBoolGlobalSetting("OSD_ShowGps", true)
    property bool   showFlightMode:     QGroundControl.loadBoolGlobalSetting("OSD_ShowFlightMode", true)

    // Style properties: 0=Dot, 1=Cross, 2=Chevron, 3=Brackets, 4=Reticle
    property int    crosshairStyle:     QGroundControl.loadIntGlobalSetting("OSD_CrosshairStyle", 1)
    property color  osdColor:           QGroundControl.loadStringGlobalSetting("OSD_Color", "#00ff66")
    property real   osdFontSize:        ScreenTools.defaultFontPointSize * 1.1

    visible: showOSD

    function reloadSettings() {
        showOSD        = QGroundControl.loadBoolGlobalSetting("OSD_Enabled", true)
        showCrosshair  = QGroundControl.loadBoolGlobalSetting("OSD_ShowCrosshair", true)
        showHorizon    = QGroundControl.loadBoolGlobalSetting("OSD_ShowHorizon", true)
        showBattery    = QGroundControl.loadBoolGlobalSetting("OSD_ShowBattery", true)
        showAltitude   = QGroundControl.loadBoolGlobalSetting("OSD_ShowAltitude", true)
        showSpeed      = QGroundControl.loadBoolGlobalSetting("OSD_ShowSpeed", true)
        showDistance   = QGroundControl.loadBoolGlobalSetting("OSD_ShowDistance", true)
        showGps        = QGroundControl.loadBoolGlobalSetting("OSD_ShowGps", true)
        showFlightMode = QGroundControl.loadBoolGlobalSetting("OSD_ShowFlightMode", true)
        crosshairStyle = QGroundControl.loadIntGlobalSetting("OSD_CrosshairStyle", 1)
        osdColor       = QGroundControl.loadStringGlobalSetting("OSD_Color", "#00ff66")
    }

    Connections {
        target: QGroundControl
        function onGlobalSettingChanged(key) {
            if (key.indexOf("OSD_") === 0) {
                osdRoot.reloadSettings()
            }
        }
    }

    // Telemetry Facts
    property real   pitch:              _activeVehicle ? _activeVehicle.pitch.rawValue : 0
    property real   roll:               _activeVehicle ? _activeVehicle.roll.rawValue : 0
    property real   altitude:           _activeVehicle ? _activeVehicle.altitudeRelative.rawValue : 0
    property real   groundSpeed:        _activeVehicle ? _activeVehicle.groundSpeed.rawValue : 0
    property real   distanceHome:       _activeVehicle ? _activeVehicle.distanceToHome.rawValue : 0
    property string flightMode:         _activeVehicle ? _activeVehicle.flightMode : "DISCONNECTED"
    property int    satellites:         _activeVehicle ? _activeVehicle.gps.count.rawValue : 0
    property real   batteryVoltage:     _activeVehicle ? _activeVehicle.battery.voltage.rawValue : 0
    property real   batteryCurrent:     _activeVehicle ? _activeVehicle.battery.current.rawValue : 0
    property real   batteryPercent:     _activeVehicle ? _activeVehicle.battery.percentRemaining.rawValue : 0

    // Center Crosshair
    Item {
        id: crosshairItem
        anchors.centerIn: parent
        width: 60
        height: 60
        visible: showCrosshair

        // Style 0: Center Dot
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: osdColor
            border.color: "#000000"
            border.width: 1
            visible: crosshairStyle === 0
        }

        // Style 1: Aircraft Cross (+)
        Item {
            anchors.fill: parent
            visible: crosshairStyle === 1

            // Horizontal lines
            Rectangle {
                x: 0; y: parent.height / 2 - 1
                width: 18; height: 2
                color: osdColor
            }
            Rectangle {
                x: parent.width - 18; y: parent.height / 2 - 1
                width: 18; height: 2
                color: osdColor
            }
            // Vertical lines
            Rectangle {
                x: parent.width / 2 - 1; y: 0
                width: 2; height: 18
                color: osdColor
            }
            Rectangle {
                x: parent.width / 2 - 1; y: parent.height - 18
                width: 2; height: 18
                color: osdColor
            }
            // Center pip
            Rectangle {
                anchors.centerIn: parent
                width: 4; height: 4
                radius: 2
                color: osdColor
            }
        }

        // Style 2: Military Chevron (^)
        Canvas {
            id: chevronCanvas
            anchors.fill: parent
            visible: crosshairStyle === 2
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = osdColor
                ctx.lineWidth = 2.5
                ctx.beginPath()
                ctx.moveTo(15, 38)
                ctx.lineTo(30, 22)
                ctx.lineTo(45, 38)
                ctx.stroke()
            }
            Connections {
                target: osdRoot
                function onOsdColorChanged() { chevronCanvas.requestPaint() }
            }
        }

        // Style 3: Tactical Target Brackets [ + ]
        Item {
            anchors.fill: parent
            visible: crosshairStyle === 3

            // Left bracket
            Rectangle { x: 5; y: 15; width: 3; height: 30; color: osdColor }
            Rectangle { x: 5; y: 15; width: 8; height: 3; color: osdColor }
            Rectangle { x: 5; y: 42; width: 8; height: 3; color: osdColor }

            // Right bracket
            Rectangle { x: parent.width - 8; y: 15; width: 3; height: 30; color: osdColor }
            Rectangle { x: parent.width - 13; y: 15; width: 8; height: 3; color: osdColor }
            Rectangle { x: parent.width - 13; y: 42; width: 8; height: 3; color: osdColor }

            // Center cross
            Rectangle { anchors.centerIn: parent; width: 10; height: 2; color: osdColor }
            Rectangle { anchors.centerIn: parent; width: 2; height: 10; color: osdColor }
        }

        // Style 4: Circular Reticle
        Item {
            anchors.fill: parent
            visible: crosshairStyle === 4

            Rectangle {
                anchors.centerIn: parent
                width: 40; height: 40; radius: 20
                color: "transparent"
                border.color: osdColor
                border.width: 2
            }
            Rectangle { anchors.centerIn: parent; width: 4; height: 4; radius: 2; color: osdColor }
        }
    }

    // Artificial Horizon Ladder
    Item {
        id: horizonContainer
        anchors.centerIn: parent
        width: 280
        height: 280
        visible: showHorizon
        clip: true

        Item {
            id: pitchRollGroup
            anchors.centerIn: parent
            width: parent.width
            height: parent.height

            // Roll rotation around center
            rotation: -osdRoot.roll

            // Pitch translation (pixels per degree)
            readonly property real pixelsPerDegree: 3.5
            y: (parent.height / 2) + (osdRoot.pitch * pixelsPerDegree) - (height / 2)

            // Horizon zero line
            Row {
                anchors.centerIn: parent
                spacing: 40
                Rectangle { width: 70; height: 2; color: osdColor }
                Rectangle { width: 70; height: 2; color: osdColor }
            }

            // +10 Pitch Ladder
            Item {
                x: parent.width / 2 - 50; y: parent.height / 2 - (10 * pitchRollGroup.pixelsPerDegree)
                width: 100; height: 12
                Rectangle { x: 0; y: 0; width: 30; height: 2; color: osdColor }
                Rectangle { x: 70; y: 0; width: 30; height: 2; color: osdColor }
                Text { x: -22; y: -6; text: "10"; color: osdColor; font.pixelSize: 11; font.bold: true }
                Text { x: 104; y: -6; text: "10"; color: osdColor; font.pixelSize: 11; font.bold: true }
            }

            // -10 Pitch Ladder
            Item {
                x: parent.width / 2 - 50; y: parent.height / 2 + (10 * pitchRollGroup.pixelsPerDegree)
                width: 100; height: 12
                Rectangle { x: 0; y: 0; width: 30; height: 2; color: osdColor }
                Rectangle { x: 70; y: 0; width: 30; height: 2; color: osdColor }
                Text { x: -24; y: -6; text: "-10"; color: osdColor; font.pixelSize: 11; font.bold: true }
                Text { x: 104; y: -6; text: "-10"; color: osdColor; font.pixelSize: 11; font.bold: true }
            }

            // +20 Pitch Ladder
            Item {
                x: parent.width / 2 - 40; y: parent.height / 2 - (20 * pitchRollGroup.pixelsPerDegree)
                width: 80; height: 12
                Rectangle { x: 0; y: 0; width: 25; height: 2; color: osdColor }
                Rectangle { x: 55; y: 0; width: 25; height: 2; color: osdColor }
                Text { x: -22; y: -6; text: "20"; color: osdColor; font.pixelSize: 11; font.bold: true }
                Text { x: 84; y: -6; text: "20"; color: osdColor; font.pixelSize: 11; font.bold: true }
            }

            // -20 Pitch Ladder
            Item {
                x: parent.width / 2 - 40; y: parent.height / 2 + (20 * pitchRollGroup.pixelsPerDegree)
                width: 80; height: 12
                Rectangle { x: 0; y: 0; width: 25; height: 2; color: osdColor }
                Rectangle { x: 55; y: 0; width: 25; height: 2; color: osdColor }
                Text { x: -24; y: -6; text: "-20"; color: osdColor; font.pixelSize: 11; font.bold: true }
                Text { x: 84; y: -6; text: "-20"; color: osdColor; font.pixelSize: 11; font.bold: true }
            }
        }
    }

    // Left Telemetry Strip (Speed & Altitude)
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Speed
        Rectangle {
            visible: showSpeed
            width: speedText.implicitWidth + 14
            height: speedText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: speedText
                anchors.centerIn: parent
                text: "SPD: " + osdRoot.groundSpeed.toFixed(1) + " m/s"
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }

        // Altitude
        Rectangle {
            visible: showAltitude
            width: altText.implicitWidth + 14
            height: altText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: altText
                anchors.centerIn: parent
                text: "ALT: " + osdRoot.altitude.toFixed(1) + " m"
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }
    }

    // Right Telemetry Strip (Distance & Flight Mode)
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Distance to Home
        Rectangle {
            visible: showDistance
            width: distText.implicitWidth + 14
            height: distText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: distText
                anchors.centerIn: parent
                text: "DST: " + osdRoot.distanceHome.toFixed(0) + " m"
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }

        // Flight Mode
        Rectangle {
            visible: showFlightMode
            width: modeText.implicitWidth + 14
            height: modeText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: modeText
                anchors.centerIn: parent
                text: osdRoot.flightMode.toUpperCase()
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }
    }

    // Lower Center Bar (Battery & GPS — placed safely above the bottom toolbar)
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        // Battery Info
        Rectangle {
            visible: showBattery
            width: battText.implicitWidth + 16
            height: battText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: battText
                anchors.centerIn: parent
                text: "BAT: " + (osdRoot.batteryVoltage > 0 ? osdRoot.batteryVoltage.toFixed(1) + "V" : "--") + 
                      (osdRoot.batteryPercent >= 0 ? " (" + osdRoot.batteryPercent.toFixed(0) + "%)" : "") +
                      (osdRoot.batteryCurrent > 0 ? " " + osdRoot.batteryCurrent.toFixed(1) + "A" : "")
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }

        // GPS Satellites
        Rectangle {
            visible: showGps
            width: gpsText.implicitWidth + 16
            height: gpsText.implicitHeight + 8
            color: "#66000000"
            radius: 4
            border.color: osdColor
            border.width: 1

            Text {
                id: gpsText
                anchors.centerIn: parent
                text: "SAT: " + osdRoot.satellites
                color: osdColor
                font.pointSize: osdFontSize
                font.bold: true
                style: Text.Outline; styleColor: "#000000"
            }
        }
    }
}
