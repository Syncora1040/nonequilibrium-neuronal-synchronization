%% PLOT_Fig2_ABCD
% Reproduce Fig. 2 as a 2-by-2 composite:
% A/B: mean-field coupling maps (R_E and R_I)
% C:   finite-N mean-field R_E bifurcation comparison
% D:   SDE versus deterministic R_E bifurcation comparison

clear; clc; clear functions;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
figureDir = fileparts(scriptDir);
addpath(scriptDir);

%% ========================================================================
% Global appearance settings -- adjust the whole figure here
% ========================================================================
fontName = 'Times New Roman';
axisFontSize = 24;          % All numeric tick labels
axisLabelFontSize = 28;     % g_IE, g_EI, R_E
textFontSize = 28;          % Regime/state text in A, B and D
legendFontSize = 24;        % Legend in C
panelLetterFontSize = 36;   % A, B, C, D
fontWeight = 'bold';        % All ticks and English text
cLegendYOffset = -0.075;    % C legend vertical shift; more negative = lower
panelLetterX_AB = -0.27;    % A/B letters; more negative = farther left
panelLetterX_CD = -0.20;    % C/D letters

axisLineWidth = 1.8;
curveLineWidth = 5.6;
sCurveLineWidth = 2.5;
scatterLineWidth = 1.5;
finiteScatterSize = [48 52 48];
outputDpi = 300;

figureSizePixels = [80 50 1350 1200];
tilePadding = 'compact';
tileSpacing = 'compact';

% A/B regime-label positions, in data coordinates [x y].
aTextPos.synchronized = [0.14 0.123];
aTextPos.bistable = [0.07 0.070];
aTextPos.asynchronous = [0.065 0.020];

bTextPos.synchronized = [0.14 0.123];
bTextPos.bistable = [0.07 0.070];
bTextPos.asynchronous = [0.065 0.020];

% D state-label positions, in data coordinates [x y].
dTextPos.SFS = [0.17 0.90];
dTextPos.AFS = [0.085 0.31];

% Couplings selected for A/B.
map_gEE = 0.10;
map_gII = 0.05;

% C settings and finite-size datasets.
c_gEE = 0.10;
c_gEI = 0.08;
c_gII = 0.05;
cNoiseTag = 'D4e-6';
cNList = [60 100 500];
cXLimits = [0 0.4];
cGreenLineWidth = 9.5;      % C green Mean field AFS line only
cLegendText = { ...
    'Mean field AFS', ...
    'Mean field SFS', ...
    'N=60', ...
    'N=100', ...
    'N=500'};

% D uses the parameter choice in PLOT_compare_bifurcation_sde_deterministic.
d_gEE = 0.10;
d_gEI = 0.08;
d_gII = 0.05;
dXLimits = [0 0.35];

%% ========================================================================
% Data files
% ========================================================================
dataDir = fullfile(figureDir, 'data');
mapFile = fullfile(dataDir, ...
    'MF_coupling_phase_map_single_fine_gEE100_gII050_server24.mat');
must_exist(mapFile, 'A/B coupling-map data');

cParamTag = coupling_tag(c_gEE, c_gEI, c_gII);
cScanTag = sprintf('%s_%s', cParamTag, cNoiseTag);
cDataDir = dataDir;
cDetFile = fullfile(dataDir, ...
    sprintf('MF_bifurcation_gIE_scan_%s.mat', cParamTag));
must_exist(cDetFile, 'C deterministic bifurcation data');

cScanFiles = cell(numel(cNList), 1);
for iN = 1:numel(cNList)
    cScanFiles{iN} = fullfile(cDataDir, sprintf( ...
        'MF_gIE_bifurcation_%s_NE%d_NI%d.mat', ...
        cScanTag, cNList(iN), cNList(iN)));
    must_exist(cScanFiles{iN}, sprintf('C finite-N=%d data', cNList(iN)));
end

dParamTag = coupling_tag(d_gEE, d_gEI, d_gII);
dDetFile = fullfile(dataDir, ...
    sprintf('MF_bifurcation_gIE_scan_%s.mat', dParamTag));
