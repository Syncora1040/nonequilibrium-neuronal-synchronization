# Supplementary Figure S1

Supplementary Figure S1 contains four mean-field coupling maps:

- S1a: processed `R_E` coupling map;
- S1b: processed `R_I` coupling map;
- S1c: finite-N `R_E` value map;
- S1d: finite-N `R_I` value map.

## Reproduce the panels

Start MATLAB, change the current folder to `SI_Figure_S1/code`, and run:

```matlab
PLOT_SI_Figure_S1_abcd
```

The four individual panels are written to `SI_Figure_S1/output/`.
The manuscript images are provided in `reference/`.

## Source data

| File | Purpose |
|---|---|
| `data/MF_coupling_scan_data_processed.mat` | Processed mean-field coupling scan used for S1a-b |
| `data/MF_4D_scan_N20_result.mat` | Finite-N four-dimensional scan used for S1c-d |

## Code scope

`MF_plot_coupling_phase_maps_raw.m` generates only the `R_E` and `R_I`
value maps needed for S1a-b because the regime-map option is disabled.

`plot_RE_RI_phase_maps.m` is distilled from the finite-N plotting workflow
and contains only the `R_E` and `R_I` value-map path. The classified
label-map branch is not included.
