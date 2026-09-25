function plot_3D_landscape_with_paths_pca(xvec, yvec, U, path_f, path_b, param, figure_folder_name, fig_name, varargin)
% plot_3D_landscape_with_paths
%
% 在 3D landscape surface 上叠加 forward/backward dominant paths
% 并在每条路径上均匀添加 3 个三角形方向标记
%
% 输入
% ----
% xvec, yvec :
%   landscape 网格坐标
%
% U :
%   landscape 矩阵，大小应为 [numel(yvec), numel(xvec)]
%
% path_f :
%   forward path，大小可以是 2 x N 或 N x 2
%
% path_b :
%   backward path，大小可以是 2 x N 或 N x 2
%
% param :
%   参数结构体，可含 param.gIE / param.g_IE / param.clrmap
%
% figure_folder_name :
%   保存文件夹
%
% fig_name :
%   保存文件名，例如 'Path_R_3D.png'
%
% 可选参数
% ----
% 'Visible'       'on'/'off'
% 'Save'          true/false
% 'CLim'          [] 或 [cmin cmax]
% 'SurfaceAlpha'  surface 透明度
% 'View'          视角
% 'ZOffset'       路径相对 surface 的轻微抬高比例
% 'LineWidth'     路径线宽
% 'MarkerSize'    起点终点 marker 大小
% 'ForwardColor'  forward path 颜色
% 'BackwardColor' backward path 颜色
% 'SaveSquare'    是否保存为 1024 x 1024
%
% 'ShowDirectionMarkers' 是否显示路径方向三角形
% 'DirectionMarkerSize'  方向三角形大小
%
% 'SmoothPath'    是否对路径做弧长插值平滑
% 'SmoothN'       平滑后路径点数
% 'SmoothMethod'  插值方式，推荐 'pchip'，也可用 'spline' 或 'linear'

p = inputParser;

addParameter(p,'Visible','off');
addParameter(p,'Save',true,@islogical);
addParameter(p,'CLim',[],@(v) isempty(v)||(isnumeric(v)&&numel(v)==2));
addParameter(p,'SurfaceAlpha',0.9,@isnumeric);
addParameter(p,'View',[45 25],@(v) isnumeric(v)&&numel(v)==2);
addParameter(p,'ZOffset',0.015,@isnumeric);
addParameter(p,'LineWidth',8,@isnumeric);
addParameter(p,'MarkerSize',300,@isnumeric);
addParameter(p,'ForwardColor',[1 1 1]);
addParameter(p,'BackwardColor',[1 1 0]);
addParameter(p,'SaveSquare',true,@islogical);

% 新增：路径方向三角形
addParameter(p,'ShowDirectionMarkers',true,@islogical);
addParameter(p,'DirectionMarkerSize',360,@isnumeric);

addParameter(p,'SmoothPath',true,@islogical);
addParameter(p,'SmoothN',500,@isnumeric);
addParameter(p,'SmoothMethod','pchip');

