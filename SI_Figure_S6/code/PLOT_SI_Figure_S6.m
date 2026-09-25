%% Plot SI Figure S6: candidates after path-uniformity filtering
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

% Panel A and the uniformity-filtered candidate indices.
[~, forwardIndex, backwardIndex] = plot_action_candidates_with_uniformity( ...
    40, P.Sopt_forward, P.Sopt_backward, ...
    P.Results_forward, P.Results_backward, outputDir, 5);
if forwardIndex ~= 24 || backwardIndex ~= 21
    error('Unexpected filtered candidate indices: forward=%d, backward=%d.', ...
        forwardIndex, backwardIndex);
end

% Panels B and C.
plot_selected_paths_PCA(P.Results_forward, P.Results_backward, ...
    S.landscape_pca.coeff, forwardIndex, backwardIndex, outputDir);

fprintf('SI Figure S6 panels saved under:\n  %s\n', outputDir);
