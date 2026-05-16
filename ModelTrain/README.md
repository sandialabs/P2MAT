# ModelTrain — ML Model Training Pipelines

This directory contains three self-contained training pipelines for predicting thermophysical properties of chemical compounds. Each pipeline shares a common architecture: compounds are split into three elemental domains — **CHO** (C, H, O only), **CHON** (adds N), and **FULL** (all elements) — and domain-specific stacking ensemble models are trained independently for each.

Each pipeline evaluates six regression algorithms (Ridge, ElasticNet, ExtraTrees, LightGBM, XGBoost, DNN), four feature-selection strategies (Whole, Boruta, PCA, Correlation), and three data transformations (none, StandardScaler, QuantileTransformer), yielding **216 base experiments** per pipeline. A stacking meta-learner (Ridge) then combines the four best base models into a final ensemble.

---

## Table of Contents

1. [Directory Layout](#directory-layout)
2. [Boiling point/](#boiling-point)
3. [Melting point 2D/](#melting-point-2d)
4. [Melting point 3D/](#melting-point-3d)
5. [Shared Pipeline Architecture](#shared-pipeline-architecture)
6. [Quick Start](#quick-start)

---

## Directory Layout

```
ModelTrain/
├── Boiling point/      # Boiling point prediction pipeline  (3 764 train / 941 test)
├── Melting point 2D/   # Melting point — 2D RDKit descriptors (15 428 train / 3 860 test)
└── Melting point 3D/   # Melting point — 3D Mordred/RDKit descriptors (3 589 train / 897 test)
```

---

## Boiling point/

Training pipeline for predicting molecular **boiling points** (BP\_K, Kelvin) from ~1 217 PaDEL/CDK molecular descriptors. The dataset covers 3 764 training and 941 test molecules, split into CHO, CHON, and FULL elemental subsets.

**High-level functionality:** Runs a full Bayesian-optimised experiment grid across all model, feature-selection, and transformation combinations; trains a stacking ensemble over the four best base models; and performs applicability domain analysis via Williams plots and outlier detection.

| Component | Description |
|---|---|
| `Data/` | Train/test CSV splits for CHO, CHON, and full compound sets |
| `src/` | Core modules — data loader, feature selection, model factory, trainer, stacking, evaluator, DNN |
| `train.py` | Experiment orchestrator: runs all 216 base experiments with load-or-train checkpointing |
| `stack.py` | Trains the stacking meta-learner on out-of-fold predictions from the four base models |
| `boruta.py` | Boruta feature selection wrapper |
| `shap_analysis.py` | SHAP feature importance analysis |
| `pred_plot.py` | Predicted vs. actual scatter plots |
| `williams_plot.py` | Williams plot for applicability domain (AD) assessment |
| `uncertainty_analysis.py` | Prediction uncertainty estimation |
| `outlier_detection.py` | Outlier identification and AD analysis |
| `results/` | Experiment metrics, stacking results, and manuscript figures |

See [Boiling point/README.md](Boiling%20point/README.md) for full pipeline documentation, setup, and usage.

---

## Melting point 2D/

Training pipeline for predicting molecular **melting points** (MP\_K, Kelvin) using **2D molecular descriptors** computed by RDKit/PaDEL (~1 240 features). This is the primary melting point model. The dataset contains 15 428 training and 3 860 test molecules across CHO, CHON, and FULL subsets.

**High-level functionality:** Identical experiment grid to the boiling point pipeline, extended with inter-dataset Tanimoto similarity analysis and full-dataset outlier detection. Produces the 2D-descriptor baseline used alongside the 3D pipeline.

| Component | Description |
|---|---|
| `Data/` | Train/test CSV splits for CHO, CHON, and full compound sets |
| `src/` | Core modules — data loader, feature selection, model factory, trainer, stacking, evaluator, DNN |
| `train.py` | Experiment orchestrator: 216 base experiments with load-or-train checkpointing |
| `stack.py` | Trains the stacking meta-learner |
| `boruta.py` | Boruta feature selection wrapper |
| `shap_analysis.py` | SHAP feature importance analysis |
| `pred_plot.py` | Predicted vs. actual scatter plots |
| `williams_plot.py` | Williams plot for AD assessment |
| `uncertainty_analysis.py` | Prediction uncertainty estimation |
| `outlier_detection.py` | Outlier identification and AD analysis |
| `outlier_detection_full.py` | Outlier detection on the full (non-split) dataset |
| `dataset_similarity.py` | Inter-dataset Tanimoto similarity analysis |
| `results/` | Experiment metrics, stacking results, and manuscript figures |

See [Melting point 2D/README.md](Melting%20point%202D/README.md) for full pipeline documentation, setup, and usage.

---

## Melting point 3D/

Training pipeline for predicting molecular **melting points** (MP\_K, Kelvin) using **3D conformer-based descriptors** computed by Mordred/RDKit 3D (~1 625 features). This pipeline mirrors `Melting point 2D/` and is used to benchmark 3D descriptor performance against the 2D baseline on the same melting point task. The dataset contains 3 589 training and 897 test molecules.

**High-level functionality:** Same experiment grid and workflow as the 2D pipeline. The key difference is the descriptor set — 3D conformer geometry is incorporated, providing additional structural information at the cost of conformer generation time. Results feed directly into the 2D vs. 3D comparison reported in the manuscript.

| Component | Description |
|---|---|
| `Data/` | Train/test CSV splits for CHO, CHON, and full compound sets |
| `src/` | Core modules — data loader, feature selection, model factory, trainer, stacking, evaluator, DNN |
| `train.py` | Experiment orchestrator: 216 base experiments with load-or-train checkpointing |
| `stack.py` | Trains the stacking meta-learner |
| `boruta.py` | Boruta feature selection wrapper |
| `shap_analysis.py` | SHAP feature importance analysis |
| `pred_plot.py` | Predicted vs. actual scatter plots |
| `williams_plot.py` | Williams plot for AD assessment |
| `uncertainty_analysis.py` | Prediction uncertainty estimation |
| `outlier_detection.py` | Outlier identification and AD analysis |
| `results/` | Experiment metrics, stacking results, and manuscript figures |

See [Melting point 3D/README.md](Melting%20point%203D/README.md) for full pipeline documentation, setup, and usage.

---

## Shared Pipeline Architecture

All three sub-pipelines follow the same experiment grid and workflow.

**Experiment grid** (216 base experiments per pipeline)

| Axis | Options |
|---|---|
| Datasets | `full`, `cho`, `chon` |
| Feature selection | `whole`, `boruta`, `pca`, `correlation` |
| Data transformation | `none`, `standard`, `quantile` |
| Base models | Ridge, ElasticNet, ExtraTrees, LightGBM, XGBoost, DNN |

**Stacking ensemble** — LightGBM, XGBoost, ExtraTrees, and DNN predictions are combined via out-of-fold (OOF) cross-validation into a Ridge regression meta-learner, avoiding data leakage.

**Load-or-train logic** — `train.py` automatically skips completed experiments, loads saved models when results are missing, and only trains from scratch when neither exists. Pass `--retrain` to force retraining. Runs can be safely interrupted and resumed.

---

## Quick Start

```bash
conda activate qsar

cd "Boiling point"         # or "Melting point 2D" / "Melting point 3D"

# Run all 216 base experiments
python train.py

# Train the stacking ensemble
python stack.py
```
