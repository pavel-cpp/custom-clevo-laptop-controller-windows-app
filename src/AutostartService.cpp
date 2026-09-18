#include "AutostartService.h"

#include <QCoreApplication>
#include <QDir>
#include <QSettings>

namespace {

constexpr auto RunKey = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr auto EntryName = "ControlCenter";

QSettings runKeySettings()
{
    return QSettings(QString::fromLatin1(RunKey), QSettings::NativeFormat);
}

} // namespace

AutostartService::AutostartService(QObject *parent)
    : QObject(parent)
{
    if (!supported())
        return;

    // Repair the entry if the executable has been moved or reinstalled.
    QSettings settings = runKeySettings();
    const QString stored = settings.value(QString::fromLatin1(EntryName)).toString();
    if (!stored.isEmpty() && stored != command())
        settings.setValue(QString::fromLatin1(EntryName), command());
}

bool AutostartService::supported() const
{
#ifdef Q_OS_WIN
    return true;
#else
    return false;
#endif
}

bool AutostartService::enabled() const
{
    if (!supported())
        return false;
    return !runKeySettings().value(QString::fromLatin1(EntryName)).toString().isEmpty();
}

void AutostartService::setEnabled(bool enabled)
{
    if (!supported() || enabled == this->enabled())
        return;

    QSettings settings = runKeySettings();
    if (enabled)
        settings.setValue(QString::fromLatin1(EntryName), command());
    else
        settings.remove(QString::fromLatin1(EntryName));
    settings.sync();

    emit enabledChanged();
}

QString AutostartService::command() const
{
    // Quoted because the install path may contain spaces; --tray keeps the
    // window closed on login.
    return QStringLiteral("\"%1\" --tray")
        .arg(QDir::toNativeSeparators(QCoreApplication::applicationFilePath()));
}
