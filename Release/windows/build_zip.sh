#!/bin/bash
# ============================================================
#  P2MAT Windows ZIP Builder
#  Run this script from Release/windows/ on macOS or Linux
#  to produce the distributable:
#    P2MAT-v1.0.0-Windows.zip
# ============================================================
set -euo pipefail

VERSION="1.0.0"
ARCHIVE_NAME="P2MAT-v${VERSION}-Windows"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_APP="$REPO_ROOT/P2MAT"
QSAR_YML="$REPO_ROOT/QSAR.yml"
PS1_SCRIPT="$SCRIPT_DIR/Install-P2MAT.ps1"
STAGING="$SCRIPT_DIR/staging"
OUTPUT="$SCRIPT_DIR/${ARCHIVE_NAME}.zip"

echo "Building P2MAT v${VERSION} Windows ZIP..."
echo "  Source : $SOURCE_APP"
echo "  Output : $OUTPUT"

# ── Validate prerequisites ───────────────────────────────────
[[ -d "$SOURCE_APP" ]] || { echo "ERROR: P2MAT source not found at $SOURCE_APP"; exit 1; }
[[ -f "$QSAR_YML"   ]] || { echo "ERROR: QSAR.yml not found at $QSAR_YML"; exit 1; }
[[ -f "$PS1_SCRIPT" ]] || { echo "ERROR: Install-P2MAT.ps1 not found at $PS1_SCRIPT"; exit 1; }
command -v zip &>/dev/null || { echo "ERROR: zip not found. Install with: brew install zip"; exit 1; }

# ── Remove existing ZIP ──────────────────────────────────────
if [[ -f "$OUTPUT" ]]; then
    echo "  Removing existing $(basename "$OUTPUT")..."
    rm -f "$OUTPUT"
fi

# ── Stage files ──────────────────────────────────────────────
rm -rf "$STAGING"
mkdir -p "$STAGING/${ARCHIVE_NAME}"

echo "  Copying P2MAT source (including models)..."
rsync -a \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.DS_Store' \
    "$SOURCE_APP/" "$STAGING/${ARCHIVE_NAME}/P2MAT/"

echo "  Copying QSAR.yml..."
cp "$QSAR_YML" "$STAGING/${ARCHIVE_NAME}/QSAR.yml"

echo "  Copying Install-P2MAT.ps1..."
cp "$PS1_SCRIPT" "$STAGING/${ARCHIVE_NAME}/Install-P2MAT.ps1"

echo "  Creating README.txt..."
cat > "$STAGING/${ARCHIVE_NAME}/README.txt" <<README
P2MAT v${VERSION} - Material Property Prediction Tool
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
README

# ── Build ZIP ────────────────────────────────────────────────
echo "  Creating ZIP..."
(cd "$STAGING" && zip -r "$OUTPUT" "${ARCHIVE_NAME}" -x "*.DS_Store")

rm -rf "$STAGING"

SIZE=$(du -sh "$OUTPUT" | awk '{print $1}')
echo ""
echo "  Done: $OUTPUT  ($SIZE)"
echo ""
echo "  Distribute this ZIP to Windows end users."
echo "  They extract it and right-click Install-P2MAT.ps1 -> Run with PowerShell."
