<#
.SYNOPSIS
    Packs an existing Control Center build into a Windows installer.

.DESCRIPTION
    Everything is taken from a CMake build directory: the executable, the Qt
    runtime the build already deployed next to it, the vendor driver DLL, the
    project version, the Qt installation and the compiler. Nothing about the
    toolchain is hard-coded, so this works on any machine that can build the
    project, wherever Qt and MinGW happen to live.

      1. find a build directory (or use -BuildDir)
      2. read CMakeCache.txt for the version, Qt and the compiler
      3. build it, unless -SkipBuild
      4. stage the runtime files into deploy\staging
      5. compile deploy\ControlCenter.iss with Inno Setup

    The result is deploy\out\ControlCenter-<version>-win64-setup.exe, which
    needs no Qt, no MinGW and no Visual C++ redistributable on the target.

.PARAMETER BuildDir
    CMake build directory to package. Autodetected when omitted: a configured
    Release build under build\, cmake-build-*\ or out\build\, most recent first.

.PARAMETER Iscc
    Inno Setup command line compiler. Found automatically when Inno Setup is
    installed in its usual location or is on PATH.

.PARAMETER Version
    Version stamped on the installer. Read from the build's CMake cache when
    omitted.

.PARAMETER SkipBuild
    Package the build directory as it is instead of building it first.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File deploy\build-installer.ps1

.EXAMPLE
    .\deploy\build-installer.ps1 -BuildDir cmake-build-release-mingwqt -SkipBuild
