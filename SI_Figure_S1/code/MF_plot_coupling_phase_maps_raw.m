function outFiles = MF_plot_coupling_phase_maps_raw(scanCoupling, outDir, opts)

if nargin < 3
    opts = struct();
end
opts = fill_defaults(opts);

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

gIE_list = scanCoupling.gIE_list(:).';
gEI_list = scanCoupling.gEI_list(:).';
gII_list = scanCoupling.gII_list(:).';
gEE_list = scanCoupling.gEE_list(:).';

iEE_list = select_index_list(gEE_list, opts.selectedGEE);
iII_list = select_index_list(gII_list, opts.selectedGII);

state_RE_grid = get_state_grid(scanCoupling, 'RE');
state_RI_grid = get_state_grid(scanCoupling, 'RI');

outFiles = {};

outRE = fullfile(outDir, sprintf('MF_phase_map_RE_%s.png', opts.prefix));
plot_value_map(state_RE_grid, gIE_list, gEI_list, gII_list, gEE_list, ...
    iII_list, iEE_list, 'R_E', [0 1], opts.titlePrefix, ...
    opts.showFigureTitle, outRE);
outFiles{end+1} = outRE;

outRI = fullfile(outDir, sprintf('MF_phase_map_RI_%s.png', opts.prefix));
plot_value_map(state_RI_grid, gIE_list, gEI_list, gII_list, gEE_list, ...
    iII_list, iEE_list, 'R_I', [0 1], opts.titlePrefix, ...
    opts.showFigureTitle, outRI);
outFiles{end+1} = outRI;

if opts.plotRegime
    regime_grid = get_regime_grid(scanCoupling);
    outRegime = fullfile(outDir, sprintf('MF_phase_map_regime_%s.png', opts.prefix));
    plot_regime_map(regime_grid, gIE_list, gEI_list, gII_list, gEE_list, ...
        iII_list, iEE_list, opts.showFigureTitle, outRegime);
    outFiles{end+1} = outRegime;
end

end

function opts = fill_defaults(opts)

if ~isfield(opts, 'selectedGEE'), opts.selectedGEE = []; end
if ~isfield(opts, 'selectedGII'), opts.selectedGII = []; end
if ~isfield(opts, 'prefix'), opts.prefix = 'raw'; end
if ~isfield(opts, 'titlePrefix'), opts.titlePrefix = 'Raw mean-field phase map'; end
if ~isfield(opts, 'showFigureTitle'), opts.showFigureTitle = true; end
if ~isfield(opts, 'plotRegime'), opts.plotRegime = true; end

end

function idxList = select_index_list(gList, selectedValue)

if isempty(selectedValue)
    idxList = 1:length(gList);
else
    [~, idx] = min(abs(gList - selectedValue));
    idxList = idx;
end

end

function state_grid = get_state_grid(scanCoupling, popName)

gridName = ['state_' popName '_grid'];
rowName = ['state_' popName];

if isfield(scanCoupling, gridName)
    state_grid = scanCoupling.(gridName);
    return;
end

if isfield(scanCoupling, 'rows') && isfield(scanCoupling.rows, rowName)
    state_vec = scanCoupling.rows.(rowName);
    state_grid = reshape(state_vec, ...
        [length(scanCoupling.gIE_list), length(scanCoupling.gEI_list), ...
         length(scanCoupling.gII_list), length(scanCoupling.gEE_list)]);
    return;
end

if isfield(scanCoupling, 'rows') && isfield(scanCoupling.rows, 'regime_code')
    regime_code = scanCoupling.rows.regime_code;

    if strcmp(popName, 'RE') && isfield(scanCoupling.rows, 'fp_RE')
        async_vec = scanCoupling.rows.fp_RE;
    elseif strcmp(popName, 'RI') && isfield(scanCoupling.rows, 'fp_RI')
        async_vec = scanCoupling.rows.fp_RI;
    else
        error('Cannot reconstruct %s: missing fixed-point branch values.', rowName);
    end

    state_vec = nan(size(regime_code));
    state_vec(regime_code == 1) = async_vec(regime_code == 1);
    state_vec(regime_code == 2) = 1;
    state_vec(regime_code == 3) = 0.5 * (async_vec(regime_code == 3) + 1);

    state_grid = reshape(state_vec, ...
        [length(scanCoupling.gIE_list), length(scanCoupling.gEI_list), ...
         length(scanCoupling.gII_list), length(scanCoupling.gEE_list)]);
    return;
end

error('Cannot find or reconstruct %s in scanCoupling.', rowName);

end

function regime_grid = get_regime_grid(scanCoupling)

if isfield(scanCoupling, 'regime_code_grid')
    regime_grid = scanCoupling.regime_code_grid;
    return;
end

