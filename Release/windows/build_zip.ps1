#Requires -Version 5.1
<#
.SYNOPSIS
    P2MAT Windows ZIP Builder  -  v1.0.0

.DESCRIPTION
    Assembles the P2MAT Windows distribution ZIP.
    Run from the Release\windows\ folder:
        powershell -ExecutionPolicy Bypass -File build_zip.ps1

.OUTPUTS
    Release\windows\P2MAT-v1.0.0-Windows.zip
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Configuration ────────────────────────────────────────────
$VERSION      = "1.0.0"
$ARCHIVE_NAME = "P2MAT-v$VERSION-Windows"
$SCRIPT_DIR   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$REPO_ROOT    = (Resolve-Path (Join-Path $SCRIPT_DIR "..\..")).Path
$SOURCE_APP   = Join-Path $REPO_ROOT "P2MAT"
$QSAR_YML     = Join-Path $REPO_ROOT "QSAR.yml"
$PS1_SCRIPT   = Join-Path $SCRIPT_DIR "Install-P2MAT.ps1"
$STAGING      = Join-Path $SCRIPT_DIR "staging\$ARCHIVE_NAME"
$OUTPUT       = Join-Path $SCRIPT_DIR "$ARCHIVE_NAME.zip"

Write-Host ""
Write-Host "Building P2MAT v$VERSION Windows ZIP..." -ForegroundColor Cyan
Write-Host "  Source : $SOURCE_APP"
Write-Host "  Output : $OUTPUT"
Write-Host ""

# ── Validate prerequisites ───────────────────────────────────
if (-not (Test-Path $SOURCE_APP)) {
    Write-Host "[ERROR] P2MAT source not found at: $SOURCE_APP" -ForegroundColor Red; exit 1
}
if (-not (Test-Path $QSAR_YML)) {
    Write-Host "[ERROR] QSAR.yml not found at: $QSAR_YML" -ForegroundColor Red; exit 1
}
if (-not (Test-Path $PS1_SCRIPT)) {
    Write-Host "[ERROR] Install-P2MAT.ps1 not found at: $PS1_SCRIPT" -ForegroundColor Red; exit 1
}

# ── Remove existing ZIP ──────────────────────────────────────
if (Test-Path $OUTPUT) {
    Write-Host "  Removing existing $(Split-Path $OUTPUT -Leaf)..." -ForegroundColor Yellow
    Remove-Item $OUTPUT -Force
}

# ── Stage files ──────────────────────────────────────────────
if (Test-Path (Split-Path $STAGING -Parent)) {
    Remove-Item (Split-Path $STAGING -Parent) -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $STAGING | Out-Null

Write-Host "  Copying P2MAT source (including models)..."
$roboArgs = @($SOURCE_APP, (Join-Path $STAGING "P2MAT"), "/E", "/XD", "__pycache__", "/XF", "*.pyc", "/NFL", "/NDL", "/NJH", "/NJS")
robocopy @roboArgs | Out-Null
if ($LASTEXITCODE -gt 7) { Write-Host "[ERROR] robocopy failed (exit $LASTEXITCODE)" -ForegroundColor Red; exit 1 }

Write-Host "  Copying QSAR.yml..."
Copy-Item $QSAR_YML (Join-Path $STAGING "QSAR.yml")

Write-Host "  Copying Install-P2MAT.ps1..."
Copy-Item $PS1_SCRIPT (Join-Path $STAGING "Install-P2MAT.ps1")

Write-Host "  Converting logo.png to icon.ico..."
$logoPng = Join-Path $STAGING "P2MAT\logo\logo.png"
$icoOut  = Join-Path $STAGING "P2MAT\icon.ico"
if (Test-Path $logoPng) {
    try {
        Add-Type -AssemblyName System.Drawing
        $bmp = [System.Drawing.Bitmap]::new($logoPng)
        $resized = [System.Drawing.Bitmap]::new(256, 256)
        $g = [System.Drawing.Graphics]::FromImage($resized)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($bmp, 0, 0, 256, 256)
        $g.Dispose(); $bmp.Dispose()
        $ms = [System.IO.MemoryStream]::new()
        $resized.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngBytes = $ms.ToArray()
        $ms.Dispose(); $resized.Dispose()
        $out = [System.IO.MemoryStream]::new()
        $w   = [System.IO.BinaryWriter]::new($out)
        $w.Write([uint16]0); $w.Write([uint16]1); $w.Write([uint16]1)
        $w.Write([byte]0); $w.Write([byte]0); $w.Write([byte]0); $w.Write([byte]0)
        $w.Write([uint16]1); $w.Write([uint16]32)
        $w.Write([uint32]$pngBytes.Length); $w.Write([uint32]22)
        $w.Write($pngBytes); $w.Flush()
        [System.IO.File]::WriteAllBytes($icoOut, $out.ToArray())
        $w.Dispose(); $out.Dispose()
        Write-Host "    icon.ico created" -ForegroundColor Green
    } catch {
        Write-Host "    Warning: icon conversion failed ($_)" -ForegroundColor Yellow
    }
} else {
    Write-Host "    Warning: logo\logo.png not found - icon.ico will not be included" -ForegroundColor Yellow
}

Write-Host "  Creating README.txt..."
$readme = @"
P2MAT v$VERSION - Material Property Prediction Tool
=====================================================

REQUIREMENTS
  - Windows 10 64-bit (build 1903+) or Windows 11
  - 8 GB RAM (16 GB recommended)
  - ~4 GB free disk space (for Python environment + models)
  - Internet connection (first install only)

INSTALLATION
  1. Right-click Install-P2MAT.ps1 and select "Run with PowerShell"
  2. If prompted by a security warning, click "Open" or "Run anyway"
  3. Press ENTER when prompted and follow the on-screen steps
     (10-20 minutes on first install)
  4. Launch P2MAT from the Desktop shortcut or Start Menu

  If PowerShell execution is blocked, open PowerShell as Administrator
  and run:
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Then right-click Install-P2MAT.ps1 and select "Run with PowerShell" again.

UNINSTALL
  Run: %LOCALAPPDATA%\P2MAT\Uninstall-P2MAT.ps1
  To also free the conda environment (~2.5 GB):
    conda remove -n qsar --all

SUPPORT
  Log files: %LOCALAPPDATA%\P2MAT\Logs\
"@
Set-Content -Path (Join-Path $STAGING "README.txt") -Value $readme -Encoding UTF8

# ── Build ZIP ────────────────────────────────────────────────
Write-Host "  Creating ZIP..."
$stagingRoot = Split-Path $STAGING -Parent
Compress-Archive -Path (Join-Path $stagingRoot $ARCHIVE_NAME) -DestinationPath $OUTPUT -CompressionLevel Optimal

Remove-Item $stagingRoot -Recurse -Force

$size = [math]::Round((Get-Item $OUTPUT).Length / 1MB, 1)
Write-Host ""
Write-Host "  Done: $OUTPUT  ($size MB)" -ForegroundColor Green
Write-Host ""
Write-Host "  Distribute this ZIP to Windows end users."
Write-Host "  They extract it and right-click Install-P2MAT.ps1 -> Run with PowerShell."
Write-Host ""
