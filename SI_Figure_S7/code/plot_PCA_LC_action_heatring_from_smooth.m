function out = plot_PCA_LC_action_heatring_from_smooth( ...
    nf, S_f, S_b, Results_forward, Results_backward, ...
    figure_folder_name, PCA_W, PCA_mu, Xlc_smooth, Xf_cand, idx_f, idx_b)
%PLOT_PCA_LC_ACTION_HEATRING_FROM_SMOOTH
% 用已经拟合好的 PCA 极限环 Xlc_smooth，画作用量热力环图。
%
% 前向热力图：
%   - 只画前向路径
%   - 第一个点标 Asyn state
%   - 最后一个点标 Syn state
%
% 后向热力图：
%   - 只画后向路径
%   - 第一个点标 Syn state
%   - 最后一个点标 Asyn state
%
% Inputs:
%   nf                 : 候选点数量
%   S_f                : 1 x nf forward action
%   S_b                : 1 x nf backward action
%   Results_forward    : 1 x nf cell
%   Results_backward   : 1 x nf cell
%   figure_folder_name : 图片保存文件夹
%   PCA_W              : 4 x 2 PCA 投影矩阵
%   PCA_mu             : 1 x 4 PCA 均值
%   Xlc_smooth         : Nlc x 2 已经拟合好的 PCA 极限环闭合曲线
%   Xf_cand            : 4 x nf 候选终点
%   idx_f              : optional, 指定 forward 路径序号
%   idx_b              : optional, 指定 backward 路径序号
%
% Outputs:
%   out.fig_forward
%   out.fig_backward
%   out.Xlc_smooth
%   out.Xf_pca
%   out.S_on_LC_f
%   out.S_on_LC_b
%   out.idx_f
%   out.idx_b
%   out.Opt_path_f_pca
%   out.Opt_path_b_pca

    if nargin < 11 || isempty(idx_f)
        [~, idx_f] = min(S_f, [], 'omitnan');
    end

    if nargin < 12 || isempty(idx_b)
        [~, idx_b] = min(S_b, [], 'omitnan');
    end

    if ~exist(figure_folder_name, 'dir')
        mkdir(figure_folder_name);
    end

    S_f = S_f(:).';
    S_b = S_b(:).';

    if numel(S_f) ~= nf
        error('S_f length must equal nf.');
    end

    if numel(S_b) ~= nf
        error('S_b length must equal nf.');
    end

    if idx_f < 1 || idx_f > nf
        error('idx_f must be between 1 and nf.');
    end

    if idx_b < 1 || idx_b > nf
        error('idx_b must be between 1 and nf.');
    end

    if isempty(Results_forward{idx_f})
        error('Results_forward{%d} is empty.', idx_f);
    end

    if isempty(Results_backward{idx_b})
        error('Results_backward{%d} is empty.', idx_b);
    end

    if size(Xlc_smooth,2) ~= 2
        error('Xlc_smooth must be Nlc x 2 in PCA space.');
    end

    if size(Xf_cand,1) ~= 4 || size(Xf_cand,2) ~= nf
        error('Xf_cand must be 4 x nf.');
    end

    if size(PCA_W,1) ~= 4 || size(PCA_W,2) < 2
        error('PCA_W must be 4 x 2 or 4 x M.');
    end

    PCA_W = PCA_W(:,1:2);
    PCA_mu = reshape(PCA_mu, 1, 4);

    % =========================================================
    % 1) 候选终点投影到 PCA
    % =========================================================
    Xf_pca = (Xf_cand.' - PCA_mu) * PCA_W;   % nf x 2

    % =========================================================
    % 2) 取选中的 forward/backward path 并投影到 PCA
    % =========================================================
    Opt_path_f_pca = result_path_to_pca(Results_forward{idx_f}, PCA_W, PCA_mu);
    Opt_path_b_pca = result_path_to_pca(Results_backward{idx_b}, PCA_W, PCA_mu);

    % =========================================================
    % 3) 保证 Xlc_smooth 是闭合画图曲线
    % =========================================================
    LC_pca = Xlc_smooth;
    LC_pca = LC_pca(all(isfinite(LC_pca),2), :);

    if size(LC_pca,1) < 5
        error('Too few valid points in Xlc_smooth.');
    end

    if norm(LC_pca(1,:) - LC_pca(end,:)) > 1e-10
        LC_closed = [LC_pca; LC_pca(1,:)];
    else
        LC_closed = LC_pca;
        LC_pca = LC_pca(1:end-1,:);
    end

    % =========================================================
    % 4) 把作用量映射到 LC 上
    % =========================================================
    S_on_LC_f = map_action_to_LC(LC_pca, Xf_pca, S_f);
    S_on_LC_b = map_action_to_LC(LC_pca, Xf_pca, S_b);

    S_plot_f = [S_on_LC_f(:); S_on_LC_f(1)];
    S_plot_b = [S_on_LC_b(:); S_on_LC_b(1)];

    % =========================================================
    % 5) 画图
    % =========================================================
    out = struct();

    % ---------- forward heat ring ----------
    out.fig_forward = plot_one_heatring_single_path( ...
        LC_closed, Xf_pca, S_f, S_plot_f, ...
        Opt_path_f_pca, ...
        'forward', ...
        figure_folder_name, ...
        sprintf('PCA_LC_action_heatring_forward_nf_%d_idxF_%03d.png', nf, idx_f), ...
        '');

    % ---------- backward heat ring ----------
    out.fig_backward = plot_one_heatring_single_path( ...
        LC_closed, Xf_pca, S_b, S_plot_b, ...
        Opt_path_b_pca, ...
        'backward', ...
        figure_folder_name, ...
        sprintf('PCA_LC_action_heatring_backward_nf_%d_idxB_%03d.png', nf, idx_b), ...
        '');

    out.Xlc_smooth = Xlc_smooth;
    out.Xf_pca = Xf_pca;

    out.S_on_LC_f = S_on_LC_f;
    out.S_on_LC_b = S_on_LC_b;

    out.S_f = S_f;
    out.S_b = S_b;

    out.idx_f = idx_f;
    out.idx_b = idx_b;

    out.Opt_path_f_pca = Opt_path_f_pca;
    out.Opt_path_b_pca = Opt_path_b_pca;
