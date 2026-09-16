#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include <clevo/Device.hpp>

#include "Theme.h"
#include "WinChrome.h"
#include "services/DeviceService.h"
#include "services/FanService.h"
#include "services/KeyboardService.h"
#include "services/PowerService.h"

#include <optional>

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Boran Software");
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
    Theme theme;
    DeviceService deviceService(device, capabilities, openError);
    PowerService powerService(device);
    KeyboardService keyboardService(device);
    FanService fanService(device, capabilities);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    context->setContextProperty("WinChrome", &winChrome);
    context->setContextProperty("Theme", &theme);
    context->setContextProperty("DeviceService", &deviceService);
    context->setContextProperty("PowerService", &powerService);
    context->setContextProperty("KeyboardService", &keyboardService);
    context->setContextProperty("FanService", &fanService);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ControlCenter", "Main");

    return app.exec();
}
