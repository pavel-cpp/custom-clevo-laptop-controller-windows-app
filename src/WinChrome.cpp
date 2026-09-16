#include "WinChrome.h"

#ifdef Q_OS_WIN
#include <windows.h>
#include <dwmapi.h>

// The MinGW-w64 dwmapi.h shipped with this Qt kit predates the Windows 11
// DWM attributes, so the values below are defined by hand. They are stable,
// documented Win32 constants (see dwmapi.h in the Windows 11 SDK).
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif
#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif
#ifndef DWMWA_SYSTEMBACKDROP_TYPE
#define DWMWA_SYSTEMBACKDROP_TYPE 38
#endif

namespace {

enum WinChromeCornerPreference {
    CornerRound = 2
};

enum WinChromeSystemBackdropType {
    BackdropNone = 1,
    BackdropAcrylic = 3
};

// Undocumented user32 composition API. It is the route that actually blurs
// the desktop behind a window which composites its own per-pixel alpha - and
// a frameless translucent QQuickWindow is exactly that. DWM's documented
// system backdrop only paints for windows that own a real non-client frame,
// so it stays invisible here and is used only as a fallback.
enum AccentState {
    AccentEnableAcrylicBlurBehind = 4
};

struct AccentPolicy {
    DWORD state;
    DWORD flags;
    DWORD gradientColor; // 0xAABBGGRR
    DWORD animationId;
};

enum WindowCompositionAttribute {
    WcaAccentPolicy = 19
};

struct WindowCompositionAttributeData {
    DWORD attribute;
    void *data;
    SIZE_T size;
};

using SetWindowCompositionAttributeFn = BOOL(WINAPI *)(HWND, WindowCompositionAttributeData *);

SetWindowCompositionAttributeFn setWindowCompositionAttribute()
{
    static SetWindowCompositionAttributeFn fn = []() -> SetWindowCompositionAttributeFn {
        if (const HMODULE user32 = GetModuleHandleW(L"user32.dll")) {
            return reinterpret_cast<SetWindowCompositionAttributeFn>(
                reinterpret_cast<void *>(GetProcAddress(user32, "SetWindowCompositionAttribute")));
        }
        return nullptr;
    }();
    return fn;
}

bool applyAcrylicBlur(HWND hwnd)
{
    const auto setAttribute = setWindowCompositionAttribute();
    if (!setAttribute)
        return false;

    // The window tint comes from the translucent panel drawn in QML, so the
    // blur layer itself carries an all but invisible tint; a fully
    // transparent one makes some Windows builds skip the effect entirely.
    AccentPolicy policy{};
    policy.state = AccentEnableAcrylicBlurBehind;
    policy.flags = 0;
    policy.gradientColor = 0x01221c1c; // 0xAABBGGRR of #1c1c22
    policy.animationId = 0;

    WindowCompositionAttributeData data{};
    data.attribute = WcaAccentPolicy;
    data.data = &policy;
    data.size = sizeof(policy);

    return setAttribute(hwnd, &data);
}

} // namespace
#endif

WinChrome::WinChrome(QObject *parent)
    : QObject(parent)
{
}

void WinChrome::applyAcrylicEffect(QQuickWindow *window)
{
    if (!window)
        return;

#ifdef Q_OS_WIN
    const HWND hwnd = reinterpret_cast<HWND>(window->winId());
    if (!hwnd)
        return;

    const BOOL dark = TRUE;
    DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, sizeof(dark));

    const int corner = CornerRound;
    DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &corner, sizeof(corner));

    if (applyAcrylicBlur(hwnd)) {
        // Keep DWM from layering its own backdrop under the blur.
        const int backdrop = BackdropNone;
        DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop, sizeof(backdrop));
    } else {
        const int backdrop = BackdropAcrylic;
        DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop, sizeof(backdrop));
        const MARGINS margins{-1, -1, -1, -1};
        DwmExtendFrameIntoClientArea(hwnd, &margins);
    }
#else
    Q_UNUSED(window);
#endif
}
