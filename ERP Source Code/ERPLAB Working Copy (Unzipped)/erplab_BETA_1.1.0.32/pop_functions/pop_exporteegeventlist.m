%
% Usage
%
%>> EEG = pop_exporteegeventlist(EEG, elname)
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

function [EEG com] = pop_exporteegeventlist(EEG, elname)

com = '';

if nargin < 1
      help pop_exporteegeventlist
      return
end
if nargin >2
      error('ERPLAB says: error at pop_exporteegeventlist(). Too many inputs!');
end

if nargin<2
      
      if isempty(EEG)
            msgboxText =  'pop_exporteegeventlist() error: cannot work with an empty dataset!';
            title = 'ERPLAB: No data';
            errorfound(msgboxText, title);
            return
      end
      if isempty(EEG.data)
            msgboxText =  'pop_exporteegeventlist() error: cannot work with an empty dataset!';
            title = 'ERPLAB: No data';
            errorfound(msgboxText, title);
            return
      end
      if isfield(EEG, 'EVENTLIST')
            if isempty(EEG.EVENTLIST)
                  msgboxText{1} =  'pop_exporteegeventlist() error: EEG.EVENTLIST structure is empty.';
                  msgboxText{2} =  'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.';
                  title = 'ERPLAB: No EVENTLIST structure';
                  errorfound(msgboxText, title);
                  return
            end
            if isfield(EEG.EVENTLIST, 'eventinfo')
                  if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText{1} =  'pop_exporteegeventlist() error: EEG.EVENTLIST.eventinfo structure is empty.';
                        msgboxText{2} =  'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.';
                        title = 'ERPLAB: No EVENTLIST.eventinfo structure';
                        errorfound(msgboxText, title);
                        return
                  end
            else
                  msgboxText{1} =  'pop_exporteegeventlist() error: EEG.EVENTLIST.eventinfo structure was not found.';
                  msgboxText{2} =  'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.';
                  title = 'ERPLAB: No EVENTLIST.eventinfo structure';
                  errorfound(msgboxText, title);
                  return
            end
      else
            msgboxText{1} =  'pop_exporteegeventlist() error: EEG.EVENTLIST structure was not found.';
            msgboxText{2} =  'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.';
            title = 'ERPLAB: No EVENTLIST structure';
            errorfound(msgboxText, title);
            return
      end
      if ~isfield(EEG.EVENTLIST, 'bdf')
            msgboxText{1} =  'pop_exporteegeventlist() error: EEG.EVENTLIST.bdf structure was not found.';
            msgboxText{2} =  'Please, use ERPLAB --> EVENTLIST --> Create EEG EventList menu before exporting to text.';
            title = 'ERPLAB: No EVENTLIST.bdf structure';
            errorfound(msgboxText, title);
            return
      end
      
      %
      % Save OUTPUT file
      %
      [fname, pathname] = uiputfile({'*.txt';'*.*'},'Save EVENTLIST file as');
      
      if isequal(fname,0)
            disp('User selected Cancel')
            return
      else
            [xpath, fname, ext, versn] = fileparts(fname);
            
            if ~strcmp(ext,'.txt')
                  ext = '.txt';
            end
            
            fname  = [fname ext];
            elname = fullfile(pathname, fname);
            disp(['For EVENTLIST output user selected ', elname])
      end
      
else
      if isempty(EEG.data)
            error('ERPLAB says: error at pop_exporteegeventlist(). cannot work with an empty dataset!')
      end
      if isfield(EEG, 'EVENTLIST')
            if isempty(EEG.EVENTLIST)
                  error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST structure is empty.');
            end
            
            if isfield(EEG.EVENTLIST, 'eventinfo')
                  if isempty(EEG.EVENTLIST.eventinfo)
                        error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.eventinfo structure is empty.');
                  end
            else
                  error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.eventinfo structure was not found.');
            end
            
      else
            error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST structure was not found.');
      end
      
      if ~isfield(EEG.EVENTLIST, 'bdf')
            error('ERPLAB says: error at pop_exporteegeventlist(). EEG.EVENTLIST.bdf structure was not found.');
      end
end

EVENTLIST = EEG.EVENTLIST;

creaeventlist(EEG, EVENTLIST, elname, 1);

com = sprintf( '%s = pop_exporteegeventlist(%s, ''%s'');', inputname(1), inputname(1), elname);
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return;