#>
[CmdletBinding()]
param(
    [string]$BuildDir,
    [string]$Iscc,
    [string]$Version,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'

$AppName = 'ControlCenter'
$AppExe = "$AppName.exe"
$DriverDll = 'InsydeDCHU.dll'

# Must match the windeployqt call in the top-level CMakeLists.txt, so that the
# file list below describes what the build actually placed next to the exe.
$DeployArgs = @('--no-translations', '--compiler-runtime')

function Write-Step([string]$Text) {
    Write-Host ''
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Invoke-Checked([string]$What, [string]$Exe, [string[]]$Arguments) {
    & $Exe @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$What failed with exit code $LASTEXITCODE."
    }
}

function Read-CMakeCache([string]$Path) {
    $cache = @{}
    foreach ($line in Get-Content $Path) {
        # NAME:TYPE=VALUE, skipping comments and blank lines.
        $m = [regex]::Match($line, '^([A-Za-z0-9_\-\.]+):[A-Za-z]+=(.*)$')
        if ($m.Success) {
            $cache[$m.Groups[1].Value] = $m.Groups[2].Value
        }
    }
    return $cache
}

$deployDir = $PSScriptRoot
$repoDir = Split-Path -Parent $deployDir
$stagingDir = Join-Path $deployDir 'staging'
$outputDir = Join-Path $deployDir 'out'
$qmlDir = Join-Path $repoDir 'qml'

# --- Locate the build ------------------------------------------------------
Write-Step 'Looking for a build'

if ($BuildDir) {
    if (-not [System.IO.Path]::IsPathRooted($BuildDir)) {
        $BuildDir = Join-Path $repoDir $BuildDir
    }
    if (-not (Test-Path (Join-Path $BuildDir 'CMakeCache.txt'))) {
        throw "'$BuildDir' is not a CMake build directory."
    }
} else {
    $caches = @()
    foreach ($pattern in 'build\*\CMakeCache.txt', 'build\CMakeCache.txt', 'cmake-build-*\CMakeCache.txt', 'out\build\*\CMakeCache.txt') {
        $caches += Get-ChildItem -Path (Join-Path $repoDir $pattern) -ErrorAction SilentlyContinue
    }
    # A Release build is what we want to ship; among equals, the freshest one.
    $ranked = $caches |
        Where-Object { (Read-CMakeCache $_.FullName)['CMAKE_PROJECT_NAME'] -eq $AppName } |
        Sort-Object @{ Expression = { (Read-CMakeCache $_.FullName)['CMAKE_BUILD_TYPE'] -eq 'Release' }; Descending = $true },
                    @{ Expression = { $_.LastWriteTime }; Descending = $true }
    if (-not $ranked) {
        throw "No configured build of $AppName found under '$repoDir'. Configure one (for example: cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release) or pass -BuildDir."
    }
    $BuildDir = Split-Path -Parent ($ranked | Select-Object -First 1).FullName
}

$BuildDir = (Resolve-Path $BuildDir).Path
$cache = Read-CMakeCache (Join-Path $BuildDir 'CMakeCache.txt')
Write-Host "    Build      $BuildDir"

$buildType = $cache['CMAKE_BUILD_TYPE']
$multiConfig = -not [string]::IsNullOrEmpty($cache['CMAKE_CONFIGURATION_TYPES'])
if (-not $multiConfig -and $buildType -ne 'Release') {
    Write-Warning "This build is configured as '$buildType', not Release. The installer will ship it as is."
}

if (-not $Version) {
    $Version = $cache['CMAKE_PROJECT_VERSION']
    if (-not $Version) {
        throw 'The build cache has no project version. Pass -Version <x.y.z>.'
    }
}
Write-Host "    Version    $Version"

# --- Tools, all discovered through the build --------------------------------
$compiler = $cache['CMAKE_CXX_COMPILER']
if ($compiler -and (Test-Path $compiler)) {
    # windeployqt resolves the compiler runtime (libgcc, libstdc++, ...)
    # through PATH, and it lives next to the compiler.
    $env:PATH = (Split-Path -Parent $compiler) + ';' + $env:PATH
}

$windeployqt = $cache['WINDEPLOYQT_EXECUTABLE']
if (-not $windeployqt -or -not (Test-Path $windeployqt)) {
    # Not cached when the project was configured with the deploy step off;
    # derive it from the Qt package the build found instead.
    $qt6Dir = $cache['Qt6_DIR']
    if ($qt6Dir) {
        # <prefix>/lib/cmake/Qt6 -> <prefix>/bin/windeployqt.exe
        $prefix = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $qt6Dir))
        $windeployqt = Join-Path $prefix 'bin\windeployqt.exe'
    }
}
if (-not $windeployqt -or -not (Test-Path $windeployqt)) {
    throw 'Could not locate windeployqt.exe from the build. Reconfigure the build against a Qt installation.'
}
Write-Host "    Qt deploy  $windeployqt"

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    throw 'cmake is not on PATH.'
}

if (-not $Iscc) {
    $candidates = @('iscc.exe')
    foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if ($root) {
            foreach ($v in 7, 6, 5) {
                $candidates += (Join-Path $root "Inno Setup $v\ISCC.exe")
            }
        }
    }
    foreach ($candidate in $candidates) {
        $found = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($found) { $Iscc = $found.Source; break }
    }
}
if (-not $Iscc -or -not (Test-Path $Iscc)) {
    throw 'Inno Setup compiler (ISCC.exe) not found. Install Inno Setup or pass -Iscc <path to ISCC.exe>.'
}
Write-Host "    Inno Setup $Iscc"

# --- Build ------------------------------------------------------------------
if ($SkipBuild) {
    Write-Step 'Skipping the build (-SkipBuild)'
} else {
    Write-Step 'Building'
    $buildArgs = @('--build', $BuildDir)
    if ($multiConfig) { $buildArgs += @('--config', 'Release') }
    Invoke-Checked 'cmake --build' 'cmake' $buildArgs
}

# Single-config generators put the exe in the build root, multi-config ones in
# a per-configuration subdirectory.
$appDir = $BuildDir
if (-not (Test-Path (Join-Path $appDir $AppExe))) {
    $appDir = Join-Path $BuildDir 'Release'
}
$appExePath = Join-Path $appDir $AppExe
if (-not (Test-Path $appExePath)) {
    throw "Nothing to package: '$AppExe' was not found in '$BuildDir'."
}