dSDEFile = fullfile(dataDir, 'SDE_bifurcation_from_mPlot_weight.mat');
must_exist(dDetFile, 'D deterministic bifurcation data');
must_exist(dSDEFile, 'D saved SDE bifurcation data');

%% ========================================================================
% Load data
% ========================================================================
Smap = load(mapFile, 'scanCoupling');
if ~isfield(Smap, 'scanCoupling')
    error('scanCoupling is missing in:\n  %s', mapFile);
end
scanCoupling = Smap.scanCoupling;

ScDet = load(cDetFile, 'scanBif');
cDet = ScDet.scanBif;
cScans = cell(numel(cScanFiles), 1);
for iN = 1:numel(cScanFiles)
    Sfinite = load(cScanFiles{iN}, 'scanN');
    cScans{iN} = Sfinite.scanN;
end

SdDet = load(dDetFile, 'scanBif');
SdSDE = load(dSDEFile, 'bifE_sde');
dDet = SdDet.scanBif;
if ~isfield(SdSDE, 'bifE_sde')
    error('bifE_sde is missing in:\n  %s', dSDEFile);
end
dSDE = SdSDE.bifE_sde;

%% ========================================================================
% Draw 2-by-2 figure
% ========================================================================
fig = figure('Color', 'w', 'Position', figureSizePixels);
tlo = tiledlayout(fig, 2, 2, ...
    'Padding', tilePadding, 'TileSpacing', tileSpacing);

common = struct( ...
    'fontName', fontName, ...
    'axisFontSize', axisFontSize, ...
    'axisLabelFontSize', axisLabelFontSize, ...
    'textFontSize', textFontSize, ...
    'legendFontSize', legendFontSize, ...
    'cLegendYOffset', cLegendYOffset, ...
    'panelLetterFontSize', panelLetterFontSize, ...
    'fontWeight', fontWeight, ...
    'axisLineWidth', axisLineWidth, ...
    'curveLineWidth', curveLineWidth, ...
    'sCurveLineWidth', sCurveLineWidth, ...
    'scatterLineWidth', scatterLineWidth);

axA = nexttile(tlo, 1);
plot_coupling_map(axA, scanCoupling, 'RE', map_gEE, map_gII, ...
    aTextPos, true, common);
add_panel_letter(axA, 'A', panelLetterX_AB, common);

axB = nexttile(tlo, 2);
plot_coupling_map(axB, scanCoupling, 'RI', map_gEE, map_gII, ...
    bTextPos, false, common);
add_panel_letter(axB, 'B', panelLetterX_AB, common);

axC = nexttile(tlo, 3);
plot_finite_N_RE(axC, cScans, cDet, cLegendText, ...
    cXLimits, cGreenLineWidth, finiteScatterSize, common);
add_panel_letter(axC, 'C', panelLetterX_CD, common);

axD = nexttile(tlo, 4);
plot_sde_deterministic_RE(axD, dDet, dSDE, dTextPos, ...
    dXLimits, common);
add_panel_letter(axD, 'D', panelLetterX_CD, common);

% Reassert global typography after colorbars and legends have been created.
allAxes = [axA axB axC axD];
set(allAxes, 'FontName', fontName, 'FontSize', axisFontSize, ...
    'FontWeight', fontWeight, 'LineWidth', axisLineWidth, 'TickDir', 'in');
set(findall(fig, 'Type', 'text'), ...
    'FontName', fontName, 'FontWeight', fontWeight);

outDir = fullfile(figureDir, 'output');
if ~exist(outDir, 'dir'), mkdir(outDir); end
outPng = fullfile(outDir, 'Fig2_ABCD.png');
outPdf = fullfile(outDir, 'Fig2_ABCD.pdf');
outFig = fullfile(outDir, 'Fig2_ABCD.fig');
exportgraphics(fig, outPng, 'Resolution', outputDpi);
exportgraphics(fig, outPdf, 'ContentType', 'vector');
savefig(fig, outFig);

