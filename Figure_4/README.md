# Figure 4

Figure 4A-C describes the asynchronous-to-synchronized (A→S) transition:

- A: asynchronous-state barrier `ΔU_Asyn` versus `g_IE`;
- B: mean first-passage time `τ_A→S` versus `g_IE`;
- C: `ln(τ_A→S)` versus `ΔU_Asyn`.

The package consolidates the A→S portions of the original
`mPlot_barrier_sde.m`, `mPlot_MFPT_AS.m`, and
`mPlot_barrier_vs_tau_AS.m` programs.

## Reproduce the panels

Start MATLAB, change the current folder to `Figure_4/code`, and run:

```matlab
PLOT_Figure_4_ABC
```

The script uses relative paths and writes all generated panels to
`Figure_4/output/`. The manuscript panel images are retained in `reference/`.

## Source data

| File | MATLAB variables used | Panel(s) |
|---|---|---|
| `data/Barrier_R_sde.mat` | `Barrier_A`, `gIE_list_A` | A, C |
| `data/MFPT_AS_22.mat` | `MFPT2`, `gIE_list` | B, C |
| `data/MFPT_AS_26.mat` | `MFPT2`, `gIE_list` | B, C |

The A→S MFPT curve is the pointwise mean of the `22` and `26` datasets,
matching the original plotting program.

## Requirements

- MATLAB
- Statistics and Machine Learning Toolbox (`fitlm`, `predict`, `tinv`, and
  `fcdf` are used by the fitting and confidence-band functions)
