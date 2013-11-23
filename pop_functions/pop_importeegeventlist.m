% PURPOSE  :	Reads an event list from a text file and creates an EVENTLIST structure.
%                 The EVENTLIST structure is attached to the EEG structure.
%
% FORMAT   :
%
% EEG = pop_importeegeventlist(EEG, ELfullname, repEL)
%
% INPUTS   :
%
% EEG           - eeglab dataset
% ELfullname    - name of eventlist text file to be imported
% repEL    - replace the current EVENTLIST structure.
%                  1:yes
%                  0:send the EVENTLIST structure to workspace
%
% OUTPUTS
%
% EEG           - EVENTLIST structure added to current EEG structure or workspace
%
%
% EXAMPLE  :
%
% EEG = pop_importeegeventlist( EEG, '/Users/etfoo/Documents/MATLAB/test.txt', 1 );
%
%
% *** This function is part of ERPLAB Toolbox ***
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

function [EEG, com] = pop_importeegeventlist(EEG, ELfullname, varargin)
com = '';
if nargin < 1
        help pop_importeegeventlist
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG)
                msgboxText =  'pop_importeegeventlist() error: cannot work with an empty dataset!';
                title = 'ERPLAB: pop_importeegeventlist() error';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'pop_importeegeventlist() cannot work with an empty dataset!';
                title = 'ERPLAB: pop_importeegeventlist() error';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG.epoch)
                msgboxText =  'pop_importeegeventlist() has been tested for continuous data only.';
                title = 'ERPLAB: pop_importeegeventlist Permission denied';
                errorfound(msgboxText, title);
                return
        end
        [filename,pathname] = uigetfile({'*.*';'*.txt'},'Select a EVENTLIST file');
        ELfullname = fullfile(pathname, filename);
        
        if isequal(filename,0)
                disp('User selected Cancel')
                return
        else
                disp(['For read an EVENTLIST, user selected ', ELfullname])
        end
        
        question = ['Do you want to replace your EEG.EVENTLIST field with this file?\n\n'...
                ' (YES: replace)             (NO: sent EVENTLIST to workspace)'];
        title    = 'ERPLAB: Confirmation';
        button   = askquest(sprintf(question), title);
        
        if strcmpi(button,'yes')
                repEL = 'on';
        elseif strcmpi(button,'no')
                repEL = 'off';
        else
                disp('User selected Cancel')
                return
        end
        
        %
        % Somersault
        %
        EEG.setname = [EEG.setname '_impel']; %suggest a new name (Imported Event List)
        [EEG, com]  = pop_importeegeventlist(EEG, ELfullname, 'ReplaceEventList', repEL, 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('ELfullname', @ischar);
% option(s)
p.addParamValue('ReplaceEventList', 'off', @ischar);
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, ELfullname, varargin{:});

if length(EEG)>1
        msgboxText =  'Unfortunately, this function does not work with multiple datasets';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if isempty(EEG)
        msgboxText =  'pop_importeegeventlist() error: cannot work with an empty dataset!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if isempty(EEG.data)
        msgboxText =  'pop_importeegeventlist() cannot work with an empty dataset!';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end
if ~isempty(EEG.epoch)
        msgboxText =  'pop_importeegeventlist() has been tested for continuous data only.';
        error('prog:input', ['ERPLAB says: ' msgboxText]);
end

if strcmpi(p.Results.ReplaceEventList,'on')
        repEL = 1;
else
        repEL = 0;
end
if strcmpi(p.Results.Warning, 'on')
        rwwarn = 1;
else
        rwwarn = 0;
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

%
% subroutine
%
[EEG, EVENTLIST] = readeventlist(EEG, ELfullname);
[pathstr, filename, ext] = fileparts(ELfullname);

if repEL
        if ~isempty(EVENTLIST)
                EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
                EEG = pop_overwritevent(EEG, 'code');
                EEG.EVENTLIST    = [];
                [EEG, EVENTLIST] = creaeventlist(EEG, EVENTLIST, [filename '_new_' num2str((datenum(datestr(now))*1e10)) '.txt'], 1);
                EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
                
                disp('EVENTLIST was added to the current EEG structure')
        else
                EEG.EVENTLIST    = [];
                [EEG, EVENTLIST] = creaeventlist(EEG, EVENTLIST, [filename '_new_' num2str((datenum(datestr(now))*1e10)) '.txt'], 1);
                EEG = pasteeventlist(EEG, EVENTLIST, 1); % joints both structs
        end
        
        %
        % History
        %
        skipfields = {'EEG', 'ELfullname','History'};
        fn     = fieldnames(p.Results);
        
        com = sprintf('%s = pop_importeegeventlist( %s, ''%s'' ', inputname(1), inputname(1), ELfullname);
        
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
                                                        com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                                end
                                        else
                                                com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                        end
                                end
                        end
                end
        end
        com = sprintf( '%s );', com);
        
        %         com = sprintf( '%s = pop_importeegeventlist( %s, ''%s'', %s );', inputname(1), inputname(1),...
        %                 ELfullname, num2str(repEL));
        %         % get history from script
        %         if shist
        %                 EEG = erphistory(EEG, [], com, 1);
        %         else
        %                 com = sprintf('%s %% %s', com, datestr(now));
        %         end
else
        filenamex = regexprep(filename, ' ', '_');
        assignin('base',filenamex,EVENTLIST);
        disp(['EVENTLIST was added to WORKSPACE as ' filenamex] )
end

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
                %EEG = erphistory(EEG, [], com, 1);
                %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                com = '';
                return
end

%
% Completion statement
%
msg2end
return