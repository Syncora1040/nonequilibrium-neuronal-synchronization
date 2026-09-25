function stats = plot_S_MFPTvsdeltaU(dU_S, logTau_S, figureFolder, opts)
% Plot ln(tau_S->A) versus the synchronized-state barrier with OLS fit.
if nargin < 4, opts = struct(); end
labels = struct('x', '\Delta U_{Syn}', 'y', 'ln \tau_{S\rightarrow A}', ...
    'file', 'MFPT_vs_dU_S.png');
stats = plot_MFPT_barrier_linear_fit(dU_S, logTau_S, figureFolder, labels, opts);
end
