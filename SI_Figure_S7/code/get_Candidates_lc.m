function [Xlc, zLC, idxLC] = get_Candidates_lc(zS, frac)
%EXTRACT_LC_CANDIDATES_FROM_ZS
% Take the last frac portion of a 2 x T complex trajectory zS,
% and convert it to a 4 x N real trajectory:
%
%   zS  = [zE(t);
%          zI(t)]              % 2 x T complex
%
%   Xlc = [real(zE);
%          imag(zE);
%          real(zI);
%          imag(zI)]           % 4 x N
%
% Inputs:
%   zS   : 2 x T complex matrix
%   frac : fraction of tail to keep, e.g. 0.10
%
% Outputs:
%   Xlc   : 4 x Nlc real matrix
%   zLC   : 2 x Nlc complex matrix, selected tail of zS
%   idxLC : indices in the original zS trajectory

    if nargin < 2 || isempty(frac)
        frac = 0.10;
    end

    if size(zS,1) ~= 2
        error('zS must be a 2 x T complex matrix: first row zE, second row zI.');
    end

    T = size(zS,2);
    Nlc = max(1, round(frac * T));

    idxStart = T - Nlc + 1;
    idxLC = idxStart:T;

    zLC = zS(:, idxLC);

    zE = zLC(1,:);
    zI = zLC(2,:);

    Xlc = [
        real(zE);
        imag(zE);
        real(zI);
        imag(zI)
    ];
end