#include "KeyboardActivity.h"

#include <QtGlobal>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

#include <atomic>
#include <future>

namespace {

#ifdef Q_OS_WIN
// The hook procedure gets no context pointer, hence a global. There is only
// ever one monitor, owned by the keyboard service.
std::atomic<DWORD> lastKeyTick{0};

LRESULT CALLBACK keyboardHook(int code, WPARAM wParam, LPARAM lParam)
{
    if (code == HC_ACTION)
        lastKeyTick.store(GetTickCount(), std::memory_order_relaxed);
    return CallNextHookEx(nullptr, code, wParam, lParam);
}

// Fallback when the hook cannot be installed: any input, mouse included.
DWORD lastInputTick()
{
    LASTINPUTINFO info{sizeof(LASTINPUTINFO), 0};
    return GetLastInputInfo(&info) ? info.dwTime : GetTickCount();
}
#endif

} // namespace

KeyboardActivity::~KeyboardActivity()
{
    stop();
}

void KeyboardActivity::start()
{
#ifdef Q_OS_WIN
    if (m_thread.joinable())
        return;

    lastKeyTick.store(GetTickCount(), std::memory_order_relaxed);

    struct Started
    {
        DWORD threadId;
        bool hooked;
    };
    std::promise<Started> started;
    std::future<Started> startedFuture = started.get_future();

    m_thread = std::thread([&started] {
        // Make sure the thread has a message queue before anyone posts to it.
        MSG msg;
        PeekMessageW(&msg, nullptr, WM_USER, WM_USER, PM_NOREMOVE);

        HHOOK hook = SetWindowsHookExW(WH_KEYBOARD_LL, keyboardHook, GetModuleHandleW(nullptr), 0);
        started.set_value({GetCurrentThreadId(), hook != nullptr});

        // Low-level hooks are called through this thread's message loop.
        while (GetMessageW(&msg, nullptr, 0, 0) > 0) {
        }

        if (hook)
            UnhookWindowsHookEx(hook);
    });

    const Started result = startedFuture.get();
    m_threadId = result.threadId;
    m_hooked = result.hooked;
#endif
}

void KeyboardActivity::stop()
{
#ifdef Q_OS_WIN
    if (!m_thread.joinable())
        return;

    PostThreadMessageW(m_threadId, WM_QUIT, 0, 0);
    m_thread.join();
    m_threadId = 0;
    m_hooked = false;
#endif
}

int KeyboardActivity::idleSeconds() const
{
#ifdef Q_OS_WIN
    const DWORD last = m_hooked ? lastKeyTick.load(std::memory_order_relaxed) : lastInputTick();
    // Unsigned arithmetic, so the 49-day tick wrap takes care of itself.
    return static_cast<int>((GetTickCount() - last) / 1000);
#else
    return 0;
#endif
}
