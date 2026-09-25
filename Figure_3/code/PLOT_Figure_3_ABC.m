%% Plot steady trajectories at one gIE value in R, PCA, and phase spaces.
clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
addpath(genpath(scriptDir));

%% User settings
gIEList = 0.15517;

% Empty means plot every trajectory stored in Zss. For example, use [1 4].
trajectoryIndices = [];
tailFraction = 1.0;       % 1.0 uses the complete saved steady trajectory.
maxPointsPerTrajectory = 5000; % Fewer display points for a lower-density cloud; raw data unchanged.
phaseRMin = 0.02;         % Ignore phase where the order-parameter radius is too small.
stateClassifyTail = 800000; % Match the tail window used by classify_attractors.m.
synREThreshold = 0.7;
synRIThreshold = 0.7;

% AFS/SFS text positions in each space: [x, y].
% R amplitudes are nonnegative; PCA and cos(psi) coordinates may be negative.
rAFSTextPosition = [0.45 0.28];
rSFSTextPosition = [0.82 0.85];
pcaAFSTextPosition = [0.15 -0.5];
pcaSFSTextPosition = [0.5 0.90];
phaseAFSTextPosition = [0.55 0.8];
phaseSFSTextPosition = [0.2 0];

% Figure titles.
spaceTitles = {'Order parameter {\itR} space', 'PCA space', 'Collective phase \psi space'};

figureDir = fileparts(scriptDir);
dataDir = fullfile(figureDir, 'data', 'trajectory');
outputDir = fullfile(figureDir, 'output', 'ABC');
plotOpts = struct( ...
    'Visible', 'on', ...
    'ScatterSize', 9, ...
    'ScatterAlpha', 0.16, ...
    'AxisFontSize', 22, ...
    'LabelFontSize', 32, ...
    'TitleFontSize', 34, ...
    'ShowLegend', false, ...
    'ShowStateText', true, ...
    'StateTextFontSize', 35, ...
    'FigurePosition', [100 100 680 600], ...
    'OutputDpi', 300);
titleFontTag = sprintf('TitleFontSize%d', plotOpts.TitleFontSize);

if ~exist(dataDir, 'dir')
    error('Data folder not found:\n  %s', dataDir);
end
if ~exist(outputDir, 'dir'), mkdir(outputDir); end

spaces = {'R', 'PCA', 'CosPhase'};
spaceData = cell(numel(spaces), numel(gIEList));

fprintf('===== Load and transform steady trajectories =====\n');
for ig = 1:numel(gIEList)
    gIE = gIEList(ig);
    for iSpace = 1:numel(spaces)
        spaceData{iSpace, ig} = cell(0, 1);
    end
    rawFile = fullfile(dataDir, sprintf('R_time_gIE=%.5f.mat', gIE));
    if ~exist(rawFile, 'file')
        error('Steady trajectory file not found:\n  %s', rawFile);
    end

    fprintf('gIE = %.5f\n  loading %s\n', gIE, rawFile);
    S = load(rawFile, 'Zss');
    if ~isfield(S, 'Zss') || ~iscell(S.Zss)
        error('File must contain a cell array named Zss:\n  %s', rawFile);
    end

    idxUse = trajectoryIndices;
    if isempty(idxUse), idxUse = 1:numel(S.Zss); end
    idxUse = idxUse(idxUse >= 1 & idxUse <= numel(S.Zss));
    if isempty(idxUse), error('No valid trajectory indices for gIE = %.5f.', gIE); end

    pcaFile = fullfile(dataDir, ...
        sprintf('PCA_basis_gIE=%.5f.mat', gIE));
    if ~exist(pcaFile, 'file')
        error('PCA analysis file not found:\n  %s', pcaFile);
    end
    P = load(pcaFile, 'landscape_pca');
    if ~isfield(P, 'landscape_pca') || ...
            ~isfield(P.landscape_pca, 'coeff') || ~isfield(P.landscape_pca, 'mu')
        error('landscape_pca.coeff or landscape_pca.mu missing:\n  %s', pcaFile);
    end
    coeff = P.landscape_pca.coeff(:, 1:2);
    mu = reshape(P.landscape_pca.mu, 1, 4);

    for k = 1:numel(idxUse)
        Z = S.Zss{idxUse(k)};
        if isempty(Z), continue; end
        if size(Z, 1) ~= 2
            error('Zss{%d} must be a 2-by-T complex array.', idxUse(k));
        end

        n = size(Z, 2);
        idxClass = max(1, n - stateClassifyTail + 1):n;
        medianRE = median(abs(Z(1, idxClass)), 'omitnan');
        medianRI = median(abs(Z(2, idxClass)), 'omitnan');
        if medianRE >= synREThreshold && medianRI >= synRIThreshold
            stateLabel = 'Syn';
        else
            stateLabel = 'Asyn';
        end

        first = max(1, floor((1 - tailFraction) * n) + 1);
        stride = max(1, ceil((n - first + 1) / maxPointsPerTrajectory));
        Z = Z(:, first:stride:end);
        zE = Z(1, :).'; zI = Z(2, :).';

        spaceData{1, ig}{end+1, 1} = struct( ...
            'xy', [abs(zE), abs(zI)], 'state', stateLabel); %#ok<SAGROW>

        X4 = [real(zE), imag(zE), real(zI), imag(zI)];
        spaceData{2, ig}{end+1, 1} = struct( ...
            'xy', (X4 - mu) * coeff, 'state', stateLabel); %#ok<SAGROW>

        RE = abs(zE); RI = abs(zI);
        cosE = nan(size(RE)); cosI = nan(size(RI));
        goodE = RE >= phaseRMin; goodI = RI >= phaseRMin;
        cosE(goodE) = real(zE(goodE)) ./ RE(goodE);
        cosI(goodI) = real(zI(goodI)) ./ RI(goodI);
        spaceData{3, ig}{end+1, 1} = struct( ...
            'xy', [cosE, cosI], 'state', stateLabel); %#ok<SAGROW>
    end
    clear S P;
end

spaceSpecs = struct( ...
    'name', {'R', 'PCA', 'CosPhase'}, ...
    'title', spaceTitles, ...
    'xLabel', {'R_E', 'PC1', 'cos\psi_E'}, ...
    'yLabel', {'R_I', 'PC2', 'cos\psi_I'}, ...
    'fileName', {sprintf('steady_trajectory_RE_RI_gIE_0p15517_%s.png', titleFontTag), ...
                 sprintf('steady_trajectory_PC1_PC2_gIE_0p15517_%s.png', titleFontTag), ...
                 sprintf('steady_trajectory_cospsiE_cospsiI_gIE_0p15517_%s.png', titleFontTag)}, ...
    'axisEqual', {false, true, true}, ...
    'xLim', {[0 1], [], [-1 1.2]}, ...
    'yLim', {[0 1], [], [-1 1.2]}, ...
    'afsTextPosition', {rAFSTextPosition, pcaAFSTextPosition, phaseAFSTextPosition}, ...
    'sfsTextPosition', {rSFSTextPosition, pcaSFSTextPosition, phaseSFSTextPosition});

fprintf('\n===== Draw figures =====\n');
for iSpace = 1:numel(spaceSpecs)
    outFile = plot_three_gIE_steady_trajectories( ...
        spaceData(iSpace, :), gIEList, spaceSpecs(iSpace), outputDir, plotOpts);
    fprintf('  %s\n', outFile);
end
fprintf('===== done =====\n');
