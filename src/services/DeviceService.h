#pragma once

#include <clevo/Capabilities.hpp>
#include <clevo/Device.hpp>

#include <QObject>
#include <QString>
#include <QVariantList>

#include <optional>

class DeviceService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(QString errorMessage READ errorMessage CONSTANT)
    Q_PROPERTY(QString controllerVersion READ controllerVersion CONSTANT)
    Q_PROPERTY(int fanCount READ fanCount CONSTANT)
    // List of {name, supported}.
    Q_PROPERTY(QVariantList capabilities READ capabilities CONSTANT)

public:
    DeviceService(const std::optional<clevo::Device> &device, const std::optional<clevo::Capabilities> &capabilities,
                  QString openError, QObject *parent = nullptr);

    bool available() const { return m_system.has_value(); }
    QString errorMessage() const { return m_errorMessage; }
    QString controllerVersion() const { return m_controllerVersion; }
    int fanCount() const { return m_fanCount; }
    QVariantList capabilities() const { return m_capabilities; }

private:
    std::optional<clevo::SystemController> m_system;
    QString m_errorMessage;
    QString m_controllerVersion;
    int m_fanCount = 0;
    QVariantList m_capabilities;
};
