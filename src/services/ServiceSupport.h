#pragma once

#include <clevo/Error.hpp>

#include <QCoreApplication>
#include <QString>

#include <algorithm>
#include <cstdint>

namespace services {

inline QString errorText(const clevo::Error &error)
{
    return QString::fromStdString(error.message);
}

inline QString statusText(const clevo::Status &status)
{
    return status ? QString() : errorText(status.error());
}

inline QString unavailableText()
{
    return QCoreApplication::translate("services", "The laptop control driver is not available.");
}

inline std::uint8_t toByte(int value)
{
    return static_cast<std::uint8_t>(std::clamp(value, 0, 255));
}

} // namespace services
