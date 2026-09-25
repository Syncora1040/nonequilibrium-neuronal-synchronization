function [fig_file, idx_min_f, idx_min_b] = plot_action_candidates( ...
    nf, S_f, S_b, figure_folder_name)
%PLOT_ACTION_CANDIDATES Plot forward/backward action values for LC candidates.
%
% This version uses the same plotting style as
% plot_action_candidates_with_uniformity, but selects the minimum-action
% candidates using only the action values, without the path-spacing
% uniformity constraint.
%
% Inputs:
%   nf                 : number of candidate points
%   S_f                : 1 x nf or nf x 1 forward action vector
%   S_b                : 1 x nf or nf x 1 backward action vector
%   figure_folder_name : folder to save png
%
% Outputs:
%   fig_file           : saved figure filename
%   idx_min_f          : candidate index with minimum forward action
%   idx_min_b          : candidate index with minimum backward action

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
    % 找最小作用量路径
    % ============================
    [Smin_f, idx_min_f] = min(S_f);
    [Smin_b, idx_min_b] = min(S_b);

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

    % 标记最小作用量路径
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

    % 如果你想强制显示为 ×10^3 或 ×10^4，可以打开下面两行
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
    %
    % annotation('textbox', ...
    %     [pos1(1)-0.08, pos1(2)+pos1(4)-0.02, 0.05, 0.05], ...
    %     'String', 'A', ...
    %     'FontSize', 55, ...
    %     'FontWeight', 'bold', ...
    %     'LineStyle', 'none');

    % ============================
    % 保存图片
    % ============================
    fig_file = fullfile(figure_folder_name, ...
        sprintf('Action_candidates_nf_%d.png', nf));

    exportgraphics(fig, fig_file, 'Resolution', 300);
    close(fig);

    fprintf('Minimum forward action at candidate %d: S = %.8e\n', ...
        idx_min_f, Smin_f);
    fprintf('Minimum backward action at candidate %d: S = %.8e\n', ...
        idx_min_b, Smin_b);
    fprintf('Saved figure: %s\n', fig_file);

end