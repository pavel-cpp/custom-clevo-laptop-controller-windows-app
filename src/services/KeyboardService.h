#pragma once

#include <clevo/Device.hpp>
#include <clevo/LightingEffects.hpp>

#include <QColor>
#include <QObject>
#include <QStringList>
#include <QTimer>

#include <memory>
#include <optional>

// Keyboard backlight. Effects are addressed by their index in `effectNames`:
// the firmware effects come first, followed by the software ones the app
// animates itself.
class KeyboardService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(QColor color READ color NOTIFY colorChanged)
    Q_PROPERTY(int brightness READ brightness NOTIFY brightnessChanged)
    Q_PROPERTY(bool bootEffect READ bootEffect NOTIFY bootEffectChanged)
    Q_PROPERTY(QStringList effectNames READ effectNames CONSTANT)
    Q_PROPERTY(int activeEffect READ activeEffect NOTIFY activeEffectChanged)
    Q_PROPERTY(bool sleepEnabled READ sleepEnabled NOTIFY sleepTimerChanged)
    Q_PROPERTY(int sleepSeconds READ sleepSeconds NOTIFY sleepTimerChanged)
    Q_PROPERTY(bool sleepSuspended READ sleepSuspended NOTIFY sleepTimerChanged)
    Q_PROPERTY(int maxSleepSeconds READ maxSleepSeconds CONSTANT)

public:
    explicit KeyboardService(const std::optional<clevo::Device> &device, QObject *parent = nullptr);
    ~KeyboardService() override;

    bool available() const { return m_keyboard.has_value(); }
    bool enabled() const { return m_enabled; }
    QColor color() const { return m_color; }
    int brightness() const { return m_brightness; }
    bool bootEffect() const { return m_bootEffect; }
    QStringList effectNames() const;
    int activeEffect() const { return m_activeEffect; }
    bool sleepEnabled() const { return m_sleepEnabled; }
    int sleepSeconds() const { return m_sleepSeconds; }
    // True while a software effect holds the sleep timer off.
    bool sleepSuspended() const { return m_suspendedSleep.has_value(); }
    int maxSleepSeconds() const;

public slots:
    void setEnabled(bool enabled);
    // Color and brightness follow sliders, so writes are coalesced.
    void setColor(const QColor &color);
    void setBrightness(int brightness);
    void setBootEffect(bool enabled);

    void applyEffect(int index);
    // Stops any effect and returns to the static color.
    void clearEffect();

    // Returns an error message, or an empty string on success.
    QString applySleepTimer(bool enabled, int seconds);

signals:
    void enabledChanged();
    void colorChanged();
    void brightnessChanged();
    void bootEffectChanged();
    void activeEffectChanged();
    void sleepTimerChanged();

private:
    bool isSoftwareEffect(int index) const;
    void setActiveEffect(int index);
    void startSoftwareEffect();
    void stopSoftwareEffect();
    void suspendSleepTimer();
    void restoreSleepTimer();
    void scheduleWrite();
    void flushWrites();

    std::optional<clevo::KeyboardController> m_keyboard;
    std::unique_ptr<clevo::EffectPlayer> m_player;
    QTimer m_writeTimer;

    bool m_enabled = false;
    QColor m_color = Qt::white;
    int m_brightness = 0;
    bool m_bootEffect = false;
    int m_activeEffect = -1;
    bool m_sleepEnabled = false;
    int m_sleepSeconds = 0;
    std::optional<std::chrono::seconds> m_suspendedSleep;

    bool m_colorPending = false;
    bool m_brightnessPending = false;
    bool m_restartPending = false;
};
