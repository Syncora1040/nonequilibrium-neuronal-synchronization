# Supplementary Figure S2

`code/PLOT_SI_Figure_S2_a_f.m` generates Supplementary Figure S2 a-f:

- S2 a-c: E-population phase plane,
  `R_E cosψ_E-R_E sinψ_E`, at `g_IE = 0.02784`, `0.15517`, and `0.28966`.
- S2 d-f: I-population phase plane,
  `R_I cosψ_I-R_I sinψ_I`, at the same three coupling values.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S2/code`, and run:

```matlab
PLOT_SI_Figure_S2_a_f
```

The script uses only relative paths and writes individual panels below
`SI_Figure_S2/output/`.

## Code and data

| Location | Purpose |
|---|---|
| `code/PLOT_SI_Figure_S2_a_f.m` | Main script for S2 a-f |
| `code/plot_landscape_flux_phase_space_3D.m` | 3D landscape/flux plotting function |
| `code/slanCM.m` | Colormap helper |
| `data/Eplane/` | Processed `landscape`, `flux`, and `param` data for S2 a-c |
| `data/Iplane/` | Processed `landscape`, `flux`, and `param` data for S2 d-f |
| `reference/S2_a.png` through `S2_f.png` | Manuscript panel images for comparison |

No external project directory or simulation output is required.
