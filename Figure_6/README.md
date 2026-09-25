# Figure 6

Figure 6 shows the forward and backward dominant transition paths on the
three-dimensional potential landscapes at `g_IE = 0.20690`:

- A: order-parameter R space;
- B: PCA space.

The plotting package is distilled from `mPlot_3D_path.m`.

## Reproduce the panels

Start MATLAB, change the current folder to `Figure_6/code`, and run:

```matlab
PLOT_Figure_6
```

The script writes `Fig6_A_R.png` and `Fig6_B_PCA.png` to
`Figure_6/output/`. The assembled manuscript figure is provided as
`reference/Fig6_published.png`.

## Selected paths

The original candidate-selection step selected:

- forward path candidate: `24`;
- backward path candidate: `21`;
- number of scanned candidates in each direction: `40`.

These selected indices are stated explicitly in the consolidated plotting
script. This avoids regenerating unrelated candidate-selection diagnostic
figures while preserving the exact paths used in Figure 6.

## Source data

| File | MATLAB variables used | Purpose |
|---|---|---|
| `data/WKB_forward_backward_scan_gIE_0.20690_nf_40.mat` | `Results_forward`, `Results_backward` | Four-dimensional optimal paths and their R-space projections |
| `data/analysis_R_gIE=0.20690.mat` | `landscape_R` | R-space potential landscape |
| `data/analysis_PCA_gIE=0.20690.mat` | `landscape_pca` | PCA landscape and PCA transformation |

The `zS.mat` limit-cycle candidate data and action-candidate plotting
functions used in the exploratory original script are not required to draw
the two Figure 6 panels and are therefore not included.
