function files = plot_selected_paths_PCA( ...
    Results_forward, Results_backward, PCA_W, forwardIndex, backwardIndex, outDir)
% Plot only the forward and backward PCA candidates used in the SI panel.

if ~exist(outDir, 'dir'), mkdir(outDir); end
if size(PCA_W,1) ~= 4 || size(PCA_W,2) < 2
    error('PCA_W must have four rows and at least two columns.');
end
PCA_W = PCA_W(:,1:2);

files.forward = plot_one(Results_forward, forwardIndex, PCA_W, outDir, 'forward');
files.backward = plot_one(Results_backward, backwardIndex, PCA_W, outDir, 'backward');
end

function outFile = plot_one(results, candidateIndex, PCA_W, outDir, direction)
if candidateIndex < 1 || candidateIndex > numel(results) || ...
        isempty(results{candidateIndex})
    error('%s candidate %d is unavailable.', direction, candidateIndex);
end
result = results{candidateIndex};
if isfield(result, 'path4D')
    path4D = result.path4D;
elseif isfield(result, 'Xopt')
    path4D = result.Xopt;
else
    error('%s candidate %d has neither path4D nor Xopt.', direction, candidateIndex);
end
if size(path4D,1) ~= 4
    error('Candidate path must be a 4-by-N array.');
end
Y = path4D.' * PCA_W;
if isfield(result, 'Sopt'), action = result.Sopt; else, action = NaN; end

fig = figure('Visible', 'off');
hold on;
plot(Y(:,1), Y(:,2), 'o-', 'LineWidth', 1.8, 'MarkerSize', 5);
plot(Y(1,1), Y(1,2), 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
plot(Y(end,1), Y(end,2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
if size(Y,1) >= 2
    quiver(Y(1:end-1,1), Y(1:end-1,2), ...
        diff(Y(:,1)), diff(Y(:,2)), 0, 'LineWidth', 1.0);
end
grid on; box on; axis equal;
xlabel('PC1'); ylabel('PC2');
title(sprintf('%s PCA path, cand = %d, S = %.4g', ...
    capitalize(direction), candidateIndex, action), 'Interpreter', 'none');
outFile = fullfile(outDir, ...
    sprintf('PCA_%s_cand_%03d.png', direction, candidateIndex));
exportgraphics(fig, outFile, 'Resolution', 300);
close(fig);
end

function value = capitalize(value)
value(1) = upper(value(1));
end