# --- Stage ------------------------------------------------------------------
Write-Step 'Staging the payload from the build'

if (Test-Path $stagingDir) {
    Remove-Item $stagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir | Out-Null

# windeployqt itself says which files belong to a deployment, as paths relative
# to the executable. The build already placed them next to it, so this is a
# copy out of the build directory rather than a second deployment.
$listArgs = $DeployArgs + @('--qmldir', $qmlDir, '--list', 'relative', $appExePath)
$runtimeFiles = & $windeployqt @listArgs
if ($LASTEXITCODE -ne 0) {
    throw "windeployqt failed to list the deployment with exit code $LASTEXITCODE."
}
$runtimeFiles = $runtimeFiles | ForEach-Object { $_.Trim() } | Where-Object { $_ }

$payload = @($AppExe, $DriverDll) + $runtimeFiles
$missing = @()
foreach ($relative in $payload) {
    $source = Join-Path $appDir $relative
    if (-not (Test-Path $source)) {
        $missing += $relative
        continue
    }
    $target = Join-Path $stagingDir $relative
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    Copy-Item $source $target
}

if ($missing -contains $DriverDll) {
    # The build normally copies it next to the exe; fall back to the submodule.
    $fallback = Join-Path $repoDir "external\clevo-community-sdk\driver\$DriverDll"
    if (-not (Test-Path $fallback)) {
        throw "$DriverDll is missing. The hardware SDK is a submodule - run 'git submodule update --init --recursive' first."
    }
    Copy-Item $fallback $stagingDir
    $missing = @($missing | Where-Object { $_ -ne $DriverDll })
}

if ($missing) {
    # The build was configured with CONTROLCENTER_DEPLOY_QT_RUNTIME off, so the
    # Qt runtime is not in the build directory. Deploy it into the staging copy.
    Write-Host "    $($missing.Count) Qt runtime file(s) not in the build directory, deploying them"
    Invoke-Checked 'windeployqt' $windeployqt ($DeployArgs + @('--qmldir', $qmlDir, (Join-Path $stagingDir $AppExe)))
}

foreach ($required in @('Qt6Core.dll', 'Qt6Quick.dll', 'libstdc++-6.dll', $DriverDll, 'platforms\qwindows.dll')) {
    if (-not (Test-Path (Join-Path $stagingDir $required))) {
        throw "Staging looks incomplete: '$required' is missing."
    }
}

$staged = Get-ChildItem $stagingDir -Recurse -File
Write-Host ("    {0} files, {1:N1} MB" -f $staged.Count, (($staged | Measure-Object -Property Length -Sum).Sum / 1MB))

# --- Pack -------------------------------------------------------------------
Write-Step 'Compiling the installer'

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# The Windows version resource is numbers only, so "1.1.0-rc1" ships as
# 1.1.0 there while the installer keeps the full name.
$fileVersion = [regex]::Match($Version, '^[0-9]+(\.[0-9]+){0,3}').Value
if (-not $fileVersion) { $fileVersion = '0.0.0' }

Invoke-Checked 'ISCC' $Iscc @(
    "/DAppVersion=$Version",
    "/DFileVersion=$fileVersion",
    "/DRepoDir=$repoDir",
    "/DStagingDir=$stagingDir",
    "/DOutputDir=$outputDir",
    (Join-Path $deployDir 'ControlCenter.iss')
)

$installer = Join-Path $outputDir "ControlCenter-$Version-win64-setup.exe"
if (-not (Test-Path $installer)) {
    throw "ISCC reported success but '$installer' is missing."
}

Write-Host ''
Write-Host 'Installer ready:' -ForegroundColor Green
Write-Host ("    {0}  ({1:N1} MB)" -f $installer, ((Get-Item $installer).Length / 1MB))
