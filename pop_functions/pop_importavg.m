% PURPOSE  :    Import ERP from Neuroscan average file (AVG-file)
%
% FORMAT   :    ERP = pop_importavg(filename, filepath);
%
% INPUTS   :    filename: (String) Name of the Neuroscan AVG-file to import
%               filepath: (String) Directory/Path of the input AVG-file
%
% OUTPUTS  :    ERP: ERPLAB ERP data structure containing imported AVG-file
%               data
%
%
% EXAMPLE  :    ERP = pop_importavg('neuroscan_file.avg', '.');
%
%
% See also pop_importerp.m loadavg2.m
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
        [ERP, erpcom]= pop_importavg(filename, filepath, 'Saveas','on','History', 'gui');
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

if strcmpi(p.Results.Saveas, 'on');
        issaveas = 1;
else
        issaveas = 0;
end
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
ERPaux = ERP;

ERP = pop_importerp('Filename', filename, 'Filepath', filepath, 'Filetype', filetype, 'Timeunit', timeunit,...
      'Pointat', orienpoint, 'Srate', fs, 'Xlim', xlim, 'History', 'off');
pause(0.1);

% ERP.saved  = 'no';

%
% History
%
skipfields = {'Saveas','History','filename','filepath'};
fn         = fieldnames(p.Results);
erpcom     = sprintf( ' ERP = pop_importavg(''%s'', ''%s''', filename{1}, filepath{1});

for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        if ischar([fn2res{:}])
                                                fn2resstr = sprintf('''%s'' ', fn2res{:});
                                        else
                                                fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        end
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                if strcmpi(fn2com,'Criterion')
                                        if p.Results.Criterion<100
                                                erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                        end
                                else
                                        erpcom = sprintf( ['%s, ''%s'', ' fnformat], erpcom, fn2com, fn2resstr);
                                end
                        end
                end
        end
end
erpcom = sprintf( '%s );', erpcom);
erpcom = strrep(erpcom, '(,','(');
if issaveas      
      [ERP, issave, erpcom_save] = pop_savemyerp(ERP,'gui','erplab', 'History', 'implicit');      
      if issave>0
            % generate text command
            if issave==2
                  erpcom = sprintf('%s\n%s', erpcom, erpcom_save);
                  msgwrng = '*** Your ERPset was saved on your hard drive.***';
            else
                    msgwrng = '*** Warning: Your ERPset was only saved on the workspace.***';
            end
            fprintf('\n%s\n\n', msgwrng)
            try cprintf([0 0 1], 'COMPLETE\n\n');catch,fprintf('COMPLETE\n\n');end ;
      else
              ERP     = ERPaux;
              msgwrng = 'ERPLAB Warning: Your changes were not saved';
              try cprintf([1 0.52 0.2], '%s\n\n', msgwrng);catch,fprintf('%s\n\n', msgwrng);end ;
      end
end
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


