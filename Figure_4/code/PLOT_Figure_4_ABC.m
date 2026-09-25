%% Plot Figure 4A-C: asynchronous-to-synchronized transition
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
originalDir = pwd;
cleanupDir = onCleanup(@() cd(originalDir));
cd(scriptDir);
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir, '-begin');
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

barrierFile = fullfile(dataDir, 'Barrier_R_sde.mat');
mfpt22File = fullfile(dataDir, 'MFPT_AS_22.mat');
mfpt26File = fullfile(dataDir, 'MFPT_AS_26.mat');
require_file(barrierFile);
require_file(mfpt22File);
require_file(mfpt26File);

B = load(barrierFile, 'Barrier_A', 'gIE_list_A');
M22 = load(mfpt22File, 'MFPT2', 'gIE_list');
M26 = load(mfpt26File, 'MFPT2', 'gIE_list');
if ~isequal(M22.gIE_list, M26.gIE_list)
    error('The gIE_list values in the two A-to-S MFPT files do not match.');
end
gIE_mfpt = M22.gIE_list;
MFPT = mean([M22.MFPT2; M26.MFPT2], 1, 'omitnan');

%% A: asynchronous-state barrier
plot_Asyn_fit_curve(B.Barrier_A, B.gIE_list_A, outputDir, ...
    'Visible', 'off', 'Save', true, 'LineWidth', 3.5, ...
    'MarkerSize', 10, 'SaveName', 'Fig4_A_barrier_Asyn_fit.png', ...
    'RobustDelta', 8, 'ConfidenceLevel', 0.95, ...
    'ConfidenceLowerBound', 0, 'ConfidenceOnlyWithinData', true, ...
    'CurveExtendFraction', 0.01, 'BandAlpha', 0.22, ...
    'StatsPosition', [0.12 0.12], 'StatsFontSize', 22, ...
    'ShowLegend', false, 'PanelLabel', '', 'TailExtend', 0.008);

%% B: mean first-passage time from asynchronous to synchronized state
plot_MFPT_AS_fit(gIE_mfpt, MFPT, outputDir, ...
    'Visible', 'off', 'Save', true, ...
    'SaveName', 'Fig4_B_MFPT_AS_fit.png', ...
    'ConfidenceLevel', 0.95, 'ConfidenceLowerBound', 0, ...
    'BandAlpha', 0.22, 'StatsPosition', [0.88 0.78], ...
    'StatsFontSize', 24, 'ShowLegend', false, 'PanelLabel', '', ...
    'LeftExtend', 0.002, 'RightExtend', 0.01);

%% C: log(MFPT) versus asynchronous-state barrier
fitOpts = struct('ConfidenceLevel', 0.95, 'ShowEquation', false, ...
    'BandAlpha', 0.28, 'AnnotationPosition', [0.88 0.12], ...
    'StatsFontSize', 26, 'LabelFontSize', 68, 'ExcludeYAbove', 8.5);
prepare_and_plot_A_MFPT_vs_Barrier( ...
    B.gIE_list_A, B.Barrier_A, gIE_mfpt, MFPT, ...
    outputDir, true, fitOpts);

fprintf('Figure 4A-C saved under:\n  %s\n', outputDir);

function require_file(filePath)
if ~exist(filePath, 'file')
    error('Required data file not found:\n  %s', filePath);
end
end