parse(p,varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

colAsync = [0 1 0];
colSync  = [1 0.4 0.7];
% =========================================================
% colormap
% =========================================================
if isfield(param,'clrmap')
    clrmap = param.clrmap;
else
    try
        clrmap = slanCM('viridis');
    catch
        clrmap = parula;
    end
end

% =========================================================
% 读取 gIE
% =========================================================
if isfield(param,'gIE')
    gIE = param.gIE;
elseif isfield(param,'g_IE')
    gIE = param.g_IE;
else
    gIE = NaN;
end

% =========================================================
% 数据整理
% =========================================================
xvec = xvec(:)';
yvec = yvec(:)';

[XX, YY] = meshgrid(xvec, yvec);

if ~isequal(size(U), [numel(yvec), numel(xvec)])
    error('U size mismatch: expected [%d,%d], got [%d,%d].', ...
        numel(yvec), numel(xvec), size(U,1), size(U,2));
end

path_f_raw = local_path_to_Nx2(path_f);
path_b_raw = local_path_to_Nx2(path_b);

% =========================================================
% 路径平滑：R 空间 / PCA 空间都统一处理
% =========================================================
if opt.SmoothPath
    path_f = local_smooth_path_by_arclength(path_f_raw, opt.SmoothN, opt.SmoothMethod);
    path_b = local_smooth_path_by_arclength(path_b_raw, opt.SmoothN, opt.SmoothMethod);
else
    path_f = path_f_raw;
    path_b = path_b_raw;
end

zmin = min(U(:), [], 'omitnan');
zmax = max(U(:), [], 'omitnan');
zrange = zmax - zmin;

if ~isfinite(zrange) || zrange <= 0
    zrange = 1;
end

zoff = opt.ZOffset * zrange;

% =========================================================
% 路径插值到 surface 上
% =========================================================
zf = interp2(XX, YY, U, path_f(:,1), path_f(:,2), 'linear');
zb = interp2(XX, YY, U, path_b(:,1), path_b(:,2), 'linear');

% 防止路径稍微超出网格导致 NaN
badf = ~isfinite(zf);
if any(badf)
    zf_near = interp2(XX, YY, U, path_f(:,1), path_f(:,2), 'nearest');
    zf(badf) = zf_near(badf);
end

badb = ~isfinite(zb);
if any(badb)
    zb_near = interp2(XX, YY, U, path_b(:,1), path_b(:,2), 'nearest');
    zb(badb) = zb_near(badb);
end

zf(~isfinite(zf)) = zmin;
zb(~isfinite(zb)) = zmin;

zf = zf + zoff;
zb = zb + zoff;

% 起点终点仍然用原始路径位置，避免插值后端点轻微漂移
pf_start = path_f_raw(1,:);
pf_end   = path_f_raw(end,:);
pb_start = path_b_raw(1,:);
pb_end   = path_b_raw(end,:);

zf_start = interp2(XX, YY, U, pf_start(1), pf_start(2), 'linear');
zf_end   = interp2(XX, YY, U, pf_end(1),   pf_end(2),   'linear');
zb_start = interp2(XX, YY, U, pb_start(1), pb_start(2), 'linear');
zb_end   = interp2(XX, YY, U, pb_end(1),   pb_end(2),   'linear');

if ~isfinite(zf_start)
    zf_start = interp2(XX, YY, U, pf_start(1), pf_start(2), 'nearest');
end

if ~isfinite(zf_end)
    zf_end = interp2(XX, YY, U, pf_end(1), pf_end(2), 'nearest');
end

if ~isfinite(zb_start)
    zb_start = interp2(XX, YY, U, pb_start(1), pb_start(2), 'nearest');
end

if ~isfinite(zb_end)
    zb_end = interp2(XX, YY, U, pb_end(1), pb_end(2), 'nearest');
end

if ~isfinite(zf_start), zf_start = zmin; end
if ~isfinite(zf_end),   zf_end   = zmin; end
if ~isfinite(zb_start), zb_start = zmin; end
if ~isfinite(zb_end),   zb_end   = zmin; end

zf_start = zf_start + zoff;
zf_end   = zf_end   + zoff;
zb_start = zb_start + zoff;
zb_end   = zb_end   + zoff;

% =========================================================
% 文件夹
% =========================================================
if ~exist(figure_folder_name,'dir')
    mkdir(figure_folder_name);
end

% =========================================================
% 作图
% =========================================================
h = figure('Color','w');
clf;

set(h,'Units','normalized');
set(h,'OuterPosition',[0 0 1 1]);
set(h,'Visible',opt.Visible);

hold on;

surf(XX, YY, U, ...
    'EdgeColor','none', ...
    'FaceAlpha',opt.SurfaceAlpha);

shading interp;
colormap(clrmap);

cb = colorbar;
cb.Label.String = 'U';
cb.Label.FontSize = 36;
cb.Label.FontWeight = 'bold';

if ~isempty(opt.CLim)
    caxis(opt.CLim);
end

% =========================================================
% forward path
% =========================================================
plot3(path_f(:,1), path_f(:,2), zf, ...
    '-', ...
    'Color',opt.ForwardColor, ...
    'LineWidth',opt.LineWidth);

% forward path 上均匀加 3 个三角形方向标记
if opt.ShowDirectionMarkers
    idx_dir_f = local_direction_marker_indices(size(path_f,1));

    if ~isempty(idx_dir_f)
        scatter3(path_f(idx_dir_f,1), path_f(idx_dir_f,2), zf(idx_dir_f), ...
    opt.DirectionMarkerSize, ...
    opt.ForwardColor, ...
    '^', ...
    'filled', ...
    'MarkerEdgeColor','k', ...
    'LineWidth',1.0);
    end
end

scatter3(pf_start(1), pf_start(2), zf_start, ...
    opt.MarkerSize, ...
    colAsync, ...
    'filled', ...
    'MarkerEdgeColor','none', ...
    'LineWidth',1.2);
% text(pf_start(1), pf_start(2), zf_start + 0.5*zrange, ...
%     'AS', ...
%     'FontSize',36, ...
%     'FontWeight','bold', ...
%     'Color',colAsync, ...
%     'HorizontalAlignment','center', ...
%     'VerticalAlignment','bottom');

scatter3(pf_end(1), pf_end(2), zf_end, ...
    opt.MarkerSize, ...
    colSync, ...
    'filled', ...
    'MarkerEdgeColor','none', ...
    'LineWidth',1.2);
% text(pf_end(1)-0.2, pf_end(2), zf_end + 0.5*zrange, ...
%     'SS1', ...
%     'FontSize',35, ...
%     'FontWeight','bold', ...
%     'Color',colSync, ...
%     'HorizontalAlignment','center', ...
%     'VerticalAlignment','bottom');

% =========================================================
% backward path
% =========================================================
plot3(path_b(:,1), path_b(:,2), zb, ...
    '-', ...
    'Color',opt.BackwardColor, ...
    'LineWidth',opt.LineWidth);

% backward path 上均匀加 3 个三角形方向标记
if opt.ShowDirectionMarkers
    idx_dir_b = local_direction_marker_indices(size(path_b,1));

    if ~isempty(idx_dir_b)
       scatter3(path_b(idx_dir_b,1), path_b(idx_dir_b,2), zb(idx_dir_b), ...
    opt.DirectionMarkerSize, ...
    opt.BackwardColor, ...
    '>', ...
    'filled', ...
    'MarkerEdgeColor','k', ...
    'LineWidth',1.0);
    end
end

scatter3(pb_start(1), pb_start(2), zb_start, ...
    opt.MarkerSize, ...
    colSync, ...
    'filled', ...
    'MarkerEdgeColor','none', ...
    'LineWidth',1.2);
% text(pb_start(1), pb_start(2), zb_start + 0.8*zrange, ...
%     'SS2', ...
%     'FontSize',35, ...
%     'FontWeight','bold', ...
%     'Color',colSync, ...
%     'HorizontalAlignment','center', ...
%     'VerticalAlignment','bottom');

% 如果你后面想显示 backward end，可以取消注释
% scatter3(pb_end(1), pb_end(2), zb_end, ...
%     opt.MarkerSize, ...
%     opt.BackwardColor, ...
%     'p', ...
%     'filled', ...
%     'MarkerEdgeColor','none', ...
%     'LineWidth',1.2);

% =========================================================
% 坐标轴与风格
% =========================================================
xlabel('PC1','FontSize',50,'FontWeight','bold');
ylabel('PC2','FontSize',50,'FontWeight','bold');
zlabel('U','FontSize',50,'FontWeight','bold');

% title(sprintf('Landscape with Paths  (g_{IE}=%.5f)', gIE), ...
%     'FontSize',25, ...
%     'FontWeight','bold');

set(gca,'FontSize',55,'FontWeight','bold');

grid on;
box on;
axis tight;

zlim([zmin - 0.04*zrange, zmax + 0.08*zrange]);

view(opt.View(1), opt.View(2));

% 如果太暗，可以打开
% camlight headlight;
% lighting gouraud;

% legend({'Landscape','Forward path','Forward direction','Forward start','Forward end', ...
%         'Backward path','Backward direction','Backward start','Backward end'}, ...
%         'Location','bestoutside');

% =========================================================
% 保存
% =========================================================
if opt.Save
    fname = fullfile(figure_folder_name, fig_name);
    print(h, fname, '-dpng', '-r300');

    if opt.SaveSquare
        try
            N = 1024;
            [img,~,alpha] = imread(fname);
            img2 = imresize(img,[N N]);

            if ~isempty(alpha)
                alpha2 = imresize(alpha,[N N]);
                imwrite(img2,fname,'Alpha',alpha2);
            else
                imwrite(img2,fname);
            end
        catch
        end
    end

    close(h);
end

end

% =========================================================
% local function: path 转成 N x 2
% =========================================================
function path = local_path_to_Nx2(path)

    if isempty(path)
        error('Path is empty.');
    end

    if size(path,1) == 2 && size(path,2) ~= 2
        path = path';
    elseif size(path,2) == 2
        % already N x 2
    else
        error('Path must be 2 x N or N x 2.');
    end

    path = double(path);
end

% =========================================================
% local function: 弧长参数化路径平滑
% =========================================================
function path_smooth = local_smooth_path_by_arclength(path, SmoothN, SmoothMethod)

    if size(path,1) < 3
        path_smooth = path;
        return;
    end

    % 去掉非有限点
    valid = all(isfinite(path),2);
    path = path(valid,:);

    if size(path,1) < 3
        path_smooth = path;
        return;
    end

    % 去掉连续重复点，避免弧长为 0
    d = sqrt(sum(diff(path,1,1).^2,2));
    keep = [true; d > 1e-12];
    path = path(keep,:);

    if size(path,1) < 3
        path_smooth = path;
        return;
    end

    % 弧长参数
    ds = sqrt(sum(diff(path,1,1).^2,2));
    s = [0; cumsum(ds)];

    if s(end) <= 0 || ~isfinite(s(end))
        path_smooth = path;
        return;
    end

    % 目标插值点数
    SmoothN = max(SmoothN, size(path,1));
    sq = linspace(0, s(end), SmoothN).';

    % pchip 比 spline 更不容易过冲
    xq = interp1(s, path(:,1), sq, SmoothMethod);
    yq = interp1(s, path(:,2), sq, SmoothMethod);

    path_smooth = [xq, yq];

    % 强制端点保持完全一致
    path_smooth(1,:)   = path(1,:);
    path_smooth(end,:) = path(end,:);
end

% =========================================================
% local function: 每条路径均匀选 3 个方向三角形标记点
% =========================================================
function idx_dir = local_direction_marker_indices(N)

    if N < 3
        idx_dir = [];
        return;
    end

    % 只在路径中点放 1 个方向三角形
    idx_dir = round(N/2);

    % 避免和起点/终点重合
    idx_dir = max(2, min(N-1, idx_dir));

end