if isfield(scanCoupling, 'rows') && isfield(scanCoupling.rows, 'regime_code')
    regime_grid = reshape(scanCoupling.rows.regime_code, ...
        [length(scanCoupling.gIE_list), length(scanCoupling.gEI_list), ...
         length(scanCoupling.gII_list), length(scanCoupling.gEE_list)]);
    return;
end

error('Cannot find regime_code_grid or rows.regime_code in scanCoupling.');

end

function plot_value_map(state_grid, gIE_list, gEI_list, gII_list, gEE_list, ...
    iII_list, iEE_list, valueLabel, clim, titlePrefix, showFigureTitle, outPath)

nEE = length(iEE_list);
nII = length(iII_list);

fig = figure('Color', 'w', 'Position', [80 80 260*nEE+140 240*nII+120]);
tlo = tiledlayout(nII, nEE, 'Padding', 'compact', 'TileSpacing', 'compact');

for row = 1:nII
    iII = iII_list(row);

    for col = 1:nEE
        iEE = iEE_list(col);
        ax = nexttile(tlo);

        Z = squeeze(state_grid(:, :, iII, iEE)).';
        hImg = imagesc(ax, gIE_list, gEI_list, Z);
        set(hImg, 'AlphaData', ~isnan(Z));

        style_axes(ax, row, col, nII, gII_list(iII), gEE_list(iEE));
        ax.CLim = clim;
    end
end

if exist('turbo', 'file')
    colormap(fig, turbo(256));
else
    colormap(fig, jet(256));
end

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = valueLabel;
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.FontName = 'Times New Roman';
cb.FontSize = 15;
cb.FontWeight = 'bold';
cb.Ticks = clim(1):0.2:clim(2);

if showFigureTitle
    title(tlo, sprintf('%s: %s', titlePrefix, valueLabel), ...
        'FontName', 'Times New Roman', 'FontSize', 24, 'FontWeight', 'bold');
end

exportgraphics(fig, outPath, 'Resolution', 300);

end

function plot_regime_map(regime_grid, gIE_list, gEI_list, gII_list, gEE_list, ...
    iII_list, iEE_list, showFigureTitle, outPath)

nEE = length(iEE_list);
nII = length(iII_list);

fig = figure('Color', 'w', 'Position', [80 80 260*nEE+180 240*nII+120]);
tlo = tiledlayout(nII, nEE, 'Padding', 'compact', 'TileSpacing', 'compact');

for row = 1:nII
    iII = iII_list(row);

    for col = 1:nEE
        iEE = iEE_list(col);
        ax = nexttile(tlo);

        Z = squeeze(regime_grid(:, :, iII, iEE)).';
        hImg = imagesc(ax, gIE_list, gEI_list, Z);
        set(hImg, 'AlphaData', ~isnan(Z));

        style_axes(ax, row, col, nII, gII_list(iII), gEE_list(iEE));
        ax.CLim = [-1.5 3.5];
    end
end

regimeColors = [
    0.50 0.50 0.50;  % -1 failed
    0.92 0.92 0.92;  %  0 none
    0.08 0.58 0.20;  %  1 async
    0.55 0.10 0.84;  %  2 sync
    0.95 0.55 0.10   %  3 bistable
];
colormap(fig, regimeColors);

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Ticks = -1:3;
cb.TickLabels = {'failed', 'none', 'asyn', 'syn', 'bi'};
cb.FontName = 'Times New Roman';
cb.FontSize = 13;
cb.FontWeight = 'bold';
cb.Label.String = 'Regime';
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 22;
cb.Label.FontWeight = 'bold';

if showFigureTitle
    title(tlo, 'Raw mean-field phase map: regime', ...
        'FontName', 'Times New Roman', 'FontSize', 24, 'FontWeight', 'bold');
end

exportgraphics(fig, outPath, 'Resolution', 300);

end

function style_axes(ax, row, col, nII, gIIValue, gEEValue)

axis(ax, 'xy');
axis(ax, 'tight');
box(ax, 'on');
ax.Color = [0.88 0.88 0.88];
ax.Layer = 'top';
ax.FontName = 'Times New Roman';
ax.FontSize = 13;
ax.FontWeight = 'bold';
ax.LineWidth = 1.0;
ax.TickDir = 'out';

if row == nII
    xlabel(ax, 'g_{IE}', 'FontName', 'Times New Roman', ...
        'FontSize', 19, 'FontWeight', 'bold');
else
    ax.XTickLabel = [];
end

if col == 1
    ylabel(ax, sprintf('g_{II}=%.2f\n g_{EI}', gIIValue), ...
        'FontName', 'Times New Roman', 'FontSize', 18, 'FontWeight', 'bold');
else
    ax.YTickLabel = [];
end

if row == 1
    title(ax, sprintf('g_{EE}=%.2f', gEEValue), ...
        'FontName', 'Times New Roman', 'FontSize', 20, 'FontWeight', 'bold');
end

end
