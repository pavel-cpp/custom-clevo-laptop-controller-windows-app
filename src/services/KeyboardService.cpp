#include "KeyboardService.h"

#include "ServiceSupport.h"

#include <QSettings>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

#include <array>
#include <chrono>
#include <utility>

namespace {

using namespace std::chrono_literals;

constexpr std::array<clevo::HardwareEffect, 7> hardwareEffects{
    clevo::HardwareEffect::Random, clevo::HardwareEffect::Breathing, clevo::HardwareEffect::Cycle,
    clevo::HardwareEffect::Wave,   clevo::HardwareEffect::Dance,     clevo::HardwareEffect::Tempo,
    clevo::HardwareEffect::Flash,
};

const int FirstSoftwareEffect = static_cast<int>(hardwareEffects.size());
const int SoftwareBreathing = FirstSoftwareEffect;
const int SoftwareColorCycle = FirstSoftwareEffect + 1;
const int SoftwareColorfulBreathing = FirstSoftwareEffect + 2;
const int EffectCount = FirstSoftwareEffect + 3;

constexpr auto CoalesceInterval = 40ms;
constexpr auto IdleCheckInterval = 500ms;
constexpr auto FadeDuration = 700ms;

// Firmware effects and the firmware sleep timer survive a reboot on their
// own. What the app runs itself has to be remembered here.
constexpr auto SoftwareEffectKey = "keyboard/softwareEffect";
constexpr auto SleepEnabledKey = "keyboard/sleepEnabled";
constexpr auto SleepSecondsKey = "keyboard/sleepSeconds";

clevo::Rgb toRgb(const QColor &color)
{
    return {services::toByte(color.red()), services::toByte(color.green()), services::toByte(color.blue())};
}

int indexOf(std::optional<clevo::HardwareEffect> effect)
{
    for (std::size_t i = 0; effect && i < hardwareEffects.size(); ++i) {
        if (hardwareEffects[i] == *effect)
            return static_cast<int>(i);
    }
    return -1;
}

// Software effects produce their own brightness curve; the user's brightness
// is its ceiling and the fade level dims the whole thing on the way to sleep.
clevo::SoftwareEffect scaled(clevo::SoftwareEffect effect, int brightness,
                             std::shared_ptr<std::atomic<int>> fadeLevel)
{
    return [effect = std::move(effect), brightness, fadeLevel = std::move(fadeLevel)](
               std::chrono::milliseconds elapsed) {
        clevo::LightFrame frame = effect(elapsed);
        const int level = fadeLevel->load(std::memory_order_relaxed);
        frame.brightness = static_cast<std::uint8_t>(frame.brightness * brightness / 255 * level / 255);
        return frame;
    };
}

// Seconds since the last keyboard or mouse input anywhere on the system.
int systemIdleSeconds()
{
#ifdef Q_OS_WIN
    LASTINPUTINFO info{sizeof(LASTINPUTINFO), 0};
    if (!GetLastInputInfo(&info))
        return 0;
    // Unsigned arithmetic, so the 49-day tick wrap takes care of itself.
    const DWORD idleMilliseconds = GetTickCount() - info.dwTime;
    return static_cast<int>(idleMilliseconds / 1000);
#else
    return 0;
#endif
}

} // namespace

KeyboardService::KeyboardService(const std::optional<clevo::Device> &device, QObject *parent)
    : QObject(parent)
{
    m_writeTimer.setSingleShot(true);
    m_writeTimer.setInterval(CoalesceInterval);
    connect(&m_writeTimer, &QTimer::timeout, this, &KeyboardService::flushWrites);

    m_idleTimer.setInterval(IdleCheckInterval);
    connect(&m_idleTimer, &QTimer::timeout, this, &KeyboardService::checkIdleTime);

    m_fadeAnimation.setDuration(static_cast<int>(FadeDuration.count()));
    connect(&m_fadeAnimation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        m_fadeLevel->store(value.toInt(), std::memory_order_relaxed);
    });
    connect(&m_fadeAnimation, &QVariantAnimation::finished, this, [this] {
        // Once dark, park the player on a constant frame so the driver is
        // left alone until the machine is used again.
        if (m_backlightAsleep && m_player)
            m_player->play([color = toRgb(m_color)](std::chrono::milliseconds) {
                return clevo::LightFrame{color, 0};
            });
    });

    if (!device)
        return;

    m_keyboard = device->keyboard();
    m_player = std::make_unique<clevo::EffectPlayer>(device->transport());

    const clevo::KeyboardState state = m_keyboard->state();
    m_enabled = state.enabled;
    m_color = QColor(state.color.r, state.color.g, state.color.b);
    m_brightness = state.brightness;
    m_bootEffect = state.bootEffect;
    m_activeEffect = indexOf(state.effect);
    m_sleepEnabled = state.sleepTimeout.has_value();
    m_sleepSeconds = state.sleepTimeout ? static_cast<int>(state.sleepTimeout->count()) : 0;
    m_firmwareTimerActive = m_sleepEnabled;

    const QSettings settings;
    const int lastSoftwareEffect = settings.value(SoftwareEffectKey, -1).toInt();
    if (isSoftwareEffect(lastSoftwareEffect)) {
        // The firmware timer was handed to the app last time, so the real
        // setting lives in the app's own storage.
        m_sleepEnabled = settings.value(SleepEnabledKey, m_sleepEnabled).toBool();
        m_sleepSeconds = settings.value(SleepSecondsKey, m_sleepSeconds).toInt();
        m_activeEffect = lastSoftwareEffect;
        setEnabled(true);
        startSoftwareEffect();
    }
}

