#pragma once

#include <thread>

// Tells how long it has been since the last key press anywhere on the system.
// Mouse input is deliberately ignored: the backlight sleep timer in the
// firmware only reacts to the keyboard, and the app's own timer must match.
//
// While running, a low-level keyboard hook lives on a thread of its own, so a
// busy GUI thread can never make Windows drop the hook for being slow. Only
// the time of the last key event is recorded, never which key it was.
class KeyboardActivity
{
public:
    KeyboardActivity() = default;
    ~KeyboardActivity();

    KeyboardActivity(const KeyboardActivity &) = delete;
    KeyboardActivity &operator=(const KeyboardActivity &) = delete;

    // Starting counts as activity, so the idle time begins at zero.
    void start();
    void stop();

    int idleSeconds() const;

private:
    std::thread m_thread;
    unsigned long m_threadId = 0;
    bool m_hooked = false;
};