end


% =========================================================
% Helper: result path to PCA
% =========================================================
function Ypath = result_path_to_pca(result, PCA_W, PCA_mu)

    if isfield(result, 'path4D')
        Xpath4D = result.path4D;
    elseif isfield(result, 'Xopt')
        Xpath4D = result.Xopt;
    else
        error('result must contain path4D or Xopt.');
    end

    if size(Xpath4D,1) ~= 4
        error('path4D/Xopt must be 4 x Npath.');
    end

    Ypath = (Xpath4D.' - PCA_mu) * PCA_W;
end


% =========================================================
% Helper: map discrete candidate actions to LC curve
% =========================================================
function S_on_LC = map_action_to_LC(LC_pca, Xf_pca, S)

    nLC = size(LC_pca,1);
    nf = size(Xf_pca,1);

    S = S(:);

    idx_near = zeros(nf,1);

    for m = 1:nf
        d2 = sum((LC_pca - Xf_pca(m,:)).^2, 2);
        [~, idx_near(m)] = min(d2);
    end

    S_on_LC = nan(nLC,1);

    for k = 1:nLC
        hit = idx_near == k;
        if any(hit)
            S_on_LC(k) = mean(S(hit), 'omitnan');
        end
    end

    known = isfinite(S_on_LC);

    if nnz(known) < 2
        error('Too few candidate actions mapped to LC.');
    end

    idx = (1:nLC).';

    idx_known = idx(known);
    S_known = S_on_LC(known);

    % 周期扩展，避免首尾断裂
    idx_ext = [idx_known - nLC; idx_known; idx_known + nLC];
    S_ext   = [S_known; S_known; S_known];

    S_on_LC = interp1(idx_ext, S_ext, idx, 'pchip');

    if any(~isfinite(S_on_LC))
        S_on_LC = fillmissing(S_on_LC, 'nearest');
    end
end


% =========================================================
% Helper: plot one heat ring with only one path
% =========================================================
function fig_file = plot_one_heatring_single_path( ...
    LC_closed, Xf_pca, S_cand, S_plot, ...
    Opt_path_pca, path_type, ...
    figure_folder_name, fig_name, titleStr)

    % =====================================================
    % 颜色、线宽、三角大小：和你现在 PCA path 函数保持一致
    % =====================================================
    col_forward  = [0.5922 0.6000 0.5961];   % yellow
    col_backward = [0.4863 0.4745 0.4745];   % pink
    col_asyn     = [0.3569 0.7098 0.6745];   % red-ish
    col_syn_text = [0.6471 0.7098 0.3647];            % cyan

    lw_path = 6.5;
    triSize = 0.20;

    fig = figure('Visible', 'on');
    set(fig, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    hold on;

    % =====================================================
    % 作用量热力环
    % 小作用量深，大作用量浅
    % =====================================================
    surface( ...
        [LC_closed(:,1), LC_closed(:,1)], ...
        [LC_closed(:,2), LC_closed(:,2)], ...
        zeros(size(LC_closed,1),2), ...
        [S_plot, S_plot], ...
        'FaceColor', 'none', ...
        'EdgeColor', 'interp', ...
        'LineWidth', 10);

    % 候选点
    scatter(Xf_pca(:,1), Xf_pca(:,2), 45, S_cand, ...
        'filled', ...
        'MarkerEdgeColor', 'none');

    % =====================================================
    % 根据类型只画一条路径
    % =====================================================
    switch lower(path_type)
        case 'forward'
            path_color = col_forward;
            start_label = 'Asyn state';
            end_label   = 'Syn state';
            start_text_color = col_asyn;
            end_text_color   = col_syn_text;

        case 'backward'
            path_color = col_backward;
            start_label = 'Syn state';
            end_label   = 'Asyn state';
            start_text_color = col_syn_text;
            end_text_color   = col_asyn;

        otherwise
            error('path_type must be ''forward'' or ''backward''.');
    end

    % 画路径
    plot(Opt_path_pca(:,1), Opt_path_pca(:,2), ...
        '-', ...
        'Color', path_color, ...
        'LineWidth', lw_path);

    % 方向三角
    add_path_triangle(gca, Opt_path_pca, path_color, triSize);

    % =====================================================
    % 起点终点标注
    % =====================================================
    p_start = Opt_path_pca(1,:);
    p_end   = Opt_path_pca(end,:);

    % 起点 marker
    plot(p_start(1), p_start(2), 'o', ...
        'MarkerSize', 10, ...
        'MarkerFaceColor', start_text_color, ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.5);

    % 终点 marker
    plot(p_end(1), p_end(2), 'o', ...
        'MarkerSize', 10, ...
        'MarkerFaceColor', end_text_color, ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 1.5);

    % 文本
    text(p_start(1) + 0.03, p_start(2) - 0.03, start_label, ...
        'Color', start_text_color, ...
        'FontSize', 36, ...
        'FontWeight', 'bold');

    text(p_end(1) + 0.02, p_end(2) - 0.02, end_label, ...
        'Color', end_text_color, ...
        'FontSize', 36, ...
        'FontWeight', 'bold');

    axis equal;
    grid on;
    box on;

    xlabel('PC1', 'FontSize', 32, 'FontWeight', 'bold');
    ylabel('PC2', 'FontSize', 32, 'FontWeight', 'bold');
    title(titleStr, 'FontSize', 30, 'FontWeight', 'bold');

    set(gca, 'FontSize', 36, 'FontWeight', 'bold', 'LineWidth', 2);

    % 小 S 深色，大 S 浅色
    clrmap=slanCM('bone');
    colormap(clrmap);

    cb = colorbar;
    cb.Label.String = 'S';
    cb.Label.FontSize = 28;
    cb.Label.FontWeight = 'bold';

    % =====================================================
    % legend
    % =====================================================
    hP = plot(nan, nan, '-', 'Color', path_color, 'LineWidth', lw_path);

    switch lower(path_type)
        case 'forward'
            lgd_str = {'Forward path'};
        case 'backward'
            lgd_str = {'Backward path'};
    end

    lgd = legend(hP, lgd_str, ...
        'Location', 'best', ...
        'FontSize', 32);

    lgd.Box = 'on';
    lgd.Color = [1 1 1 0.90];
    lgd.EdgeColor = [0 0 0];

    fig_file = fullfile(figure_folder_name, fig_name);
    exportgraphics(fig, fig_file, 'Resolution', 300);
    close(fig);

    fprintf('Saved figure: %s\n', fig_file);
end


% =========================================================
% Helper: draw direction triangle
% =========================================================
function add_path_triangle(ax, P, faceColor, triSize)

    if nargin < 4 || isempty(triSize)
        triSize = 0.20;
    end

    if size(P,1) < 3
        return;
    end

    k = round(size(P,1) * 0.60);
    k = max(1, min(k, size(P,1)-1));

    p1 = P(k,:);
    p2 = P(k+1,:);

    v = p2 - p1;
    nv = norm(v);

    if nv < 1e-12
        return;
    end

    t = v / nv;
    n = [-t(2), t(1)];

    center = 0.5 * (p1 + p2);

    L = triSize;
    W = 0.55 * triSize;

    tip = center + 0.7 * L * t;
    base_center = center - 0.3 * L * t;

    v1 = tip;
    v2 = base_center + 0.5 * W * n;
    v3 = base_center - 0.5 * W * n;

    patch(ax, ...
        [v1(1), v2(1), v3(1)], ...
        [v1(2), v2(2), v3(2)], ...
        faceColor, ...
        'EdgeColor', 'none', ...
        'LineWidth', 1.5);
end