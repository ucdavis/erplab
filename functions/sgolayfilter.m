% sgolayfilter performs a (cubic) polynomial filtering over your EEG data, either continuous or epoched.
%
% Beta version.
%
% Usage
%
% EEG = sgolayfilter( EEG, chanArray, winsec )
%
% Example
%
% Filter channels 39 and 40. Use a 5 second frame.
%
% >> EEG = sgolayfilter( EEG, [39 40], 5 );
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

function EEG = sgolayfilter( EEG, chanArray, winsec )

if nargin < 1
        help sgolaydetrend
        return
end
if isempty(EEG.data)
        disp('sgolaydetrend error: cannot detrend an empty dataset')
        return
end

np       = round(winsec*EEG.srate + 1);
fprintf('Time window = %g sec    =>    %g points\n', winsec, np);

if ~mod(np,2) % is even?
        np =np +1;
        fprintf('Number of points was modified to %g points in order to be an odd number\n', np);
end
if nargin < 3
        disp('sgolayfilter error: please, enter all arguments!')
        return
end
if np<3
        error('ERPLAB ERROR: sgolayfilter -> too narrow time window!');
end

numchan = length(chanArray);
ntrials = EEG.trials;

disp('sgolaying...')

for i = 1:numchan
        fprintf('.')
        for j=1:ntrials
                EEG.data(chanArray(i),:,j) = sgolayfilt(EEG.data(chanArray(i),:,j)',3,np)';
        end
end
