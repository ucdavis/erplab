%
% Author: Javier Lopez-Calderon & Steven Luck
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

function [EEG com] = pop_overwritevent(EEG, mainfield)

com='';

if nargin<1
      help pop_overwritevent
      return
end

if nargin>3
      error('ERPLAB says: Too many inputs!!! (2 max)')
end

if ~isempty(EEG.epoch)
      msgboxText{1} =  'Permission denied:';
      msgboxText{2} =  'pop_overwritevent has been tested for continuous data only';
      title = 'ERPLAB: pop_overwritevent Permission';
      errorfound(msgboxText, title);
      return
end

if isempty(EEG.data)
      msgboxText{1} =  'pop_overwritevent() error: cannot work with an empty dataset!';
      title = 'ERPLAB: No data';
      errorfound(msgboxText, title);
      return
end

if ~isfield(EEG, 'EVENTLIST')
      msgboxText{1} =  '      EEG.EVENTLIST structure was not found!';
      msgboxText{2} =  'Use Create EVENTLIST before overwriting EEG.event';
      title = 'ERPLAB: pop_overwritevent Error';
      errorfound(msgboxText, title);
      return
end

if ~isfield(EEG.EVENTLIST, 'eventinfo')
      msgboxText{1} =  '      EEG.EVENTLIST.eventinfo structure was not found!';
      msgboxText{2} =  'Use Create EVENTLIST before overwriting EEG.event';
      title = 'ERPLAB: pop_overwritevent Error';
      errorfound(msgboxText, title);
      return
else
      if isempty(EEG.EVENTLIST.eventinfo)
            msgboxText{1} =  '      EEG.EVENTLIST.eventinfo structure is empty!';
            msgboxText{2} =  'Use Create EVENTLIST before overwriting EEG.event';
            title = 'ERPLAB: pop_overwritevent Error';
            errorfound(msgboxText, title);
            return
      else
            disp('EEG.EVENTLIST.eventinfo is correct.')
      end
end

if nargin<2
      mainfield = overwriteventGUI;
      if isempty(mainfield)
            disp('User selected Cancel')
            return
      end
else
      if ~ismember({mainfield}, {'code','codelabel','binlabel'})
            error(['Field "' mainfield '" is not an EEG.EVENTLIST.eventinfo''s structure field'])
      end
end

iserrorf   = 0;
testfield1 = unique([EEG.EVENTLIST.eventinfo.(mainfield)]);

if isempty(testfield1)
      iserrorf = 1;
end

if isnumeric(testfield1)
      testfield1 = num2str(testfield1);
end

if strcmp(testfield1,'"')
      iserrorf = 1;
end

if iserrorf
      msgboxText{1} =  ['      Sorry, EEG.EVENTLIST.eventinfo.'  mainfield ' field is empty!'];
      msgboxText{2} =  'You should assign values to this field before overwriting EEG.event';
      title = 'ERPLAB: pop_overwritevent Error';
      errorfound(msgboxText, title);
      EEG = pop_overwritevent(EEG);
      return
else
      disp(['EEG.EVENTLIST.eventinfo.'  mainfield ' will replace your EEG.event.type structure.'])
end

%
% Replace fields  (needs more thought...)
%
EEG = update_EEG_event_field(EEG, mainfield);

com = sprintf( '%s = pop_overwritevent( %s, ''%s'');', inputname(1), inputname(1), mainfield);

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return
