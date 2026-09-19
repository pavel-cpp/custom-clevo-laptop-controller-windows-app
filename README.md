

# Clevo Control Center for Windows 11 — open-source fan, keyboard and power control

A modern, open-source replacement for Clevo's Control Center. It controls **fan curves**, **RGB keyboard
backlight** and **power profiles** on Clevo-based laptops from a single Windows 11 style window, and stays
out of the way in the notification area.

Clevo builds the barebones behind many brands, so this also applies to laptops sold as **Machenike, Schenker / XMG,
Eluktronics, Tuxedo, Sager, Hasee, Mechrevo, Monster Abra, Metabox, PC Specialist** and other Clevo or
Tongfang rebrands.

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011%20x64-0078D4)
![Built with Qt](https://img.shields.io/badge/built%20with-Qt%206%20%2F%20QML-41CD52)
![C++23](https://img.shields.io/badge/C%2B%2B-23-00599C)
![License](https://img.shields.io/badge/license-GPL--3.0-blue)

---

## Demo

https://github.com/user-attachments/assets/1b096f64-ac9c-4c20-9f66-9d0b51cd3ef5

---

## Features

### Performance modes
Switch the firmware power profile in one click: **Silent**, **Power Saver**, **Entertainment** and
**Full Performance**. The active profile is read back from the machine, so the app always shows what the
firmware is really doing, and it can also be switched straight from the tray menu.

### Fan control
- Live **RPM, duty cycle and temperature** for the CPU and GPU fans, refreshed every second.
- Fan modes: **Automatic**, **Maximum**, **MaxQ** and **Custom**.
- **Anti-Dust** cleaning run, which spins the fans in reverse to blow dust out of the heatsink.
- **Custom fan curves** for CPU and GPU with draggable points, validated before they are sent to the
  embedded controller, plus a one-click return to the factory curve.
- **Speed offset** (0–100%), a constant boost added on top of whatever curve is active.

### RGB keyboard backlight
- Colour picker with live preview, RGB read-out and hex value.
- Brightness control and backlight on/off.
- **Firmware effects**: Random, Breathing, Cycle, Wave, Dance, Tempo, Flash.
- **Software effects** rendered by the app: Breathing, Colour Cycle, Colourful Breathing.
- **Boot effect** toggle and a **sleep timer** that switches the backlight off after a chosen delay.
- While a software effect runs the app takes the sleep timer over from the firmware and fades the backlight
  out itself after the same delay, so the keyboard dims smoothly instead of flickering, and fades back in on
  the next keypress.
- The last software effect is remembered and switched back on the next time the app starts.

### Firmware insight
The "For Enthusiasts" page reports the **embedded controller version** and the full list of
**capabilities the firmware advertises** — fan control, MaxQ, dust cleaning, per-key lighting, overclocking
support and more — so you can see what your particular model actually supports.

### Interface
Frameless Windows 11 window with **acrylic blur**, rounded corners, Snap and maximize-by-drag, a tray icon
with a quick profile switcher, an autostart toggle, and `--tray` to start hidden.

---

## Requirements

- Windows 10 or 11, 64-bit
- A Clevo-based laptop whose vendor driver stack (Insyde DCHU) is installed — normally already present if
  the machine shipped with Clevo Control Center
- No Visual C++ redistributable needed

The app starts on any machine. Without the driver it shows a notice and leaves the controls disabled
instead of failing.

---

## Download and run

Grab the latest build from the [Releases page](https://github.com/pavel-cpp/custom-clevo-laptop-controller-windows-app/releases)
and run `ControlCenter.exe`. Everything it needs is in the folder.

Closing the window keeps the app in the notification area; quit it from the tray menu or the
**Quit Application** button.

### Start in the tray

```powershell
ControlCenter.exe --tray
```

### Start with Windows

Turn on **Startup** on the *For Enthusiasts* page. The app registers itself for the current user only — no
administrator rights, nothing written outside your account — and starts minimised to the tray with your last
keyboard effect restored. Move or reinstall the app and the entry repairs itself on the next launch.

---

## Build from source

The hardware layer lives in a submodule, so clone recursively:

```powershell
git clone --recurse-submodules https://github.com/pavel-cpp/custom-clevo-laptop-controller-windows-app.git
cd custom-clevo-laptop-controller-windows-app
```

You need **Qt 6.5 or newer** (built and tested with Qt 6.11.2, MinGW 13.1 and Ninja) and **CMake 3.21+**.
A C++23 compiler is required, because the SDK uses `std::expected`.

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

The build copies the Qt runtime and the vendor driver library next to the executable, so `build\ControlCenter.exe`
runs straight away.

### Build the installer

With [Inno Setup](https://jrsoftware.org/isinfo.php) installed:

```powershell
deploy\build-installer.bat
```

It picks up your build directory, packages exactly what the build deployed next to the executable and writes
`deploy\out\ControlCenter-<version>-win64-setup.exe`. Qt, the compiler and the version are read out of the
build's CMake cache, so there is nothing to configure. See [`deploy/README.md`](deploy/README.md) for the
options and for what the installer puts where.

---

## How it works

The UI is Qt 6 / QML; the hardware layer is a separate, reusable C++ library:

| Layer | What it does |
|-------|--------------|
| [ClevoCommunitySDK](https://github.com/pavel-cpp/clevo-community-sdk) | Talks to the Insyde DCHU driver: power profiles, keyboard, fans, capabilities |
| `src/services` | Thin Qt objects that expose the SDK to QML as properties and slots |
| `qml/` | The Windows 11 style interface |

The protocol was reverse-engineered from Clevo's own Control Center: commands go to the firmware through
`InsydeDCHU.dll`, and the settings the vendor tools read are kept in sync so both agree on the current state.
The SDK is usable on its own if you want to script your laptop instead — see its README.

---

## Troubleshooting

**"Laptop controls are unavailable"** — the driver could not be opened. The banner shows the reason. This is
expected on non-Clevo hardware and on machines where the vendor driver was never installed.

**A fan mode or MaxQ is greyed out** — the firmware does not report support for it. The card stays clickable,
so you can still try; the "For Enthusiasts" page lists what the firmware claims.

**Custom curve is rejected** — temperatures must rise from point to point and fan speed must never drop;
the last point is always 100 °C at full speed.

**Fn combinations do not trigger anything** — Fn is handled inside the keyboard firmware and most of its
combinations never reach Windows, so no application can bind them.

---

## Credits

- Protocol groundwork from [BSCustomClevoController](https://github.com/omerboran63/CustomClevoController)
  by omerboran63, and from Clevo's own Control Center.
- `InsydeDCHU.dll` is Insyde/Clevo's own component, redistributed so the app can talk to the firmware.

Not affiliated with, endorsed by, or supported by Clevo or Insyde. It drives the embedded controller of your
laptop directly: use it at your own risk.

<p align="center"><i>…although, Clevo, if you're reading this: <b>hire me!</b> 👋<br>
I already rewrote your Control Center for free.</i></p>

---

## License

[GPL-3.0](LICENSE)

---

<sub>Keywords: Clevo Control Center alternative, Clevo fan control Windows 11, Clevo keyboard backlight
software, Tongfang laptop control, Schenker XMG fan curve, Eluktronics fan control, Tuxedo Windows control
center, Sager laptop fan software, custom fan curve Windows, RGB keyboard control open source, Insyde DCHU,
Qt QML Windows 11 acrylic app.</sub>
