#pragma once

#include <QActionGroup>
#include <QMenu>
#include <QObject>
#include <QPointer>
#include <QSystemTrayIcon>
#include <QWindow>

class PowerService;

// Notification-area icon that keeps the app reachable while its window is
// hidden: reopen it, switch the power profile, or quit.
class TrayController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)

public:
    explicit TrayController(PowerService *power, QObject *parent = nullptr);

    bool available() const { return m_available; }
    void setWindow(QWindow *window);

public slots:
    void showWindow();
    // Tells the user once per session where the window went.
    void notifyHidden();

private:
    void syncProfileChecks();

    PowerService *m_power;
    bool m_available;
    bool m_hiddenNoticeShown = false;
    QPointer<QWindow> m_window;
    QActionGroup m_profiles{nullptr};
    // Declared before the icon, which must be destroyed first.
    QMenu m_menu;
    QSystemTrayIcon m_icon;
};
