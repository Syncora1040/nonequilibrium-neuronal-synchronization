%% Plot SI Figure S7: action heat rings for selected forward/backward paths
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir);

pathFile = fullfile(dataDir, ...
    'WKB_forward_backward_scan_gIE_0.20690_nf_40.mat');
pcaFile = fullfile(dataDir, 'analysis_PCA_gIE=0.20690.mat');
trajectoryFile = fullfile(dataDir, 'zS.mat');

P = load(pathFile, 'Sopt_forward', 'Sopt_backward', ...
    'Results_forward', 'Results_backward', 'Xf_cand');
S = load(pcaFile, 'landscape_pca');
Z = load(trajectoryFile, 'zS');

[Xlc, ~, ~] = get_Candidates_lc(Z.zS, 0.1);
pcaW = S.landscape_pca.coeff;
pcaMu = reshape(S.landscape_pca.mu, 1, 4);
XlcPCA = (Xlc' - pcaMu) * pcaW;
XlcSmooth = fit_closed_curve(XlcPCA, 200);

plot_PCA_LC_action_heatring_from_smooth( ...
    40, P.Sopt_forward, P.Sopt_backward, ...
    P.Results_forward, P.Results_backward, outputDir, ...
    pcaW, pcaMu, XlcSmooth, P.Xf_cand, 24, 21);

fprintf('SI Figure S7 panels saved under:\n  %s\n', outputDir);
