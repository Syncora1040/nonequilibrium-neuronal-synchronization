# Supplementary Figure S4

Supplementary Figure S4 contains the PCA- and collective-phase-space
portions extracted from `mPlot_epr_five_spaces_sde.m`.

The manuscript panel order, verified against the existing output images, is:

- S4a: collective-phase ψ space, represented by
  `cosψ_E-cosψ_I`;
- S4b: PCA space.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S4/code`, and run:

```matlab
PLOT_SI_Figure_S4_ab
```

The script writes `S4_a.png` and `S4_b.png` to `SI_Figure_S4/output/`.
Reference manuscript images are supplied in `reference/`.

## Source data

| File | MATLAB variables used | Panel |
|---|---|---|
| `data/Jav_EPR_Xcorr_phase_spaces.mat` | `gIE_list`, `epr_CosPhase`, `Jav_CosPhase`, `Xcorr_CosPhase` | S4a |
| `data/Jav_EPR_from_saved_analysis.mat` | `gIE_list`, `epr_pca`, `Jav_pca`, `Xcorr_pca` | S4b |
| `data/MF_bifurcation_gIE_scan_gEE010_gEI008_gII005.mat` | `scanBif` | Transition lines in both panels |

Only the PCA and ψ-space variables required for S4a-b are loaded. The
E-population phase plane, I-population phase plane, and R-space portions of
the original five-space program are not plotted by this package.
