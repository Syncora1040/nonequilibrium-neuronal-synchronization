function [fig_file, idx_min_f, idx_min_b] = plot_action_candidates_with_uniformity( ...
    nf, S_f, S_b, Results_forward, Results_backward, figure_folder_name, segRatioThresh)

if nargin < 7
    segRatioThresh = 5;  % 默认最大段长度与平均段长度比阈值
end

if ~exist(figure_folder_name, 'dir')
    mkdir(figure_folder_name);
end

S_f = S_f(:).';
S_b = S_b(:).';

if numel(S_f) ~= nf || numel(S_b) ~= nf
    error('S_f and S_b must be length nf.');
end

% ============================
% 字体与整体风格设置
% ============================
set(0, 'DefaultAxesFontName', 'Latin Modern Math');
set(0, 'DefaultTextFontName', 'Latin Modern Math');

ms_main = 10;
color_forward  = '#002c53';   % 前向路径颜色
color_backward = '#b22222';   % 反向路径颜色

% ============================
% 计算路径均匀性指标
% ============================
segRatio_f = nan(1, nf);
segRatio_b = nan(1, nf);

for i = 1:nf
    if ~isempty(Results_forward{i})
        dX = diff(Results_forward{i}.Xopt, 1, 2);
        segLen = sqrt(sum(dX.^2, 1));
        segRatio_f(i) = max(segLen) / mean(segLen);
    end

    if ~isempty(Results_backward{i})
        dX = diff(Results_backward{i}.Xopt, 1, 2);
        segLen = sqrt(sum(dX.^2, 1));
        segRatio_b(i) = max(segLen) / mean(segLen);
    end
end

% ============================
% 标记无效路径
% ============================
valid_f = segRatio_f <= segRatioThresh;
valid_b = segRatio_b <= segRatioThresh;

S_f_valid = S_f;
S_b_valid = S_b;

S_f_valid(~valid_f) = NaN;
S_b_valid(~valid_b) = NaN;

% ============================
% 找最小作用量路径
% ============================
[Smin_f, idx_min_f] = min(S_f_valid, [], 'omitnan');
[Smin_b, idx_min_b] = min(S_b_valid, [], 'omitnan');

% ============================
% 绘图
% ============================
Order_nf = 1:nf;

fig = figure('Visible', 'off');
hold on;
set(fig, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

plot(Order_nf, S_f, 'o-', ...
    'Color', color_forward, ...
    'LineWidth', 4, ...
    'MarkerSize', ms_main, ...
    'MarkerFaceColor', 'none');

plot(Order_nf, S_b, 's-', ...
    'Color', color_backward, ...
    'LineWidth', 4, ...
    'MarkerSize', ms_main, ...
    'MarkerFaceColor', 'none');

% 标记筛选后的最小作用量路径
plot(idx_min_f, Smin_f, 'p', ...
    'MarkerSize', 30, ...
    'MarkerFaceColor', 'g', ...
    'MarkerEdgeColor', 'g', ...
    'LineWidth', 2);

plot(idx_min_b, Smin_b, 'p', ...
    'MarkerSize', 30, ...
    'MarkerFaceColor', 'b', ...
    'MarkerEdgeColor', 'b', ...
    'LineWidth', 2);

box on;
set(gca, 'LineWidth', 2);
set(gca, 'FontSize', 35, 'FontWeight', 'bold');

xlabel('Candidate index', ...
    'FontSize', 30, ...
    'FontWeight', 'bold');

ylabel('S', ...
    'FontSize', 30, ...
    'FontWeight', 'bold');

ax = gca;
ax.YAxis.TickLabelFormat = '%.3g';

% 如果你想强制显示为 ×10^3，可以打开下面两行
% ax.YAxis.Exponent = 3;
% ax.YAxis.ExponentMode = 'manual';

lgd = legend({ ...
    'Forward action', ...
    'Backward action', ...
    'Minimum-action candidate for forward path', ...
    'Minimum-action candidate for backward path'});
lgd.Position = [0.4, 0.78, 0.10, 0.10];

set(lgd, 'FontSize', 26);
set(lgd, 'Box', 'off');

title(sprintf('Action vs candidate index: min F = %d, min B = %d', ...
        idx_min_f, idx_min_b), ...
        'Interpreter', 'none', ...
        'FontSize', 30, ...
        'FontWeight', 'bold');

% ============================
% 面板字母，可按需要修改
% ============================
% ax1 = gca;
% pos1 = ax1.Position;

% annotation('textbox', ...
%     [pos1(1)-0.08, pos1(2)+pos1(4)-0.02, 0.05, 0.05], ...
%     'String', 'B', ...
%     'FontSize', 55, ...
%     'FontWeight', 'bold', ...
%     'LineStyle', 'none');

% ============================
% 保存图片
% ============================
fig_file = fullfile(figure_folder_name, ...
    sprintf('Action_candidates_correct_nf_%d.png', nf));

exportgraphics(fig, fig_file, 'Resolution', 300);
close(fig);

fprintf('Minimum forward action (uniform) at candidate %d: S = %.8e\n', idx_min_f, Smin_f);
fprintf('Minimum backward action (uniform) at candidate %d: S = %.8e\n', idx_min_b, Smin_b);
fprintf('Saved figure: %s\n', fig_file);

end