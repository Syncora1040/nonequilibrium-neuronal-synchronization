# Nonequilibrium neuronal synchronization

MATLAB code for reproducing the figures and analyses associated with the
manuscript **"Nonequilibrium Dynamical and Thermodynamic Mechanisms of a
Neuronal Synchronization Transition in a Reduced Mean-Field Description"** by
Jiacheng Xu and Jin Wang.

The study combines a reduced excitatory-inhibitory theta-neuron model with
bifurcation analysis, nonequilibrium landscape and probability-flux analysis,
mean first-passage times, entropy production, time-reversal asymmetry, and
dominant transition paths.

## Repository contents

Each figure directory is self-contained:

- `code/` contains the main MATLAB plotting script and required helper code.
- `data/` contains processed source data read directly by the script. These
  large files are excluded from GitHub and will be archived separately on
  Zenodo.
- `output/` is the destination for regenerated figures.
- `reference/` contains the corresponding manuscript figure for comparison.

```text
.
|-- Figure_1/
|-- Figure_2/
|-- Figure_3/
|-- Figure_4/
|-- Figure_5/
|-- Figure_6/
|-- SI_Figure_S1/
|-- SI_Figure_S2/
|-- SI_Figure_S3/
|-- SI_Figure_S4/
|-- SI_Figure_S5/
|-- SI_Figure_S6/
|-- SI_Figure_S7/
|-- CITATION.cff
|-- LICENSE
`-- README.md
```

## Figure index

| Figure | Main plotting program | Status |
|---|---|---|
| Figure 1 | Not generated with MATLAB; final image included | Complete |
| Figure 2 | `Figure_2/code/PLOT_Fig2_ABCD.m` | Complete |
| Figure 3 A-C | `Figure_3/code/PLOT_Figure_3_ABC.m` | Complete |
| Figure 3 D | `Figure_3/code/PLOT_Figure_3_D.m` | Complete |
| Figure 4 A-C | `Figure_4/code/PLOT_Figure_4_ABC.m` | Complete |
| Figure 5 | `Figure_5/code/PLOT_Figure_5.m` | Complete |
| Figure 6 | `Figure_6/code/PLOT_Figure_6.m` | Complete |
| SI Figure S1 a-d | `SI_Figure_S1/code/PLOT_SI_Figure_S1_abcd.m` | Complete |
| SI Figure S2 a-f | `SI_Figure_S2/code/PLOT_SI_Figure_S2_a_f.m` | Complete |
| SI Figure S3 a-c | `SI_Figure_S3/code/PLOT_SI_Figure_S3_abc.m` | Complete |
| SI Figure S4 a-b | `SI_Figure_S4/code/PLOT_SI_Figure_S4_ab.m` | Complete |
| SI Figure S5 | `SI_Figure_S5/code/PLOT_SI_Figure_S5.m` | Complete |
| SI Figure S6 | `SI_Figure_S6/code/PLOT_SI_Figure_S6.m` | Complete |
| SI Figure S7 | `SI_Figure_S7/code/PLOT_SI_Figure_S7.m` | Complete |

## Requirements

- MATLAB with `tiledlayout` and `exportgraphics` support.
- Statistics and Machine Learning Toolbox may be required by analyses using
  principal component analysis or kernel-density estimation.
- Optimization Toolbox may be required by dominant-path calculations.
- Times New Roman is used by the Figure 2 plotting script.

Exact input files and commands are documented in the README inside each figure
directory.

## Reproducing a figure

1. Download the source-data archive from Zenodo once the DOI is available.
2. Place each downloaded `data/` directory in its matching figure directory.
3. Start MATLAB and change the current directory to the relevant `code/`
   directory.
4. Run the plotting program listed in the figure index or in that directory's
   README.
5. Compare the generated files in `output/` with the files in `reference/`.

## Data availability

The complete processed source data are approximately 3.38 GB and include files
larger than GitHub's 100 MB per-file limit. They are therefore not tracked in
this repository. The permanent Zenodo DOI will be added here before manuscript
submission.

**Zenodo DOI:** forthcoming

## Citation

If you use this code, please cite the associated manuscript and the archived
software release. Citation metadata are provided in `CITATION.cff`; the final
article and Zenodo DOI will be added when available.

## License

The source code is released under the MIT License. See `LICENSE`.

## Contact

For questions about the code or data, please open a GitHub issue.
