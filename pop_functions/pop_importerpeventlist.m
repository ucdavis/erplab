%   >> ERP = pop_importerpeventlist(ERP, elfullname, reventlist)
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

function [ERP erpcom] = pop_importerpeventlist(ERP, elfullname, reventlist, indexel)

erpcom = '';

if nargin < 1
      help pop_importerpeventlist
      return
end
if isempty(ERP)
      msgboxText =  'pop_importerpeventlist() cannot work with an empty erpset!';
      title = 'ERPLAB: pop_importerpeventlist() error';
      errorfound(msgboxText, title);
      return
end
if isempty(ERP.bindata)
      msgboxText =  'pop_importerpeventlist() cannot work with an empty erpset!';
      title = 'ERPLAB: pop_importerpeventlist() error';
      errorfound(msgboxText, title);
      return
end

nvar=4;
if nargin<nvar
      
      answer = eventlist2erpGUI(ERP);
      
      if isempty(answer)
            disp('User selected Cancel')
            return
      end
      
      elfullname = answer{1};
      reventlist = answer{2};
      indexel    = answer{3};
else
      % under construction
end

[ERP EVENTLIST serror] = importerpeventlist(ERP, elfullname);

if serror==1
      return
end

[pathstr, filename, ext, versn] = fileparts(elfullname); %#ok<NASGU>

if reventlist==0 % make #1
      ERP = pasteeventlist(ERP, EVENTLIST, 1); % joints both structs
elseif reventlist==1 % replace
      ERP = pasteeventlist(ERP, EVENTLIST, 1, indexel); % joints both structs
elseif reventlist==2  % append
      nelnext = length(ERP.EVENTLIST)+1;
      ERP = pasteeventlist(ERP, EVENTLIST, 1, nelnext); % joints both structs
else
      filenamex = regexprep(filename, ' ', '_');
      assignin('base',filenamex,EVENTLIST);
      disp(['EVENTLIST was added to WORKSPACE as ' filenamex] )
      return
end

ERP.erpname = [ERP.erpname '_impel']; %suggest a new name (Imported Event List)
ERP.saved   = 'no';
disp('EVENTLIST was added to the current ERP structure')

[ERP issave]= pop_savemyerp(ERP, 'gui', 'erplab');

if issave
      erpcom = sprintf( '%s = pop_importerpeventlist( %s, ''%s'', %s );', inputname(1), inputname(1),...
            elfullname, num2str(reventlist));
      try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      return
else
      disp('Warning: Your ERP structure has not yet been saved')
      disp('user cancelled')
      return
end