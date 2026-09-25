# Supplementary Figure S3

Supplementary Figure S3a-c describes the synchronized-to-asynchronous
(S→A) transition:

- a: synchronized-state barrier `ΔU_Syn` versus `g_IE`;
- b: mean first-passage time `τ_S→A` versus `g_IE`;
- c: `ln(τ_S→A)` versus `ΔU_Syn`.

The package consolidates the S→A portions of the original
`mPlot_barrier_sde.m`, `mPlot_MFPT_SA.m`, and
`mPlot_barrier_vs_tau_SA.m` programs.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S3/code`, and run:

```matlab
PLOT_SI_Figure_S3_abc
```

Generated panels are written to `SI_Figure_S3/output/`. The manuscript panel
images are provided in `reference/`.

## Source data

| File | MATLAB variables used | Panel(s) |
|---|---|---|
| `data/Barrier_R_sde.mat` | `Barrier_S`, `gIE_list_S` | a, c |
| `data/MFPT_SA_88.mat` | `MFPT2`, `gIE_list` | b, c |
| `data/MFPT_SA_100.mat` | Loaded by the original program; retained for provenance | — |

The original `mPlot_MFPT_SA.m` loads both MFPT files but constructs the
plotted S→A curve from `MFPT_SA_88.mat` only. This behavior is preserved
explicitly in the consolidated script.

## Requirements

- MATLAB
- Statistics and Machine Learning Toolbox (`fitlm`, `predict`, `tinv`, and
  `fcdf` are used by the fitting and confidence-band functions)
