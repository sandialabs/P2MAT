<div align="center">
  <img src="P2MAT/logo/logo.png" alt="P2MAT Logo" width="180"/>
  <h1>P2MAT — Material Property Prediction</h1>
  <p>
    A QSAR-based desktop application for predicting thermophysical properties of chemical
    compounds directly from their SMILES representation, powered by domain-specific stacking
    ensemble models (LightGBM · XGBoost · ExtraTrees · DNN → Ridge).
  </p>
</div>

---

## Overview

P2MAT predicts **melting point** and **boiling point** (in Kelvin) from SMILES strings. Compounds are automatically routed to the appropriate model based on their elemental composition — CHO-only, CHON, or the full element set — giving more accurate predictions by keeping each model focused on a chemically coherent subset.

The application runs on **macOS** (Apple Silicon), **Windows** (x64), and **Linux** (x86\_64 / aarch64).

---

## Components

### [ModelTrain/](ModelTrain/README.md) — ML Training Pipelines

Three self-contained pipelines covering boiling point and melting point (2D and 3D descriptors). Each pipeline runs 216 Bayesian-optimised experiments across six regression algorithms, four feature-selection strategies, and three data transformations. The four best-performing base models are then combined into a stacking ensemble via out-of-fold Ridge regression.

→ Full documentation in [`ModelTrain/README.md`](ModelTrain/README.md)

---

### [P2MAT/](P2MAT/README.md) — Desktop Application

The PyQt5 desktop GUI. Users enter SMILES strings, select the properties to predict, and receive results in an interactive table that can be exported to CSV. Bundled model artifacts and feature lists are included — no dependency on the training codebase at runtime.

→ Full documentation in [`P2MAT/README.md`](P2MAT/README.md)

---

### [Release/](Release/README.md) — Distribution Packaging

Platform-specific scripts for building and distributing P2MAT to end users.

| Platform | Build | Installer |
|---|---|---|
| macOS | `macOS/build_dmg.sh` | `macOS/install.command` |
| Linux | `linux/build_tarball.sh` | `linux/install.sh` |
| Windows | `windows/P2MAT.iss` (Inno Setup) | `windows/Install-P2MAT.ps1` |

→ Full build and install instructions in [`Release/README.md`](Release/README.md)


---

## Environment

All components share a single conda environment defined in [`QSAR.yml`](QSAR.yml). To create it:

```bash
conda env create -f QSAR.yml
conda activate qsar
```

See [`Release/README.md`](Release/README.md) for full platform-specific installation instructions including Java and Miniconda setup.
