function plot_MFPT_AS_fit(g, MFPT_AS, figure_folder_name, varargin)
% plot_MFPT_AS_fit
%
% 对 MFPT of A to S 做拟合：
%   原始数据：方块点
%   拟合结果：平滑曲线
%
% 模型：
%   y(x) = c + A * exp(-k * (x - xmin))
%
% 适合：
%   随 g 增大，MFPT 单调下降并逐渐趋于平台的情况
%
% 输入：
%   g                 g_IE 序列
%   MFPT_AS           对应 MFPT
%   figure_folder_name 保存文件夹
%
% 可选参数：
%   'Visible'       'on' / 'off'
%   'Save'          true / false
%   'SaveName'      保存文件名
%   'MarkerSize'    原始点大小
%   'LineWidth'     拟合线宽
%   'FitN'          拟合曲线采样点数
%   'LeftExtend'    左侧延长量
%   'RightExtend'   右侧延长量
%   'PanelLabel'    面板字母
%   'LegendText'    图例文字
%   'TitleText'     标题文字，默认显示 R^2
%   'RobustDelta'   Huber loss 阈值

p = inputParser;

addParameter(p, 'Visible', 'on');
addParameter(p, 'Save', true, @islogical);
addParameter(p, 'SaveName', 'MFPT_fit.png');
addParameter(p, 'MarkerSize', 10, @isnumeric);
addParameter(p, 'LineWidth', 4, @isnumeric);
addParameter(p, 'FitN', 1000, @isnumeric);
addParameter(p, 'LeftExtend', 0.002, @isnumeric);
addParameter(p, 'RightExtend', 0.01, @isnumeric);
addParameter(p, 'PanelLabel', '');
addParameter(p, 'LegendText', 'MFPT of A to S');
addParameter(p, 'ShowLegend', false, @islogical);
addParameter(p, 'TitleText', '');
addParameter(p, 'RobustDelta', 300, @isnumeric);
addParameter(p, 'ConfidenceLevel', 0.95, @isnumeric);
addParameter(p, 'ConfidenceLowerBound', 0, @isnumeric);
addParameter(p, 'BandAlpha', 0.22, @isnumeric);
addParameter(p, 'StatsPosition', [0.88 0.78], @(v) isnumeric(v) && numel(v)==2);
addParameter(p, 'StatsFontSize', 24, @isnumeric);
addParameter(p, 'FigurePosition', [100 100 760 760], @isnumeric);

