; ============================================================
;  P2MAT Inno Setup Script  –  v1.0.0
;  Builds a professional Windows .exe installer that bundles
;  the application source and runs Install-P2MAT.ps1.
;
;  Prerequisites (on a Windows build machine):
;    - Inno Setup 6.x  (https://jrsoftware.org/isinfo.php)
;    - The P2MAT source folder in the same directory as this script
;
;  Build command:
;    iscc P2MAT.iss
; ============================================================

#define AppName      "P2MAT"
#define AppVersion   "1.0.0"
#define AppPublisher "Sandia National Laboratories"
#define AppURL       "https://www.sandia.gov"
#define AppExeName   "P2MAT.bat"
#define SourceDir    "P2MAT"
#define InstallerPS  "Install-P2MAT.ps1"

[Setup]
AppId={{F3A1C2D0-4E7B-4A8C-9D2E-1F5B6C8A3E7F}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={localappdata}\{#AppName}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableProgramGroupPage=yes
OutputBaseFilename=P2MAT-v{#AppVersion}-Windows-x64-Setup
OutputDir=.
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0.18362
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline
WizardStyle=modern
; SetupIconFile={#SourceDir}\icon.ico  ; requires a .ico file — provide icon.ico in the P2MAT source folder to enable
UninstallDisplayIcon={app}\icon.icns
ShowLanguageDialog=no
ChangesEnvironment=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Stage source into {tmp} so Install-P2MAT.ps1 can copy to its final location
; ({tmp} is cleaned up automatically after the installer exits)
Source: "{#SourceDir}\*"; DestDir: "{tmp}\P2MAT"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "__pycache__,*.pyc"
Source: "..\..\QSAR.yml"; DestDir: "{tmp}"; Flags: ignoreversion
Source: "{#InstallerPS}"; DestDir: "{tmp}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
; Run the PowerShell installer to set up Java, Miniconda, conda env, and shortcuts
; WorkingDir is {tmp} so Install-P2MAT.ps1 finds its P2MAT\ subfolder there
Filename: "powershell.exe"; \
    Parameters: "-ExecutionPolicy Bypass -NoProfile -File ""{tmp}\Install-P2MAT.ps1"""; \
    WorkingDir: "{tmp}"; \
    Flags: waituntilterminated; \
    StatusMsg: "Setting up Python environment (this may take 10-20 minutes)..."; \
    Description: "Set up Python environment"

[UninstallRun]
Filename: "powershell.exe"; \
    Parameters: "-ExecutionPolicy Bypass -NoProfile -Command ""Remove-Item '{app}' -Recurse -Force -ErrorAction SilentlyContinue"""; \
    Flags: runhidden

[Code]
// Warn the user that internet access is required
function InitializeSetup: Boolean;
begin
  Result := True;
  MsgBox(
    'P2MAT Installer' + #13#10 + #13#10 +
    'This installer requires:' + #13#10 +
    '  - Windows 10 64-bit (build 1903+) or Windows 11' + #13#10 +
    '  - Internet connection (to download Python packages)' + #13#10 +
    '  - ~3 GB of free disk space' + #13#10 + #13#10 +
    'The setup will download and install Java 21 and Miniconda3 if ' +
    'they are not already present. This may take 10-20 minutes.' + #13#10 + #13#10 +
    'Click OK to continue.',
    mbInformation, MB_OK
  );
end;
