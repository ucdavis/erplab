% PURPOSE: asks you whether you would like to change the current directory for the one you load (an) ERPset(s).
%
% FORMAT:
%
% changecd(pathname)
%
% INPUT:
%
% pathname        - ERPset's pathname
%
%
% See also cd.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon & Stanley Huang
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

function changecd(pathname)
cdir = lower(strtrim(regexprep(cd,'/|\','')));
ndir = lower(strtrim(regexprep(pathname,'/|\','')));
if ~strcmp(cdir, ndir)
        question = ['Would you like to change your current directory to:\n\n'...
                    pathname];
        tittle      = 'ERPLAB: Change Current Directory';
        button      = askquest(sprintf(question), tittle);

        if strcmpi(button,'Yes')
                cdaux = cd;
                cd(pathname)
                fprintf('\nNOTE: Current directory was change from %s  to  %s\n\n', cdaux, pathname);
        end
end