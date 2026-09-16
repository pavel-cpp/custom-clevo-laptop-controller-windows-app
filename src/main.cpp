#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>

#include "Theme.h"
#include "WinChrome.h"

int main(int argc, char *argv[])
{
    QQuickWindow::setDefaultAlphaBuffer(true);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Boran Software");
    app.setApplicationName("Control Center");
    app.setWindowIcon(QIcon(QStringLiteral(":/qt/qml/ControlCenter/resources/app_icon.svg")));

    WinChrome winChrome;
    Theme theme;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("WinChrome", &winChrome);
    engine.rootContext()->setContextProperty("Theme", &theme);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
        []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

    engine.loadFromModule("ControlCenter", "Main");

    return app.exec();
}
