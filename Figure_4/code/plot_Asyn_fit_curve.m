function plot_Asyn_fit_curve(Barrier, gIE_list, figure_folder_name, varargin)
% fit_barrier_gIE_sigmoid_drop
%
% 用 sigmoid drop 模型拟合 barrier-gIE 关系：
%
%   B(g) = low + slope*(g-gmin) + amp / (1 + exp((g-gc)/w))
%
% 适合：
%   前面平台区缓慢下降，后面在临界 g 附近快速下降的曲线。
%
% 输入：
%   Barrier            barrier height
%   gIE_list           gIE 序列
%   figure_folder_name 保存文件夹
%
% 可选参数：
%   'Visible'       'on'/'off'
%   'Save'          true/false
%   'SaveName'      保存文件名
%   'LineWidth'     曲线宽度
%   'MarkerSize'    点大小
%   'FitN'          拟合曲线采样点数
%   'RobustDelta'   Huber robust loss 阈值
%   'UseMedianBin'  同一个 g 是否取 median 后参与拟合
%   'PanelLabel'    面板字母
%   'TailExtend'    拟合曲线右端延长量，例如 0.008

p = inputParser;

addParameter(p, 'Visible', 'on');
addParameter(p, 'Save', true, @islogical);
addParameter(p, 'SaveName', 'Barrier_sigmoid_drop_fit.png');
addParameter(p, 'LineWidth', 4, @isnumeric);
addParameter(p, 'MarkerSize', 10, @isnumeric);
addParameter(p, 'FitN', 900, @isnumeric);
addParameter(p, 'RobustDelta', 8, @isnumeric);
addParameter(p, 'UseMedianBin', true, @islogical);
addParameter(p, 'PanelLabel', '');
addParameter(p, 'ShowLegend', false, @islogical);
addParameter(p, 'TailExtend', 0.008, @isnumeric);
addParameter(p, 'CurveExtendFraction', [], ...
    @(v) isempty(v) || (isnumeric(v) && isscalar(v) && v >= 0));
addParameter(p, 'ConfidenceLevel', 0.95, @isnumeric);
addParameter(p, 'ConfidenceLowerBound', 0, @isnumeric);
addParameter(p, 'ConfidenceOnlyWithinData', true, @islogical);
addParameter(p, 'BandAlpha', 0.22, @isnumeric);
addParameter(p, 'StatsPosition', [0.88 0.78], @(v) isnumeric(v) && numel(v)==2);
addParameter(p, 'StatsFontSize', 22, @isnumeric);
addParameter(p, 'FigurePosition', [100 100 760 760], @isnumeric);

