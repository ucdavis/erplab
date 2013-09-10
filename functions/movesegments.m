% PURPOSE: subroutine for pop_continuousartdet.m
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

function [WinRej chanrej] = movesegments(WinRej, chanrej, winoffsetsam, pnts)
fprintf('\nWARNING: Marked segments will be displaced in %g samples.\n\n', winoffsetsam);
WinRej = WinRej + winoffsetsam;
WinRej(WinRej<1) = 1;
WinRej(WinRej>pnts) = pnts;
[WinRej chanrej] = discardshortsegments(WinRej, chanrej, 0, 0);