fprintf('Fig. 2 composite saved:\n  %s\n  %s\n  %s\n', ...
    outPng, outPdf, outFig);

%% ========================================================================
% Local plotting functions
% ========================================================================
function plot_coupling_map(ax, scanCoupling, popName, selectedGEE, selectedGII, ...
    textPos, asyncTextWhite, s)

gIE = scanCoupling.gIE_list(:).';
gEI = scanCoupling.gEI_list(:).';
iEE = nearest_index(scanCoupling.gEE_list, selectedGEE);
iII = nearest_index(scanCoupling.gII_list, selectedGII);
stateGrid = coupling_state_grid(scanCoupling, popName);
Z = squeeze(stateGrid(:, :, iII, iEE)).';

h = imagesc(ax, gIE, gEI, Z);
h.AlphaData = isfinite(Z);
axis(ax, 'xy');
axis(ax, 'tight');
ax.CLim = [0 1];
ax.Color = [0.88 0.88 0.88];
ax.Layer = 'top';
box(ax, 'on');
colormap(ax, slanCM('plasma', 256));

cb = colorbar(ax);
cb.Ticks = 0:0.2:1;
cb.FontName = s.fontName;
cb.FontSize = s.axisFontSize;
cb.FontWeight = s.fontWeight;
cb.LineWidth = s.axisLineWidth;

style_axis(ax, s);
xlabel(ax, 'g_{IE}', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);
ylabel(ax, 'g_{EI}', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);

text(ax, textPos.synchronized(1), textPos.synchronized(2), ...
    'SFS regime', 'FontName', s.fontName, ...
    'FontSize', s.textFontSize, 'FontWeight', s.fontWeight, ...
    'Color', 'k', 'HorizontalAlignment', 'left');
text(ax, textPos.bistable(1), textPos.bistable(2), ...
    'Bistable regime', 'FontName', s.fontName, ...
    'FontSize', s.textFontSize, 'FontWeight', s.fontWeight, ...
    'Color', 'k', 'HorizontalAlignment', 'left');
asyncColor = 'k';
if asyncTextWhite, asyncColor = 'w'; end
text(ax, textPos.asynchronous(1), textPos.asynchronous(2), ...
    'AFS regime', 'FontName', s.fontName, ...
    'FontSize', s.textFontSize, 'FontWeight', s.fontWeight, ...
    'Color', asyncColor, 'HorizontalAlignment', 'left');
end

function plot_finite_N_RE(ax, scans, det, legendText, xLimits, ...
    greenLineWidth, scatterSizes, s)
hold(ax, 'on');
asyncColor = [0 0.55 0];
syncColor = [0.45 0 1];
finiteColors = [0.00 0.45 0.95; 1.00 0.20 0.05; 0.50 0.00 0.90];
markers = {'d', '^', 'o'};

gDet = det.gIE_list(:);
idxA = logical(det.fp_converged(:)) & logical(det.fp_stable(:)) & ...
    isfinite(det.fp_RE(:));
idxS = logical(det.sync_converged(:)) & logical(det.sync_stable(:)) & ...
    isfinite(det.sync_RE(:));
hA = plot(ax, gDet(idxA), det.fp_RE(idxA), '-', 'Color', asyncColor, ...
    'LineWidth', greenLineWidth);
hS = plot(ax, gDet(idxS), det.sync_RE(idxS), '-', 'Color', syncColor, ...
    'LineWidth', s.curveLineWidth);

hN = gobjects(numel(scans), 1);
allGCells = cellfun(@(x) x.gIE_list(:), scans, 'UniformOutput', false);
allG = vertcat(allGCells{:});
xOffsets = linspace(-0.004, 0.004, numel(scans)) * ...
    (max(allG) - min(allG));
