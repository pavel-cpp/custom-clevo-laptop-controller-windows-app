#include "FanService.h"

#include "ServiceSupport.h"

#include <QVariantMap>

namespace {

constexpr int AutomaticCard = 0;
constexpr int MaximumCard = 1;
constexpr int MaxQCard = 2;
constexpr int DustCleaningCard = 3;
constexpr int CustomCard = 4;

int cardOf(std::optional<clevo::FanMode> mode)
{
    if (!mode)
        return -1;
    switch (*mode) {
    case clevo::FanMode::Automatic:
        return AutomaticCard;
    case clevo::FanMode::Maximum:
        return MaximumCard;
    case clevo::FanMode::MaxQ:
        return MaxQCard;
    case clevo::FanMode::Custom:
        return CustomCard;
    }
    return -1;
}

QVariantMap toVariant(clevo::FanPoint point)
{
    // Plain ints: QML would see std::uint8_t as a character.
    return {{QStringLiteral("t"), static_cast<int>(point.temperature)},
            {QStringLiteral("f"), static_cast<int>(point.duty)}};
}

QVariantList toVariant(const clevo::FanCurve &curve)
{
    return {toVariant(curve.base), toVariant(curve.lower), toVariant(curve.upper),
            toVariant(clevo::FanCurve::ceiling)};
}

clevo::FanPoint pointFrom(const QVariant &value)
{
    const QVariantMap map = value.toMap();
    return {services::toByte(map.value(QStringLiteral("t")).toInt()),
            services::toByte(map.value(QStringLiteral("f")).toInt())};
}

std::optional<clevo::FanCurve> curveFrom(const QVariantList &points)
{
    if (points.size() < 3)
        return std::nullopt;
    return clevo::FanCurve{pointFrom(points[0]), pointFrom(points[1]), pointFrom(points[2])};
}

} // namespace

FanService::FanService(const std::optional<clevo::Device> &device,
                       const std::optional<clevo::Capabilities> &capabilities, QObject *parent)
    : QObject(parent)
{
    m_telemetryTimer.setInterval(1000);
    connect(&m_telemetryTimer, &QTimer::timeout, this, &FanService::refreshTelemetry);

    if (capabilities) {
        m_supportsMaxQ = capabilities->maxQ;
        m_supportsDustCleaning = capabilities->dustCleaning;
        m_supportsCustomCurves = capabilities->customFanCurves;
        m_supportsOffset = capabilities->fanOffset;
    }

    if (!device)
        return;

    m_fans = device->fans();
    m_mode = cardOf(m_fans->mode());
    m_offset = m_fans->offsetPercent();
    reloadCurves();
    refreshTelemetry();
}

void FanService::setTelemetryActive(bool active)
{
    if (!m_fans || active == telemetryActive())
        return;

    if (active) {
        refreshTelemetry();
        m_telemetryTimer.start();
    } else {
        m_telemetryTimer.stop();
    }
    emit telemetryActiveChanged();
}

QString FanService::applyMode(int index, const QVariantList &cpuCurve, const QVariantList &gpuCurve)
{
    if (!m_fans)
        return services::unavailableText();

    switch (index) {
    case AutomaticCard:
        m_fans->setMode(clevo::FanMode::Automatic);
        break;
    case MaximumCard:
        m_fans->setMode(clevo::FanMode::Maximum);
        break;
    case MaxQCard:
        m_fans->setMode(clevo::FanMode::MaxQ);
        break;
    case DustCleaningCard:
        m_fans->startDustCleaning();
        return {};
    case CustomCard: {
        const auto cpu = curveFrom(cpuCurve);
        const auto gpu = curveFrom(gpuCurve);
        if (!cpu || !gpu)
            return tr("Both fan curves need four points.");
        if (const clevo::Status status = m_fans->applyCustomCurves(*cpu, *gpu); !status)
            return services::errorText(status.error());
        reloadCurves();
        break;
    }
    default:
        return tr("Unknown fan mode.");
    }

    if (m_mode != index) {
        m_mode = index;
        emit modeChanged();
    }
    return {};
}

QString FanService::setOffset(int percent)
{
    if (!m_fans)
        return services::unavailableText();
    if (percent == m_offset)
        return {};

    if (const clevo::Status status = m_fans->setOffsetPercent(services::toByte(percent)); !status)
        return services::errorText(status.error());

    m_offset = percent;
    emit offsetChanged();
    return {};
}

QVariantList FanService::defaultCurve(bool gpu) const
{
    if (!m_fans)
        return {};
    return toVariant(m_fans->defaultCurve(gpu ? clevo::FanId::Gpu : clevo::FanId::Cpu));
}

void FanService::refreshTelemetry()
{
    m_telemetry = m_fans->telemetry();
    emit telemetryChanged();
}

void FanService::reloadCurves()
{
    m_cpuCurve = toVariant(m_fans->curve(clevo::FanId::Cpu));
    m_gpuCurve = toVariant(m_fans->curve(clevo::FanId::Gpu));
    emit curvesChanged();
}
