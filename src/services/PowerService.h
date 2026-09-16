#pragma once

#include <clevo/Device.hpp>

#include <QObject>

#include <optional>

// Performance profiles. Exposed to QML by card index:
// 0 Silent, 1 Power Saver, 2 Entertainment, 3 Full Performance; -1 unknown.
class PowerService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(int profile READ profile NOTIFY profileChanged)

public:
    explicit PowerService(const std::optional<clevo::Device> &device, QObject *parent = nullptr);

    bool available() const { return m_power.has_value(); }
    int profile() const { return m_profile; }

    Q_INVOKABLE void setProfile(int index);

signals:
    void profileChanged();

private:
    std::optional<clevo::PowerController> m_power;
    int m_profile = -1;
};
