#include "PowerService.h"

#include <array>

namespace {

// Card order in the UI differs from the firmware's numbering.
constexpr std::array<clevo::PowerProfile, 4> profileByIndex{
    clevo::PowerProfile::Quiet,
    clevo::PowerProfile::PowerSaving,
    clevo::PowerProfile::Entertainment,
    clevo::PowerProfile::Performance,
};

int indexOf(std::optional<clevo::PowerProfile> profile)
{
    for (std::size_t i = 0; profile && i < profileByIndex.size(); ++i) {
        if (profileByIndex[i] == *profile)
            return static_cast<int>(i);
    }
    return -1;
}

} // namespace

PowerService::PowerService(const std::optional<clevo::Device> &device, QObject *parent)
    : QObject(parent)
{
    if (device) {
        m_power = device->power();
        m_profile = indexOf(m_power->profile());
    }
}

void PowerService::setProfile(int index)
{
    if (!m_power || index < 0 || index >= static_cast<int>(profileByIndex.size()) || index == m_profile)
        return;

    m_power->setProfile(profileByIndex[static_cast<std::size_t>(index)]);
    m_profile = index;
    emit profileChanged();
}
