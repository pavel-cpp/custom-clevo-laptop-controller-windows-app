#include "DeviceService.h"

#include <QVariantMap>

#include <utility>

DeviceService::DeviceService(const std::optional<clevo::Device> &device,
                             const std::optional<clevo::Capabilities> &capabilities, QString openError,
                             QObject *parent)
    : QObject(parent)
    , m_errorMessage(std::move(openError))
{
    if (device) {
        m_system = device->system();
        m_controllerVersion = QString::fromStdString(m_system->embeddedControllerVersion());
    }

    if (capabilities) {
        m_fanCount = capabilities->fanCount;
        for (const clevo::CapabilityFlag &flag : capabilities->flags()) {
            m_capabilities.append(QVariantMap{
                {QStringLiteral("name"), QString::fromUtf8(flag.name.data(), static_cast<qsizetype>(flag.name.size()))},
                {QStringLiteral("supported"), flag.supported},
            });
        }
    }
}

