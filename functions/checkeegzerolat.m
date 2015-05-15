% PURPOSE: Tests whether an actual 0 (zero) latency value is part of EEG.times or not.
%         
% FORMAT:
%
% EEG = checkeegzerolat(EEG)
%
% INPUT:
%
% EEG        - epoched dataset
%
%
% OUTPUT:
%
% EEG        - epoched dataset
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

function EEG = checkeegzerolat(EEG)
if ~iseegstruct(EEG)
      fprintf('\nWARNING: checkeegzerolat() only works with EEG structure. This call was ignored.\n')
      return
end
if isempty(EEG.epoch)
      fprintf('\nWARNING: checkeegzerolat() only works for epoched datasets. This call was ignored.\n')
      return
end
nepoch = EEG.trials;
for i=1:nepoch
      latcell = EEG.epoch(i).eventlatency;
      if iscell(latcell)
            latcell  =  cell2mat(latcell);
            [v, indx] = min(abs(latcell));
            EEG.epoch(i).eventlatency = num2cell(latcell - latcell(indx));
      else
            [v, indx] = min(abs(latcell));
            EEG.epoch(i).eventlatency = latcell - latcell(indx);
      end
end
auxtimes  = EEG.times;
[v, indx] = min(abs(auxtimes));
EEG.times = auxtimes - auxtimes(indx);
EEG.xmin  = min(EEG.times)/1000;
EEG.xmax  = max(EEG.times)/1000;
EEG.srate = round(EEG.srate);
EEG       = eeg_checkset( EEG );

if EEG.times(1)~=auxtimes(1)
      msg = ['\nWarning: zero time-locked stimulus latency values were not found.\n'...
      'Therefore, ERPLAB adjusted latency values at EEG.epoch.eventlatency, EEG.times, EEG.xmin,and EEG.xmax.\n\n'];
      fprintf(msg);
      fprintf('Time range is now [%.3f  %.3f] sec.\n', EEG.xmin, EEG.xmax )
else
      fprintf('Zero latencies OK.\n')
end