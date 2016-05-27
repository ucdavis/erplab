% PURPOSE: Tests artifact info synchronization between ERPLAB and EEGLAB
%
% FORMAT:
%
% sync_status = checksynchroar(EEG);
%
%
% INPUT:
%
% EEG           - bin-based epoched dataset
%
% OUTPUT:
%
% sync_status   - status for synchro. 1 means syncho; 0 means unsynchro
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon and Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

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


function sync_status = checksynchroar(EEG)

sync_status = 1; % status for synchro. 1 means syncho; 0 means unsynchro
if ~isempty(EEG.reject.rejmanual)
        if ~isfield(EEG, 'EVENTLIST')
                sync_status = 0;
        end
        if ~isfield(EEG.EVENTLIST.eventinfo, 'bepoch')
                sync_status = 0;
        end
        if length(EEG.reject.rejmanual) ~= max([EEG.EVENTLIST.eventinfo.bepoch]) && sync_status
                sync_status = 2; % deleted epochs detected
                return
        end
end

fprintf('\n---------------------------------------------------------\n');
fprintf('Testing artifact info synchronization I: EEG.reject.rejmanual vs EEG.epoch.eventflag...\n');
fprintf('---------------------------------------------------------\n\n');

nepoch = EEG.trials;
for i=1:nepoch
      cflag = EEG.epoch(i).eventflag; % flag(s) from event(s) within this epoch
      if iscell(cflag)
            %cflag = cell2mat(cflag);
            cflag = uint16([cflag{:}]); % giving some problems with uint16 type of flags
      end
      laten = EEG.epoch(i).eventlatency;% latency(ies) from event(s) within this epoch
      if iscell(laten)
            laten = cell2mat(laten);
      end
      
      indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
      flag  = cflag(indxtimelock);
      
      if ~isempty(EEG.reject.rejmanual)
            if flag>0 && flag<=255  && EEG.reject.rejmanual(i)==0; %
                  sync_status = 0;
                  iflag = find(bitget(flag,1:8));
                  fprintf('Epoch # %g is not marked as artifactual but flag(s) # %s is(are) set.\n', i, num2str(iflag));
            elseif flag==0 && EEG.reject.rejmanual(i)==1
                  sync_status = 0;
                  fprintf('Epoch # %g is marked as artifactual but no flag is set.\n', i);
            end
      else
            if flag>0 && flag<=255 %
                  sync_status = 0;
                  iflag = find(bitget(flag,1:8));
                  fprintf('Epoch # %g is not marked as artifactual but flag(s) # %s is(are) set.\n', i, num2str(iflag));
            end
      end
end
if sync_status
      disp('Ok!')
else
        fprintf('\nFail!\n\n');
end

fprintf('\n---------------------------------------------------------\n');
fprintf('Testing artifact info synchronization II: EEG.reject.rejmanual vs EEG.EVENTLIST.eventinfo.flag...\n');
fprintf('---------------------------------------------------------\n\n');

sync_status = 1;
if ~isfield(EEG, 'EVENTLIST')
        sync_status = 0;
end
if ~isfield(EEG.EVENTLIST.eventinfo, 'bepoch')
        sync_status = 0;
end
if sync_status
        nitem = length(EEG.EVENTLIST.eventinfo);
        for i=1:nitem
                flag   = EEG.EVENTLIST.eventinfo(i).flag;
                bepoch = EEG.EVENTLIST.eventinfo(i).bepoch;
                if bepoch>0
                        if ~isempty(EEG.reject.rejmanual)
                                if flag>0 && flag<=255 && EEG.reject.rejmanual(bepoch) == 0;
                                        sync_status = 0;
                                        iflag = find(bitget(flag,1:8));
                                        fprintf('Epoch # %g is not marked as artifactual but flag(s) # %s is(are) set.\n', i, num2str(iflag));
                                elseif flag==0 && EEG.reject.rejmanual(bepoch)==1
                                        sync_status = 0;
                                        fprintf('Item # %g is not marked as artifactual but its corresponding epoch # %g.\n', i, bepoch);
                                end
                        else
                                if flag>0 && flag<=255
                                        sync_status = 0;
                                        iflag = find(bitget(flag,1:8));
                                        fprintf('Epoch # %g is not marked as artifactual but flag(s) # %s is(are) set.\n', i, num2str(iflag));
                                end
                        end
                end
        end
end
if sync_status
        disp('Ok!')
else
        fprintf('\nFail!\n\n');
end
return