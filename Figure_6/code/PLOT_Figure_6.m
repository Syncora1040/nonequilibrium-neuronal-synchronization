%% Plot Figure 6: dominant transition paths in R and PCA spaces
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data');
outputDir = fullfile(figureDir, 'output');
addpath(scriptDir);
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

gIE = 0.20690;
forwardIndex = 24;
backwardIndex = 21;

pathFile = fullfile(dataDir, ...
    'WKB_forward_backward_scan_gIE_0.20690_nf_40.mat');
pcaFile = fullfile(dataDir, 'analysis_PCA_gIE=0.20690.mat');
rFile = fullfile(dataDir, 'analysis_R_gIE=0.20690.mat');
require_file(pathFile);
require_file(pcaFile);
require_file(rFile);

P = load(pathFile, 'Results_forward', 'Results_backward');
SPCA = load(pcaFile, 'landscape_pca');
SR = load(rFile, 'landscape_R');

if forwardIndex > numel(P.Results_forward) || ...
        isempty(P.Results_forward{forwardIndex})
    error('Forward path candidate %d is unavailable.', forwardIndex);
end
if backwardIndex > numel(P.Results_backward) || ...
        isempty(P.Results_backward{backwardIndex})
    error('Backward path candidate %d is unavailable.', backwardIndex);
end

resultForward = P.Results_forward{forwardIndex};
resultBackward = P.Results_backward{backwardIndex};
landscapePCA = SPCA.landscape_pca;
landscapeR = SR.landscape_R;
param = struct('gIE', gIE);

% Panel A: order-parameter R space
plot_3D_landscape_with_paths_R( ...
    landscapeR.cE, landscapeR.cI, landscapeR.U, ...
    resultForward.path_RE_RI, resultBackward.path_RE_RI, ...
    param, outputDir, 'Fig6_A_R.png', ...
    'Visible', 'off', 'Save', true, ...
    'View', [230.6167835934999, 69.660027220917598], ...
    'ZOffset', 0.015, 'SmoothPath', true, ...
    'SmoothN', 600, 'SmoothMethod', 'pchip');

% Panel B: PCA space
pcaForward = (resultForward.path4D' - landscapePCA.mu) * landscapePCA.coeff;
pcaBackward = (resultBackward.path4D' - landscapePCA.mu) * landscapePCA.coeff;
plot_3D_landscape_with_paths_pca( ...
    landscapePCA.c1, landscapePCA.c2, landscapePCA.U, ...
    pcaForward(:,1:2), pcaBackward(:,1:2), ...
    param, outputDir, 'Fig6_B_PCA.png', ...
    'Visible', 'off', 'Save', true, ...
    'View', [23.734144811690747, 82.304803518928281], ...
    'ZOffset', 0.015, 'SmoothPath', true, ...
    'SmoothN', 600, 'SmoothMethod', 'pchip');

fprintf('Figure 6 panels saved under:\n  %s\n', outputDir);

function require_file(filePath)
if ~exist(filePath, 'file')
    error('Required data file not found:\n  %s', filePath);
end
end
