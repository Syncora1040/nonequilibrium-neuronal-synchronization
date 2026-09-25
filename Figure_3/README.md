# Figure 3

Figure 3 is reproduced by two MATLAB scripts:

- `code/PLOT_Figure_3_ABC.m` generates the steady-trajectory plots in
  order-parameter R, collective-phase ψ, and PCA spaces (panels A-C).
- `code/PLOT_Figure_3_D.m` generates the nine landscape-and-flux plots in
  panel D. The first row is R space, the second row is collective-phase
  `cosψ_E-cosψ_I` space, and the third row is PCA space.

## Reproduce the figure panels

Start MATLAB, change the current folder to `Figure_3/code`, and run:

```matlab
PLOT_Figure_3_ABC
PLOT_Figure_3_D
```

Both scripts use paths relative to their own locations. Generated files are
written below `Figure_3/output/`. The scripts generate the individual panels;
the final manuscript layout is provided as `reference/Fig3_published.png`.

## Code

| File | Purpose |
|---|---|
| `PLOT_Figure_3_ABC.m` | Main plotting script for panels A-C |
| `plot_three_gIE_steady_trajectories.m` | Scatter-plot helper for panels A-C |
| `PLOT_Figure_3_D.m` | Main plotting script for the nine plots in panel D |
| `creature_figure_landscape_flux_3D.m` | R-space landscape/flux plotter |
| `plot_landscape_flux_phase_space_3D.m` | Collective-phase landscape/flux plotter |
| `creature_figure_landscape_flux_PCA_3D.m` | PCA-space landscape/flux plotter |
| `slanCM.m` | Colormap helper |

## Source data

### Panels A-C

| File | MATLAB variable(s) | Purpose |
|---|---|---|
| `data/trajectory/R_time_gIE=0.15517.mat` | `Zss` | Complex steady trajectories used to construct all three coordinate-space plots |
| `data/trajectory/PCA_basis_gIE=0.15517.mat` | `landscape_pca.coeff`, `landscape_pca.mu` | PCA transformation basis |

The trajectory file is a MATLAB 7.3 file and is approximately 2.33 GB.

### Panel D

For each space, the data directory contains files at
`g_IE = 0.02784`, `0.15517`, and `0.28966`.

| Directory | MATLAB variable(s) | Panel-D row |
|---|---|---|
| `data/R/` | `landscape_R`, `flux_R` | First row: order-parameter R space |
| `data/CosPhase/` | `landscape`, `flux`, `param` | Second row: collective-phase `cosψ_E-cosψ_I` space |
| `data/PCA/` | `landscape_pca`, `flux_pca` | Third row: PCA space |

These files contain processed landscape and probability-flux data read
directly by the plotting script.
