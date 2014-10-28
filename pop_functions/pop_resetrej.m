% PURPOSE  : 	Clear Artifact Detection marks on EEG
%
% FORMAT   :
%
% EEG = pop_resetrej(EEG, arjm, bflag)
%
%
% INPUTS   :
%
% Arjm          - 1- Reset EEGLAB Artifact Detection Mark
%                 0- Do not reset EEGLAB Artifact Detection
% Bflag         - numbers correspond to which User flags and Artifact flags are
%                 marked
%
% OUTPUTS  :
%
% Outputted dataset with artifact detection marks cleared
%
%
% EXAMPLE  :
%
% EEG = pop_resetrej(EEG, 1, 10312);
%
%
% See also resetrejGUI.m
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

function [EEG, com]= pop_resetrej(EEG, varargin)
com ='';
if nargin<1
        help pop_resetrej
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1        
        serror = erplab_eegscanner(EEG, 'pop_resetrej', 2, 0, 1, 2, 2);
        if serror
                return
        end
        
        %
        % Call GUI
        %
        inputoption = resetrejGUI; % open GUI
        
        if isempty(inputoption)
                disp('User selected Cancel')
                return
        end
        arjm  = inputoption{1};
        bflag = inputoption{2};
        
        if arjm==1
                arjmstr = 'on';
        else
                arjmstr = 'off';
        end
        
        [arflag usflag] = dec2flag(bflag);
        if length(EEG)==1
                EEG.setname = [EEG.setname '_resetrej']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_resetrej(EEG, 'ResetArtifactFields', arjmstr, 'ArtifactFlag', arflag, 'UserFlag', usflag, 'History', 'gui');
        return
end

p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('ResetArtifactFields', 'on', @ischar);
p.addParamValue('ArtifactFlag', [], @isnumeric);
p.addParamValue('UserFlag', [], @isnumeric);
p.addParamValue('History', 'script', @ischar);             % history from scripting
p.parse(EEG, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if strcmpi(p.Results.ResetArtifactFields,'on')
        arjm = 1;
else
        arjm = 0;
end

arflag = p.Results.ArtifactFlag;
usflag = p.Results.UserFlag;
bflag = flag2dec('ArtifactFlag', arflag, 'UserFlag', usflag);

%
% process multiple datasets. Updated August 23, 2013 JLC
%
if length(EEG) > 1
        options1 = {'ResetArtifactFields', p.Results.ResetArtifactFields, 'ArtifactFlag', p.Results.ArtifactFlag,...
                    'UserFlag', p.Results.UserFlag, 'History', 'gui'};
        [ EEG, com ] = eeg_eval( 'pop_resetrej', EEG, 'warning', 'on', 'params', options1);
        return;
end
if arjm
        
        %
        % resets EEGLAB's artifact rejection fields used by ERPLAB
        %
        F = fieldnames(EEG.reject);
        sfields1 = regexpi(F, '\w*E$', 'match');
        sfields2 = [sfields1{:}];
        sfields3  = regexprep(sfields2,'E','');
        arfields = [sfields2 sfields3];
        
        for j=1:length(arfields)
                EEG.reject.(arfields{j}) = [];
        end
end
if bflag>0
        % reset flag
        EEG = resetflag(EEG, bflag);
end

skipfields = {'EEG', 'History','History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_resetrej( %s ', inputname(1), inputname(1));
for q=1:length(fn)
        fn2com = fn{q};
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com);
                if ~isempty(fn2res)
                        if ischar(fn2res)
                                if ~strcmpi(fn2res,'off')
                                        com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                end
                        else
                                if iscell(fn2res)
                                        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        fnformat = '{%s}';
                                else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                end
                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                        end
                end
        end
end
com = sprintf( '%s );', com);

% get history from script. EEG
switch shist
        case 1 % from GUI
                com = sprintf('%s %% GUI: %s', com, datestr(now));
                %fprintf('%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
        otherwise %off or none
                com = '';
                return
end

%
% Completion statement
%
msg2end
return


% com = sprintf('%s = pop_resetrej(%s, %s, %s);', inputname(1), inputname(1), num2str(arjm), num2str(bflag));
% % get history from script
% if shist
%         EEG = erphistory(EEG, [], com, 1);
% else
%         com = sprintf('%s %% %s', com, datestr(now));
% end
%
% %
% % Completion statement
% %
% msg2end
% return