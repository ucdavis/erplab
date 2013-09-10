% delshortseg.m (alpha version)
%
% Deletes segment of data between 2 event codes (string or number) if the size of the segment
% is lesser than a specified time (in msec)
% 
% USAGE
%
% EEG = delshortseg(EEG, code, mindistance);
%
% Input:
%
% EEG         - continuous EEG dataset (EEGLAB's EEG structure)
% code        - event code. You may use string or numeric event codes depending on the format of EEG.event.type
% mindistance - time threshold, in msec, for short segment(s) to be deleted.
%
% Output:
%
% EEG         - continuous EEG dataset  (EEGLAB's EEG structure)
% 
%
% Example
%  Delete segment of data between 2 'boundary' event codes when it is shorter than 3000 ms (3 secs).
% 
% EEG = delshortseg(EEG, 'boundary', 3000);
% 
%  
% *** This function is part of ERPLAB Toolbox ***
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

function EEG = delshortseg(EEG, code, mindistance)

if nargin<1
        help delshortseg
        return
end
if nargin<3
        error('ERPLAB says: delshortseg.m needs 3 inputs.')
end
disp('Working...')
if length(EEG.event)<1
      fprintf('\ndelshortseg.m did not found remaining event codes.\n')
      return
end
mindistancesamp = round(mindistance*EEG.srate/1000);  %ms to samples
if ischar(EEG.event(1).type) && ischar(code)
        latx  = strmatch(code, {EEG.event.type}, 'exact');
elseif ~ischar(EEG.event(1).type) && isnumeric(code)
        latx = find([EEG.event.type]==code);
else
        error('ERPLAB says: Your specified code must have the same format as your event codes (string or numeric).')
end

sampx = round([EEG.event(latx).latency]); % samples

if sampx(end)~=EEG.pnts
        sampx(end+1) = EEG.pnts; % add the last sample
end
a=1;
windx = [];
k=1;
% look for short segments
for i=1:length(sampx)
        if abs(sampx(i)-a)<=mindistancesamp
                t1 = a;
                t2 = sampx(i);
                windx(k,:) = [t1 t2];
                k=k+1;
        end
        a = sampx(i);
end

if k==1
        fprintf('\nNote: No short segment was found.\n')
else
        EEG = eeg_eegrej( EEG, windx);        
end
% get rid of the first boundary when is on the first sample.
if ischar(EEG.event(1).type)
        if strcmpi(code, EEG.event(1).type) && EEG.event(1).latency<=1 % in sample
                EEG = pop_editeventvals(EEG,'delete',1);
        end
else
        if code==EEG.event(1).type && EEG.event(1).latency<=1 % in sample
                EEG = pop_editeventvals(EEG,'delete',1);
        end
end









