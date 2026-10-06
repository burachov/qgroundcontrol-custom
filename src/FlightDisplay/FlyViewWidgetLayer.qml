/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import QtLocation
import QtPositioning
import QtQuick.Window
import QtQml.Models

import QGroundControl
import QGroundControl.Controls
import QGroundControl.Controllers
import QGroundControl.Controls
import QGroundControl.FactSystem
import QGroundControl.FlightDisplay
import QGroundControl.FlightMap
import QGroundControl.Palette
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

// This is the ui overlay layer for the widgets/tools for Fly View
Item {
    id: _root

    property var    parentToolInsets
    property var    totalToolInsets:        _totalToolInsets
    property var    mapControl
    property bool   isViewer3DOpen:         false

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _planMasterController:  globals.planMasterControllerFlyView
    property var    _missionController:     _planMasterController.missionController
    property var    _geoFenceController:    _planMasterController.geoFenceController
    property var    _rallyPointController:  _planMasterController.rallyPointController
    property var    _guidedController:      globals.guidedControllerFlyView
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property alias  _gripperMenu:           gripperOptions
    property real   _layoutMargin:          ScreenTools.defaultFontPixelWidth * 0.75
    property bool   _layoutSpacing:         ScreenTools.defaultFontPixelWidth
    property bool   _showSingleVehicleUI:   true

    property bool utmspActTrigger

    QGCToolInsets {
        id:                     _totalToolInsets
        leftEdgeTopInset:       toolStrip.leftEdgeTopInset
        leftEdgeCenterInset:    toolStrip.leftEdgeCenterInset
        leftEdgeBottomInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.leftEdgeBottomInset : parentToolInsets.leftEdgeBottomInset
        rightEdgeTopInset:      topRightPanel.rightEdgeTopInset
        rightEdgeCenterInset:   topRightPanel.rightEdgeCenterInset
        rightEdgeBottomInset:   bottomRightRowLayout.rightEdgeBottomInset
        topEdgeLeftInset:       toolStrip.topEdgeLeftInset
        topEdgeCenterInset:     mapScale.topEdgeCenterInset
        topEdgeRightInset:      topRightPanel.topEdgeRightInset
        bottomEdgeLeftInset:    virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeLeftInset : parentToolInsets.bottomEdgeLeftInset
        bottomEdgeCenterInset:  bottomRightRowLayout.bottomEdgeCenterInset
        bottomEdgeRightInset:   virtualJoystickMultiTouch.visible ? virtualJoystickMultiTouch.bottomEdgeRightInset : bottomRightRowLayout.bottomEdgeRightInset
    }

    FlyViewTopRightPanel {
        id:                     topRightPanel
        anchors.top:            parent.top
        anchors.right:          parent.right
        anchors.topMargin:      ScreenTools.toolbarHeight + _layoutMargin
        anchors.rightMargin:    _layoutMargin
        maximumHeight:          parent.height - (bottomRightRowLayout.height + _margins * 5) - ScreenTools.toolbarHeight

        property real topEdgeRightInset:    height + _layoutMargin
        property real rightEdgeTopInset:    width + _layoutMargin
        property real rightEdgeCenterInset: rightEdgeTopInset
    }

    FlyViewTopRightColumnLayout {
        id:                 topRightColumnLayout
        anchors.margins:    _layoutMargin
        anchors.top:        parent.top
        anchors.topMargin:  ScreenTools.toolbarHeight + _layoutMargin
        anchors.right:      parent.right
        spacing:            _layoutSpacing
        visible:           !topRightPanel.visible

        property real topEdgeRightInset:    childrenRect.height + _layoutMargin
        property real rightEdgeTopInset:    width + _layoutMargin
        property real rightEdgeCenterInset: rightEdgeTopInset
    }

    Item {
        id:                 movableInstruments
        z:                  QGroundControl.zOrderWidgets
        width:              bottomRightRowLayout.width
        height:             bottomRightRowLayout.height + (isPinned ? 0 : dragHandleBar.height)

        property bool isPinned: QGroundControl.loadBoolGlobalSetting("Instruments_Pinned", false)
        property real savedX:   QGroundControl.loadDoubleGlobalSetting("Instruments_PosX", -1)
        property real savedY:   QGroundControl.loadDoubleGlobalSetting("Instruments_PosY", -1)

        x: (savedX >= 0 && savedX <= (parent.width - width)) ? savedX : (parent.width - width - _layoutMargin)
        y: (savedY >= 0 && savedY <= (parent.height - height)) ? savedY : (parent.height - height - _layoutMargin)

        property real bottomEdgeRightInset:     height + _layoutMargin
        property real bottomEdgeCenterInset:    bottomEdgeRightInset
        property real rightEdgeBottomInset:     width + _layoutMargin

        // Drag handle bar with Pin / Unpin and Edit buttons
        Rectangle {
            id:                 dragHandleBar
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.right:      parent.right
            height:             isPinned ? 0 : ScreenTools.defaultFontPixelHeight * 2
            visible:            !isPinned
            color:              "#DD1A1A1A"
            radius:             4
            border.color:       qgcPal.colorGreen
            border.width:       1
            z:                  2

            RowLayout {
                anchors.fill:       parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing:            6

                QGCLabel {
                    text:               qsTr("✥ DRAG")
                    font.bold:          true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    color:              qgcPal.colorGreen
                    Layout.fillWidth:   true
                }

                QGCButton {
                    text:               qsTr("⚙ Edit Values")
                    font.pointSize:     ScreenTools.smallFontPointSize * 0.9
                    Layout.preferredHeight: dragHandleBar.height - 8
                    onClicked: {
                        if (bottomRightRowLayout.telemetryValuesBar) {
                            var grid = bottomRightRowLayout.telemetryValuesBar.factValueGrid
                            grid.settingsUnlocked = !grid.settingsUnlocked
                        }
                    }
                }

                QGCButton {
                    text:               qsTr("📌 Pin")
                    font.pointSize:     ScreenTools.smallFontPointSize * 0.9
                    Layout.preferredHeight: dragHandleBar.height - 8
                    onClicked: {
                        movableInstruments.isPinned = true
                        QGroundControl.saveBoolGlobalSetting("Instruments_Pinned", true)
                    }
                }
            }

            MouseArea {
                id:                 dragArea
                anchors.fill:       parent
                drag.target:        movableInstruments
                drag.axis:          Drag.XAndYAxis
                drag.minimumX:      10
                drag.maximumX:      movableInstruments.parent ? (movableInstruments.parent.width - movableInstruments.width - 10) : 500
                drag.minimumY:      60
                drag.maximumY:      movableInstruments.parent ? (movableInstruments.parent.height - movableInstruments.height - 10) : 500
                onReleased: {
                    QGroundControl.saveDoubleGlobalSetting("Instruments_PosX", movableInstruments.x)
                    QGroundControl.saveDoubleGlobalSetting("Instruments_PosY", movableInstruments.y)
                }
            }
        }

        // Small toggle button when pinned so user can unpin at any time
        Rectangle {
            anchors.top:        parent.top
            anchors.right:      parent.right
            anchors.topMargin:  -ScreenTools.defaultFontPixelHeight * 0.5
            anchors.rightMargin: -ScreenTools.defaultFontPixelWidth * 0.5
            width:              ScreenTools.defaultFontPixelHeight * 1.6
            height:             width
            radius:             width / 2
            color:              "#CC222222"
            border.color:       qgcPal.button
            border.width:       1
            visible:            isPinned
            z:                  10

            QGCLabel {
                anchors.centerIn:   parent
                text:               "📌"
                font.pointSize:     ScreenTools.smallFontPointSize * 0.8
            }

            MouseArea {
                anchors.fill:   parent
                onClicked: {
                    movableInstruments.isPinned = false
                    QGroundControl.saveBoolGlobalSetting("Instruments_Pinned", false)
                }
            }
        }

        FlyViewBottomRightRowLayout {
            id:                 bottomRightRowLayout
            anchors.top:        isPinned ? parent.top : dragHandleBar.bottom
            anchors.left:       parent.left
            spacing:            _layoutSpacing
        }
    }

    // Missions disabled: mission complete dialog suppressed

    GuidedActionConfirm {
        anchors.margins:            _toolsMargin
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       _toolsMargin * 2
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        guidedValueSlider:          _guidedValueSlider
        utmspSliderTrigger:         utmspActTrigger
    }

    //-- Virtual Joystick
    Loader {
        id:                         virtualJoystickMultiTouch
        z:                          QGroundControl.zOrderTopMost + 1
        anchors.right:              parent.right
        anchors.rightMargin:        anchors.leftMargin
        height:                     Math.min(parent.height * 0.25, ScreenTools.defaultFontPixelWidth * 16)
        visible:                    _virtualJoystickEnabled && !QGroundControl.videoManager.fullScreen && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)
        anchors.bottom:             parent.bottom
        anchors.bottomMargin:       bottomLoaderMargin
        anchors.left:               parent.left   
        anchors.leftMargin:         ( y > toolStrip.y + toolStrip.height ? toolStrip.width / 2 : toolStrip.width * 1.05 + toolStrip.x) 
        source:                     "qrc:/qml/QGroundControl/FlightDisplay/VirtualJoystick.qml"
        active:                     _virtualJoystickEnabled && !(_activeVehicle ? _activeVehicle.usingHighLatencyLink : false)

        property real bottomEdgeLeftInset:     parent.height-y
        property bool autoCenterThrottle:      QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle.rawValue
        property bool leftHandedMode:          QGroundControl.settingsManager.appSettings.virtualJoystickLeftHandedMode.rawValue
        property bool _virtualJoystickEnabled: QGroundControl.settingsManager.appSettings.virtualJoystick.rawValue
        property real bottomEdgeRightInset:    parent.height-y
        property var  _pipViewMargin:          _pipView.visible ? parentToolInsets.bottomEdgeLeftInset + ScreenTools.defaultFontPixelHeight * 2 : 
                                               bottomRightRowLayout.height + ScreenTools.defaultFontPixelHeight * 1.5

        property var  bottomLoaderMargin:      _pipViewMargin >= parent.height / 2 ? parent.height / 2 : _pipViewMargin

        // Width is difficult to access directly hence this hack which may not work in all circumstances
        property real leftEdgeBottomInset:  visible ? bottomEdgeLeftInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rightEdgeBottomInset: visible ? bottomEdgeRightInset + width/18 - ScreenTools.defaultFontPixelHeight*2 : 0
        property real rootWidth:            _root.width
        property var  itemX:                virtualJoystickMultiTouch.x   // real X on screen

        onRootWidthChanged: virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth : undefined
        onItemXChanged:     virtualJoystickMultiTouch.status == Loader.Ready && visible ? virtualJoystickMultiTouch.item.uiRealX = itemX : undefined

        //Loader status logic
        onLoaded: {
            if (virtualJoystickMultiTouch.visible) {
                virtualJoystickMultiTouch.item.calibration = true 
                virtualJoystickMultiTouch.item.uiTotalWidth = rootWidth
                virtualJoystickMultiTouch.item.uiRealX = itemX
            } else {
                virtualJoystickMultiTouch.item.calibration = false
            }
        }
    }

    FlyViewToolStrip {
        id:                     toolStrip
        anchors.leftMargin:     _toolsMargin + parentToolInsets.leftEdgeCenterInset
        anchors.left:           parent.left
        anchors.verticalCenter: parent.verticalCenter
        z:                      QGroundControl.zOrderWidgets
        maxHeight:              parent.height - parentToolInsets.bottomEdgeLeftInset - (_toolsMargin * 2)
        visible:                !QGroundControl.videoManager.fullScreen

        onDisplayPreFlightChecklist: {
            if (!preFlightChecklistLoader.active) {
                preFlightChecklistLoader.active = true
            }
            preFlightChecklistLoader.item.open()
        }

        property real topEdgeLeftInset:     visible ? y + height : 0
        property real leftEdgeTopInset:     visible ? x + width : 0
        property real leftEdgeCenterInset:  leftEdgeTopInset
    }

    GripperMenu {
        id: gripperOptions
    }

    VehicleWarnings {
        anchors.centerIn:   parent
        z:                  QGroundControl.zOrderTopMost
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    _toolsMargin
        anchors.left:       toolStrip.right
        anchors.top:        parent.top
        mapControl:         _mapControl
        buttonsOnLeft:      true
        visible:            !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale && !isViewer3DOpen && mapControl.pipState.state === mapControl.pipState.fullState

        property real topEdgeCenterInset: visible ? y + height : 0
    }

    Loader {
        id: preFlightChecklistLoader
        sourceComponent: preFlightChecklistPopup
        active: false
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {
        }
    }
}
