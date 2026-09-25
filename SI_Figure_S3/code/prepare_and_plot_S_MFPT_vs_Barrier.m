function [g_common, dU_common, MFPT_common] = prepare_and_plot_S_MFPT_vs_Barrier(gB, Barrier, gM, MFPT, figure_folder_name, doLogMFPT, plotOpts)
%PREPARE_AND_PLOT_MFPT_VS_BARRIER
% Match common gIE values between Barrier and MFPT data, then plot MFPT vs Barrier.
%
% Inputs:
%   gB                 : gIE vector for Barrier
%   Barrier            : Barrier vector
%   gM                 : gIE vector for MFPT
%   MFPT               : MFPT vector
%   figure_folder_name : figure save folder
%   doLogMFPT          : true if plotting ln(MFPT), false if MFPT already logged
%
% Outputs:
%   g_common           : common gIE values
%   dU_common          : matched Barrier values
%   MFPT_common        : matched MFPT or ln(MFPT)

    if nargin < 6
        doLogMFPT = true;
    end
    if nargin < 7, plotOpts = struct(); end

    gB = gB(:);
    Barrier = Barrier(:);

    gM = gM(:);
    MFPT = MFPT(:);

    if numel(gB) ~= numel(Barrier)
        error('gB and Barrier must have the same length.');
    end

    if numel(gM) ~= numel(MFPT)
        error('gM and MFPT must have the same length.');
    end

    % 浮点容差匹配
    scale = 1e6;
    gB_key = round(gB * scale) / scale;
    gM_key = round(gM * scale) / scale;

    [g_common, idxB, idxM] = intersect(gB_key, gM_key, 'stable');

    dU_common = Barrier(idxB);
    MFPT_common = MFPT(idxM);

    if doLogMFPT
        MFPT_common = log(MFPT_common);
    end

    valid = isfinite(g_common) & isfinite(dU_common) & isfinite(MFPT_common);

    g_common = g_common(valid);
    dU_common = dU_common(valid);
    MFPT_common = MFPT_common(valid);
 %    idx=[1,3,4,6,7,9];
 % dU_common(idx)=nan;MFPT_common(idx)=nan;
 % valid = isfinite(g_common) & isfinite(dU_common) & isfinite(MFPT_common);
 % dU_common = dU_common(valid);MFPT_common = MFPT_common(valid);

    plot_S_MFPTvsdeltaU(dU_common, MFPT_common, figure_folder_name, plotOpts);
end
