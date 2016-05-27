% PURPOSE: sets backup ERPLAB folder
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2012

%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%
% ERPLAB Toolbox
% Copyright � 2007 The Regents of the University of California
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

function setbackuploc

cvname = sprintf('erplab_%s', geterplabversion); % current version name
p = which('eegplugin_erplab', '-all');
if length(p)>1
    fprintf('\nERPLAB WARNING: More than one %s folder was found.\n\n', cvname);
end
p = p{1};
[erplabpath]  = fileparts(p); % erplab's path
[pluginspath] = fileparts(erplabpath); % plugins' path

bckupdir = erpworkingmemory('setbackuploc');
if isempty(bckupdir)
    bckupdir = uigetdir(pluginspath);
else
    bckupdir = uigetdir(bckupdir);
end
if isequal(bckupdir,0)
    disp('User selected Cancel')
    return
end
erpworkingmemory('setbackuploc', bckupdir);
fprintf('%s was set as your backup location\n\n', bckupdir);
