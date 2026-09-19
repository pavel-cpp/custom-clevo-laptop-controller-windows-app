#pragma once

#include <QAbstractNativeEventFilter>
#include <QList>
#include <QObject>
#include <QQuickWindow>

// Native Windows 11 chrome for a frameless QQuickWindow: dark immersive mode,
// rounded corners, acrylic blur, and a real resizable frame so Aero Snap,
// maximize-by-drag and window animations work. The frame's non-client area
// is removed again in WM_NCCALCSIZE, so the QML content still fills the
// whole window. No-op on non-Windows platforms.
class WinChrome : public QObject, public QAbstractNativeEventFilter
{
    Q_OBJECT
public:
    explicit WinChrome(QObject *parent = nullptr);

    Q_INVOKABLE void attach(QQuickWindow *window);

    // A maximized window keeps its invisible sizing frame outside the monitor
    // edges; content must be inset by this many logical pixels to stay visible.
    Q_INVOKABLE qreal maximizedInset(QQuickWindow *window) const;

    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

private:
    void applyFrameStyle(QQuickWindow *window) const;

    QList<QQuickWindow *> m_windows;
};
