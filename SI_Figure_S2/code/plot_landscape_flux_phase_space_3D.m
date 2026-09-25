function outFile = plot_landscape_flux_phase_space_3D(landscape, flux, param, outDir, varargin)
% Plot a 3D landscape with normalized steady-flux arrows on the surface.

p = inputParser;
addParameter(p, 'Visible', 'off');
addParameter(p, 'Save', true, @islogical);
addParameter(p, 'PlotFluxArrows', true, @islogical);
addParameter(p, 'Step', [], @(v) isempty(v) || (isnumeric(v) && numel(v) == 2));
addParameter(p, 'ArrowBase', 0.045, @isnumeric);
addParameter(p, 'ArrowLineWidth', 2.2, @isnumeric);
addParameter(p, 'ArrowColor', [1 1 1], @isnumeric);
addParameter(p, 'SurfaceAlpha', 0.94, @isnumeric);
addParameter(p, 'UCap', 14, @isnumeric);
addParameter(p, 'FluxPThreshold', 1e-4, @isnumeric);
addParameter(p, 'View', [35 55], @(v) isnumeric(v) && numel(v) == 2);
addParameter(p, 'ZOffset', 0.025, @isnumeric);
addParameter(p, 'FigurePosition', [100 100 1050 850], @isnumeric);
addParameter(p, 'AxisFontSize', 25, @isnumeric);
addParameter(p, 'LabelFontSize', 34, @isnumeric);
addParameter(p, 'ShowTitle', false, @islogical);
addParameter(p, 'ColorMap', [], @isnumeric);
addParameter(p, 'XLim', [-1 1], @(v) isnumeric(v) && numel(v) == 2);
addParameter(p, 'YLim', [-1 1], @(v) isnumeric(v) && numel(v) == 2);
parse(p, varargin{:});
opt = p.Results;

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

x = landscape.x_centers(:).';
y = landscape.y_centers(:).';
U = min(landscape.U, opt.UCap);
[X, Y] = meshgrid(x, y);

nx = numel(x); ny = numel(y);
if isempty(opt.Step)
    sx = max(1, round(nx / 25));
    sy = max(1, round(ny / 25));
else
    sx = max(1, round(opt.Step(1)));
    sy = max(1, round(opt.Step(2)));
end

ix = 1:sx:nx;
iy = 1:sy:ny;
Xq = X(iy, ix); Yq = Y(iy, ix);
Jx = flux.Jx(iy, ix); Jy = flux.Jy(iy, ix);
Pq = flux.P(iy, ix);
valid = flux.validMask(iy, ix) & ...
    Pq >= opt.FluxPThreshold * max(flux.P(:)) & isfinite(Jx) & isfinite(Jy);

mag = hypot(Jx, Jy);
ux = zeros(size(Jx)); uy = zeros(size(Jy));
nonzero = valid & mag > 0;
ux(nonzero) = Jx(nonzero) ./ mag(nonzero);
uy(nonzero) = Jy(nonzero) ./ mag(nonzero);
arrowLength = opt.ArrowBase * min(range(x), range(y));
ux = ux * arrowLength;
uy = uy * arrowLength;

Zq = interp2(X, Y, U, Xq, Yq, 'linear');
zRange = max(U(:)) - min(U(:));
if ~isfinite(zRange) || zRange <= 0, zRange = 1; end
Zq = Zq + opt.ZOffset * zRange;

fig = figure('Color', 'w', 'Visible', opt.Visible, 'Position', opt.FigurePosition);
ax = axes(fig);
hold(ax, 'on');
surf(ax, X, Y, U, 'EdgeColor', 'none', 'FaceAlpha', opt.SurfaceAlpha);
shading(ax, 'interp');

if isempty(opt.ColorMap)
    try
        cmap = slanCM('viridis');
    catch
        cmap = turbo(256);
    end
else
    cmap = opt.ColorMap;
end
colormap(ax, cmap);
colorbar(ax);

if opt.PlotFluxArrows
    quiver3(ax, Xq(nonzero), Yq(nonzero), Zq(nonzero), ...
        ux(nonzero), uy(nonzero), zeros(nnz(nonzero), 1), 0, ...
        'Color', opt.ArrowColor, 'LineWidth', opt.ArrowLineWidth, 'MaxHeadSize', 4);
end

[xLabel, yLabel, shortName] = axis_labels(landscape.spaceName);
xlabel(ax, xLabel, 'Interpreter', 'tex', 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
ylabel(ax, yLabel, 'Interpreter', 'tex', 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
zlabel(ax, '\bf U', 'Interpreter', 'tex', 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
ax.XLabel.FontWeight = 'bold';
ax.YLabel.FontWeight = 'bold';
ax.ZLabel.FontWeight = 'bold';
if opt.ShowTitle
    title(ax, sprintf('$g_{IE}=%.5f$', param.gIE), 'Interpreter', 'latex', ...
        'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
end

set(ax, 'FontSize', opt.AxisFontSize, 'FontWeight', 'bold', ...
    'LineWidth', 1.8, 'TickDir', 'in', 'Box', 'on');
grid(ax, 'on');
xlim(ax, opt.XLim);
ylim(ax, opt.YLim);
view(ax, opt.View(1), opt.View(2));
caxis(ax, [0 opt.UCap]);

outFile = fullfile(outDir, sprintf('LF_3D_%s_gIE=%.5f.png', shortName, param.gIE));
if opt.Save
    exportgraphics(fig, outFile, 'Resolution', 300);
end
if strcmpi(opt.Visible, 'off')
    close(fig);
end
end

function [xLabel, yLabel, shortName] = axis_labels(spaceName)
key = lower(regexprep(char(spaceName), '[^a-zA-Z0-9]', ''));
switch key
    case {'eplane', 'recospsieresinpsie'}
        xLabel = '\bf R_{E} cos\psi_{E}'; yLabel = '\bf R_{E} sin\psi_{E}';
        shortName = 'REcospsiE_REsinpsiE';
    case {'iplane', 'ricospsiirisinpsii'}
        xLabel = '\bf R_{I} cos\psi_{I}'; yLabel = '\bf R_{I} sin\psi_{I}';
        shortName = 'RIcospsiI_RIsinpsiI';
    case {'cosphase', 'cospsiecospsii'}
        xLabel = '\bf cos\psi_{E}'; yLabel = '\bf cos\psi_{I}';
        shortName = 'cospsiE_cospsiI';
    otherwise
        error('Unknown phase space: %s', string(spaceName));
end
end
