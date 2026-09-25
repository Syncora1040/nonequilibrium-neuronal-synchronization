function stats = plot_A_MFPTvsdeltaU(dU_A, logTau_A, figureFolder, opts)
% Plot ln(tau_A->S) versus the asynchronous-state barrier with OLS fit.
if nargin < 4, opts = struct(); end
labels = struct('x', '\Delta U_{Asyn}', 'y', 'ln \tau_{A\rightarrow S}', ...
    'file', 'MFPT_vs_dU_A.png');
stats = plot_MFPT_barrier_linear_fit(dU_A, logTau_A, figureFolder, labels, opts);
end