parse(p, varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

color_main = [0 44 83] / 255; % Equivalent to #002c53; compatible with fill().

%% ========================================================
% 数据整理
% ==========================================================
g = g(:);
MFPT_AS = MFPT_AS(:);

if numel(g) ~= numel(MFPT_AS)
    error('g 和 MFPT_AS 长度不一致。');
end

valid = isfinite(g) & isfinite(MFPT_AS);
g = g(valid);
MFPT_AS = MFPT_AS(valid);

[g, idx] = sort(g);
MFPT_AS = MFPT_AS(idx);

xmin = min(g);
xmax = max(g);

%% ========================================================
% 指数衰减模型
% theta = [c, A, logk]
% y = c + A * exp(-k * (x - xmin))
% 其中 k = exp(logk) > 0
% ==========================================================
model = @(theta, x) theta(1) + theta(2) .* exp(-exp(theta(3)) .* (x - xmin));

% 初值
c0 = min(MFPT_AS);                    % 右侧平台
A0 = max(MFPT_AS) - c0;               % 振幅
k0 = 40;                              % 衰减速率初值，可自行调
theta0 = [c0, A0, log(k0)];

delta = opt.RobustDelta;

objfun = @(theta) local_objective_exp_decay(theta, g, MFPT_AS, model, delta, xmin, xmax);

options = optimset( ...
    'Display','off', ...
    'MaxIter',5000, ...
    'MaxFunEvals',10000);

theta_hat = fminsearch(objfun, theta0, options);

%% ========================================================
% 生成拟合曲线
% ==========================================================
x_left  = xmin - opt.LeftExtend;
x_right = xmax + opt.RightExtend;

g_fit = linspace(x_left, x_right, opt.FitN).';
MFPT_fit = model(theta_hat, g_fit);

% 保险：强制非增
for i = 2:numel(MFPT_fit)
    if MFPT_fit(i) > MFPT_fit(i-1)
        MFPT_fit(i) = MFPT_fit(i-1);
    end
end

%% ========================================================
% R^2
% ==========================================================
MFPT_pred = model(theta_hat, g);
SS_res = sum((MFPT_AS - MFPT_pred).^2);
SS_tot = sum((MFPT_AS - mean(MFPT_AS)).^2);

if SS_tot <= eps
    R2 = NaN;
else
    R2 = 1 - SS_res / SS_tot;
end

[MFPT_ci, P_model] = nonlinear_fit_confidence_band( ...
    model, theta_hat, g, MFPT_AS, g_fit, opt.ConfidenceLevel);
MFPT_ci = max(MFPT_ci, opt.ConfidenceLowerBound);

%% ========================================================
% 画图
% ==========================================================
h = figure('Color', 'w', 'Position', opt.FigurePosition); 
hold on;
set(h,'Visible',opt.Visible);

fill([g_fit; flipud(g_fit)], ...
    [MFPT_ci(:,1); flipud(MFPT_ci(:,2))], color_main, ...
    'EdgeColor', 'none', 'FaceAlpha', opt.BandAlpha);

% 原始数据：只画方块点
plot(g, MFPT_AS, 's', ...
    'Color', color_main, ...
    'LineWidth', 2.5, ...
    'MarkerSize', opt.MarkerSize, ...
    'MarkerFaceColor', 'none');

% 拟合曲线
plot(g_fit, MFPT_fit, '-', ...
    'Color', color_main, ...
    'LineWidth', opt.LineWidth);

xlabel('g_{IE}','FontSize',68,'FontWeight','bold');
ylabel('\tau','FontSize',68,'FontWeight','bold');

box on;
set(gca,'linewidth',2);
set(gca,'FontSize',26,'FontWeight','bold');
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
%     title(sprintf('Exponential decay fit, R^2 = %.4f', R2), ...
%         'FontSize',28, ...
%         'FontWeight','bold');
% else
%     title(opt.TitleText, ...
%         'FontSize',28, ...
%         'FontWeight','bold');
% end

% 图例
if opt.ShowLegend
    hA = plot(nan,nan,'-s', 'Color', color_main, ...
        'LineWidth', 2.5, 'MarkerFaceColor','none');
    legend(hA, {opt.LegendText}, 'Location', 'northeast', ...
        'FontSize', 20, 'Box', 'off');
end

% 面板字母 B
if ~isempty(opt.PanelLabel)
    ax1 = gca;
    pos1 = ax1.Position;
    annotation('textbox', ...
        [pos1(1)-0.07, pos1(2)+pos1(4)-0.01, 0.05, 0.05], ...
        'String', opt.PanelLabel, 'FontSize',32, ...
        'FontWeight','bold', 'LineStyle','none');
end

% x 轴范围
xlim([xmin - opt.LeftExtend - 0.003, xmax + opt.RightExtend]);

% y 轴科学计数法 ×10^3
ax = gca;
ax.YAxis.Exponent = 3;
ax.YAxis.ExponentMode = 'manual';
ax.YAxis.TickLabelFormat = '%.3g';

%% ========================================================
% 保存
% ==========================================================
if opt.Save
    if ~exist(figure_folder_name, 'dir')
        mkdir(figure_folder_name);
    end

    fname = fullfile(figure_folder_name, opt.SaveName);
    print(h, fname, '-dpng', '-r300');
end

%% ========================================================
% 输出参数
% ==========================================================
fprintf('\n===== MFPT exponential decay fit =====\n');
fprintf('c          = %.6g\n', theta_hat(1));
fprintf('A          = %.6g\n', theta_hat(2));
fprintf('k          = %.6g\n', exp(theta_hat(3)));
fprintf('LeftExtend = %.6g\n', opt.LeftExtend);
fprintf('RightExtend= %.6g\n', opt.RightExtend);
fprintf('R2         = %.6g\n', R2);
fprintf('P overall  = %.6g (approximate nonlinear-model F test)\n', P_model);
fprintf('======================================\n');

end

%% ========================================================
% local objective: exponential decay + robust + monotone penalty
% ==========================================================
function loss = local_objective_exp_decay(theta, x, y, model, delta, xmin, xmax)

    yhat = model(theta, x);
    r = y - yhat;

    % Huber loss
    absr = abs(r);
    huber = zeros(size(r));

    small = absr <= delta;
    huber(small) = 0.5 * r(small).^2;
    huber(~small) = delta * (absr(~small) - 0.5 * delta);

    loss_data = sum(huber);

    % 参数
    c = theta(1);
    A = theta(2);
    k = exp(theta(3));

    penalty = 0;

    % A 应为正
    if A < 0
        penalty = penalty + 1e8 * A^2;
    end

    % k 应为正且不要太极端
    if k < 1e-3
        penalty = penalty + 1e8 * (1e-3 - k)^2;
    end
    if k > 500
        penalty = penalty + 1e8 * (k - 500)^2;
    end

    % c 不希望明显小于 0
    if c < 0
        penalty = penalty + 1e8 * c^2;
    end

    % 非增惩罚
    xx = linspace(xmin, xmax, 500).';
    yy = model(theta, xx);
    dyy = diff(yy);
    up = dyy(dyy > 0);

    if ~isempty(up)
        penalty = penalty + 1e8 * sum(up.^2);
    end

    loss = loss_data + penalty;
end