for k = 1:numel(scans)
    scanN = scans{k};
    g = scanN.gIE_list(:) + xOffsets(k);
    a = scanN.RE_asyn_mean(:);
    y = scanN.RE_sync_mean(:);
    idxAfinite = scanN.RE_asyn_weight(:) > 0 & isfinite(a);
    idxSfinite = scanN.RE_sync_weight(:) > 0 & isfinite(y);
    stagger = false(numel(g), 1);
    stagger(k:numel(scans):end) = true;
    idxAfinite = idxAfinite & stagger;
    idxSfinite = idxSfinite & stagger;
    hN(k) = scatter(ax, g(idxAfinite), a(idxAfinite), scatterSizes(k), ...
        markers{k}, 'MarkerEdgeColor', finiteColors(k,:), ...
        'MarkerFaceColor', 'none', 'LineWidth', s.scatterLineWidth);
    scatter(ax, g(idxSfinite), y(idxSfinite), scatterSizes(k), ...
        markers{k}, 'MarkerEdgeColor', finiteColors(k,:), ...
        'MarkerFaceColor', 'none', 'LineWidth', s.scatterLineWidth, ...
        'HandleVisibility', 'off');
end

style_axis(ax, s);
grid(ax, 'on');
ax.GridAlpha = 0.18;
xlim(ax, xLimits);
ylim(ax, [0.32 1.05]);
xlabel(ax, 'g_{IE}', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);
ylabel(ax, 'R_E', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);

if numel(legendText) ~= 2 + numel(scans)
    error('cLegendText must contain two mean-field labels and one label per finite-N scan.');
end
lgd = legend(ax, [hA; hS; hN], legendText, 'Box', 'off', ...
    'FontName', s.fontName, 'FontSize', s.legendFontSize, ...
    'FontWeight', s.fontWeight, 'Location', 'north');
lgd.NumColumns = 1;
lgd.Units = 'normalized';
lgd.Position(2) = lgd.Position(2) + s.cLegendYOffset;
end

function plot_sde_deterministic_RE(ax, det, bifSDE, textPos, xLimits, s)
hold(ax, 'on');
asyncColor = [0.10 0.60 0.20];
syncColor = [0.55 0.10 0.80];

g = det.gIE_list(:);
a = det.fp_RE(:);
y = det.sync_RE(:);
idxA = logical(det.fp_converged(:)) & logical(det.fp_stable(:)) & isfinite(a);
idxS = logical(det.sync_converged(:)) & logical(det.sync_stable(:)) & isfinite(y);
plot(ax, g(idxA), a(idxA), '-', 'Color', asyncColor, ...
    'LineWidth', s.curveLineWidth, 'HandleVisibility', 'off');
plot(ax, g(idxS), y(idxS), '-', 'Color', syncColor, ...
    'LineWidth', s.curveLineWidth, 'HandleVisibility', 'off');

add_s_curve(ax, g, a, y, idxA, idxS, s);

gSDE = bifSDE.g(:);
aSDE = bifSDE.R_async(:);
ySDE = bifSDE.R_sync(:);
scatter(ax, gSDE(isfinite(aSDE)), aSDE(isfinite(aSDE)), 64, 'o', ...
    'MarkerEdgeColor', asyncColor, 'MarkerFaceColor', 'none', ...
    'LineWidth', s.scatterLineWidth, 'HandleVisibility', 'off');
scatter(ax, gSDE(isfinite(ySDE)), ySDE(isfinite(ySDE)), 64, 'd', ...
    'MarkerEdgeColor', syncColor, 'MarkerFaceColor', 'none', ...
    'LineWidth', s.scatterLineWidth, 'HandleVisibility', 'off');

text(ax, textPos.SFS(1), textPos.SFS(2), 'SFS', 'Color', syncColor, ...
    'FontName', s.fontName, 'FontSize', s.textFontSize, ...
    'FontWeight', s.fontWeight);
text(ax, textPos.AFS(1), textPos.AFS(2), 'AFS', 'Color', asyncColor, ...
    'FontName', s.fontName, 'FontSize', s.textFontSize, ...
    'FontWeight', s.fontWeight);

