#include "TrayController.h"

#include "services/PowerService.h"

#include <QApplication>
#include <QIcon>

TrayController::TrayController(PowerService *power, bool startHidden, QObject *parent)
    : QObject(parent)
    , m_power(power)
    , m_available(QSystemTrayIcon::isSystemTrayAvailable())
    , m_startHidden(startHidden)
{
    if (!m_available)
        return;

    m_menu.addAction(tr("Open Control Center"), this, &TrayController::showWindow);

    QMenu *profileMenu = m_menu.addMenu(tr("Power Profile"));
    profileMenu->setEnabled(m_power->available());
    // Same order as the cards on the Performance Modes page.
    const QStringList profileNames{tr("Silent Mode"), tr("Power Saver"), tr("Entertainment Mode"),
                                   tr("Full Performance")};
    for (int index = 0; index < profileNames.size(); ++index) {
        QAction *action = profileMenu->addAction(profileNames[index]);
        action->setCheckable(true);
        m_profiles.addAction(action);
        connect(action, &QAction::triggered, this, [this, index] { m_power->setProfile(index); });
    }
    connect(m_power, &PowerService::profileChanged, this, &TrayController::syncProfileChecks);
    syncProfileChecks();

    m_menu.addSeparator();
    m_menu.addAction(tr("Quit"), qApp, &QCoreApplication::quit);

    m_icon.setIcon(QApplication::windowIcon());
    m_icon.setToolTip(QApplication::applicationName());
    m_icon.setContextMenu(&m_menu);
    connect(&m_icon, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick)
            showWindow();
    });
    m_icon.show();
}

void TrayController::setWindow(QWindow *window)
{
    m_window = window;
}

void TrayController::showWindow()
{
    if (!m_window)
        return;

    m_window->setWindowStates(m_window->windowStates() & ~Qt::WindowMinimized);
    m_window->setVisible(true);
    m_window->raise();
    m_window->requestActivate();
}

void TrayController::syncProfileChecks()
{
    const QList<QAction *> actions = m_profiles.actions();
    const int current = m_power->profile();
    for (int index = 0; index < actions.size(); ++index)
        actions[index]->setChecked(index == current);
}
