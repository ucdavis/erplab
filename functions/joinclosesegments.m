% PURPOSE: subroutine for pop_continuousartdet.m
%          joins together marked segments that are closer than a specific time value.
%
% FORMAT
%
% [WinRej2 ChanRej2 ] = joinclosesegments(WinRej, chanrej, shortisisam);
%
% INPUTS:
%
% WinRej         - latency array. Each row is a pair of values (start end), so the array has 2 columns.
% chanrej        - marked channels array
% shortisisam    - inter window time. (marked windows closer than this value will be joined together)
%
%
% OUTPUT
%
% WinRej2        - latency array for the resulting marked windows
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

function [WinRej2, ChanRej2 ] = joinclosesegments(WinRej, chanrej, shortisisam)

WinRej2= []; ChanRej2 = [];
fprintf('\nWARNING: Marked segments that are closer than %g samples will be join together.\n\n', shortisisam);
if ~isempty(chanrej)
        chanrej = uint8(chanrej);
end
a = WinRej(1,1);
b = WinRej(1,2);
m = 1;
working = 0;
if ~isempty(chanrej)
        chrej2 = uint8(zeros(1,size(chanrej,2)));
end
nwin = size(WinRej,1);
for j=2:nwin
        isi = WinRej(j,1) - WinRej(j-1,2);
        if isi<shortisisam
                b = WinRej(j,2);
                if ~isempty(chanrej)
                        chrej2 = bitor(chrej2, bitor(chanrej(j,:),chanrej(j-1,:)));
                end
                working = 1;
                if j==nwin
                        WinRej2(m,:)  = [a b];
                        if ~isempty(chanrej)
                                ChanRej2(m,:) = chrej2;
                        end
                end
        else
                if working==1
                        WinRej2(m,:)  = [a b];
                        if ~isempty(chanrej)
                                ChanRej2(m,:) = chrej2;
                        end
                        %                     a = WinRej(j,1);
                        working = 0;
                else
                        WinRej2(m,:)  = [a b];
                        if ~isempty(chanrej)
                                ChanRej2(m,:) = chanrej(j-1);
                        end
                        %                     a = WinRej(j,1);
                        %                     b = WinRej(j,2);
                end
                a = WinRej(j,1);
                b = WinRej(j,2);
                chrej2 = uint8(zeros(1,size(chanrej,2)));
                m = m + 1;
        end
end
if ~isempty(chanrej)
        ChanRej2  = double(ChanRej2);
end

WinRej2(end+1,:) = WinRej(end,:); % Save/append the last rejection window