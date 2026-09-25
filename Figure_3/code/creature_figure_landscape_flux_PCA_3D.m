function creature_figure_landscape_flux_PCA_3D(landscape, flux, param, figure_folder_name, varargin)
% creature_figure_landscape_flux_PCA_3D
%
% PCA 空间中合并 Landscape 和 Flux：
%   1) 3D landscape: z = U(PCA1, PCA2)
%   2) flux arrows: 直接画在 landscape surface 上
%
% 修改重点：
%   - 不再把 flux 画在 z = 0 平面
%   - 不再画 z = 0 平面
%   - 不再投影 contour 到 z = 0
%   - 不再扩展 xlim / ylim
%   - flux 箭头的 z 坐标通过 interp2 从 landscape U 上插值得到
%   - 所有非零 flux 箭头长度统一
%
% 输入
% ----
% landscape :
%   .c1
%   .c2
%   .U
%   .P       可选
%   .Yall    可选
%
% flux :
%   .x_centers  可选；如果没有，则默认用 landscape.c1
%   .y_centers  可选；如果没有，则默认用 landscape.c2
%   .Jx
%   .Jy
%
% param :
%   .gIE 或 .g_IE
%
% figure_folder_name :
%   输出路径
%
% 可选参数
% ----
% 'Step'          [] 或 [sx sy]     quiver 抽稀
% 'CLim'          [] 或 [c1 c2]     landscape colorbar 范围
% 'Save'          true/false
% 'Visible'       'on'/'off'
%
% 'ArrowGain'     3                 保留参数；统一长度模式下不参与缩放
% 'ArrowBase'     0.025             所有非零 flux 箭头的统一长度比例
% 'ArrowLineWidth' 3.2              flux 箭头粗细
% 'FluxColor'     'w'               flux 箭头颜色
% 'SurfaceAlpha'  0.9               landscape 透明度
% 'View'          [45 22]           3D 视角
% 'ZOffset'       0.01              箭头相对 surface 的轻微抬高比例，避免被 surface 遮住
% 'ZPad'          0.04              z 轴上下额外留白比例
% 'PauseBeforeClose' false          是否在保存/关闭前暂停，便于手动调 view
% 'SaveSquare'    true              是否保存成 1024 x 1024

p = inputParser;

addParameter(p,'Step',[],@(v) isempty(v)||(isnumeric(v)&&numel(v)==2));
addParameter(p,'CLim',[],@(v) isempty(v)||(isnumeric(v)&&numel(v)==2));
addParameter(p,'Save',true,@islogical);
addParameter(p,'Visible','off');

addParameter(p,'ArrowGain',3,@isnumeric);
addParameter(p,'ArrowBase',0.025,@isnumeric);
addParameter(p,'ArrowLineWidth',3.2,@isnumeric);
addParameter(p,'FluxColor','w');

addParameter(p,'SurfaceAlpha',0.9,@isnumeric);
addParameter(p,'View',[45 22],@(v) isnumeric(v)&&numel(v)==2);

addParameter(p,'ZOffset',0.01,@isnumeric);
addParameter(p,'ZPad',0.04,@isnumeric);

addParameter(p,'PauseBeforeClose',false,@islogical);
addParameter(p,'SaveSquare',true,@islogical);

