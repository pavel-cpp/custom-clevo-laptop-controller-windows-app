#pragma once

#include <QObject>
#include <QQuickWindow>

// Applies native Windows 11 window chrome (dark immersive titlebar, rounded
// corners, DWM Acrylic system backdrop) to a frameless QQuickWindow so the
// translucent panel drawn in QML is actually blurring the desktop behind it.
// No-op on non-Windows platforms.
class WinChrome : public QObject
{
    Q_OBJECT
public:
    explicit WinChrome(QObject *parent = nullptr);

    Q_INVOKABLE void applyAcrylicEffect(QQuickWindow *window);
};
