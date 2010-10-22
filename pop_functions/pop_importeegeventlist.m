%   >> EEG = pop_importeegeventlist(EEG, elfullname, reventlist)
%
%  Note: very preliminary alfa version. Only for testing purpose. May  2008
%
%  HELP PENDING for this function
%  Write erplab at command window for help
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

function [EEG com] = pop_importeegeventlist(EEG, elfullname, reventlist)

com = '';

if nargin < 1
      help pop_importeegeventlist
      return
end
if nargin>3
      error('Error: pop_importeegeventlist() works with 3 input arguments')
end
if isempty(EEG)
      msgboxText =  'pop_importeegeventlist() error: cannot work with an empty dataset!';
      title = 'ERPLAB: pop_importeegeventlist() error';
      errorfound(msgboxText, title);
      return
end
if isempty(EEG.data)
      msgboxText =  'pop_importeegeventlist() cannot work with an empty dataset!';
      title = 'ERPLAB: pop_importeegeventlist() error';
      errorfound(msgboxText, title);
      return
end
if ~isempty(EEG.epoch)
      msgboxText{1} =  'pop_importeegeventlist() has been tested for continuous data only.';
      title = 'ERPLAB: pop_importeegeventlist Permission denied';
      errorfound(msgboxText, title);
      return
end

if nargin==1
      
      [filename,pathname] = uigetfile({'*.*';'*.txt'},'Select a EVENTLIST file');
      elfullname = fullfile(pathname, filename);
      
      if isequal(filename,0)
            disp('User selected Cancel')
            return
      else
            disp(['For read an EVENTLIST, user selected ', elfullname])
      end
      
      question{1} = 'Do you want to replace your EEG.EVENTLIST field with this file?';
      question{2} = ' (YES: replace)             (NO: sent EVENTLIST to workspace)';
      title   = 'ERPLAB: Confirmation';
      button   = askquest(question, title);
      
      if strcmpi(button,'yes')
            reventlist = 1;
      elseif strcmpi(button,'no')
            reventlist = 0;
      else
            disp('User selected Cancel')
            return
      end
else
      % ...under construction
end

[EEG EVENTLIST] = readeventlist(EEG, elfullname);
[pathstr, filename, ext, versn] = fileparts(elfullname);

if reventlist
      if ~isempty(EVENTLIST)
            EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
            EEG.setname = [EEG.setname '_impel']; %suggest a new name (Imported Event List)
            EEG = pop_overwritevent(EEG, 'code');
            EEG.EVENTLIST   = [];
            [EEG EVENTLIST] = creaeventlist(EEG, EVENTLIST, [filename '_new_' num2str((datenum(datestr(now))*1e10)) '.txt'], 1);
            EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
            
            disp('EVENTLIST was added to the current EEG structure')
      else
            error('ERPLAB says: error at pop_importeegeventlist(). EVENTLIST structure is empty.')
      end
      
      com = sprintf( '%s = pop_importeegeventlist( %s, ''%s'', %s );', inputname(1), inputname(1),...
            elfullname, num2str(reventlist));
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      return
else
      filenamex = regexprep(filename, ' ', '_');
      assignin('base',filenamex,EVENTLIST);
      disp(['EVENTLIST was added to WORKSPACE as ' filenamex] )
end
