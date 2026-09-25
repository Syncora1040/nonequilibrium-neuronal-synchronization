%% Plot Supplementary Figure S1a-d
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir);
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

%% S1a-b: processed mean-field coupling maps
abFile = fullfile(dataDir, 'MF_coupling_scan_data_processed.mat');
if ~exist(abFile, 'file')
    error('Required data file not found:\n  %s', abFile);
end
SAB = load(abFile, 'scanCoupling');
abOpts = struct( ...
    'selectedGEE', [], ...
    'selectedGII', [], ...
    'prefix', 'S1', ...
    'titlePrefix', 'Mean-field phase map', ...
    'showFigureTitle', false, ...
    'plotRegime', false);
MF_plot_coupling_phase_maps_raw(SAB.scanCoupling, outputDir, abOpts);

%% S1c-d: finite-N mean-field R_E and R_I value maps
cdFile = fullfile(dataDir, 'MF_4D_scan_N20_result.mat');
if ~exist(cdFile, 'file')
    error('Required data file not found:\n  %s', cdFile);
end
plot_RE_RI_phase_maps(cdFile, outputDir);

fprintf('Supplementary Figure S1a-d panels saved under:\n  %s\n', outputDir);
