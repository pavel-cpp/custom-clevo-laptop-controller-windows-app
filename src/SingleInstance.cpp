#include "SingleInstance.h"

#ifdef Q_OS_WIN
#include <QWinEventNotifier>

#include <windows.h>

#include <string>
#endif

SingleInstance::SingleInstance(const QString &key, QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN
    // Unprefixed names live in the session's Local\ namespace: one copy per
    // signed-in user, and no special rights needed to create them.
    const std::wstring mutexName = (key + QStringLiteral(".Instance")).toStdWString();
    const std::wstring eventName = (key + QStringLiteral(".Activate")).toStdWString();

    m_mutex = CreateMutexW(nullptr, FALSE, mutexName.c_str());
    // If the mutex cannot be created at all, rather run twice than not at all.
    m_primary = !m_mutex || GetLastError() != ERROR_ALREADY_EXISTS;

    // Auto-reset, so each signal from a second copy is delivered once.
    m_event = CreateEventW(nullptr, FALSE, FALSE, eventName.c_str());
    if (m_primary && m_event) {
        m_notifier = new QWinEventNotifier(m_event, this);
        connect(m_notifier, &QWinEventNotifier::activated, this, &SingleInstance::activationRequested);
    }
#else
    Q_UNUSED(key);
#endif
}

SingleInstance::~SingleInstance()
{
#ifdef Q_OS_WIN
    delete m_notifier;
    if (m_event)
        CloseHandle(m_event);
    if (m_mutex)
        CloseHandle(m_mutex);
#endif
}

void SingleInstance::activatePrimary()
{
#ifdef Q_OS_WIN
    if (!m_event)
        return;
    // This copy was just started by the user, so it may hand the foreground
    // over; without that Windows would only flash the other copy's taskbar
    // button instead of raising its window.
    AllowSetForegroundWindow(ASFW_ANY);
    SetEvent(m_event);
#endif
}
