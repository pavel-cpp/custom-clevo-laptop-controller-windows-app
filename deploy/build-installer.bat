@echo off
rem Double-click to build the Control Center installer.
rem Any arguments are passed straight through to build-installer.ps1,
rem so `build-installer.bat -SkipBuild` works from a console too.

setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0build-installer.ps1" %*
set "RESULT=%ERRORLEVEL%"

echo.
if not "%RESULT%"=="0" (
    echo Build FAILED with exit code %RESULT%.
) else (
    echo Done. The installer is in "%~dp0out".
)

rem Keep the window open when started from Explorer.
echo.
pause
exit /b %RESULT%
