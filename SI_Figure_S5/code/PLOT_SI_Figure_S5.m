%% Plot SI Figure S5: minimum-action candidates without uniformity filtering
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
P = load(pathFile, 'Sopt_forward', 'Sopt_backward', ...
    'Results_forward', 'Results_backward');
S = load(pcaFile, 'landscape_pca');

% Panel A and the unfiltered minimum-action indices.
[~, forwardIndex, backwardIndex] = plot_action_candidates( ...
    40, P.Sopt_forward, P.Sopt_backward, outputDir);
if forwardIndex ~= 9 || backwardIndex ~= 22
    error('Unexpected unfiltered candidate indices: forward=%d, backward=%d.', ...
        forwardIndex, backwardIndex);
end

% Panels B and C.
plot_selected_paths_PCA(P.Results_forward, P.Results_backward, ...
    S.landscape_pca.coeff, forwardIndex, backwardIndex, outputDir);

fprintf('SI Figure S5 panels saved under:\n  %s\n', outputDir);
