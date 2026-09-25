%% Plot SI Figure S4a-b in collective-phase and PCA spaces
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir);

legacyFile = fullfile(dataDir, 'Jav_EPR_from_saved_analysis.mat');
phaseFile = fullfile(dataDir, 'Jav_EPR_Xcorr_phase_spaces.mat');
bifFile = fullfile(dataDir, ...
    'MF_bifurcation_gIE_scan_gEE010_gEI008_gII005.mat');
require_file(legacyFile);
require_file(phaseFile);
require_file(bifFile);

SPCA = load(legacyFile, ...
    'gIE_list', 'epr_pca', 'Jav_pca', 'Xcorr_pca');
SPhase = load(phaseFile, ...
    'gIE_list', 'epr_CosPhase', 'Jav_CosPhase', 'Xcorr_CosPhase');
transitionLines = deterministic_transition_lines(bifFile);

commonArgs = { ...
    'Visible', 'off', 'Save', true, 'Close', true, ...
    'OutputDpi', 300, 'TransitionLines', transitionLines, ...
    'ShowTransitionLines', true, 'LineWidth', 2.0, ...
    'MarkerSize', 10, 'MarkerStride', 1, ...
    'JavPlotIndices', [1:3, 5, 9, 13, 16:18, 21, 24:45, 52, 59, 64, 66:10000], ...
    'EPRPlotIndices', [1:3, 5, 9, 14, 16:17, 19, 21, 24:45, 49, 51:54, 57:59, 62, 65:10000], ...
    'XcorrPlotIndices', [1:3, 5, 9, 13, 16:17, 19:22, 24:43, 45, 47, 50, 53, 56, 59, 62, 64:10000], ...
    'AlwaysIncludeEPRPeak', true, 'AxisFontSize', 45, ...
    'LabelFontSize', 55, 'LegendFontSize', 42, ...
    'TransitionColor', [0.55 0.00 0.80], ...
    'TransitionLineWidth', 4, 'ShowTitle', false};

% S4a: collective-phase psi space (cospsi_E, cospsi_I)
plot_physics_au_sde_space( ...
    SPhase.gIE_list, SPhase.epr_CosPhase, ...
    SPhase.Jav_CosPhase, SPhase.Xcorr_CosPhase, ...
    outputDir, 'cos(psi_E), cos(psi_I)', 'S4_a.png', commonArgs{:});

% S4b: PCA space
plot_physics_au_sde_space( ...
    SPCA.gIE_list, SPCA.epr_pca, SPCA.Jav_pca, SPCA.Xcorr_pca, ...
    outputDir, 'PCA-space', 'S4_b.png', commonArgs{:});

fprintf('SI Figure S4a-b saved under:\n  %s\n', outputDir);

function require_file(filePath)
if ~exist(filePath, 'file')
    error('Required data file not found:\n  %s', filePath);
end
end

function lines = deterministic_transition_lines(bifFile)
S = load(bifFile, 'scanBif');
bif = S.scanBif;
g = bif.gIE_list(:).';
asynStable = bif.fp_converged(:).' & bif.fp_stable(:).';
syncStable = bif.sync_converged(:).' & bif.sync_stable(:).';
idxSyncBorn = find(syncStable, 1, 'first');
idxAsynLost = find(asynStable, 1, 'last');
if isempty(idxSyncBorn) || isempty(idxAsynLost)
    error('Could not identify both deterministic transition lines.');
end
lines = sort(unique([g(idxSyncBorn), g(idxAsynLost)]));
end
