function outFile = plot_physics_au_sde_space(g, epr, Jav, xcorr, outDir, spaceLabel, saveName, varargin)
% Draw normalized Jav, EPR, and Xcorr for one projected SDE space.

p = inputParser;
addParameter(p, 'Visible', 'off');
addParameter(p, 'Save', true, @islogical);
addParameter(p, 'Close', true, @islogical);
addParameter(p, 'OutputDpi', 300, @isnumeric);
addParameter(p, 'TransitionLines', [], @isnumeric);
addParameter(p, 'ShowTransitionLines', true, @islogical);
addParameter(p, 'LineWidth', 2.0, @isnumeric);
addParameter(p, 'MarkerSize', 10, @isnumeric);
addParameter(p, 'AxisFontSize', 45, @isnumeric);
addParameter(p, 'LabelFontSize', 55, @isnumeric);
addParameter(p, 'LegendFontSize', 42, @isnumeric);
addParameter(p, 'MarkerStride', 1, @isnumeric);
addParameter(p, 'JavPlotIndices', [], @isnumeric);
addParameter(p, 'EPRPlotIndices', [], @isnumeric);
addParameter(p, 'XcorrPlotIndices', [], @isnumeric);
addParameter(p, 'AlwaysIncludeEPRPeak', true, @islogical);
addParameter(p, 'TransitionColor', [0.55 0.00 0.80], @isnumeric);
addParameter(p, 'TransitionLineWidth', 4, @isnumeric);
addParameter(p, 'ShowTitle', false, @islogical);
parse(p, varargin{:});
opt = p.Results;

g = g(:);
Jav = Jav(:);
epr = epr(:);
xcorr = xcorr(:);
if ~(numel(g) == numel(Jav) && numel(g) == numel(epr) && numel(g) == numel(xcorr))
    error('g, Jav, epr, and xcorr must have the same length.');
end

JavAU = normalize_au(Jav);
eprAU = normalize_au(epr);
xcorrAU = normalize_au(xcorr);
idxJ = resolve_plot_indices(opt.JavPlotIndices, numel(g), opt.MarkerStride);
idxE = resolve_plot_indices(opt.EPRPlotIndices, numel(g), opt.MarkerStride);
idxX = resolve_plot_indices(opt.XcorrPlotIndices, numel(g), opt.MarkerStride);
if opt.AlwaysIncludeEPRPeak
    [~, idxPeak] = max(epr, [], 'omitnan');
    if ~isempty(idxPeak) && isfinite(epr(idxPeak))
        idxE = unique([idxE, idxPeak]);
    end
end

set(0, 'DefaultAxesFontName', 'Latin Modern Math');
set(0, 'DefaultTextFontName', 'Latin Modern Math');

fig = figure('Visible', opt.Visible, 'Color', 'w');
set(fig, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
ax = axes(fig);
hold(ax, 'on');

plot(ax, g(idxJ), JavAU(idxJ), '-o', ...
    'Color', [0.00 0.27 0.52], ...
    'LineWidth', opt.LineWidth, ...
    'MarkerSize', opt.MarkerSize, ...
    'MarkerFaceColor', 'none');
plot(ax, g(idxE), eprAU(idxE), '-^', ...
    'Color', [0.82 0.33 0.00], ...
    'LineWidth', opt.LineWidth, ...
    'MarkerSize', opt.MarkerSize, ...
    'MarkerFaceColor', [0.82 0.33 0.00]);
plot(ax, g(idxX), xcorrAU(idxX), '-p', ...
    'Color', [0.00 0.55 0.38], ...
    'LineWidth', opt.LineWidth, ...
    'MarkerSize', opt.MarkerSize + 2, ...
    'MarkerFaceColor', 'none');

if opt.ShowTransitionLines
    for iLine = 1:numel(opt.TransitionLines)
        xline(ax, opt.TransitionLines(iLine), '--', ...
            'Color', opt.TransitionColor, ...
            'LineWidth', opt.TransitionLineWidth);
    end
end

xlabel(ax, 'g_{IE}', 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
ylabel(ax, 'a.u.', 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
if opt.ShowTitle
    title(ax, spaceLabel, 'FontSize', opt.LabelFontSize, 'FontWeight', 'bold');
end
legend(ax, {'J_{av}', 'e_p', '\Delta CC'}, ...
    'FontSize', opt.LegendFontSize, 'Location', 'best', 'Box', 'off');
xlim(ax, [min(g) max(g)]);
ylim(ax, [-0.05 1.05]);
box(ax, 'on');
grid(ax, 'on');
set(ax, 'LineWidth', 2, 'FontSize', opt.AxisFontSize, 'FontWeight', 'bold');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
outFile = fullfile(outDir, saveName);
if opt.Save
    print(fig, outFile, '-dpng', sprintf('-r%d', opt.OutputDpi));
end
if opt.Close
    close(fig);
end
end

function idx = resolve_plot_indices(requested, n, markerStride)
if isempty(requested)
    idx = 1:max(1, round(markerStride)):n;
else
    idx = unique(round(requested(:).'));
    idx = idx(idx >= 1 & idx <= n);
end
if isempty(idx)
    idx = 1:n;
end
end

function y = normalize_au(x)
x = x(:);
valid = isfinite(x);
y = nan(size(x));
if ~any(valid)
    y(:) = 0;
    return;
end
xMin = min(x(valid));
xMax = max(x(valid));
if xMax - xMin < eps
    y(valid) = 0;
else
    y(valid) = (x(valid) - xMin) / (xMax - xMin);
end
y(~valid) = nan;
end
