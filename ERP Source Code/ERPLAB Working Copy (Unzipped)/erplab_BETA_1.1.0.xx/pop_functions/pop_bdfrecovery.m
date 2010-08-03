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

function erpcom = pop_bdfrecovery(ERPLAB)

erpcom='';

if nargin<1
      help pop_bdfrecovery
      return
end

if isempty(ERPLAB)
      msgboxText =  'pop_bdfrecovery() cannot read an empty dataset!';
      title = 'ERPLAB: pop_bdfrecovery error';
      errorfound(msgboxText, title);
      return
end

if iserpstruct(ERPLAB)
      strstruct = 'ERP';
else
      strstruct = 'EEG';
end

if isfield(ERPLAB, 'EVENTLIST')
      if isfield(ERPLAB.EVENTLIST, 'bdf')
            if isempty(ERPLAB.EVENTLIST.bdf)
                  msgboxText =  [strstruct '.EVENTLIST.bdf structure is empty!'];
                  title = 'ERPLAB: pop_bdfrecovery() error';
                  errorfound(msgboxText, title);
                  return
            end
            
            if isempty([ERPLAB.EVENTLIST.bdf.expression])
                  msgboxText =  [strstruct '.EVENTLIST.bdf structure is empty!'];
                  title = 'ERPLAB: pop_bdfrecovery() error';
                  errorfound(msgboxText, title);
                  return
            end
            
      else
            msgboxText = [strstruct '.EVENTLIST.bdf structure was not found!'];
            title = 'ERPLAB: pop_bdfrecovery() error';
            errorfound(msgboxText, title);
            return
      end
else
      msgboxText = [strstruct '.EVENTLIST structure was not found!'];
      title = 'ERPLAB: pop_bdfrecovery() error';
      errorfound(msgboxText, title);
      return
end

%
% Save ascii file
%
bdfnamefull = ERPLAB.EVENTLIST.bdfname;
[pathbdf, bdfname, extbdf, verx] = fileparts(bdfnamefull);

[filenamei, pathname, findex] = uiputfile({'*.txt';'*.*'},...
      'Save bin descriptor file as', [bdfname '.txt']);

if isequal(filenamei,0)
      disp('User selected Cancel')
      return
else
      [pathx, filename, ext, verx] = fileparts(filenamei);
      
      if ~strcmpi(ext,'.txt') && ~isempty(ext)
            ext = '.txt';
      end
      
      filename = [filename ext];
      fname    = fullfile(pathname, filename);
end

nbin = ERPLAB.EVENTLIST.nbin;
fid_rt  = fopen(fname, 'w');

for i=1:nbin
      fprintf(fid_rt, 'bin %g\n',i);
      fprintf(fid_rt, '%s\n', ERPLAB.EVENTLIST.bdf(i).description);
      fprintf(fid_rt, '%s\n', ERPLAB.EVENTLIST.bdf(i).expression);
      fprintf(fid_rt, '\n');
end

fclose(fid_rt);
disp(['A recovered bin descriptor file was saved at <a href="matlab: open(''' fname ''')">' fname '</a>'])
erpcom = sprintf('pop_bdfrecovery(%s);', inputname(1));
try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return