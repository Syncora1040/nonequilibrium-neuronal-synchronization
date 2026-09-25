function outFile = plot_three_gIE_steady_trajectories(dataByGIE, gIEList, spec, outDir, opts)
% Draw steady trajectories for one or more gIE values in a specified 2D space.

if nargin < 5, opts = struct(); end
opts = fill_defaults(opts);
if numel(dataByGIE) ~= numel(gIEList)
    error('dataByGIE and gIEList must have the same length.');
end
if ~exist(outDir, 'dir'), mkdir(outDir); end

fig = figure('Color', 'w', 'Visible', opts.Visible, ...
    'Position', opts.FigurePosition);
tl = tiledlayout(fig, 1, numel(gIEList), 'TileSpacing', 'compact', ...
    'Padding', 'compact');

asynColor = [0.00 0.55 0.15];
synColor = [0.49 0.18 0.75];

for ig = 1:numel(gIEList)
    ax = nexttile(tl, ig);
    hold(ax, 'on');
    traces = dataByGIE{ig};
    for k = 1:numel(traces)
        trace = traces{k};
        xy = trace.xy;
        if strcmpi(trace.state, 'Syn')
            lineColor = synColor;
        else
            lineColor = asynColor;
        end
        scatter(ax, xy(:, 1), xy(:, 2), opts.ScatterSize, lineColor, ...
            'filled', ...
            'MarkerFaceAlpha', opts.ScatterAlpha, ...
            'MarkerEdgeAlpha', 0);
    end

    set(ax, 'FontSize', opts.AxisFontSize, 'FontWeight', 'bold', ...
        'LineWidth', 1.8, 'Box', 'on', 'TickDir', 'in');

    xLabelHandle = xlabel(ax, spec.xLabel, 'Interpreter', 'tex', ...
        'FontSize', opts.LabelFontSize, 'FontWeight', 'bold');
    yLabelHandle = ylabel(ax, spec.yLabel, 'Interpreter', 'tex', ...
        'FontSize', opts.LabelFontSize, 'FontWeight', 'bold');
    titleHandle = title(ax, spec.title, ...
        'Interpreter', 'tex', 'FontSize', opts.TitleFontSize, ...
        'FontWeight', 'bold');

    % Keep explicit sizes independent of subsequent axes font updates.
    set(xLabelHandle, 'FontSize', opts.LabelFontSize, 'FontWeight', 'bold');
    set(yLabelHandle, 'FontSize', opts.LabelFontSize, 'FontWeight', 'bold');
    set(titleHandle, 'FontSize', opts.TitleFontSize, 'FontWeight', 'bold');

    grid(ax, 'on');
    if ~isempty(spec.xLim), xlim(ax, spec.xLim); end
    if ~isempty(spec.yLim), ylim(ax, spec.yLim); end
    if spec.axisEqual, axis(ax, 'equal'); end

    if opts.ShowStateText
        text(ax, spec.afsTextPosition(1), spec.afsTextPosition(2), 'AFS', ...
            'Color', asynColor, ...
            'FontSize', opts.StateTextFontSize, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
        text(ax, spec.sfsTextPosition(1), spec.sfsTextPosition(2), 'SFS', ...
            'Color', synColor, ...
            'FontSize', opts.StateTextFontSize, ...
            'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');
    end

    if opts.ShowLegend
        hAsyn = scatter(ax, nan, nan, opts.LegendMarkerSize, asynColor, 'filled');
        hSyn = scatter(ax, nan, nan, opts.LegendMarkerSize, synColor, 'filled');
        legend(ax, [hAsyn hSyn], {'Asynchronous state', 'Synchronized state'}, ...
            'Location', 'best', ...
            'FontSize', opts.LegendFontSize, 'FontWeight', 'bold', ...
            'Box', 'off');
    end
end

outFile = fullfile(outDir, spec.fileName);
exportgraphics(fig, outFile, 'Resolution', opts.OutputDpi);
end

function opts = fill_defaults(opts)
if ~isfield(opts, 'Visible'), opts.Visible = 'on'; end
if ~isfield(opts, 'ScatterSize'), opts.ScatterSize = 9; end
if ~isfield(opts, 'ScatterAlpha'), opts.ScatterAlpha = 0.16; end
if ~isfield(opts, 'AxisFontSize'), opts.AxisFontSize = 18; end
if ~isfield(opts, 'LabelFontSize'), opts.LabelFontSize = 24; end
if ~isfield(opts, 'TitleFontSize'), opts.TitleFontSize = 22; end
if ~isfield(opts, 'FigurePosition'), opts.FigurePosition = [80 100 1650 520]; end
if ~isfield(opts, 'OutputDpi'), opts.OutputDpi = 300; end
if ~isfield(opts, 'ShowLegend'), opts.ShowLegend = false; end
if ~isfield(opts, 'ShowStateText'), opts.ShowStateText = true; end
if ~isfield(opts, 'StateTextFontSize'), opts.StateTextFontSize = 22; end
if ~isfield(opts, 'LegendFontSize'), opts.LegendFontSize = 25; end
if ~isfield(opts, 'LegendMarkerSize'), opts.LegendMarkerSize = 280; end
end
