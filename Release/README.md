# P2MAT — v1.0.0 Installation Guide

**P2MAT** (Property Prediction for Materials) predicts thermophysical
properties of molecules from SMILES strings using pre-trained machine learning
models.

**Supported predictions:** Melting Point (K) · Boiling Point (K) ·
Heat Capacity (J/K) · Heat of Hydrogenation · H₂ Uptake

---

## Table of Contents

1. [System Requirements](#1-system-requirements)
2. [Quick Installation Guide](#2-quick-installation-guide)
3. [macOS Installation](#3-macos-installation)
4. [Windows Installation](#4-windows-installation)
5. [Linux Installation](#5-linux-installation)
6. [First Launch & Usage](#6-first-launch--usage)
7. [What the Installer Sets Up](#7-what-the-installer-sets-up)
8. [Uninstalling P2MAT](#8-uninstalling-p2mat)
9. [Troubleshooting](#9-troubleshooting)

---

## 1. System Requirements

| | macOS | Windows | Linux |
|---|---|---|---|
| **Minimum OS** | macOS 12.0 (Monterey) | Windows 10 64-bit, build 1903 | Debian 11 / Ubuntu 20.04 / Fedora 36 or equivalent |
| **Recommended OS** | macOS 13 (Ventura) or later | Windows 11 | Ubuntu 22.04 LTS or later |
| **CPU** | Apple Silicon (M1 / M2 / M3 / M4) | x64 (Intel or AMD) | x86_64 or aarch64 |
| **RAM** | 8 GB minimum, 16 GB recommended | 8 GB minimum, 16 GB recommended | 8 GB minimum, 16 GB recommended |
| **Disk space** | ~3.5 GB (environment + models) | ~4 GB (environment + models) | ~4 GB (environment + models) |
| **Internet** | Required for first install | Required for first install | Required for first install |
| **Java** | Installed automatically | Installed automatically | Installed automatically |
| **Display** | Required | Required | Required (X11 or Wayland) |

> **Why Apple Silicon only on macOS?**
> The Melting Point stacking ensemble uses a PyTorch DNN accelerated with
> Apple MPS (Metal Performance Shaders) and ships as a
> `macosx_12_0_arm64` wheel. Running it on an Intel Mac would require
> retraining on x86 hardware. Intel Mac support may be added in a future
> release.

---

## 2. Quick Installation Guide

One command to build each distributable, one command to install it.

### macOS

```bash
cd macOS && bash build_dmg.sh
```
Distribute `P2MAT-v1.0.0-macOS-arm64.dmg`. End users double-click `install.command` inside the DMG.

### Windows

**ZIP — Windows build machine (PowerShell):**
```powershell
cd windows
powershell -ExecutionPolicy Bypass -File build_zip.ps1
```

**ZIP — macOS / Linux build machine (bash):**
```bash
cd windows && bash build_zip.sh
```

Both produce `P2MAT-v1.0.0-Windows.zip`. End users extract and right-click `Install-P2MAT.ps1` → **Run with PowerShell**.

**Inno Setup .exe — Windows build machine:**
```batch
cd windows
xcopy /E /I ..\..\P2MAT P2MAT
iscc P2MAT.iss
```
Produces `P2MAT-v1.0.0-Windows-x64-Setup.exe`. End users double-click and follow the wizard.

### Linux

```bash
cd linux && bash build_tarball.sh
```
Distribute `P2MAT-v1.0.0-Linux-x86_64.tar.gz`. End users run:
```bash
tar -xzf P2MAT-v1.0.0-Linux-x86_64.tar.gz && cd P2MAT-v1.0.0-Linux-x86_64 && bash install.sh
```

### Bumping the version

Update `VERSION` in all eight files before building a new release:

| File | Variable |
|------|----------|
| `Release/macOS/install.command` | `VERSION="1.0.0"` |
| `Release/macOS/build_dmg.sh` | `VERSION="1.0.0"` |
| `Release/windows/Install-P2MAT.ps1` | `$VERSION = "1.0.0"` |
| `Release/windows/P2MAT.iss` | `#define AppVersion "1.0.0"` |
| `Release/windows/build_zip.sh` | `VERSION="1.0.0"` |
| `Release/windows/build_zip.ps1` | `$VERSION = "1.0.0"` |
| `Release/linux/install.sh` | `VERSION="1.0.0"` |
| `Release/linux/build_tarball.sh` | `VERSION="1.0.0"` |

---

## 3. macOS Installation

### 3.1 Building the DMG

Build the distributable DMG from source on an Apple Silicon Mac.

**Prerequisites**

- Apple Silicon Mac (M1 / M2 / M3 / M4) running macOS 12+
- [`create-dmg`](https://github.com/create-dmg/create-dmg) installed via Homebrew

```bash
# Install the DMG builder (one-time)
brew install create-dmg

# Build the DMG
cd macOS
bash build_dmg.sh
```

Output: `Release/macOS/P2MAT-v1.0.0-macOS-arm64.dmg` (~200 MB). This single file is what you distribute to end users.

### 3.2 Install from the DMG

1. **Double-click** `P2MAT-v1.0.0-macOS-arm64.dmg`. A Finder window opens showing four items:

   ```
   ┌──────────────────────────────────────────────────────────────┐
   │  P2MAT Installer                                             │
   │                                                              │
   │   📁 P2MAT   📄 QSAR.yml   📄 install.command   📄 README.txt │
   └──────────────────────────────────────────────────────────────┘
   ```

2. **Double-click `install.command`.**

   macOS will ask: _"install.command is an application downloaded from the internet. Are you sure you want to open it?"_ Click **Open**.

   A Terminal window opens. You will see:

   ```
   ══════════════════════════════════════════
     P2MAT v1.0.0  –  macOS Installer
   ══════════════════════════════════════════

     This installer will:
       1. Verify macOS version and hardware
       2. Install Homebrew (if needed)
       3. Install Java / OpenJDK (if needed)
       4. Install Miniconda (if needed)
       5. Create the 'qsar' Python environment
       6. Install P2MAT and create the Application bundle

     Press ENTER to continue, or Ctrl+C to cancel ...
   ```

   Press **ENTER** to begin.

3. When installation finishes you will see:

   ```
   ══════════════════════════════════════════
     Installation complete
   ══════════════════════════════════════════
   ```

   Close the Terminal window. P2MAT is now installed.

### 3.3 What happens at each step

| Step | What to expect | Typical duration |
|------|---------------|-----------------|
| **System check** | Verifies macOS 12+ and Apple Silicon. Aborts if unsupported. | < 1 s |
| **Homebrew** | Installs Homebrew if missing (may ask for your password). If already installed, skips. | 0–5 min |
| **Java** | Installs the latest OpenJDK via `brew install openjdk`. Java is required by the PaDEL descriptor engine. | 0–3 min |
| **Miniconda** | Downloads and installs Miniconda3 for Apple Silicon if no conda is found. | 1–3 min |
| **Python environment** | Creates the `qsar` conda environment and installs ~40 packages including PyTorch, LightGBM, RDKit, and PyQt5. **This is the longest step.** | 5–10 min |
| **Application install** | Copies the app to `~/Applications/P2MAT/` and creates `/Applications/P2MAT.app`. | < 30 s |

> **Note:** During the Homebrew or Java step macOS may prompt for your
> **administrator password**. This is normal. The password is passed to
> `sudo` only for creating a Java symlink; no other root actions are taken.

### 3.4 Launch P2MAT

Open **Finder → Applications** and double-click **P2MAT**.

On first launch macOS may show:
> _"P2MAT cannot be verified because it was not downloaded from the App Store."_

To allow it:
1. Open **System Settings → Privacy & Security**
2. Scroll to the Security section and click **Open Anyway** next to P2MAT
3. Click **Open** in the confirmation dialog

P2MAT will open and is now permanently allowed.

---

## 4. Windows Installation

### 4.1 Install from the ZIP archive (recommended)

1. **Extract the archive** — right-click `P2MAT-v1.0.0-Windows.zip` → **Extract All** → choose a location → click **Extract**.

   The extracted folder contains:

   ```
   P2MAT-v1.0.0-Windows\
   ├── P2MAT\                  ← application source and ML models
   ├── QSAR.yml                ← conda environment definition
   ├── Install-P2MAT.ps1       ← installer script
   └── README.txt
   ```

2. **Right-click** `Install-P2MAT.ps1` → **Run with PowerShell**.

   If you see a blue security warning, click **Open** or **Run anyway**.

   If PowerShell execution is blocked on your machine, open PowerShell as
   Administrator and run:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   Then try right-clicking again.

3. The installer window shows:

   ```
   ==================================================
     P2MAT v1.0.0  -  Windows Installer
   ==================================================

     This installer will set up P2MAT on your computer.
     An internet connection is required for the first install.
     Estimated time: 10-20 minutes.

     Press ENTER to continue, or Ctrl+C to cancel
   ```

   Press **ENTER**.

4. What happens at each step:

   | Step | What to expect | Typical duration |
   |------|---------------|-----------------|
   | **System check** | Verifies 64-bit Windows 10 build 1903+. Aborts if unsupported. | < 1 s |
   | **Java 21** | Installs Microsoft OpenJDK 21 via `winget`, or downloads the MSI installer. A UAC prompt may appear. | 1–5 min |
   | **Miniconda3** | Downloads and silently installs Miniconda3 for the current user only (no admin rights needed). | 2–4 min |
   | **Python environment** | Creates the `qsar` conda environment and installs all packages. **This is the longest step.** | 5–15 min |
   | **Application files** | Copies P2MAT to `%LOCALAPPDATA%\P2MAT\` and writes the launcher batch file. | < 30 s |
   | **Shortcuts** | Creates a Desktop shortcut and a Start Menu entry under **P2MAT**. | < 5 s |

5. When the installer finishes it prints **"Installation complete!"** and waits
   for you to press ENTER before closing.

### 4.2 Install from the .exe wizard

If you received a file named `P2MAT-v1.0.0-Windows-x64-Setup.exe`:

1. Double-click the `.exe` file.
2. If prompted by Windows SmartScreen: click **More info → Run anyway**.
3. Follow the installation wizard. Accept the defaults and click **Next** until
   **Install** is available, then click **Install**.
4. The wizard opens a PowerShell window and runs the installer. Follow the
   on-screen prompts. The process takes 10–20 minutes.
5. Click **Finish** when done.

### 4.3 Launch P2MAT

Double-click the **P2MAT** shortcut on your Desktop, or open the Start Menu
and search for **P2MAT**.

A console window appears briefly while the Python environment activates, then
the P2MAT GUI opens.

---

## 5. Linux Installation

### 5.1 Build the Linux tarball

Run on any Linux machine (or macOS with `rsync` and `tar`):

```bash
cd linux
bash build_tarball.sh
```

Output: `P2MAT-v1.0.0-Linux-x86_64.tar.gz` (or `aarch64` on ARM). Distribute this archive to Linux end users.

### 5.2 Install from the tarball

1. **Extract the archive** and enter the folder:

   ```bash
   tar -xzf P2MAT-v1.0.0-Linux-x86_64.tar.gz
   cd P2MAT-v1.0.0-Linux-x86_64
   ```

   The folder contains:

   ```
   P2MAT-v1.0.0-Linux-x86_64/
   ├── P2MAT/          ← application source and ML models
   ├── QSAR.yml        ← conda environment definition
   ├── install.sh      ← installer script
   └── README.txt
   ```

2. **Run the installer:**

   ```bash
   bash install.sh
   ```

   Press **ENTER** when prompted to begin.

3. When installation finishes you will see:

   ```
   ══════════════════════════════════════════
     Installation complete
   ══════════════════════════════════════════
   ```

### 5.3 What the installer does

| Step | What to expect | Typical duration |
|------|---------------|-----------------|
| **System check** | Confirms Linux x86\_64/aarch64 and detects the distribution. | < 1 s |
| **Java 17** | Installs OpenJDK 17 via `apt`, `dnf`, `zypper`, or `pacman` depending on the distro. Skips if already present. | 0–3 min |
| **Miniconda3** | Downloads and installs Miniconda3 to `~/miniconda3` if no `conda` is found. | 1–3 min |
| **Python environment** | Creates the `qsar` conda environment and installs all packages including PyTorch, LightGBM, RDKit, and PyQt5. **Longest step.** | 5–15 min |
| **Application install** | Copies files to `~/.local/share/P2MAT/` and writes the launch script. | < 30 s |
| **Desktop launcher** | Creates a `.desktop` entry so P2MAT appears in your application menu. | < 1 s |

> **Note:** Java and Miniconda installation may require `sudo` for your
> package manager. The installer will prompt for your password if needed.

### 5.4 Launch P2MAT

Search for **P2MAT** in your application menu, or run directly:

```bash
~/.local/share/P2MAT/p2mat-launch.sh
```

If you just installed and `conda` is not yet on your PATH, source it first:

```bash
source ~/miniconda3/etc/profile.d/conda.sh
~/.local/share/P2MAT/p2mat-launch.sh
```

> **Headless / server note:** P2MAT requires a graphical display.
> On a server without a display, run:
> ```bash
> Xvfb :99 -screen 0 1024x768x24 &
> export DISPLAY=:99
> ~/.local/share/P2MAT/p2mat-launch.sh
> ```

---

## 6. First Launch & Usage

### 6.1 Application window

When P2MAT opens you will see:

```
┌─────────────────────────────────────────────────────────────┐
│  [SNL Logo]                                                 │
│                                                             │
│  Enter a SMILES string          ┌─────────────────────┐    │
│  (Multiple SMILEs in new line)  │                     │    │
│                                 │  (text input area)  │    │
│                                 └─────────────────────┘    │
│                                                             │
│  ┌─ Properties to predict ────────────────────────────────┐ │
│  │  ☑ Melting point (K)   ☑ Boiling point (K)  ☑ ...    │ │
│  └────────────────────────────────────────────────────────┘ │
│                                               [Predict]     │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Running a prediction

1. **Enter one or more SMILES strings** in the text area, one per line.

   Example:
   ```
   CCO
   c1ccccc1
   CC(=O)Oc1ccccc1C(=O)O
   ```

2. **Select the properties** you want to predict using the checkboxes.
   At least one property must be checked (the last checked box cannot be
   unchecked).

3. Click **Predict properties**.

4. A progress bar appears. Each SMILES is validated with RDKit and its
   molecular descriptors are computed by PaDEL-Descriptor (this takes a few
   seconds per molecule).

5. Results appear in a table below the progress bar. Invalid SMILES strings
   are listed above the table.

6. Click **Save data** to export the results as a CSV file.

### 6.3 SMILES format tips

- Use standard SMILES notation (e.g. `CCO` for ethanol, `c1ccccc1` for benzene).
- Salts and multi-fragment SMILES (containing `.`) are handled per fragment.
- Very large or complex molecules may time out in PaDEL — try splitting
  them or increasing Java heap space.

---

## 7. What the Installer Sets Up

| Component | Version | Purpose |
|---|---|---|
| Python | 3.12 | Runtime |
| PyQt5 | latest | GUI framework |
| scikit-learn | latest | ML models (BP, HC, dH) |
| LightGBM | latest | MP stacking base model |
| XGBoost | latest | MP stacking base model |
| PyTorch | latest | MP stacking DNN base model |
| RDKit | latest | SMILES validation & 2D rendering |
| padelpy | latest | Python wrapper for PaDEL-Descriptor |
| PaDEL-Descriptor | bundled in padelpy | ~1 240 molecular descriptors (Java) |
| Java 17+ | system-level | Required to run PaDEL (17 on Linux, 21 on Windows, latest via Homebrew on macOS) |
| cairosvg | latest | SVG-to-PNG rendering |
| Pillow | latest | Image annotation |
| joblib | latest | Model serialisation / loading |
| numpy, pandas, scipy | latest | Numerical computation |

**Installed locations**

| Item | macOS | Windows | Linux |
|------|-------|---------|-------|
| App source | `~/Applications/P2MAT/` | `%LOCALAPPDATA%\P2MAT\` | `~/.local/share/P2MAT/` |
| App launcher | `/Applications/P2MAT.app` | Desktop + Start Menu shortcut | `~/.local/share/applications/p2mat.desktop` |
| Conda env | `~/miniconda3/envs/qsar/` | `%USERPROFILE%\miniconda3\envs\qsar\` | `~/miniconda3/envs/qsar/` |
| Log file | `~/Library/Logs/P2MAT/p2mat.log` | `%LOCALAPPDATA%\P2MAT\Logs\` | `~/.local/share/P2MAT/logs/p2mat.log` |

---

## 8. Uninstalling P2MAT

### macOS

```bash
# Remove the app bundle and source files
rm -rf /Applications/P2MAT.app ~/Applications/P2MAT

# Optionally remove the conda environment (~2.5 GB)
conda remove -n qsar --all
```

### Windows

**Option A** — run the uninstaller that was created during installation:

```powershell
powershell -File "%LOCALAPPDATA%\P2MAT\Uninstall-P2MAT.ps1"
```

**Option B** — if the Inno Setup `.exe` installer was used, go to
**Settings → Apps → Installed Apps**, search for **P2MAT**, and click
**Uninstall**.

To also remove the conda environment (~2.5 GB):

```powershell
conda remove -n qsar --all
```

### Linux

```bash
# Remove the application and desktop launcher
rm -rf ~/.local/share/P2MAT ~/.local/share/applications/p2mat.desktop

# Optionally remove the conda environment (~2.5 GB)
conda remove -n qsar --all
```

---

## 9. Troubleshooting

### Application won't open

| Platform | Action |
|----------|--------|
| macOS | Check the log: `cat ~/Library/Logs/P2MAT/p2mat.log` |
| Windows | Run `P2MAT.bat` from a Command Prompt window to see console errors |
| Linux | Check the log: `cat ~/.local/share/P2MAT/logs/p2mat.log` |

### Common errors and fixes

| Error message | Cause | Fix |
|---|---|---|
| `No module named 'lightgbm'` | lightgbm not installed in qsar env | `conda activate qsar && pip install lightgbm` |
| `No module named 'torch'` | PyTorch not installed in qsar env | `conda activate qsar && pip install torch` |
| `PaDEL-Descriptor timed out` | Java not found or too slow | Verify: `java -version`. On macOS: `brew install openjdk` |
| `No descriptors could be computed` | All SMILES invalid or PaDEL crash | Check SMILES format; try one molecule at a time |
| `FileNotFoundError: Feature file not found` | Feature list file missing | Re-run installer; check `include/feature/` folder |
| `Conda environment 'qsar' not found` (macOS/Linux) | Conda not initialised in shell | `source ~/miniconda3/etc/profile.d/conda.sh` |
| Execution policy error (Windows) | PowerShell restricted mode | Open PowerShell as Admin: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| macOS Gatekeeper blocks the app | App not notarised | System Settings → Privacy & Security → **Open Anyway** |
| No display / `cannot connect to X server` (Linux) | Running without a display server | Use Xvfb: `Xvfb :99 -screen 0 1024x768x24 & ; export DISPLAY=:99` |
| `sudo` password required during install (Linux) | Java installation needs package manager | Expected — enter your user password when prompted |
| Slow first prediction | PaDEL JVM startup + model loading | Normal — subsequent predictions in the same session are faster |

### Re-running the installer

The installer is safe to run multiple times. If the `qsar` environment already
exists it will update packages in place rather than recreating from scratch.

---

