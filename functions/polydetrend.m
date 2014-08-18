% PURPOSE: subroutine for pop_polydetrend()
%
%
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

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

function EEG = polydetrend(EEG, winpnts, stepnts, chanArray, pmethod)

if nargin < 1
        help polydetrend
        return
end
if nargin < 2
        error('ERPLAB says: polydetrend requieres 2 inputs at least.')
end
if isempty(EEG.data)
        error('ERPLAB says: polydetrend cannot detrend an empty dataset')
end
if ~isempty(EEG.epoch)
        error('polydetrend only works on continuous data')
end
if nargin<5
        pmethod = 1; % spline
end
if nargin<4
        chanArray = 1:EEG.nbchan;
end
if nargin<3
        stepnts = winpnts; % in points
end

numchan = length(chanArray);
points  = EEG.pnts;

% windows
win  = 1:stepnts:points-(winpnts-1);
nwin = length(win);
xf   = linspace(1,nwin,points);
ss   = zeros(numchan,nwin);
switch pmethod
        case 0
        case 1
                for ch = 1:numchan
                        for j=1:nwin
                                ss(ch,j)  = mean(EEG.data(chanArray(ch), win(j):win(j)+winpnts-1)); % ch x window
                        end
%                         EEG.data(chanArray(ch),:) = EEG.data(chanArray(ch),:) - spline(1:nwin, ss(ch,:),xf); % substracts the fitted data (using spline polynomial)
                        
                        EEG.data(chanArray(ch),:) = spline(1:nwin, ss(ch,:),xf); % delete later. only for testing purposes: low pass filter
                end
        case 2
                EEG.data(chanArray,:)  = EEG.data(chanArray,:) - sgolayfilt(EEG.times, EEG.data(chanArray,:)', 3, winpnts)';   % Apply 3rd-order filter
        otherwise
end


