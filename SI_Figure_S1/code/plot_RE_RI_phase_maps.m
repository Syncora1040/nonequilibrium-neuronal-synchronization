function outFiles = plot_RE_RI_phase_maps(matFile, outDir)
% Draw only the R_E and R_I value maps from the finite-N 4D scan.

S = load(matFile);
required = { ...
    'gEE_range', 'gII_range', 'gEI_range', 'gIE_range', ...
    'RE_phase_type_4D', 'RI_phase_type_4D', ...
    'RE_asyn_mean_4D', 'RE_sync_mean_4D', ...
    'RI_asyn_mean_4D', 'RI_sync_mean_4D'};
missing = required(~cellfun(@(name) isfield(S, name), required));
if ~isempty(missing)
    error('Missing variables in %s: %s', matFile, strjoin(missing, ', '));
end
if ~exist(outDir, 'dir'), mkdir(outDir); end

RE = phase_values(S.RE_phase_type_4D, ...
    S.RE_asyn_mean_4D, S.RE_sync_mean_4D);
RI = phase_values(S.RI_phase_type_4D, ...
    S.RI_asyn_mean_4D, S.RI_sync_mean_4D);

outFiles = { ...
    fullfile(outDir, 'S1_c_RE_2D_phase_map.png'), ...
    fullfile(outDir, 'S1_d_RI_2D_phase_map.png')};
draw_value_map(RE, S, 'R_E', outFiles{1});
draw_value_map(RI, S, 'R_I', outFiles{2});
end

function values = phase_values(types, asynchronousMean, synchronizedMean)
values = nan(size(types));
idxA = types == 0;
idxS = types == 1;
idxB = types == 2;
values(idxA) = asynchronousMean(idxA);
values(idxS) = synchronizedMean(idxS);
values(idxB) = 0.5 * (asynchronousMean(idxB) + synchronizedMean(idxB));
end

function draw_value_map(values, S, valueName, outFile)
gEE = S.gEE_range(:).';
gII = S.gII_range(:).';
gEI = S.gEI_range(:).';
gIE = S.gIE_range(:).';
nEE = numel(gEE);
nII = numel(gII);

fig = figure('Color', 'w', ...
    'Position', [80 80 260*nEE+140 240*nII+120]);
tlo = tiledlayout(nII, nEE, ...
    'Padding', 'compact', 'TileSpacing', 'compact');

for row = 1:nII
    for col = 1:nEE
        ax = nexttile(tlo);
        Z = squeeze(values(col, row, :, :));
        imageHandle = imagesc(ax, gIE, gEI, Z);
        imageHandle.AlphaData = isfinite(Z);
        style_axis(ax, row, col, nII, gII(row), gEE(col));
        ax.CLim = [0 1];
    end
end

if exist('turbo', 'file')
    colormap(fig, turbo(256));
else
    colormap(fig, jet(256));
end
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = valueName;
cb.Label.FontName = 'Times New Roman';
cb.Label.FontSize = 24;
cb.Label.FontWeight = 'bold';
cb.FontName = 'Times New Roman';
cb.FontSize = 15;
cb.FontWeight = 'bold';
cb.Ticks = 0:0.2:1;

exportgraphics(fig, outFile, 'Resolution', 300);
close(fig);
end

function style_axis(ax, row, col, nII, gIIValue, gEEValue)
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
        'FontSize', 15, 'FontWeight', 'bold');
else
    ax.XTickLabel = [];
end
if col == 1
    ylabel(ax, sprintf('g_{II}=%.2f\n g_{EI}', gIIValue), ...
        'FontName', 'Times New Roman', ...
        'FontSize', 18, 'FontWeight', 'bold');
else
    ax.YTickLabel = [];
end
if row == 1
    title(ax, sprintf('g_{EE}=%.2f', gEEValue), ...
        'FontName', 'Times New Roman', ...
        'FontSize', 20, 'FontWeight', 'bold');
end
end
