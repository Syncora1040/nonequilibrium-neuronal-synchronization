# Figure 5

Figure 5 shows normalized average probability flux `J_av`, entropy
production rate `e_p`, and correlation difference `ΔCC` in order-parameter
R space as functions of `g_IE`.

The package contains the R-space portion associated with `mPlot_epr.m`.
The plotting options reproduce the manuscript output, including the two
deterministic transition lines.

## Reproduce the figure

Start MATLAB, change the current folder to `Figure_5/code`, and run:

```matlab
PLOT_Figure_5
```

The regenerated image is written to `Figure_5/output/Fig5.png`. The
manuscript image is provided in `reference/Fig5.png`.

## Source data

| File | MATLAB variables used | Purpose |
|---|---|---|
| `data/Jav_EPR_from_saved_analysis.mat` | `gIE_list`, `epr_R`, `Jav_R`, `Xcorr_R` | R-space physical metrics |
| `data/MF_bifurcation_gIE_scan_gEE010_gEI008_gII005.mat` | `scanBif` | Locations of the two vertical transition lines |

The three metrics are independently min-max normalized to `[0,1]` before
plotting.