style_axis(ax, s);
xlim(ax, xLimits);
ylim(ax, [0.25 1.05]);
xlabel(ax, 'g_{IE}', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);
ylabel(ax, 'R_E', 'FontSize', s.axisLabelFontSize, ...
    'FontWeight', s.fontWeight);
end

function add_s_curve(ax, g, asyncY, syncY, idxA, idxS, s)
gA = g(idxA); yA = asyncY(idxA);
gS = g(idxS); yS = syncY(idxS);
if isempty(gA) || isempty(gS), return; end
[g0, i0] = min(gS);
y0 = yS(i0);
[g3, i3] = max(gA);
y3 = yA(i3);
if g3 <= g0, return; end
dx = g3 - g0;
dy = y0 - y3;
p0 = [g0 y0];
p1 = [g0 + 0.12*dx, y0 - 0.20*dy];
p2 = [g0 + 1.00*dx, y0 - 0.38*dy];
p3 = [g3 y3];
t = linspace(0, 1, 180);
b0 = (1-t).^3;
b1 = 3*(1-t).^2.*t;
b2 = 3*(1-t).*t.^2;
b3 = t.^3;
x = b0*p0(1) + b1*p1(1) + b2*p2(1) + b3*p3(1);
y = b0*p0(2) + b1*p1(2) + b2*p2(2) + b3*p3(2);
plot(ax, x, y, '--', 'Color', [0.38 0.38 0.38], ...
    'LineWidth', s.sCurveLineWidth, 'HandleVisibility', 'off');
end

function style_axis(ax, s)
box(ax, 'on');
ax.FontName = s.fontName;
ax.FontSize = s.axisFontSize;
ax.FontWeight = s.fontWeight;
ax.LineWidth = s.axisLineWidth;
ax.TickDir = 'in';
ax.XLabel.FontName = s.fontName;
ax.YLabel.FontName = s.fontName;
end

function add_panel_letter(ax, letterText, xPosition, s)
text(ax, xPosition, 1.08, letterText, 'Units', 'normalized', ...
    'FontName', s.fontName, 'FontSize', s.panelLetterFontSize, ...
    'FontWeight', s.fontWeight, 'Color', 'k', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
    'Clipping', 'off');
end

function grid = coupling_state_grid(scanCoupling, popName)
gridName = ['state_' popName '_grid'];
rowName = ['state_' popName];
if isfield(scanCoupling, gridName)
    grid = scanCoupling.(gridName);
elseif isfield(scanCoupling, 'rows') && isfield(scanCoupling.rows, rowName)
    grid = reshape(scanCoupling.rows.(rowName), ...
        [numel(scanCoupling.gIE_list), numel(scanCoupling.gEI_list), ...
         numel(scanCoupling.gII_list), numel(scanCoupling.gEE_list)]);
elseif isfield(scanCoupling, 'rows') && ...
        isfield(scanCoupling.rows, 'regime_code')
    code = scanCoupling.rows.regime_code;
    if strcmpi(popName, 'RE')
        fp = scanCoupling.rows.fp_RE;
    else
        fp = scanCoupling.rows.fp_RI;
    end
    values = nan(size(code));
    values(code == 1) = fp(code == 1);
    values(code == 2) = 1;
    values(code == 3) = 0.5 * (fp(code == 3) + 1);
    grid = reshape(values, ...
        [numel(scanCoupling.gIE_list), numel(scanCoupling.gEI_list), ...
         numel(scanCoupling.gII_list), numel(scanCoupling.gEE_list)]);
else
    error('Cannot find or reconstruct %s.', gridName);
end
end

function idx = nearest_index(values, target)
[~, idx] = min(abs(values(:) - target));
end

function tag = coupling_tag(gEE, gEI, gII)
tag = sprintf('gEE%03d_gEI%03d_gII%03d', ...
    round(100*gEE), round(100*gEI), round(100*gII));
end

function must_exist(filePath, description)
if ~exist(filePath, 'file')
    error('%s not found:\n  %s', description, filePath);
end
end
