# Supplementary Figure S5

Supplementary Figure S5 shows the minimum-action candidates before applying
the path-uniformity filter at `g_IE = 0.20690`:

- A: forward and backward action versus candidate index;
- B: unfiltered minimum-action forward PCA path, candidate 9;
- C: unfiltered minimum-action backward PCA path, candidate 22.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S5/code`, and run:

```matlab
PLOT_SI_Figure_S5
```

The script writes the three individual panels to `output/`. The assembled
manuscript figure is provided as `reference/S5.png`.

## Source data

| File | Purpose |
|---|---|
| `data/WKB_forward_backward_scan_gIE_0.20690_nf_40.mat` | Actions and all 40 forward/backward path candidates |
| `data/analysis_PCA_gIE=0.20690.mat` | PCA projection matrix |

The plotting code verifies that the unfiltered minima are candidates 9 and
22. Only those two PCA paths are drawn.
