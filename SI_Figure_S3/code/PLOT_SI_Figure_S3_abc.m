%% Plot SI Figure S3a-c: synchronized-to-asynchronous transition
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir);
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

barrierFile = fullfile(dataDir, 'Barrier_R_sde.mat');
mfpt88File = fullfile(dataDir, 'MFPT_SA_88.mat');
mfpt100File = fullfile(dataDir, 'MFPT_SA_100.mat');
require_file(barrierFile);
require_file(mfpt88File);
require_file(mfpt100File);

B = load(barrierFile, 'Barrier_S', 'gIE_list_S');
M88 = load(mfpt88File, 'MFPT2', 'gIE_list');
M100 = load(mfpt100File, 'MFPT2', 'gIE_list'); %#ok<NASGU>

% Preserve the manuscript plotting program: the S-to-A curve uses the
% MFPT_SA_88 data, while MFPT_SA_100 is retained as an accompanying source
% dataset because it was loaded by the original main program.
gIE_mfpt = M88.gIE_list;
MFPT = mean(M88.MFPT2, 1, 'omitnan');

%% a: synchronized-state barrier
plot_Syn_fit_curve(B.Barrier_S, B.gIE_list_S, outputDir, ...
    'Visible', 'off', 'Save', true, 'LineWidth', 3.5, ...
    'MarkerSize', 10, 'SaveName', 'S3_a_barrier_Syn_fit.png', ...
    'RobustDelta', 8, 'ConfidenceLevel', 0.95, ...
    'ConfidenceLowerBound', 0, 'ConfidenceOnlyWithinData', true, ...
    'CurveExtendFraction', 0.01, 'BandAlpha', 0.22, ...
    'StatsPosition', [0.88 0.12], 'StatsFontSize', 22, ...
    'ShowLegend', false, 'LeftExtend', 0.01, ...
    'TailExtend', 0.00008, 'PanelLabel', '', ...
    'LegendText', '\DeltaU_{Syn}');

%% b: mean first-passage time from synchronized to asynchronous state
plot_MFPT_SA_fit(gIE_mfpt, MFPT, outputDir, ...
    'Visible', 'off', 'Save', true, ...
    'SaveName', 'S3_b_MFPT_SA_fit.png', ...
    'ConfidenceLevel', 0.95, 'ConfidenceLowerBound', 0, ...
    'BandAlpha', 0.22, 'StatsPosition', [0.12 0.78], ...
    'StatsFontSize', 24, 'ShowLegend', false, 'PanelLabel', '', ...
    'LeftExtend', 0.0002, 'RightExtend', 0.001);

%% c: log(MFPT) versus synchronized-state barrier
fitOpts = struct('ConfidenceLevel', 0.95, 'ShowEquation', false, ...
    'BandAlpha', 0.28, 'AnnotationPosition', [0.88 0.12], ...
    'StatsFontSize', 26);
prepare_and_plot_S_MFPT_vs_Barrier( ...
    B.gIE_list_S, B.Barrier_S, gIE_mfpt, MFPT, ...
    outputDir, true, fitOpts);

fprintf('SI Figure S3a-c saved under:\n  %s\n', outputDir);

function require_file(filePath)
if ~exist(filePath, 'file')
    error('Required data file not found:\n  %s', filePath);
end
end
