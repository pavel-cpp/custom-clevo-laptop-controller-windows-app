#include "KeyboardService.h"

#include "ServiceSupport.h"

#include <array>
#include <chrono>

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

// Software effects produce their own brightness curve; keep the user's
// brightness as its ceiling.
clevo::SoftwareEffect scaledTo(clevo::SoftwareEffect effect, int brightness)
{
    return [effect = std::move(effect), brightness](std::chrono::milliseconds elapsed) {
        clevo::LightFrame frame = effect(elapsed);
        frame.brightness = static_cast<std::uint8_t>(frame.brightness * brightness / 255);
        return frame;
    };
}

} // namespace

KeyboardService::KeyboardService(const std::optional<clevo::Device> &device, QObject *parent)
    : QObject(parent)
{
    m_writeTimer.setSingleShot(true);
    m_writeTimer.setInterval(CoalesceInterval);
    connect(&m_writeTimer, &QTimer::timeout, this, &KeyboardService::flushWrites);

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
}

KeyboardService::~KeyboardService()
{
    // Give the keyboard its sleep timer back before the app exits.
    if (m_player)
        m_player->stop();
    restoreSleepTimer();
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
    if (turnOn && isSoftwareEffect(m_activeEffect)) {
        // The timer switches the backlight off while the effect keeps
        // writing frames, which makes the keyboard flicker. Only one of the
        // two can be active.
        m_suspendedSleep.reset();
        stopSoftwareEffect();
        setActiveEffect(-1);
        m_colorPending = true;
        m_brightnessPending = true;
        flushWrites();
    }

    const clevo::Status status = m_keyboard->setSleepTimeout(
        turnOn ? std::optional<std::chrono::seconds>(seconds) : std::nullopt);
    if (!status)
        return services::errorText(status.error());

    m_sleepEnabled = turnOn;
    if (turnOn)
        m_sleepSeconds = seconds;
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
    emit activeEffectChanged();
}

void KeyboardService::startSoftwareEffect()
{
    suspendSleepTimer();

    clevo::SoftwareEffect effect;
    if (m_activeEffect == SoftwareBreathing)
        effect = clevo::breathingEffect(toRgb(m_color), 3000ms);
    else if (m_activeEffect == SoftwareColorCycle)
        effect = clevo::colorCycleEffect({}, 2000ms);
    else if (m_activeEffect == SoftwareColorfulBreathing)
        effect = clevo::colorfulBreathingEffect({}, 3000ms);
    else
        return;

    m_player->play(scaledTo(std::move(effect), m_brightness));
}

void KeyboardService::stopSoftwareEffect()
{
    if (m_player)
        m_player->stop();
    m_restartPending = false;
    restoreSleepTimer();
}

void KeyboardService::suspendSleepTimer()
{
    if (!m_sleepEnabled || m_suspendedSleep)
        return;

    m_suspendedSleep = std::chrono::seconds(m_sleepSeconds);
    m_keyboard->setSleepTimeout(std::nullopt);
    m_sleepEnabled = false;
    emit sleepTimerChanged();
}

void KeyboardService::restoreSleepTimer()
{
    if (!m_suspendedSleep)
        return;

    const auto timeout = *m_suspendedSleep;
    m_suspendedSleep.reset();
    if (m_keyboard->setSleepTimeout(timeout)) {
        m_sleepEnabled = true;
        m_sleepSeconds = static_cast<int>(timeout.count());
    }
    emit sleepTimerChanged();
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
