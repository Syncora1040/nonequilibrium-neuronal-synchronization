function Xlc_smooth = fit_closed_curve(Xlc, nBins)
%FIT_CLOSED_CURVE_BINNED
% 将带噪声极限环点沿角度或极坐标分区，取每个区的均值作为平滑闭合曲线
%
% Inputs:
%   Xlc    : N x 2 点 (极限环散点)
%   nBins  : 要生成的平滑点数 / bin 数
%
% Output:
%   Xlc_smooth : nBins x 2 平滑闭合曲线

if nargin < 2
    nBins = 200;
end

% -------------------------------
% 1) 中心化点云
% -------------------------------
center = mean(Xlc,1);
Xc = Xlc - center;  % N x 2

% -------------------------------
% 2) 转极坐标
% -------------------------------
[theta,rho] = cart2pol(Xc(:,1), Xc(:,2));

% -------------------------------
% 3) 将 theta 映射到 [0, 2pi]
% -------------------------------
theta(theta<0) = theta(theta<0) + 2*pi;

% -------------------------------
% 4) 将 0-2pi 分成 nBins 区间
% -------------------------------
edges = linspace(0, 2*pi, nBins+1);
Xlc_smooth = zeros(nBins,2);

for k = 1:nBins
    idx = theta >= edges(k) & theta < edges(k+1);
    if sum(idx)==0
        % 如果这一段没有点，用上一段点代替
        Xlc_smooth(k,:) = Xlc_smooth(max(k-1,1),:);
    else
        % 区间内点的均值
        meanX = mean(Xlc(idx,1));
        meanY = mean(Xlc(idx,2));
        Xlc_smooth(k,:) = [meanX, meanY];
    end
end

% -------------------------------
% 5) 闭合曲线
% -------------------------------
% 平均最后一个点和第一个点距离
distEndStart = norm(Xlc_smooth(1,:) - Xlc_smooth(end,:));
if distEndStart > 1e-3
    Xlc_smooth(end,:) = Xlc_smooth(1,:);
end
end