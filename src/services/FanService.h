#pragma once

#include <clevo/Capabilities.hpp>
#include <clevo/Device.hpp>

#include <QObject>
#include <QTimer>
#include <QVariantList>

#include <optional>

// Fan modes are exposed by card index: 0 Automatic, 1 Maximum, 2 MaxQ,
// 3 Anti-Dust (a one-shot action, never the current mode), 4 Custom.
// Curves are lists of four {t, f} points; the first comes from the firmware
// and the last is always {100, 100}.
class FanService : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(int mode READ mode NOTIFY modeChanged)
    Q_PROPERTY(int offset READ offset NOTIFY offsetChanged)
    Q_PROPERTY(QVariantList cpuCurve READ cpuCurve NOTIFY curvesChanged)
    Q_PROPERTY(QVariantList gpuCurve READ gpuCurve NOTIFY curvesChanged)

    Q_PROPERTY(bool supportsMaxQ READ supportsMaxQ CONSTANT)
    Q_PROPERTY(bool supportsDustCleaning READ supportsDustCleaning CONSTANT)
    Q_PROPERTY(bool supportsCustomCurves READ supportsCustomCurves CONSTANT)
    Q_PROPERTY(bool supportsOffset READ supportsOffset CONSTANT)

    Q_PROPERTY(bool telemetryActive READ telemetryActive WRITE setTelemetryActive NOTIFY telemetryActiveChanged)
    Q_PROPERTY(int cpuRpm READ cpuRpm NOTIFY telemetryChanged)
    Q_PROPERTY(int cpuDuty READ cpuDuty NOTIFY telemetryChanged)
    Q_PROPERTY(int cpuTemperature READ cpuTemperature NOTIFY telemetryChanged)
    Q_PROPERTY(int gpuRpm READ gpuRpm NOTIFY telemetryChanged)
    Q_PROPERTY(int gpuDuty READ gpuDuty NOTIFY telemetryChanged)
    Q_PROPERTY(int gpuTemperature READ gpuTemperature NOTIFY telemetryChanged)

public:
    FanService(const std::optional<clevo::Device> &device, const std::optional<clevo::Capabilities> &capabilities,
               QObject *parent = nullptr);

    bool available() const { return m_fans.has_value(); }
    int mode() const { return m_mode; }
    int offset() const { return m_offset; }
    QVariantList cpuCurve() const { return m_cpuCurve; }
    QVariantList gpuCurve() const { return m_gpuCurve; }

    bool supportsMaxQ() const { return m_supportsMaxQ; }
    bool supportsDustCleaning() const { return m_supportsDustCleaning; }
    bool supportsCustomCurves() const { return m_supportsCustomCurves; }
    bool supportsOffset() const { return m_supportsOffset; }

    bool telemetryActive() const { return m_telemetryTimer.isActive(); }
    void setTelemetryActive(bool active);

    int cpuRpm() const { return static_cast<int>(m_telemetry.cpu.rpm); }
    int cpuDuty() const { return m_telemetry.cpu.dutyPercent; }
    int cpuTemperature() const { return m_telemetry.cpu.temperatureCelsius; }
    int gpuRpm() const { return static_cast<int>(m_telemetry.gpu.rpm); }
    int gpuDuty() const { return m_telemetry.gpu.dutyPercent; }
    int gpuTemperature() const { return m_telemetry.gpu.temperatureCelsius; }

    // Each returns an error message, or an empty string on success.
    Q_INVOKABLE QString applyMode(int index, const QVariantList &cpuCurve, const QVariantList &gpuCurve);
    Q_INVOKABLE QString setOffset(int percent);
    // The factory curves, for resetting the editor.
    Q_INVOKABLE QVariantList defaultCurve(bool gpu) const;

signals:
    void modeChanged();
    void offsetChanged();
    void curvesChanged();
    void telemetryActiveChanged();
    void telemetryChanged();

private:
    void refreshTelemetry();
    void reloadCurves();

    std::optional<clevo::FanController> m_fans;
    QTimer m_telemetryTimer;
    clevo::FanTelemetry m_telemetry;

    int m_mode = -1;
    int m_offset = 0;
    QVariantList m_cpuCurve;
    QVariantList m_gpuCurve;

    bool m_supportsMaxQ = false;
    bool m_supportsDustCleaning = false;
    bool m_supportsCustomCurves = false;
    bool m_supportsOffset = false;
};
