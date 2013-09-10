% PURPOSE: subroutine for updatehistory.m
%          gets last command
%
% FORMAT:
%
% lastcom = getlastcommand;
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

function lastcom = getlastcommand

fid = fopen(fullfile(prefdir, 'history.m'), 'rt');
linein = cell(1);
i=1;

while ~feof(fid)
  linein{i} = fgetl(fid);
  if ~ischar(linein{i}) && i>5000
        break
  end
i=i+1;
end

lastcom = linein{end-1};
fclose(fid);
disp('Hola')