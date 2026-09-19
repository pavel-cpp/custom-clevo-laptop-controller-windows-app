# Packaging Control Center

Everything needed to turn a build into a redistributable Windows installer.

| File | Purpose |
| --- | --- |
| `build-installer.bat` | Double-click entry point. Wraps the PowerShell script and keeps the window open. |
| `build-installer.ps1` | Does the work: build → stage → pack. |
| `ControlCenter.iss` | Inno Setup script describing the installer. |
| `staging/` | Generated. The exact file tree that gets installed. |
| `out/` | Generated. The finished `ControlCenter-<version>-win64-setup.exe`. |

## Requirements

- A configured CMake build of the project (any generator, any Qt location)
- CMake on `PATH`
- [Inno Setup](https://jrsoftware.org/isinfo.php) 6 or newer
- The hardware SDK submodule: `git submodule update --init --recursive`

Nothing else is assumed. Qt, the compiler, the project version and the
deployment file list are all read out of the build directory, so the script
works on any machine that can build the project.

## Build

```powershell
deploy\build-installer.bat
```

or, with options:

```powershell
powershell -ExecutionPolicy Bypass -File deploy\build-installer.ps1 -Version 1.1.0
```

| Option | Meaning |
| --- | --- |
| `-BuildDir <path>` | Build directory to package. Default: autodetected (see below). |
| `-Version <x.y.z>` | Version stamped on the installer. Default: `CMAKE_PROJECT_VERSION` from the build's cache, which comes from `project(... VERSION ...)`. |
| `-SkipBuild` | Package the build directory as it is instead of building it first. |
| `-Iscc <path>` | Inno Setup compiler, if it is not in the usual place or on `PATH`. |

## What the script does

1. **Finds the build.** Either `-BuildDir`, or the first hit among
   `build\*`, `build`, `cmake-build-*` and `out\build\*` that holds a
   `CMakeCache.txt` for this project — Release builds first, then most recently
   configured. So a CLion build directory works just as well as one made by
   hand.
2. **Reads `CMakeCache.txt`** for the project version, the Qt installation
   (`WINDEPLOYQT_EXECUTABLE`, falling back to `Qt6_DIR`) and the compiler, whose
   directory goes on `PATH` so the MinGW runtime can be resolved. This is why
   no paths are hard-coded anywhere in the script.
3. **Builds** with `cmake --build <build dir>`, adding `--config Release` for
   multi-config generators. Skipped with `-SkipBuild`.
4. **Stages** into `deploy\staging`. The build already put the Qt runtime next
   to the executable (the `windeployqt` step in `CMakeLists.txt`), so the script
   asks `windeployqt --list relative` which files that deployment consists of
   and copies exactly those out of the build directory, along with
   `ControlCenter.exe` and `InsydeDCHU.dll`. Build-system artefacts never get
   near the installer, and no file is deployed twice.
   If the build was configured with `CONTROLCENTER_DEPLOY_QT_RUNTIME=OFF`, the
   missing files are deployed straight into the staging copy instead.
5. **Verifies** that the staged tree contains the files the app cannot start
   without, so a broken deployment fails here rather than on a user's machine.
6. **Packs** with Inno Setup into `deploy\out`.

The staged tree is the whole application — copying `deploy\staging` to another
machine and running `ControlCenter.exe` works without installing anything. That
also makes it the right thing to zip for a portable release.

Translations are left out; the software OpenGL fallback is kept, so the UI also
renders on machines with no usable GPU driver.

## What the installer does

- Installs to `C:\Program Files\Control Center` (per machine) or, if the user
  picks a non-elevated install, under their own profile.
- Start menu shortcut; desktop shortcut optional.
- **Startup checkbox** — writes
  `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\ControlCenter` =
  `"<install dir>\ControlCenter.exe" --tray`. That is the same key, value name
  and command line the in-app *Startup* toggle on the **For Enthusiasts** page
  uses, so the installer and the application always agree, and neither needs
  administrator rights for it.
- Offers to close a running copy before overwriting files.
- Uninstall removes the Run entry even when it was switched on inside the app.

Upgrades reuse the `AppId` GUID in `ControlCenter.iss`, so a newer installer
replaces the previous version in place. **Never change that GUID** — Windows
would then treat the new version as a separate product.

## Releasing

1. Bump `project(ControlCenter VERSION x.y.z ...)` in the top-level
   `CMakeLists.txt` and commit.
2. Run `deploy\build-installer.bat`.
3. Install the result on a clean machine and check the app starts without Qt
   on `PATH`.
4. Tag the commit and attach `deploy\out\ControlCenter-<version>-win64-setup.exe`
   to a GitHub release.
