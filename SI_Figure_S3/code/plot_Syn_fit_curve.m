function plot_Syn_fit_curve(Barrier, gIE_list, figure_folder_name, varargin)
% plot_barrier_fit_curve_rise
%
% 用 sigmoid rise 模型拟合递增型 barrier-gIE 关系：
%
%   B(g) = high - amp / (1 + exp((g-gc)/w)) + slope*(g-gmin)
%
% 适合：
%   前面低，随后快速上升，最后进入平台的趋势。
%
% 输入：
%   Barrier            barrier height，例如 Delta U_Syn
%   gIE_list           对应 gIE 序列
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
%   'TailExtend'    拟合曲线右端延长量
%   'LeftExtend'    拟合曲线左端延长量
%   'LegendText'    图例文字
%   'TitleText'     标题文字，默认显示 R^2
%
% 说明：
%   这个函数适合 Delta U_Syn 这种递增平台型数据：
%   - 鼓励曲线整体非减
%   - 左右两端都可以延长显示

p = inputParser;

addParameter(p, 'Visible', 'on');
addParameter(p, 'Save', true, @islogical);
addParameter(p, 'SaveName', 'Barrier_Syn_sigmoid_rise_fit.png');
addParameter(p, 'LineWidth', 6, @isnumeric);
addParameter(p, 'MarkerSize', 10, @isnumeric);
addParameter(p, 'FitN', 900, @isnumeric);
addParameter(p, 'RobustDelta', 8, @isnumeric);
addParameter(p, 'UseMedianBin', true, @islogical);
addParameter(p, 'PanelLabel', '');
addParameter(p, 'ShowLegend', false, @islogical);
addParameter(p, 'TailExtend', 0.008, @isnumeric);
addParameter(p, 'LeftExtend', 0.008, @isnumeric);
addParameter(p, 'CurveExtendFraction', [], ...
    @(v) isempty(v) || (isnumeric(v) && isscalar(v) && v >= 0));
addParameter(p, 'LegendText', '\DeltaU_{Syn}');
addParameter(p, 'TitleText', '');
addParameter(p, 'ConfidenceLevel', 0.95, @isnumeric);
addParameter(p, 'ConfidenceLowerBound', 0, @isnumeric);
addParameter(p, 'ConfidenceOnlyWithinData', true, @islogical);
addParameter(p, 'BandAlpha', 0.22, @isnumeric);
addParameter(p, 'StatsPosition', [0.12 0.78], @(v) isnumeric(v) && numel(v)==2);
addParameter(p, 'StatsFontSize', 22, @isnumeric);
addParameter(p, 'FigurePosition', [100 100 760 760], @isnumeric);

