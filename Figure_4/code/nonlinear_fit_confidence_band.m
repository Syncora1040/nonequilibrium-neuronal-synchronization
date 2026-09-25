function [yCI, pModel, info] = nonlinear_fit_confidence_band( ...
    model, thetaHat, x, y, xPred, confidenceLevel)
% Approximate nonlinear mean-response CI using a numerical Jacobian.
% pModel is an approximate overall F-test against an intercept-only model.

if nargin < 6 || isempty(confidenceLevel), confidenceLevel = 0.95; end
x = x(:); y = y(:); xPred = xPred(:); thetaHat = thetaHat(:).';
n = numel(y); k = numel(thetaHat);

yHat = model(thetaHat, x);
yPred = model(thetaHat, xPred);
residual = y - yHat;
sse = sum(residual.^2);
sst = sum((y - mean(y)).^2);
dof = n - k;

Jdata = numerical_jacobian(model, thetaHat, x);
Jpred = numerical_jacobian(model, thetaHat, xPred);

if dof > 0
    mse = sse / dof;
    covTheta = mse * pinv(Jdata.' * Jdata);
    predVar = sum((Jpred * covTheta) .* Jpred, 2);
    predSE = sqrt(max(predVar, 0));
    tCritical = tinv(0.5 + confidenceLevel/2, dof);
    yCI = [yPred - tCritical*predSE, yPred + tCritical*predSE];
else
    mse = NaN;
    covTheta = nan(k);
    yCI = [nan(size(yPred)), nan(size(yPred))];
end

dfModel = k - 1;
if dof > 0 && dfModel > 0 && sse > 0 && sst > sse
    F = ((sst - sse) / dfModel) / (sse / dof);
    pModel = fcdf(F, dfModel, dof, 'upper');
else
    F = NaN;
    pModel = NaN;
end

info = struct('SSE', sse, 'SST', sst, 'MSE', mse, 'F', F, ...
    'dfModel', dfModel, 'dfError', dof, 'covTheta', covTheta);
end

function J = numerical_jacobian(model, theta, x)
n = numel(x); k = numel(theta);
J = zeros(n, k);
for j = 1:k
    step = sqrt(eps) * max(1, abs(theta(j)));
    thetaPlus = theta;
    thetaMinus = theta;
    thetaPlus(j) = thetaPlus(j) + step;
    thetaMinus(j) = thetaMinus(j) - step;
    J(:,j) = (model(thetaPlus, x) - model(thetaMinus, x)) / (2*step);
end
end
