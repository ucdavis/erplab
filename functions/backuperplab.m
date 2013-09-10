% PURPOSE: Zips and Backups current ERPLAB folder
%
% Usage:
%
% backuperplab(bckupdir)
%
% Input:
%
% bckupdir   = backup folder (including whole path)
%
%
% See also zip.m
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

function backuperplab(bckupdir)
cvname = sprintf('erplab_%s', geterplabversion); % current version name
p = which('eegplugin_erplab', '-all');
if length(p)>1
    fprintf('\nERPLAB WARNING: More than one %s folder was found.\n\n', cvname);
end
p = p{1};
[erplabpath]  = fileparts(p); % erplab's path
[pluginspath] = fileparts(erplabpath); % plugins' path

if nargin<1
        bckupdir = erpworkingmemory('setbackuploc');
        if isempty(bckupdir)
                bckupdir = pluginspath;
        end
end

datecode      = sprintf('%g%g%g%g%g%g', round(clock));
bckupname     = sprintf('%s_%s', cvname, datecode);

%
% Zip current erplab folder at plugins
%
try
    cleanerplab
    fname    = [bckupname '.zip'];
    fullname = fullfile(bckupdir, fname); % save the zip file at bckupdir
    zip(fullname, cvname, pluginspath);
    fprintf('Your current ERPLAB was backed up in %s\n', fullname);
catch
    msgboxText = 'Oops! Something went wrong.\nERPLAB could not back up your current version...';
    title = 'ERPLAB: backup error';
    errorfound(sprintf(msgboxText), title);
    return
end
