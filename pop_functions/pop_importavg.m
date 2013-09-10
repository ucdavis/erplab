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

function [ERP, erpcom]= pop_importavg(filename, filepath, varargin)
erpcom = '';
ERP = preloadERP;
if nargin < 1
        help pop_importavg
        return
end
if nargin==1
        %
        % Call GUI
        %
        [filename, filepath] = uigetfile({'*.avg';'Neuroscan average file (*.avg)'},'Select a file (Neuroscan)', 'MultiSelect', 'on');
        
        if ~iscell(filename) && ~ischar(filename) && filename==0
                disp('User selected Cancel')
                return
        end
        
        %
        % Somersault
        %
        [ERP, erpcom]= pop_importavg(filename, filepath, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('filename');
p.addRequired('filepath');
% option(s)
p.addParamValue('Saveas', 'off', @ischar); % 'on', 'off'
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(filename, filepath, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if ~iscell(filename)
      filename = cellstr(filename);
end 
if ~iscell(filepath)
      filepath = cellstr(filepath);
end

timeunit    = [];
fs          = [];
xlim        = [];
filetype    = {'neuroscan'};
orienpoint  = 'column'; % points at columns

ERP = pop_importerp('Filename', filename, 'Filepath', filepath, 'Filetype', filetype, 'Timeunit', timeunit,...
      'Pointat', orienpoint, 'Srate', fs, 'Xlim', xlim, 'Saveas', 'on', 'History', 'off');
pause(0.1);
erpcom = sprintf('ERP = pop_importavg( ''%s'', ''%s''', filename, filepath);
% get history from script. ERP
switch shist
        case 1 % from GUI
                displayEquiComERP(erpcom);
        case 2 % from script
                ERP = erphistory(ERP, [], erpcom, 1);
        case 3
                % implicit
                % ERP = erphistory(ERP, [], erpcom, 1);
                % fprintf('%%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                erpcom = '';
                return
end
%
% Completion statement
%
msg2end
return


