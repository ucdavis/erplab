% PURPOSE: converts a cell string into an actual string (including {}).
%          Used to create command history.
%
% FORMAT:
%
% st = cellstr2str(cst)
%
% INPUT:
%
% cst        - cell string
%
%
% OUTPUT:
%
% st        - string (char)
%
%
% EXAMPLE: 
%
% st = cellstr2str({'arica' 'valparaiso' 'santiago' 'osorno2004'})
% 
% st =
% 
% { 'arica'  'valparaiso'  'santiago'  'osorno2004' }
%
%
% See also 
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

function st = cellstr2str(cst)
if ~iscellstr(cst)
   error('Input must be a celltring')     
end
n = length(cst);
st = '{';
for i=1:n
        st = sprintf('%s ''%s'' ', st, cst{i});
end
st = sprintf('%s}', st);