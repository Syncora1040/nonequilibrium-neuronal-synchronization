# Supplementary Figure S7

Supplementary Figure S7 shows action values mapped around the PCA
limit-cycle curve together with the final selected paths:

- A: forward path candidate 24;
- B: backward path candidate 21.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S7/code`, and run:

```matlab
PLOT_SI_Figure_S7
```

The two generated heat-ring panels are written to `output/`. The assembled
manuscript figure is provided as `reference/S7.png`.

## Source data

| File | Purpose |
|---|---|
| `data/WKB_forward_backward_scan_gIE_0.20690_nf_40.mat` | Candidate actions, selected paths, and candidate endpoints |
| `data/analysis_PCA_gIE=0.20690.mat` | PCA projection and centering information |
| `data/zS.mat` | Synchronized limit-cycle trajectory used to construct the PCA limit-cycle curve |

The program uses the last 10% of `zS`, projects it into PCA space, fits a
200-bin closed curve, and maps the forward/backward candidate actions onto
that curve.