parse(p,varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

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
% 文件夹
% =========================================================
Merge_folder = fullfile(figure_folder_name,'PCA_Landscape_Flux_3D');
if ~exist(Merge_folder,'dir')
    mkdir(Merge_folder);
end

% =========================================================
% Landscape 数据
% =========================================================
xvec_land = landscape.c1(:)';   % PCA1
yvec_land = landscape.c2(:)';   % PCA2
U         = landscape.U;

[XX, YY] = meshgrid(xvec_land, yvec_land);

% =========================================================
% Flux 数据
% =========================================================
if isfield(flux,'x_centers')
    xvec_flux = flux.x_centers(:)';
else
    xvec_flux = xvec_land;
end

if isfield(flux,'y_centers')
    yvec_flux = flux.y_centers(:)';
else
    yvec_flux = yvec_land;
end

Jx = flux.Jx;
Jy = flux.Jy;

% =========================================================
% quiver 抽稀
% =========================================================
nx = numel(xvec_flux);
ny = numel(yvec_flux);

nn = 22.5;

if isempty(opt.Step)
    sx = max(1, round(nx/nn));
    sy = max(1, round(ny/nn));
else
    sx = opt.Step(1);
    sy = opt.Step(2);
end

[Xq, Yq] = meshgrid(xvec_flux(1:sx:end), yvec_flux(1:sy:end));

Jxq = Jx(1:sy:end, 1:sx:end);
Jyq = Jy(1:sy:end, 1:sx:end);

% ===== 清理非有限值 =====
bad = ~isfinite(Jxq) | ~isfinite(Jyq);
Jxq(bad) = 0;
Jyq(bad) = 0;

% =========================================================
% 箭头长度归一化：方向来自 flux，所有非零箭头长度统一
% =========================================================
M = hypot(Jxq, Jyq);
epsM = 1e-323;

ux = Jxq ./ max(M, epsM);
uy = Jyq ./ max(M, epsM);

% 所有非零 flux 箭头统一长度
L0 = opt.ArrowBase * min(range(xvec_flux), range(yvec_flux));

L = L0 * ones(size(M));
L(M <= epsM) = 0;

Jxr = ux .* L;
Jyr = uy .* L;
Jzr = zeros(size(Jxr));

% =========================================================
% flux 箭头不再放在 z = 0
% 而是插值到 landscape surface 上
% =========================================================
Zq = interp2(XX, YY, U, Xq, Yq, 'linear');

% 防止 flux 网格稍微超出 landscape 网格导致 NaN
badZ = ~isfinite(Zq);
if any(badZ(:))
    Zq_nearest = interp2(XX, YY, U, Xq, Yq, 'nearest');
    Zq(badZ) = Zq_nearest(badZ);
end

% 再清一次，如果仍然有 NaN，就用 U 的最小值兜底
badZ = ~isfinite(Zq);
if any(badZ(:))
    Zq(badZ) = min(U(:), [], 'omitnan');
end

% 轻微抬高箭头，避免被 surface 遮住
zmin = min(U(:), [], 'omitnan');
zmax = max(U(:), [], 'omitnan');
zrange = zmax - zmin;

if ~isfinite(zrange) || zrange <= 0
    zrange = 1;
end

Zq = Zq + opt.ZOffset * zrange;

% =========================================================
% 作图
% =========================================================
h = figure('Color','w');
clf;

set(h,'Units','normalized');
set(h,'OuterPosition',[0 0 1 1]);
set(h,'Visible',opt.Visible);

hold on;

% ---------------------------------------------------------
% 1. PCA Landscape 3D surface
% ---------------------------------------------------------
surf(XX, YY, U, ...
    'EdgeColor','none', ...
    'FaceAlpha',opt.SurfaceAlpha);

shading interp;
colormap(clrmap);

cb = colorbar;
cb.Label.String = 'U';
cb.Label.FontSize = 30;
cb.Label.FontWeight = 'bold';

if ~isempty(opt.CLim)
    caxis(opt.CLim);
end

% ---------------------------------------------------------
% 2. Flux arrows on landscape surface
% ---------------------------------------------------------
quiver3(Xq, Yq, Zq, ...
    Jxr, Jyr, Jzr, ...
    0, ...
    opt.FluxColor, ...
    'LineWidth',opt.ArrowLineWidth, ...
    'MaxHeadSize',1.5);

% =========================================================
% 坐标轴与风格
% =========================================================
xlabel('PC1','FontSize',60,'FontWeight','bold');
ylabel('PC2','FontSize',60,'FontWeight','bold');
zlabel('U','FontSize',60,'FontWeight','bold');

% title(sprintf('g_{IE}=%.5f', gIE), ...
%     'FontSize',40, ...
%     'FontWeight','bold');

set(gca,'FontSize',36,'FontWeight','bold');

grid on;
box on;
axis tight;

% =========================================================
% zlim：只给 z 方向留一点空间
% 不再人为扩展 xlim / ylim
% =========================================================
if isfinite(zmin) && isfinite(zmax)
    dz = zmax - zmin;
    if dz <= 0 || ~isfinite(dz)
        dz = 1;
    end

    zlim([zmin - opt.ZPad * dz, zmax + opt.ZPad * dz]);
end

view(opt.View(1), opt.View(2));

% 如果你觉得 surface 太暗，可以取消下面两行注释
% camlight headlight;
% lighting gouraud;

% =========================================================
% 保存
% =========================================================
if opt.PauseBeforeClose
    wait_for_continue_before_save(h);
end

if opt.Save
    fname = fullfile(Merge_folder, ...
        sprintf('PCA_Landscape_Flux_3D_gIE=%.5f.png', gIE));

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
            % 如果 imresize 或 alpha 处理失败，就保留原始图片
        end
    end

    close(h);
end

end

function wait_for_continue_before_save(h)

if ~ishandle(h)
    return;
end

set(h, 'Visible', 'on');
drawnow;

btn = uicontrol(h, ...
    'Style', 'pushbutton', ...
    'String', 'Continue', ...
    'Units', 'normalized', ...
    'Position', [0.87 0.02 0.10 0.045], ...
    'FontSize', 12, ...
    'Callback', @(~, ~) uiresume(h));

fprintf('Figure is paused. Adjust the view, then click Continue in the figure window.\n');
uiwait(h);

if ishandle(h)
    [az, el] = view(gca);
    fprintf('Current view = [%.15g, %.15g]\n', az, el);
end

if ishandle(btn)
    delete(btn);
end
drawnow;

end
