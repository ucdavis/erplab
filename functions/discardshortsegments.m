% PURPOSE: subroutine for pop_continuousartdet.m
%          discards short marked segments after continuous artifact detection
%
% FORMAT
%
% [WinRej2 ChanRej2 ] = discardshortsegments(WinRej, chanrej, shortsegsam, dwarning);
%
% INPUTS:
%
% WinRej         - latency array. Each row is a pair of values (start end), so the array has 2 columns.
% chanrej        - marked channels array 
% shortsegsam    - duration threshold in seconds (marked windows lower than this value will be unmarked)
% dwarning       - display warning. 1 yes; 0 no
%
% OUTPUT
%
% WinRej2        - latency array for marked windows that were not shorter than the specified value at shortsegsam.
% ChanRej2       - marked channels array belonging to WinRej2
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2011

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright © 2007 The Regents of the University of California
% Created by Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [WinRej2 ChanRej2 ] = discardshortsegments(WinRej, chanrej, shortsegsam, dwarning)

WinRej2= []; ChanRej2 = [];
if nargin<4
        dwarning = 1;
end
if dwarning
        fprintf('\nWARNING: Marked segments shorter than %g samples will unmarked.\n\n', shortsegsam);
end
nwin     = size(WinRej,1);
indxgood = [];
k=1;
for j=1:nwin
        widthw = WinRej(j,2) - WinRej(j,1);
        if widthw>shortsegsam
                indxgood(k) = j;
                k=k+1;
        end
end
WinRej2 = WinRej(indxgood,:);
if ~isempty(chanrej)
        ChanRej2= chanrej(indxgood,:);
end