# Supplementary Figure S6

Supplementary Figure S6 shows the candidates selected after applying the
path-uniformity filter at `g_IE = 0.20690`:

- A: filtered action-versus-candidate plot;
- B: selected forward PCA path, candidate 24;
- C: selected backward PCA path, candidate 21.

The filtering uses a segment-ratio threshold of 5.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S6/code`, and run:

```matlab
PLOT_SI_Figure_S6
```

The script writes the three individual panels to `output/`. The assembled
manuscript figure is provided as `reference/S6.png`.

## Source data

| File | Purpose |
|---|---|
| `data/WKB_forward_backward_scan_gIE_0.20690_nf_40.mat` | Actions, paths, and information used by the uniformity filter |
| `data/analysis_PCA_gIE=0.20690.mat` | PCA projection matrix |

The program reruns the filter, verifies the expected 24/21 selection, and
draws only those two PCA paths.
