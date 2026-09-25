function creature_figure_landscape_flux_3D(landscape, flux, param, figure_folder_name, varargin)
% creature_figure_landscape_flux_3D
%
% 合并原来的 Fig1 Landscape 和 Fig2 Flux：
%   1) 3D landscape: z = U(R_E, R_I)
%   2) flux arrows: 直接画在 landscape surface 上
%
% 修改重点：
%   - 不再把 flux 画在 z = 0 平面
%   - 不再画 z = 0 灰色平面
%   - flux 箭头的 z 坐标通过 interp2 从 landscape U 上插值得到
%   - 所有非零 flux 箭头长度统一
%
% 输入：
%
% landscape :
%   .cE
%   .cI
%   .U
%
% flux :
%   .x_centers
%   .y_centers
%   .U
%   .Jx
%   .Jy
%
% param :
%   .gIE 或 .g_IE
%
% figure_folder_name :
%   输出路径
%
% 可选参数：
%   Step          quiver 抽稀，例如 [3 3]
%   CLim          landscape colorbar 范围
%   Save          是否保存
%   Visible       'on' / 'off'
%   ArrowGain     保留参数；统一长度模式下不参与缩放
%   ArrowBase     所有非零 flux 箭头统一长度比例
%   ArrowLineWidth flux 箭头粗细
%   FluxColor     flux 箭头颜色，默认 'w'
%   SurfaceAlpha  landscape 透明度，默认 0.88
%   View          视角
%   ZOffset       箭头相对 surface 的轻微抬高比例，避免被 surface 遮住
%   ZPad          z 轴上下额外留白比例
%   PauseBeforeClose 是否在保存/关闭前暂停，便于手动调 view
%   SaveSquare    是否保存后转成 1024x1024，默认 true

p = inputParser;

addParameter(p,'Step',[],@(v) isempty(v)||(isnumeric(v)&&numel(v)==2));
addParameter(p,'CLim',[],@(v) isempty(v)||(numel(v)==2));
addParameter(p,'Save',true,@islogical);
addParameter(p,'Visible','on');

addParameter(p,'ArrowGain',3,@isnumeric);
addParameter(p,'ArrowBase',0.025,@isnumeric);
addParameter(p,'ArrowLineWidth',3.2,@isnumeric);
addParameter(p,'FluxColor','w');

addParameter(p,'SurfaceAlpha',0.88,@isnumeric);
addParameter(p,'View',[2.039320191489361e+02,35.2721002206804145],@(v) isnumeric(v)&&numel(v)==2);

addParameter(p,'ZOffset',0.01,@isnumeric);
addParameter(p,'ZPad',0.04,@isnumeric);

addParameter(p,'PauseBeforeClose',false,@islogical);
addParameter(p,'SaveSquare',true,@islogical);

parse(p,varargin{:});
opt = p.Results;

set(0,'DefaultAxesFontName','Latin Modern Math');
set(0,'DefaultTextFontName','Latin Modern Math');

% ===== colormap =====
if isfield(param,'clrmap')
    clrmap = param.clrmap;
else
    try
        clrmap = slanCM('viridis');
    catch
        clrmap = parula;
    end
end

% ===== 读取 gIE =====
if isfield(param,'gIE')
    gIE = param.gIE;
elseif isfield(param,'g_IE')
    gIE = param.g_IE;
else
    gIE = NaN;
end

% ===== 文件夹 =====
Merge_folder = fullfile(figure_folder_name,'Landscape_Flux_3D');
if ~exist(Merge_folder,'dir')
    mkdir(Merge_folder);
end

% =========================================================
% Landscape 数据
% =========================================================
cE = landscape.cE(:)';
cI = landscape.cI(:)';
U_land = landscape.U;

[CE, CI] = meshgrid(cE, cI);

% =========================================================
% Flux 数据
% =========================================================
xvec = flux.x_centers(:)';
yvec = flux.y_centers(:)';

Jx = flux.Jx;
Jy = flux.Jy;

nx = numel(xvec);
ny = numel(yvec);

% =========================================================
% quiver 抽稀
% =========================================================
nn = 30;

if isempty(opt.Step)
    sx = max(1, round(nx/nn));
    sy = max(1, round(ny/nn));
else
    sx = opt.Step(1);
    sy = opt.Step(2);
end

[Xq, Yq] = meshgrid(xvec(1:sx:end), yvec(1:sy:end));

Jxq = Jx(1:sy:end, 1:sx:end);
Jyq = Jy(1:sy:end, 1:sx:end);

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
L0 = opt.ArrowBase * min(range(xvec), range(yvec));

L = L0 * ones(size(M));
L(M <= epsM) = 0;

Jxr = ux .* L;
Jyr = uy .* L;
Jzr = zeros(size(Jxr));

% =========================================================
% flux 箭头不再放在 z = 0
% 而是插值到 landscape surface 上
% =========================================================
Zq = interp2(CE, CI, U_land, Xq, Yq, 'linear');

% 防止 flux 网格稍微超出 landscape 网格导致 NaN
badZ = ~isfinite(Zq);
if any(badZ(:))
    Zq_nearest = interp2(CE, CI, U_land, Xq, Yq, 'nearest');
    Zq(badZ) = Zq_nearest(badZ);
end

% 再清一次，如果仍然有 NaN，就用 U 的最小值兜底
badZ = ~isfinite(Zq);
if any(badZ(:))
    Zq(badZ) = min(U_land(:), [], 'omitnan');
end

% 轻微抬高箭头，避免被 surface 遮住
zmin = min(U_land(:), [], 'omitnan');
zmax = max(U_land(:), [], 'omitnan');
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

% -----------------------------
% 1. landscape surface
% -----------------------------
surf(CE, CI, U_land, ...
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

% -----------------------------
% 2. flux arrows on landscape surface
% -----------------------------
quiver3(Xq, Yq, Zq, ...
    Jxr, Jyr, Jzr, ...
    0, ...
    opt.FluxColor, ...
    'LineWidth',opt.ArrowLineWidth, ...
    'MaxHeadSize',7.5);

% =========================================================
% 坐标轴与风格
% =========================================================
xlabel('R_E','FontSize',60,'FontWeight','bold');
ylabel('R_I','FontSize',60,'FontWeight','bold');
zlabel('U','FontSize',60,'FontWeight','bold');

% title(sprintf('g_{IE}=%.5f', gIE), ...
%     'FontSize',40, ...
%     'FontWeight','bold');

set(gca,'FontSize',32,'FontWeight','bold');

grid on;
box on;
axis tight;

view(opt.View(1), opt.View(2));

% z 方向留一点空间，避免箭头贴顶
if isfinite(zmin) && isfinite(zmax)
    dz = zmax - zmin;
    if dz <= 0 || ~isfinite(dz)
        dz = 1;
    end

    zlim([zmin - opt.ZPad * dz, zmax + opt.ZPad * dz]);
end

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
        sprintf('LF_3D_g_IE=%.5f.png', gIE));

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
            % 如果 imresize 或 alpha 处理出问题，就保留原图
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