parse(p, varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

color_main = [0 44 83] / 255; % Equivalent to #002c53; compatible with fill().

%% ========================================================
% data
% ==========================================================
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

%% ========================================================
% 用于拟合的数据
% 同一个 gIE 如果有多个点，取 median
% ==========================================================
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

%% ========================================================
% sigmoid rise model
% theta = [high, amp, slope, gc, logw]
%
% high : 右侧平台高度
% amp  : 上升幅度
% slope: 平台上的缓慢趋势
% gc   : 上升中心位置
% w    : 上升宽度，越小越陡
% ==========================================================
model = @(theta, xx) theta(1) + ...
                     theta(3) .* (xx - xmin) - ...
                     theta(2) ./ (1 + exp((xx - theta(4)) ./ exp(theta(5))));

%% ========================================================
% 初值
% ==========================================================
low0   = min(y);
high0  = max(y);
amp0   = high0 - low0;

slope0 = 0;
gc0 = x(round(0.25 * numel(x)));
w0  = 0.01;

theta0 = [high0, amp0, slope0, gc0, log(w0)];

%% ========================================================
% robust loss + 单调非减惩罚
% ==========================================================
delta = opt.RobustDelta;

objfun = @(theta) local_objective_rise(theta, x, y, model, delta, xmin, xmax);

options = optimset( ...
    'Display','off', ...
    'MaxIter',5000, ...
    'MaxFunEvals',10000);

theta_hat = fminsearch(objfun, theta0, options);

%% ========================================================
% 生成拟合曲线
% 左右两端都延长
% ==========================================================
leftExtend = opt.LeftExtend;
tailExtend = opt.TailExtend;
if ~isempty(opt.CurveExtendFraction)
    leftExtend = opt.CurveExtendFraction * range(gIE_list);
    tailExtend = leftExtend;
end
x_left = min(gIE_list) - leftExtend;
x_right = max(gIE_list) + tailExtend;

g_smooth = linspace(x_left, x_right, opt.FitN).';
B_smooth = model(theta_hat, g_smooth);

% 保险：强制非减，避免数值轻微回落
for i = 2:numel(B_smooth)
    if B_smooth(i) < B_smooth(i-1)
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

%% ========================================================
% plot
% ==========================================================
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

xlabel('g_{IE}','FontSize',34,'FontWeight','bold');
ylabel('\Delta U','FontSize',34,'FontWeight','bold');

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

% if isempty(opt.TitleText)
%     title(sprintf('Sigmoid rise fit, R^2 = %.4f', R2), ...
%         'FontSize',28, ...
%         'FontWeight','bold');
% else
%     title(opt.TitleText, ...
%         'FontSize',28, ...
%         'FontWeight','bold');
% end

% x 轴左右都放宽一点
xlim([min(gIE_list)-leftExtend-0.01, ...
      max(gIE_list)+tailExtend+0.01]);

% % 面板字母
% ax1 = gca;
% pos1 = ax1.Position;
% annotation('textbox', ...
%     [pos1(1)-0.08, pos1(2)+pos1(4)-0.02, 0.05, 0.05], ...
%     'String',opt.PanelLabel, ...
%     'FontSize',55,'FontWeight','bold', ...
%     'LineStyle','none');

% legend
if opt.ShowLegend
    hA = plot(nan,nan,'-o', 'Color',color_main, ...
        'LineWidth',2.5, 'MarkerFaceColor','none');
    legend(hA, {opt.LegendText}, 'Location','best', ...
        'FontSize',20, 'Box','off');
end

%% ========================================================
% save
% ==========================================================
if opt.Save
    if ~exist(figure_folder_name, 'dir')
        mkdir(figure_folder_name);
    end

    fname = fullfile(figure_folder_name, opt.SaveName);
    print(h, fname, '-dpng', '-r300');
end

%% ========================================================
% 打印参数
% ==========================================================
fprintf('\n===== Sigmoid rise fit =====\n');
fprintf('high       = %.6g\n', theta_hat(1));
fprintf('amp        = %.6g\n', theta_hat(2));
fprintf('slope      = %.6g\n', theta_hat(3));
fprintf('gc         = %.6g\n', theta_hat(4));
fprintf('w          = %.6g\n', exp(theta_hat(5)));
fprintf('LeftExtend = %.6g\n', leftExtend);
fprintf('TailExtend = %.6g\n', tailExtend);
fprintf('R2         = %.6g\n', R2);
fprintf('P overall  = %.6g (approximate nonlinear-model F test)\n', P_model);
fprintf('============================\n');

end

%% ========================================================
% local objective function: rise
% ==========================================================
function loss = local_objective_rise(theta, x, y, model, delta, xmin, xmax)

    yhat = model(theta, x);
    r = y - yhat;

    % Huber loss，降低离群点影响
    absr = abs(r);
    huber = zeros(size(r));

    small = absr <= delta;
    huber(small) = 0.5 * r(small).^2;
    huber(~small) = delta * (absr(~small) - 0.5 * delta);

    loss_data = sum(huber);

    % 参数
    high  = theta(1);
    amp   = theta(2);
    slope = theta(3);
    gc    = theta(4);
    w     = exp(theta(5));

    penalty = 0;

    % amp 应为正
    if amp < 0
        penalty = penalty + 1e5 * amp^2;
    end

    % w 太大或太小都罚
    if w < 1e-4
        penalty = penalty + 1e5 * (1e-4 - w)^2;
    end

    if w > 0.08
        penalty = penalty + 1e5 * (w - 0.08)^2;
    end

    % gc 限制在数据范围附近
    if gc < xmin
        penalty = penalty + 1e5 * (xmin - gc)^2;
    end

    if gc > xmax
        penalty = penalty + 1e5 * (gc - xmax)^2;
    end

    % high 不希望为负
    if high < 0
        penalty = penalty + 1e4 * high^2;
    end

    % 曲线非减惩罚
    xx = linspace(xmin, xmax, 400).';
    yy = model(theta, xx);
    dyy = diff(yy);

    down = dyy(dyy < 0);

    if ~isempty(down)
        penalty = penalty + 1e5 * sum(down.^2);
    end

    loss = loss_data + penalty;
end