KeyboardService::~KeyboardService()
{
    if (!m_keyboard)
        return;

    m_fadeAnimation.stop();
    m_idleTimer.stop();
    if (m_player)
        m_player->stop();

    // Leave the keyboard lit and the firmware timer back in charge.
    if (m_backlightAsleep)
        m_keyboard->setBrightness(services::toByte(m_brightness));
    setFirmwareTimer(m_sleepEnabled);
}

QStringList KeyboardService::effectNames() const
{
    return {
        tr("Random (Driver)"),
        tr("Breathing (Driver)"),
        tr("Cycle (Driver)"),
        tr("Wave (Driver)"),
        tr("Dance (Driver)"),
        tr("Tempo (Driver)"),
        tr("Flash (Driver)"),
        tr("Breathing (Software)"),
        tr("Color Cycle (Software)"),
        tr("Colorful Breathing (Software)"),
    };
}

int KeyboardService::maxSleepSeconds() const
{
    return static_cast<int>(clevo::KeyboardController::MaxSleepTimeout.count());
}

void KeyboardService::setEnabled(bool enabled)
{
    if (!m_keyboard || enabled == m_enabled)
        return;

    if (!enabled && isSoftwareEffect(m_activeEffect)) {
        stopSoftwareEffect();
        setActiveEffect(-1);
    }
    m_keyboard->setEnabled(enabled);
    m_enabled = enabled;
    emit enabledChanged();
}

void KeyboardService::setColor(const QColor &color)
{
    if (!m_keyboard || color == m_color)
        return;

    m_color = color;
    emit colorChanged();

    if (m_activeEffect == SoftwareBreathing) {
        m_restartPending = true;
    } else {
        // Picking a color means leaving any other effect for a static color.
        if (isSoftwareEffect(m_activeEffect))
            stopSoftwareEffect();
        setActiveEffect(-1);
        m_colorPending = true;
    }
    scheduleWrite();
}

void KeyboardService::setBrightness(int brightness)
{
    brightness = std::clamp(brightness, 0, 255);
    if (!m_keyboard || brightness == m_brightness)
        return;

    m_brightness = brightness;
    emit brightnessChanged();

    if (isSoftwareEffect(m_activeEffect))
        m_restartPending = true;
    else
        m_brightnessPending = true;
    scheduleWrite();
}

void KeyboardService::setBootEffect(bool enabled)
{
    if (!m_keyboard || enabled == m_bootEffect)
        return;

    m_keyboard->setBootEffectEnabled(enabled);
    m_bootEffect = enabled;
    emit bootEffectChanged();
}

void KeyboardService::applyEffect(int index)
{
    if (!m_keyboard || index < 0 || index >= EffectCount)
        return;

    if (!m_enabled)
        setEnabled(true);

    if (isSoftwareEffect(index)) {
        setActiveEffect(index);
        startSoftwareEffect();
        return;
    }

    stopSoftwareEffect();
    m_keyboard->setEffect(hardwareEffects[static_cast<std::size_t>(index)]);
    setActiveEffect(index);
}

void KeyboardService::clearEffect()
{
    if (!m_keyboard || m_activeEffect < 0)
        return;

    stopSoftwareEffect();
    setActiveEffect(-1);
    m_colorPending = true;
    m_brightnessPending = true;
    flushWrites();
}

QString KeyboardService::applySleepTimer(bool enabled, int seconds)
{
    if (!m_keyboard)
        return services::unavailableText();

    const bool turnOn = enabled && seconds > 0;
    if (turnOn && (seconds < 0 || seconds > maxSleepSeconds())) {
        return tr("Keyboard sleep timeout must be between 1 and %1 seconds").arg(maxSleepSeconds());
    }

    m_sleepEnabled = turnOn;
    if (turnOn)
        m_sleepSeconds = seconds;
    storeSleepSettings();

    if (isSoftwareEffect(m_activeEffect)) {
        // The app owns the timer while it animates the backlight.
        setFirmwareTimer(false);
        updateIdleWatch();
    } else {
        setFirmwareTimer(turnOn);
    }

    emit sleepTimerChanged();
    return {};
}

