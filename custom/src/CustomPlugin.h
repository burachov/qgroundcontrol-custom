#pragma once

#include <QtCore/QTranslator>
#include <QtQml/QQmlAbstractUrlInterceptor>

#include "QGCCorePlugin.h"
#include "QGCOptions.h"

class ComplexMissionItem;
class PlanCreator;

class CustomOptions;
class CustomPlugin;
class QQmlApplicationEngine;

Q_DECLARE_LOGGING_CATEGORY(CustomLog)

class CustomFlyViewOptions : public QGCFlyViewOptions
{
    Q_OBJECT

public:
    explicit CustomFlyViewOptions(CustomOptions *options, QObject *parent = nullptr);

    // Overrides from CustomFlyViewOptions

    /// Set to true to show standard instrument panel, or false if using a custom instrument widget
    bool showInstrumentPanel() const final { return true; }
    /// Support connecting multiple vehicles
    bool showMultiVehicleList() const final { return true; }
};

/*===========================================================================*/

class CustomOptions : public QGCOptions
{
    Q_OBJECT

public:
    explicit CustomOptions(CustomPlugin *plugin, QObject *parent = nullptr);

    // Overrides from QGCOptions

    /// Firmware upgrade page is only shown in Advanced Mode.
    bool showFirmwareUpgrade() const final { return _plugin->showAdvancedUI(); }
    QGCFlyViewOptions *flyViewOptions() const final { return _flyViewOptions; }

private:
    QGCCorePlugin *_plugin = nullptr;
    CustomFlyViewOptions *_flyViewOptions = nullptr;
};

/*===========================================================================*/

class CustomPlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    explicit CustomPlugin(QObject *parent = nullptr);

    static QGCCorePlugin *instance();

    // Overrides from QGCCorePlugin

    QGCOptions *options() final { return _options; }
    /// Disable first-run welcoming setup prompts
    bool showInitialSetupVehiclePreferences() const final { return false; }
    bool showInitialSetupMeasurementUnits() const final { return false; }
    QList<int> firstRunPromptStdIds() final { return {}; }
    /// This allows you to override/hide QGC Application settings
    void adjustSettingMetaData(const QString &settingsGroup, FactMetaData &metaData, bool &userVisible) final;
    /// This modifies QGC colors palette to match possible custom corporate branding
    void paletteOverride(const QString &colorName, QGCPalette::PaletteColorInfo_t &colorInfo) final;
    /// We override this so we can get access to QQmlApplicationEngine and use it to register our qml module
    QQmlApplicationEngine *createQmlApplicationEngine(QObject *parent) final;
    /// Releases the url interceptor attached in createQmlApplicationEngine before the engine is destroyed
    void destroyQmlApplicationEngine(QQmlApplicationEngine *qmlEngine) final;

    /// Adds the Perimeter Scan item to the complex-item menu.
    QVariantList complexMissionItemNames(Vehicle *vehicle) final;
    /// Factory: creates PerimeterScanComplexItem for our custom type, falls back to base for built-ins.
    ComplexMissionItem *createComplexMissionItem(const QString &complexItemType,
                                                 PlanMasterController *masterController,
                                                 bool flyView,
                                                 const QString &kmlOrShpFile = QString()) final;
    /// Adds the Perimeter Scan plan creator to the New Plan dialog.
    QList<PlanCreator *> planCreators(PlanMasterController *planMasterController) final;
    /// Registers the CustomSettings group so the generated Custom settings page can access it.
    void registerCustomSettings(SettingsManager *settingsManager) final;

private slots:
    void _advancedChanged(bool advanced);

private:
    CustomOptions *_options = nullptr;
    QQmlApplicationEngine *_qmlEngine = nullptr;
    class CustomOverrideInterceptor *_urlInterceptor = nullptr;
};

/*===========================================================================*/

class CustomOverrideInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    CustomOverrideInterceptor();

    QUrl intercept(const QUrl &url, QQmlAbstractUrlInterceptor::DataType type) final;
};
