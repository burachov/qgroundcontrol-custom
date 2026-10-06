/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

#include "QGCPalette.h"
#include "QGCCorePlugin.h"

#include <QtCore/QDebug>

QList<QGCPalette*>   QGCPalette::_paletteObjects;

QGCPalette::Theme QGCPalette::_theme = QGCPalette::Dark;

QMap<int, QMap<int, QMap<QString, QColor>>> QGCPalette::_colorInfoMap;

QStringList QGCPalette::_colors;

QGCPalette::QGCPalette(QObject* parent) :
    QObject(parent),
    _colorGroupEnabled(true)
{
    if (_colorInfoMap.isEmpty()) {
        _buildMap();
    }

    // We have to keep track of all QGCPalette objects in the system so we can signal theme change to all of them
    _paletteObjects += this;
}

QGCPalette::~QGCPalette()
{
    bool fSuccess = _paletteObjects.removeOne(this);
    if (!fSuccess) {
        qWarning() << "Internal error";
    }
}

void QGCPalette::_buildMap()
{
    //                                             Light                 Dark                  RedBlack              MilitaryGreen
    //                                             Disabled   Enabled    Disabled   Enabled    Disabled   Enabled    Disabled   Enabled
    DECLARE_QGC_COLOR_THEMED(window,               "#ffffff", "#ffffff", "#222222", "#222222", "#0a0a0a", "#0a0a0a", "#0d140d", "#0d140d")
    DECLARE_QGC_COLOR_THEMED(windowShadeLight,     "#909090", "#828282", "#707070", "#626262", "#400808", "#330a0a", "#223322", "#1a2b1a")
    DECLARE_QGC_COLOR_THEMED(windowShade,          "#d9d9d9", "#d9d9d9", "#333333", "#333333", "#220505", "#1a0505", "#162216", "#121e12")
    DECLARE_QGC_COLOR_THEMED(windowShadeDark,      "#bdbdbd", "#bdbdbd", "#282828", "#282828", "#150202", "#120202", "#0f160f", "#0c150c")
    DECLARE_QGC_COLOR_THEMED(text,                 "#9d9d9d", "#000000", "#707070", "#ffffff", "#882222", "#ff3b30", "#1b5e20", "#39ff14")
    DECLARE_QGC_COLOR(warningText,                 "#cc0808", "#cc0808", "#f85761", "#f85761")
    DECLARE_QGC_COLOR_THEMED(button,               "#ffffff", "#ffffff", "#707070", "#626270", "#441010", "#250808", "#1d2e1d", "#162816")
    DECLARE_QGC_COLOR_THEMED(buttonBorder,         "#ffffff", "#d9d9d9", "#707070", "#adadb8", "#661515", "#ff2d55", "#244424", "#2ecc71")
    DECLARE_QGC_COLOR_THEMED(buttonText,           "#9d9d9d", "#000000", "#A6A6A6", "#ffffff", "#882222", "#ff453a", "#1b5e20", "#39ff14")
    DECLARE_QGC_COLOR_THEMED(buttonHighlight,      "#e4e4e4", "#946120", "#3a3a3a", "#fff291", "#330808", "#450c0c", "#142514", "#254525")
    DECLARE_QGC_COLOR_THEMED(buttonHighlightText,  "#2c2c2c", "#ffffff", "#2c2c2c", "#000000", "#2c2c2c", "#ffffff", "#2c2c2c", "#ffffff")
    DECLARE_QGC_COLOR_THEMED(primaryButton,        "#585858", "#8cb3be", "#585858", "#8cb3be", "#441010", "#b01c1c", "#1d3a1d", "#1e6b34")
    DECLARE_QGC_COLOR_THEMED(primaryButtonText,    "#2c2c2c", "#000000", "#2c2c2c", "#000000", "#2c2c2c", "#ffffff", "#2c2c2c", "#ffffff")
    DECLARE_QGC_COLOR_THEMED(textField,            "#ffffff", "#ffffff", "#707070", "#ffffff", "#441010", "#1a0505", "#1d2e1d", "#101e10")
    DECLARE_QGC_COLOR_THEMED(textFieldText,        "#808080", "#000000", "#000000", "#000000", "#882222", "#ff3b30", "#1b5e20", "#39ff14")
    DECLARE_QGC_COLOR(mapButton,                   "#585858", "#000000", "#585858", "#000000")
    DECLARE_QGC_COLOR(mapButtonHighlight,          "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicator,                "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_QGC_COLOR(mapIndicatorChild,           "#585858", "#766043", "#585858", "#766043")
    DECLARE_QGC_COLOR(colorGreen,                  "#008f2d", "#008f2d", "#00e04b", "#00e04b") 
    DECLARE_QGC_COLOR(colorYellow,                 "#a2a200", "#a2a200", "#ffff00", "#ffff00")  
    DECLARE_QGC_COLOR(colorYellowGreen,            "#799f26", "#799f26", "#9dbe2f", "#9dbe2f")  
    DECLARE_QGC_COLOR(colorOrange,                 "#bf7539", "#bf7539", "#de8500", "#de8500")  
    DECLARE_QGC_COLOR(colorRed,                    "#b52b2b", "#b52b2b", "#f32836", "#f32836")
    DECLARE_QGC_COLOR(colorGrey,                   "#808080", "#808080", "#bfbfbf", "#bfbfbf")
    DECLARE_QGC_COLOR(colorBlue,                   "#1a72ff", "#1a72ff", "#536dff", "#536dff")
    DECLARE_QGC_COLOR(alertBackground,             "#eecc44", "#eecc44", "#eecc44", "#eecc44")
    DECLARE_QGC_COLOR(alertBorder,                 "#808080", "#808080", "#808080", "#808080")
    DECLARE_QGC_COLOR(alertText,                   "#000000", "#000000", "#000000", "#000000")
    DECLARE_QGC_COLOR(missionItemEditor,           "#585858", "#dbfef8", "#585858", "#585d83")
    DECLARE_QGC_COLOR(toolStripHoverColor,         "#585858", "#9D9D9D", "#585858", "#585d83")
    DECLARE_QGC_COLOR(statusFailedText,            "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR(statusPassedText,            "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR(statusPendingText,           "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_QGC_COLOR_THEMED(toolbarBackground,    "#ffffff", "#ffffff", "#222222", "#222222", "#120303", "#0f0303", "#101a10", "#0e180e")
    DECLARE_QGC_COLOR(groupBorder,                 "#bbbbbb", "#bbbbbb", "#707070", "#707070")

    // Colors not affecting by theming
    //                                              Disabled    Enabled
    DECLARE_QGC_NONTHEMED_COLOR(brandingPurple,     "#4A2C6D", "#4A2C6D")
    DECLARE_QGC_NONTHEMED_COLOR(brandingBlue,       "#48D6FF", "#6045c5")
    DECLARE_QGC_NONTHEMED_COLOR(toolStripFGColor,   "#707070", "#ffffff")

    // Colors not affecting by theming or enable/disable
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderLight,          "#ffffff")
    DECLARE_QGC_SINGLE_COLOR(mapWidgetBorderDark,           "#000000")
    DECLARE_QGC_SINGLE_COLOR(mapMissionTrajectory,          "#be781c")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonInterior,         "green")
    DECLARE_QGC_SINGLE_COLOR(surveyPolygonTerrainCollision, "red")

// Colors for UTM Adapter
#ifdef QGC_UTM_ADAPTER
    DECLARE_QGC_COLOR(switchUTMSP,        "#b0e0e6", "#b0e0e6", "#b0e0e6", "#b0e0e6");
    DECLARE_QGC_COLOR(sliderUTMSP,        "#9370db", "#9370db", "#9370db", "#9370db");
    DECLARE_QGC_COLOR(successNotifyUTMSP, "#3cb371", "#3cb371", "#3cb371", "#3cb371");
#endif
}

void QGCPalette::setColorGroupEnabled(bool enabled)
{
    _colorGroupEnabled = enabled;
    emit paletteChanged();
}

void QGCPalette::setGlobalTheme(Theme newTheme)
{
    // Mobile build does not have themes
    if (_theme != newTheme) {
        _theme = newTheme;
        _signalPaletteChangeToAll();
    }
}

void QGCPalette::_signalPaletteChangeToAll()
{
    // Notify all objects of the new theme
    for (QGCPalette *palette : std::as_const(_paletteObjects)) {
        palette->_signalPaletteChanged();
    }
}

void QGCPalette::_signalPaletteChanged()
{
    emit paletteChanged();
}
