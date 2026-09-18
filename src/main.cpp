#include <QApplication>
#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include <clevo/Device.hpp>

#include "Theme.h"
#include "TrayController.h"
#include "WinChrome.h"
#include "services/DeviceService.h"
#include "services/FanService.h"
#include "services/KeyboardService.h"
#include "services/PowerService.h"

#include <optional>

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    // QApplication rather than QGuiApplication: the tray icon lives in Qt Widgets.
    QApplication app(argc, argv);
    app.setOrganizationName("Pavel Remdenok");
    app.setApplicationName("Control Center");
    app.setWindowIcon(QIcon(QStringLiteral(":/qt/qml/ControlCenter/resources/app_icon.svg")));

    QCommandLineParser parser;
    parser.setApplicationDescription(QCoreApplication::translate("main", "Clevo laptop control center"));
    parser.addHelpOption();
    const QCommandLineOption trayOption({QStringLiteral("t"), QStringLiteral("tray")},
                                        QCoreApplication::translate("main", "Start hidden in the notification area."));
    parser.addOption(trayOption);
    parser.process(app);

    // Without the driver the UI still starts; every service reports itself
    // unavailable and ignores requests.
    std::optional<clevo::Device> device;
    std::optional<clevo::Capabilities> capabilities;
    QString openError;
    if (auto opened = clevo::Device::open()) {
        device = std::move(*opened);
        capabilities = device->capabilities();
    } else {
        openError = QString::fromStdString(opened.error().message);
    }

    WinChrome winChrome;
    app.installNativeEventFilter(&winChrome);

    Theme theme;
    DeviceService deviceService(device, capabilities, openError);
    PowerService powerService(device);
    KeyboardService keyboardService(device);
    FanService fanService(device, capabilities);

    TrayController tray(&powerService, parser.isSet(trayOption));
    // With a tray icon, closing the window only hides it.
    app.setQuitOnLastWindowClosed(!tray.available());

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("WinChrome", &winChrome);
    context->setContextProperty("Theme", &theme);
    context->setContextProperty("Tray", &tray);
    context->setContextProperty("DeviceService", &deviceService);
    context->setContextProperty("PowerService", &powerService);
    context->setContextProperty("KeyboardService", &keyboardService);
    context->setContextProperty("FanService", &fanService);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ControlCenter", "Main");

    if (!engine.rootObjects().isEmpty())
        tray.setWindow(qobject_cast<QWindow *>(engine.rootObjects().constFirst()));

    return app.exec();
}
