% Usage
%
%>> pop_erp2asc(ERP, filename)
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

function [erpcom] = pop_erp2asc(ERP, filename)

erpcom = '';

if nargin < 1
      help pop_erp2asc
      return
end

if isempty(ERP)
      msgboxText{1} =  'cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_erp2asc() error:';
      errorfound(msgboxText, title);
      return
end

if ~isfield(ERP, 'bindata')
      msgboxText{1} =  'cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_erp2asc() error:';
      errorfound(msgboxText, title);
      return
end

if isempty(ERP.bindata)
      msgboxText{1} =  'cannot export an empty ERP dataset';
      title = 'ERPLAB: pop_erp2asc() error:';
      errorfound(msgboxText, title);
      return
end

if nargin<2
      
      %
      % Save ascii file
      %
      [filenamei, pathname] = uiputfile({'*.txt';'*.*'},'Save Exported Averaged file as');
      
      if isequal(filenamei,0)
            disp('User selected Cancel')
            return
      else
            [pathx, filename, ext, verx] = fileparts(filenamei);
            
            if ~strcmpi(ext,'.txt')
                  ext = '.txt';
            end
            
            filename = [filename ext];
            disp(['For text exporting ERP, user selected ', fullfile(pathname, filename)])
      end
      
else
      [pathname, filename, ext, versn] = fileparts(filename);
      
      if ~strcmpi(ext,'.txt')
            ext = '.txt';
      end
      
      filename = [filename ext];
end

erp2asc(ERP, filename, pathname);

erpcom = sprintf( 'pop_erp2asc( %s, ''%s'');',  inputname(1), fullfile(pathname, filename));

try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
return