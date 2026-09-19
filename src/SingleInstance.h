#pragma once

#include <QObject>

class QWinEventNotifier;

// Keeps the app to one copy per user session.
//
// The first copy owns a named mutex. A later copy sees the mutex already
// exists, signals a named event so the first copy brings its window up, and
// exits before it touches the hardware.
class SingleInstance : public QObject
{
    Q_OBJECT

public:
    // `key` names the mutex and the event; it must be the same for every copy.
    explicit SingleInstance(const QString &key, QObject *parent = nullptr);
    ~SingleInstance() override;

    bool isPrimary() const { return m_primary; }

    // Called in a second copy: asks the running one to show itself.
    void activatePrimary();

signals:
    // Emitted in the running copy when another one was started.
    void activationRequested();

private:
    bool m_primary = true;
    void *m_mutex = nullptr;
    void *m_event = nullptr;
    QWinEventNotifier *m_notifier = nullptr;
};
