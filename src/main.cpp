#include <QApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include <clevo/Device.hpp>

#include "HotkeyController.h"
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

    HotkeyController hotkeys;
    app.installNativeEventFilter(&hotkeys);
    QObject::connect(&hotkeys, &HotkeyController::displayOffRequested, &deviceService,
                     &DeviceService::turnDisplayOff);

    TrayController tray(&powerService);
    // With a tray icon, closing the window only hides it.
    app.setQuitOnLastWindowClosed(!tray.available());

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("WinChrome", &winChrome);
    context->setContextProperty("Theme", &theme);
    context->setContextProperty("Tray", &tray);
    context->setContextProperty("Hotkeys", &hotkeys);
    context->setContextProperty("DeviceService", &deviceService);
    context->setContextProperty("PowerService", &powerService);
    context->setContextProperty("KeyboardService", &keyboardService);
    context->setContextProperty("FanService", &fanService);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ControlCenter", "Main");

    if (!engine.rootObjects().isEmpty()) {
        auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst());
        tray.setWindow(window);
        hotkeys.registerShortcuts(window);
    }

    return app.exec();
}