parse(p, varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

color_main = [0 44 83] / 255; % Equivalent to #002c53; compatible with fill().

% =========================================================
% data
% =========================================================
Barrier = Barrier(:);
gIE_list = gIE_list(:);

if numel(Barrier) ~= numel(gIE_list)
    error('Barrier 和 gIE_list 长度不一致。');
end

valid = isfinite(Barrier) & isfinite(gIE_list);
Barrier = Barrier(valid);
gIE_list = gIE_list(valid);

[gIE_list, idx] = sort(gIE_list);
Barrier = Barrier(idx);

% =========================================================
% 用于拟合的数据
% 如果同一个 g 有多个点，取 median，更接近趋势线
% =========================================================
if opt.UseMedianBin
    [g_fit_data, ~, ic] = unique(gIE_list);
    B_fit_data = accumarray(ic, Barrier, [], @median);
else
    g_fit_data = gIE_list;
    B_fit_data = Barrier;
end

x = g_fit_data(:);
y = B_fit_data(:);

xmin = min(x);
xmax = max(x);
yrange = max(y) - min(y);

if yrange <= 0 || ~isfinite(yrange)
    yrange = 1;
end

% =========================================================
% sigmoid drop model
% theta = [low, amp, slope, gc, logw]
% w = exp(logw), 保证 w > 0
% =========================================================
model = @(theta, xx) theta(1) + ...
                     theta(3) .* (xx - xmin) + ...
                     theta(2) ./ (1 + exp((xx - theta(4)) ./ exp(theta(5))));

% =========================================================
% 初值
% =========================================================
low0   = max(0, min(y));
high0  = max(y);
amp0   = high0 - low0;
slope0 = -20;

% 临界点初值：靠近右侧快速下降区域
gc0 = x(round(0.85 * numel(x)));

% 宽度初值：越小下降越陡
w0 = 0.004;

theta0 = [low0, amp0, slope0, gc0, log(w0)];

% =========================================================
% robust loss + 单调惩罚
% =========================================================
delta = opt.RobustDelta;

objfun = @(theta) local_objective(theta, x, y, model, delta, xmin, xmax);

options = optimset( ...
    'Display','off', ...
    'MaxIter',5000, ...
    'MaxFunEvals',10000);

theta_hat = fminsearch(objfun, theta0, options);

% =========================================================
% 生成拟合曲线
% 这里用 TailExtend 把右端曲线多画一段
% =========================================================
x_left = min(gIE_list);
tailExtend = opt.TailExtend;
if ~isempty(opt.CurveExtendFraction)
    tailExtend = opt.CurveExtendFraction * range(gIE_list);
end
x_right = max(gIE_list) + tailExtend;

g_smooth = linspace(x_left, x_right, opt.FitN).';
B_smooth = model(theta_hat, g_smooth);

% 保险：强制非增，避免数值上轻微回弹
for i = 2:numel(B_smooth)
    if B_smooth(i) > B_smooth(i-1)
        B_smooth(i) = B_smooth(i-1);
    end
end

% 拟合优度，用 median-bin 数据算
y_pred = model(theta_hat, x);
SS_res = sum((y - y_pred).^2);
SS_tot = sum((y - mean(y)).^2);

if SS_tot <= eps
    R2 = NaN;
else
    R2 = 1 - SS_res / SS_tot;
end

[B_ci, P_model] = nonlinear_fit_confidence_band( ...
    model, theta_hat, x, y, g_smooth, opt.ConfidenceLevel);
B_ci = max(B_ci, opt.ConfidenceLowerBound);
if opt.ConfidenceOnlyWithinData
    ciMask = g_smooth >= min(x) & g_smooth <= max(x);
else
    ciMask = true(size(g_smooth));
end

% =========================================================
% plot
% =========================================================
h = figure('Color', 'w', 'Position', opt.FigurePosition);
hold on;
set(h,'Visible',opt.Visible);

fill([g_smooth(ciMask); flipud(g_smooth(ciMask))], ...
    [B_ci(ciMask,1); flipud(B_ci(ciMask,2))], color_main, ...
    'EdgeColor', 'none', 'FaceAlpha', opt.BandAlpha);

% 原始散点
plot(gIE_list, Barrier, 'o', ...
    'Color', color_main, ...
    'LineWidth', opt.LineWidth, ...
    'MarkerSize', opt.MarkerSize, ...
    'MarkerFaceColor', 'none');

% 拟合曲线
plot(g_smooth, B_smooth, '-', ...
    'Color', color_main, ...
    'LineWidth', opt.LineWidth);

xlabel('g_{IE}','FontSize',68,'FontWeight','bold');
ylabel('\Delta U','FontSize',68,'FontWeight','bold');

box on;
set(gca,'linewidth',2);
set(gca,'FontSize',24,'FontWeight','bold');
set(gca, 'Position', [0.16 0.15 0.78 0.75]);

statsAlign = 'left';
if opt.StatsPosition(1) > 0.5, statsAlign = 'right'; end
text(gca, opt.StatsPosition(1), opt.StatsPosition(2), ...
    sprintf('R^2 = %.4f\nP = %.3g', R2, P_model), ...
    'Units', 'normalized', 'Interpreter', 'tex', ...
    'Color', color_main, 'FontSize', opt.StatsFontSize, ...
    'FontWeight', 'bold', 'HorizontalAlignment', statsAlign, ...
    'BackgroundColor', 'none');

% title(sprintf('Sigmoid drop fit, R^2 = %.4f', R2), ...
%     'FontSize',28, ...
%     'FontWeight','bold');

% x 轴右端也放宽一点，保证延长尾端显示出来
xlim([min(gIE_list)-0.01, max(gIE_list)+tailExtend+0.01]);

% 面板字母
if ~isempty(opt.PanelLabel)
    ax1 = gca;
    pos1 = ax1.Position;
    annotation('textbox', ...
        [pos1(1)-0.07, pos1(2)+pos1(4)-0.01, 0.05, 0.05], ...
        'String',opt.PanelLabel, 'FontSize',32,'FontWeight','bold', ...
        'LineStyle','none');
end

% legend
if opt.ShowLegend
    hA = plot(nan,nan,'-o', 'Color',color_main, ...
        'LineWidth',2.5, 'MarkerFaceColor','none');
    legend(hA, {'\Delta U_{Asyn}'}, 'Location', 'best', ...
        'FontSize',20, 'Box','off');
end

% =========================================================
% save
% =========================================================
if opt.Save
    if ~exist(figure_folder_name, 'dir')
        mkdir(figure_folder_name);
    end

    fname = fullfile(figure_folder_name, opt.SaveName);
    print(h, fname, '-dpng', '-r300');
end

% =========================================================
% 打印参数
% =========================================================
fprintf('\n===== Sigmoid drop fit =====\n');
fprintf('low        = %.6g\n', theta_hat(1));
fprintf('amp        = %.6g\n', theta_hat(2));
fprintf('slope      = %.6g\n', theta_hat(3));
fprintf('gc         = %.6g\n', theta_hat(4));
fprintf('w          = %.6g\n', exp(theta_hat(5)));
fprintf('TailExtend = %.6g\n', tailExtend);
fprintf('R2         = %.6g\n', R2);
fprintf('P overall  = %.6g (approximate nonlinear-model F test)\n', P_model);
fprintf('============================\n');

end

% =========================================================
% local objective function
% =========================================================
function loss = local_objective(theta, x, y, model, delta, xmin, xmax)

    yhat = model(theta, x);
    r = y - yhat;

    % Huber loss，降低离群点影响
    absr = abs(r);
    huber = zeros(size(r));

    small = absr <= delta;
    huber(small) = 0.5 * r(small).^2;
    huber(~small) = delta * (absr(~small) - 0.5 * delta);

    loss_data = sum(huber);

    % 参数惩罚，防止跑飞
    low   = theta(1);
    amp   = theta(2);
    slope = theta(3);
    gc    = theta(4);
    w     = exp(theta(5));

    penalty = 0;

    % amp 应该为正
    if amp < 0
        penalty = penalty + 1e5 * amp^2;
    end

    % w 太大或太小都罚一下
    if w < 1e-4
        penalty = penalty + 1e5 * (1e-4 - w)^2;
    end

    if w > 0.05
        penalty = penalty + 1e5 * (w - 0.05)^2;
    end

    % gc 限制在数据范围附近
    if gc < xmin
        penalty = penalty + 1e5 * (xmin - gc)^2;
    end

    if gc > xmax
        penalty = penalty + 1e5 * (gc - xmax)^2;
    end

    % slope 希望整体偏下降
    if slope > 0
        penalty = penalty + 1e4 * slope^2;
    end

    % 曲线非增惩罚
    xx = linspace(xmin, xmax, 400).';
    yy = model(theta, xx);
    dyy = diff(yy);
    up = dyy(dyy > 0);

    if ~isempty(up)
        penalty = penalty + 1e5 * sum(up.^2);
    end

    % 不希望低平台特别负
    if low < -5
        penalty = penalty + 1e4 * (low + 5)^2;
    end

    loss = loss_data + penalty;
end
