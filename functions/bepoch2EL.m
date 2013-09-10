% PURPOSE: Updates EVENTLIST (EEG.EVENTLIST.eventinfo(k).bepoch) with the information about epoch index.
%
% FORMAT:
%
% EEG = bepoch2EL(EEG)
%
% Inputs:
%
%   EEG      - input dataset
%
% Output
% 
%   EEG      - output dataset
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2010

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

function EEG = bepoch2EL(EEG)

if isempty(EEG)
      msgboxText =  'bepoch2EL() error: cannot work with an empty dataset!';
      tittle = 'ERPLAB: No data';
      errorfound(msgboxText, tittle);
      return
end
if isempty(EEG.data)
      msgboxText =  'bepoch2EL() error: cannot work with an empty dataset!';
      tittle = 'ERPLAB: No data';
      errorfound(msgboxText, tittle);
      return
end
if isfield(EEG, 'EVENTLIST')
      if isfield(EEG.EVENTLIST, 'eventinfo')
            if isempty(EEG.EVENTLIST.eventinfo)
                  msgboxText =  ['EVENTLIST.eventinfo structure is empty!\n'...
                                'Use Create EVENTLIST before BINLISTER'];
                  tittle = 'ERPLAB: Error';
                  errorfound(sprintf(msgboxText), tittle);
                  return
            end
      else
            msgboxText = ['EVENTLIST.eventinfo structure was not found!\n'...
                          'Use Create EVENTLIST before BINLISTER'];
            tittle = 'ERPLAB: Error';
            errorfound(sprintf(msgboxText), tittle);
            return
      end
else
      msgboxText =  ['EVENTLIST structure was not found!\n'...
                    'Use Create EVENTLIST before BINLISTER'];
      tittle = 'ERPLAB: Error';
            errorfound(sprintf(msgboxText), tittle);
      return
end
if isfield(EEG, 'epoch')
      if isempty(EEG.epoch)
            msgboxText =  ['EEG.epoch structure is empty!'...
                           'Use must bin-epoch your data first.'];
            tittle = 'ERPLAB: Error';
            errorfound(sprintf(msgboxText), tittle);
            return
      end
else
        msgboxText = ['EEG.epoch structure was not found!'...
                'Something is going wrong. Please, check your EEG struct'];
        tittle = 'ERPLAB: Error';
        errorfound(sprintf(msgboxText), tittle);
        return
end

nbepoch = length(EEG.epoch);

for i=1:nbepoch
      if length(EEG.epoch(i).eventlatency) == 1
            
            bines = EEG.epoch(i).eventbini;
            eventitem = EEG.epoch(i).eventitem;
            
            if iscell(bines)
                  bines = cell2mat(bines);
            end
            if iscell(eventitem)
                  eventitem = cell2mat(eventitem);
            end
            if sum(bines)>0
                  EEG.EVENTLIST.eventinfo(eventitem).bepoch = i;
            else
                  EEG.EVENTLIST.eventinfo(eventitem).bepoch = 0; % no bepoch for this item
            end
            
      elseif length(EEG.epoch(i).eventlatency) > 1
            
            indxtimelock = find(cell2mat(EEG.epoch(i).eventlatency) == 0,1,'first'); % catch zero-time locked type,
            bines = EEG.epoch(i).eventbini{indxtimelock};
            eventitem = EEG.epoch(i).eventitem{indxtimelock};
            
            if iscell(eventitem)
                  eventitem = cell2mat(eventitem);
            end
            if sum(bines)>0
                  EEG.EVENTLIST.eventinfo(eventitem).bepoch = i;
            else
                  EEG.EVENTLIST.eventinfo(eventitem).bepoch = 0; % no bepoch for this item
            end
      end
end