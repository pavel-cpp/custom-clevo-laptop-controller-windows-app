; Inno Setup script for Control Center.
;
; Not meant to be compiled by hand - build-installer.ps1 stages the payload
; and passes the paths below in. Compiling this file directly works too, as
; long as deploy\staging has already been filled by that script.

#define AppName "Control Center"
#define AppExeName "ControlCenter.exe"
#define AppPublisher "Pavel Remdenok"
#define AppURL "https://github.com/pavel-cpp/custom-clevo-laptop-controller-windows-app"

; Overridden from the command line with /D<name>=<value>.
#ifndef AppVersion
  #define AppVersion "1.0.1"
#endif
; The Windows version resource only accepts numbers, so a version like
; "1.1.0-rc1" is trimmed to its numeric part before it gets here.
#ifndef FileVersion
  #define FileVersion AppVersion
#endif
#ifndef RepoDir
  #define RepoDir ".."
#endif
#ifndef StagingDir
  #define StagingDir "staging"
#endif
#ifndef OutputDir
  #define OutputDir "out"
#endif

#if !FileExists(AddBackslash(StagingDir) + AppExeName)
  #error Staging directory is empty - run deploy\build-installer.ps1 first.
#endif

[Setup]
; Keep this GUID stable forever: it is how Windows recognises an upgrade.
AppId={{6B2C2F41-7A1E-4C63-9E4B-2D5A0F8C1E27}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
VersionInfoVersion={#FileVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}/issues
AppUpdatesURL={#AppURL}/releases

DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
LicenseFile={#RepoDir}\LICENSE
SetupIconFile={#RepoDir}\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExeName}
UninstallDisplayName={#AppName}

OutputDir={#OutputDir}
OutputBaseFilename=ControlCenter-{#AppVersion}-win64-setup
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=4

WizardStyle=modern
; 64-bit only: the SDK loads the vendor's 64-bit InsydeDCHU.dll.
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Qt 6.11 needs Windows 10 1809 or newer.
MinVersion=10.0.17763

; Per-machine by default, but the user may pick a per-user install; either way
; autostart is written under HKCU, so it only affects the installing account.
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=commandline dialog
; The Run entry is deliberately per-user; see [Registry] below.
UsedUserAreasWarning=no

; Offer to close a running copy instead of failing on a locked file.
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "autostart"; Description: "Start {#AppName} when I sign in (minimised to the notification area, last keyboard effect restored)"; GroupDescription: "Startup:"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Everything the app needs at runtime: the executable, the Qt runtime laid out
; by windeployqt, the MinGW runtime and the vendor driver DLL.
Source: "{#StagingDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{group}\{cm:UninstallProgram,{#AppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Registry]
; Same key, same value name and same command line the in-app Startup toggle
; uses, so the two never disagree.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "ControlCenter"; ValueData: """{app}\{#AppExeName}"" --tray"; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
const
  RunKey = 'Software\Microsoft\Windows\CurrentVersion\Run';
  RunValue = 'ControlCenter';

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // The in-app toggle can have written the entry after installation, in which
  // case uninsdeletevalue knows nothing about it. Clear it either way.
  if CurUninstallStep = usPostUninstall then
    RegDeleteValue(HKEY_CURRENT_USER, RunKey, RunValue);
end;