bool KeyboardService::isSoftwareEffect(int index) const
{
    return index >= FirstSoftwareEffect && index < EffectCount;
}

void KeyboardService::setActiveEffect(int index)
{
    if (index == m_activeEffect)
        return;
    m_activeEffect = index;
    QSettings().setValue(SoftwareEffectKey, isSoftwareEffect(index) ? index : -1);
    emit activeEffectChanged();
    emit sleepTimerChanged(); // sleepHandledByApp follows the effect
}

clevo::SoftwareEffect KeyboardService::currentSoftwareEffect() const
{
    if (m_activeEffect == SoftwareBreathing)
        return clevo::breathingEffect(toRgb(m_color), 3000ms);
    if (m_activeEffect == SoftwareColorCycle)
        return clevo::colorCycleEffect({}, 2000ms);
    if (m_activeEffect == SoftwareColorfulBreathing)
        return clevo::colorfulBreathingEffect({}, 3000ms);
    return {};
}

void KeyboardService::startSoftwareEffect()
{
    clevo::SoftwareEffect effect = currentSoftwareEffect();
    if (!effect)
        return;

    // The firmware timer would switch the backlight off underneath the
    // effect, which reads as flicker; the app dims it instead.
    setFirmwareTimer(false);

    m_fadeAnimation.stop();
    m_backlightAsleep = false;
    m_fadeLevel->store(255, std::memory_order_relaxed);
    m_player->play(scaled(std::move(effect), m_brightness, m_fadeLevel));

    updateIdleWatch();
    emit sleepTimerChanged();
}

void KeyboardService::stopSoftwareEffect()
{
    m_fadeAnimation.stop();
    m_idleTimer.stop();
    m_restartPending = false;

    if (m_player)
        m_player->stop();

    const bool wasAsleep = std::exchange(m_backlightAsleep, false);
    m_fadeLevel->store(255, std::memory_order_relaxed);
    if (wasAsleep && m_keyboard)
        m_keyboard->setBrightness(services::toByte(m_brightness));

    // Hand the sleep timer back to the firmware.
    setFirmwareTimer(m_sleepEnabled);
    emit sleepTimerChanged();
}

void KeyboardService::setFirmwareTimer(bool active)
{
    if (!m_keyboard)
        return;

    active = active && m_sleepSeconds > 0;
    if (active == m_firmwareTimerActive)
        return;

    const clevo::Status status = m_keyboard->setSleepTimeout(
        active ? std::optional<std::chrono::seconds>(m_sleepSeconds) : std::nullopt);
    if (status)
        m_firmwareTimerActive = active;
}

void KeyboardService::updateIdleWatch()
{
    const bool watching = isSoftwareEffect(m_activeEffect) && m_sleepEnabled && m_sleepSeconds > 0;
    if (watching) {
        m_idleTimer.start();
    } else {
        m_idleTimer.stop();
        if (m_backlightAsleep) {
            m_backlightAsleep = false;
            m_player->play(scaled(currentSoftwareEffect(), m_brightness, m_fadeLevel));
            fadeBacklight(255);
        }
    }
}

void KeyboardService::checkIdleTime()
{
    const int idleSeconds = systemIdleSeconds();

    if (!m_backlightAsleep && idleSeconds >= m_sleepSeconds) {
        m_backlightAsleep = true;
        fadeBacklight(0);
    } else if (m_backlightAsleep && idleSeconds < m_sleepSeconds) {
        m_backlightAsleep = false;
        // Restart the effect before fading it back in; it was parked on a
        // constant dark frame while asleep.
        m_fadeLevel->store(0, std::memory_order_relaxed);
        m_player->play(scaled(currentSoftwareEffect(), m_brightness, m_fadeLevel));
        fadeBacklight(255);
    }
}

void KeyboardService::fadeBacklight(int target)
{
    m_fadeAnimation.stop();
    m_fadeAnimation.setStartValue(m_fadeLevel->load(std::memory_order_relaxed));
    m_fadeAnimation.setEndValue(target);
    m_fadeAnimation.start();
}

void KeyboardService::storeSleepSettings() const
{
    QSettings settings;
    settings.setValue(SleepEnabledKey, m_sleepEnabled);
    settings.setValue(SleepSecondsKey, m_sleepSeconds);
}

void KeyboardService::scheduleWrite()
{
    if (!m_writeTimer.isActive())
        m_writeTimer.start();
}

void KeyboardService::flushWrites()
{
    if (!m_keyboard)
        return;

    if (m_restartPending && isSoftwareEffect(m_activeEffect))
        startSoftwareEffect();
    if (m_colorPending)
        m_keyboard->setColor(toRgb(m_color));
    if (m_brightnessPending)
        m_keyboard->setBrightness(services::toByte(m_brightness));

    m_restartPending = false;
    m_colorPending = false;
    m_brightnessPending = false;
}
