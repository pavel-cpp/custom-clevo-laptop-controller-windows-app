#pragma once

#include <QObject>
#include <QString>

// Starting with Windows, through the per-user Run key. No administrator
// rights are needed and nothing outside the current user is touched.
// The entry always points at the executable that wrote it, so moving or
// reinstalling the app repairs itself on the next start.
class AutostartService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool supported READ supported CONSTANT)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)

public:
    explicit AutostartService(QObject *parent = nullptr);

    bool supported() const;
    bool enabled() const;

public slots:
    void setEnabled(bool enabled);

signals:
    void enabledChanged();

private:
    QString command() const;
};
