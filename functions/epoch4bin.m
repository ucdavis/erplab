% PURPOSE: Identifies epoch indices, within an epoched dataset, corresponding to the specified bin(s).
%
% FORMAT
% 
% eindex = epoch4bin(EEG, binArray);
% 
% INPUT
% 
% EEG        - input (epoched) EEG dataset 
% binArray   - bin index(ices) to identify its corresponding epoch indices.
% 
% 
% OUTPUT
% 
% eindex     - epoch indices belonging to the bin(s) specified in binArray
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
%
% Fixed bug. JLC Aug 18, 2012

function eindex = epoch4bin(EEG, binArray)

eindex = [];

if isempty(EEG.epoch)
      msgboxText =  'epoch4bin() only works with epoched data.';
      title = 'ERPLAB: epoch4bin error';
      errorfound(msgboxText, title);
      return
end
if isfield(EEG, 'EVENTLIST')
      if isfield(EEG.EVENTLIST, 'eventinfo')
            if isempty(EEG.EVENTLIST.eventinfo)
                  msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                        'Use Create EVENTLIST before BINLISTER'];
                  title = 'ERPLAB: Error at epoch4bin()';
                  errorfound(sprintf(msgboxText), title);
                  return
            end
      else
            msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                  'Use Create EVENTLIST before BINLISTER'];
            title = 'ERPLAB: Error at epoch4bin()';
            errorfound(sprintf(msgboxText), title);
            return
      end
else
      msgboxText =  ['EVENTLIST structure was not found!\n'...
            'Use Create EVENTLIST before BINLISTER'];
      title = 'ERPLAB: Error at epoch4bin()';
      errorfound(sprintf(msgboxText), title);
      return
end

nbinori = EEG.EVENTLIST.nbin; 

if min(binArray)<1
      msgboxText =  'bin indexing must be a positive integer.';
      title = 'ERPLAB: Error at epoch4bin()';
      errorfound(sprintf(msgboxText), title);
      return
end
if max(binArray)>nbinori
      msgboxText =  'You have specified an unexisting bin index.';
      title = 'ERPLAB: Error at epoch4bin()';
      errorfound(sprintf(msgboxText), title);
      return
end

nepoch = EEG.trials;
k=1;
indx    = zeros(1,nepoch);

for i=1:nepoch
      bini  = EEG.epoch(i).eventbini; % bin indices at this epoch
      laten = EEG.epoch(i).eventlatency; % latencies at this epoch
      
      if iscell(laten)
            laten = cell2mat(laten);
      end
      
      indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
      bin = bini(indxtimelock); % bin of the home item event code (time-locked event)
      
      if iscell(bin)
            bin = cell2mat(bin); %bug. It said "bini"
      end     
      if nnz(ismember_bc2(bin, binArray)) > 0
            indx(k) = i;
            k=k+1;
      end
end


% for i=1:nepoch
%
%       bini  = EEG.epoch(i).eventbini; % bin indices at this epoch
%       laten = EEG.epoch(i).eventlatency; % latencies at this epoch
%
%       if iscell(laten)
%             laten = cell2mat(laten);
%       end
%       if iscell(bini)
%             bini = cell2mat(bini);
%       end
%
%       indxtimelock = find(laten == 0,1,'first'); % catch zero-time locked code position,
%       bin = bini(indxtimelock); % bin of the home item event code (time-locked event)
%
%       if nnz(ismember_bc2(bin, binArray))>0 %ismember_bc2(bin, binArray)
%             indx(k) = i;
%             k=k+1;
%       end
% end
eindex = nonzeros(indx)';
% disp('COMPLETE')