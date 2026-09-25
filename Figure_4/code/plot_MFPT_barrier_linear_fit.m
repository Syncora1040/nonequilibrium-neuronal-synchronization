function stats = plot_MFPT_barrier_linear_fit(x, y, figureFolder, labels, opts)
% Ordinary least-squares fit with a confidence band for the mean response.

if nargin < 5, opts = struct(); end
opts = fill_defaults(opts);
x = x(:); y = y(:);
valid = isfinite(x) & isfinite(y);
xExcluded = x(valid & y > opts.ExcludeYAbove);
yExcluded = y(valid & y > opts.ExcludeYAbove);
valid = valid & y <= opts.ExcludeYAbove;
x = x(valid); y = y(valid);
if numel(x) < 3 || numel(unique(x)) < 2
    error('At least three finite points and two distinct x values are required.');
end
if ~exist(figureFolder, 'dir'), mkdir(figureFolder); end

% fitlm uses ordinary least squares by default. The coefficient-table p-value
% below tests H0: slope = 0. predict(...,'curve') gives the mean-response CI.
mdl = fitlm(x, y, 'linear');
xFit = linspace(min(x), max(x), opts.NumFitPoints).';
alpha = 1 - opts.ConfidenceLevel;
[yFit, yCI] = predict(mdl, xFit, 'Alpha', alpha, 'Prediction', 'curve');

slope = mdl.Coefficients.Estimate(2);
intercept = mdl.Coefficients.Estimate(1);
pSlope = mdl.Coefficients.pValue(2);
rSquared = mdl.Rsquared.Ordinary;

mainColor = [0 44 83] / 255; % Original #002c53 color.
bandColor = mainColor;

h = figure('Color', 'w', 'Position', opts.FigurePosition);
ax = axes(h); hold(ax, 'on');
fill(ax, [xFit; flipud(xFit)], [yCI(:,1); flipud(yCI(:,2))], ...
    bandColor, 'EdgeColor', 'none', 'FaceAlpha', opts.BandAlpha);
plot(ax, xFit, yFit, '-', 'Color', mainColor, 'LineWidth', opts.FitLineWidth);
scatter(ax, x, y, opts.MarkerSize, mainColor, 's', 'filled', ...
    'MarkerEdgeColor', 'w', 'LineWidth', 0.8);

xlabel(ax, labels.x, 'Interpreter', 'tex', 'FontSize', opts.LabelFontSize, ...
    'FontWeight', 'bold');
ylabel(ax, labels.y, 'Interpreter', 'tex', 'FontSize', opts.LabelFontSize, ...
    'FontWeight', 'bold');
set(ax, 'FontName', 'Times New Roman', 'FontSize', opts.AxisFontSize, ...
    'FontWeight', 'bold', 'LineWidth', 1.8, 'Box', 'on', 'TickDir', 'in');

if opts.ShowEquation
    statText = sprintf('y = %.3g x %+.3g\nR^2 = %.4f\nP = %.3g', ...
        slope, intercept, rSquared, pSlope);
else
    statText = sprintf('R^2 = %.4f\nP = %.3g', rSquared, pSlope);
end
statsAlign = 'left';
if opts.AnnotationPosition(1) > 0.5, statsAlign = 'right'; end
text(ax, opts.AnnotationPosition(1), opts.AnnotationPosition(2), statText, ...
    'Units', 'normalized', 'Interpreter', 'tex', 'Color', mainColor, ...
    'FontSize', opts.StatsFontSize, 'FontWeight', 'bold', ...
    'HorizontalAlignment', statsAlign, 'BackgroundColor', 'none', ...
    'VerticalAlignment', 'bottom');

outFile = fullfile(figureFolder, labels.file);
set(h, 'PaperPositionMode', 'auto');
print(h, outFile, '-dpng', sprintf('-r%d', opts.OutputDpi));

stats = struct('slope', slope, 'intercept', intercept, ...
    'R2', rSquared, 'pSlope', pSlope, ...
    'confidenceLevel', opts.ConfidenceLevel, 'outputFile', outFile);
fprintf('OLS fit: slope=%.6g, intercept=%.6g, R^2=%.6g, P(slope)=%.6g\n', ...
    slope, intercept, rSquared, pSlope);
fprintf('Mean-response %.1f%% confidence band saved to:\n  %s\n', ...
    100 * opts.ConfidenceLevel, outFile);
if ~isempty(xExcluded)
    fprintf('Excluded %d point(s) from display and fit using y > %.6g:\n', ...
        numel(xExcluded), opts.ExcludeYAbove);
    fprintf('  x = %.6g, y = %.6g\n', [xExcluded yExcluded].');
end
end

function opts = fill_defaults(opts)
if ~isfield(opts, 'ConfidenceLevel'), opts.ConfidenceLevel = 0.95; end
if ~isfield(opts, 'ShowEquation'), opts.ShowEquation = true; end
if ~isfield(opts, 'BandAlpha'), opts.BandAlpha = 0.28; end
if ~isfield(opts, 'AnnotationPosition'), opts.AnnotationPosition = [0.88 0.12]; end
if ~isfield(opts, 'NumFitPoints'), opts.NumFitPoints = 300; end
if ~isfield(opts, 'MarkerSize'), opts.MarkerSize = 72; end
if ~isfield(opts, 'FitLineWidth'), opts.FitLineWidth = 3.0; end
if ~isfield(opts, 'AxisFontSize'), opts.AxisFontSize = 28; end
if ~isfield(opts, 'LabelFontSize'), opts.LabelFontSize = 34; end
if ~isfield(opts, 'StatsFontSize'), opts.StatsFontSize = 26; end
if ~isfield(opts, 'FigurePosition'), opts.FigurePosition = [100 100 760 760]; end
if ~isfield(opts, 'OutputDpi'), opts.OutputDpi = 300; end
if ~isfield(opts, 'ExcludeYAbove'), opts.ExcludeYAbove = inf; end
end
