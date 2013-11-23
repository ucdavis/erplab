% PURPOSE  : Assign events to bins
%
% FORMAT   :
%
% EEG  = pop_binlister( EEG , parameters);
%
% INPUTS   :
%
% EEG           - input dataset
%
% The available parameters are as follows:
%
%     'BDF'         - name of the text file containing your bin descriptions (formulas).
%     'ImportEL'	  - (optional) name of the text file, to import, that contain the event information to process,
%                     according to ERPLAB format (see tutorial).
%
%     'ExportEL' 	  - (optional) name of the text file, to export, that will contain the upgraded event information,
%                     according to ERPLAB format (see tutorial).

%     'Resetflag'   - set (all) flags to zero before starting binlister process. 'on'=reset;  'off':keep as it is.
%
%     'Forbidden'	  - array of event codes (numeric). If any of these codes is among a set of codes successfully captured by a bin
%                     this "capture" will be disable.
%     'Ignore'      - array of event codes (numeric) to be ignored. Binlister will be blind to them.
%
%     'UpdateEEG'   - after binlister process you can move the upgraded event information to EEG.event field. 'on'=update, 'off'=keep as it is.
%     'Warning'     - 'on'- warn if EVENTLIST will be overwritten. 'off' - do not warn if EVENTLIST will be overwritten.
%     'SendEL2'     - once binlister ends its work, you can send a copy of the resulting EVENTLIST structure to:
%                    'Text'           - send to text file
%                    'EEG'            - send to EEG structure
%                    'EEG&Text'       - send to EEG & text file
%                    'Workspace'      - send to Matlab workspace,
%                    'Workspace&Text' - send to Workspace and text file,
%                    'Workspace&EEG'  - send to workspace and EEG,
%                    'All'- send to all of them.
%     'Report'      - 'on'= create report about binlister performance, 'off'= do not create a report.
%     'Saveas'      - (optional) open GUI for saving dataset. 'on'/'off'
%
%
%
% OUTPUTS  :
%
% EEG            - updated output dataset
%
% EXAMPLE  :
%
% EEG  = pop_binlister( EEG , 'BDF', '/Users/etfoo/Documents/MATLAB/Test_Data/binlister_demo_2.txt', 'ExportEL', ...
%                      '/Users/etfoo/Documents/MATLAB/Test_output.txt', 'Forbidden',  12, 'Ignore',  10, 'ImportEL',...
%                      '/Users/etfoo/Documents/MATLAB/Test.txt', 'Saveas','on', 'SendEL2', 'All', 'UpdateEEG', 'on', 'Warning', 'on');
%
%
% See also menuBinListGUI.m binlister.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon and Steven Luck
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

function [EEG, com] = pop_binlister(EEG, varargin)
global ALLEEG
global CURRENTSET
com = '';
if nargin < 1
        help pop_binlister
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if iseegstruct(EEG) && length(EEG)>1
                msgboxText = 'Unfortunately, binlister does not work with multiple datasets';
                title      = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if isfield(EEG.event, 'type')
                if ~all(cellfun(@isnumeric, { EEG.event.type }))
                        msgboxText = ['Some or all of your events contain only a text-based event label, '...
                                'and not a numeric event code.  ERPLAB must have a numeric code '...
                                'for every event (a text label can also be present).  For labels such as "S14", '...
                                'you can automatically create an equivalent numeric event code (e.g., 14) by '...
                                'checking the box labeled "Create numeric equivalents of nonnumeric event codes '...
                                'when possible" when creating the EventList.\n\nFor labels that cannot be automatically '...
                                'converted (e.g., "RESP"), or for ambiguous cases (e.g., when you have both "S14" and '...
                                '"R14"), you can flexibly create numeric versions using the Advanced button at EVENTLIST GUI.'];
                        title      = 'ERPLAB: Warning';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        end
        def  = erpworkingmemory('pop_binlister');
        if isempty(def)
                def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        try
                ERPX = evalin('base', 'ERP');
        catch
                ERPX = [];
        end
        
        %
        % Call a GUI
        %
        packarray = menuBinListGUI(EEG, ERPX, def);
        
        if isempty(packarray)
                disp('User selected Cancel')
                return
        end
        
        file1      = packarray{1};         % bin descriptor file
        file2      = packarray{2};         % external eventlist (read event list from)
        file3      = packarray{3};         % text file containing the updated EVENTLIST (Write resulting eventlist to)
        flagrst    = packarray{4};         % 1 means reset flags
        forbiddenCodeArray = packarray{5};
        ignoreCodeArray    = packarray{6};
        updevent   = packarray{7};
        option2do  = packarray{8};         % See  option2do below
        reportable = packarray{9};         % 1 means create a report about binlister work.
        iswarning  = packarray{10};        % 1 means create a report about binlister work.
        getfromerp = packarray{11};
        indexEL    = packarray{12};
        
        if isempty(file2) || strcmpi(file2,'no') || strcmpi(file2,'none')
                if getfromerp
                        if isempty(ERPX)
                                msgboxText =  'You do not have any loaded ERPset yet.';
                                title = 'ERPLAB: no data';
                                errorfound(msgboxText, title);
                                return
                        end
                        EEGaux = EEG;
                        EEG    = ERPX;
                end
                if isfield(EEG, 'EVENTLIST')
                        %if length(EEG.EVENTLIST)>1
                        %        prompt    = {'Enter  EVENLIST index:'};
                        %        dlg_title = 'Multiple EVENTLIST at EEG were detected';
                        %        num_lines = 1;
                        %        def       = {'1'};
                        %        answer    = inputvalue(prompt,dlg_title,num_lines,def);
                        %        if isempty(answer)
                        %                disp('User selected Cancel')
                        %                return
                        %        end
                        %        indexEL = str2num(answer{1});
                        %else
                        %        indexEL = 1;
                        %end
                        
                        if isfield(EEG.EVENTLIST, 'eventinfo')
                                if isempty(EEG.EVENTLIST(indexEL).eventinfo)
                                        msgboxText = ['EVENTLIST.eventinfo structure is empty!\n'...
                                                'Use Create EVENTLIST before BINLISTER'];
                                        title = 'ERPLAB: Error';
                                        errorfound(sprintf(msgboxText), title);
                                        return
                                end
                        else
                                msgboxText =  ['EVENTLIST.eventinfo structure was not found!\n'...
                                        'Use Create EVENTLIST before BINLISTER'];
                                title = 'ERPLAB: Error';
                                errorfound(sprintf(msgboxText), title);
                                return
                        end
                else
                        msgboxText =  ['EVENTLIST structure was not found!\n'...
                                'Use Create EVENTLIST before BINLISTER'];
                        title = 'ERPLAB: Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
                logfilename = 'no';
                logpathname = '';
                file2 = [logpathname logfilename];
                disp('For LOGFILE, user selected INTERNAL')
        end
        
        erpworkingmemory('pop_binlister', {file1, file2, file3, flagrst, forbiddenCodeArray, ignoreCodeArray,...
                updevent, option2do, reportable, iswarning, getfromerp, indexEL});
        
        if flagrst==1
                strflagrst = 'on';
        else
                strflagrst = 'off';
        end
        if updevent==1
                strupdevent = 'on';
        else
                strupdevent = 'off';
        end
        switch option2do
                case 0
                        msgboxText = 'Where should I send the update EVENTLIST???\n Pick an option.';
                        title = 'ERPLAB: Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                case 1
                        stroption2do = 'Text';
                case 2
                        stroption2do = 'EEG';
                case 3
                        stroption2do = 'EEG&Text';
                case 4
                        stroption2do = 'Workspace';
                case 5
                        stroption2do = 'Workspace&Text';
                case 6
                        stroption2do = 'Workspace&EEG';
                case 7
                        stroption2do = 'All';
        end
        if reportable==1
                strreportable = 'on';
        else
                strreportable = 'off';
        end
        if iswarning==1
                striswarning = 'on';
        else
                striswarning = 'off';
        end
        if ~getfromerp
                EEG.setname = [EEG.setname '_bins']; %suggest a new name
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_binlister(EEG, 'BDF', file1, 'ImportEL', file2, 'ExportEL', file3, 'Resetflag', strflagrst, 'Forbidden', forbiddenCodeArray,...
                'Ignore', ignoreCodeArray, 'UpdateEEG', strupdevent, 'SendEL2', stroption2do,'Report', strreportable, 'Warning', striswarning,...
                'Saveas', 'on', 'IndexEL', indexEL, 'History', 'gui');
        if getfromerp
                EEG = EEGaux;
        end
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
% option(s)
p.addParamValue('BDF', '', @ischar);
p.addParamValue('ImportEL', 'none', @ischar);
p.addParamValue('ExportEL', 'none', @ischar);
p.addParamValue('Resetflag', 'off', @ischar);% 'on', 'off'
p.addParamValue('Forbidden', [], @isnumeric);
p.addParamValue('Ignore', [], @isnumeric);
p.addParamValue('UpdateEEG', 'off', @ischar);% 'on', 'off'
p.addParamValue('SendEL2', 'EEG', @ischar);  %
p.addParamValue('Report', 'off', @ischar);   % 'on', 'off'
p.addParamValue('Warning', 'off', @ischar);  % 'on', 'off'
p.addParamValue('Saveas', 'off', @ischar);   % 'on', 'off'
p.addParamValue('IndexEL', 1, @isnumeric);   % integer
p.addParamValue('Voutput', 'EEG', @ischar);  % 'EEG' (which contains EVENTLIST) or 'EVENTLIST' (EVENTLIST only)
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

if length(EEG)>1
        msgboxText =  'ERPLAB says: Unfortunately, this function does not work with multiple datasets';
        error(msgboxText);
end

file1      = p.Results.BDF;              % bin descriptor file
file2      = p.Results.ImportEL;         % external eventlist (read event list from)
file3      = p.Results.ExportEL;         % text file containing the updated EVENTLIST (Write resulting eventlist to)
indexEL    = p.Results.IndexEL;          % EVENTLIST's index (in case of multiple EVENTLISTs)
outputv    = p.Results.Voutput;          % 'EEG' (which contains EVENTLIST) or 'EVENTLIST' (EVENTLIST only)

if strcmpi(p.Results.Resetflag, 'on')
        flagrst = 1;
else
        flagrst = 0;
end
if strcmpi(p.Results.Warning, 'on')
        iswarning = 1;
else
        iswarning = 0;
end
switch p.Results.SendEL2
        case 'Text'
                option2do = 1;
        case 'EEG'
                option2do = 2;
        case 'EEG&Text'
                option2do = 3;
        case 'Workspace'
                option2do = 4;
        case 'Workspace&Text'
                option2do = 5;
        case 'Workspace&EEG'
                option2do = 6;
        case {'All', 'Workspace&EEG&Text', 'Workspace&Text&EEG', 'EEG&Text&Workspace', 'EEG&Workspace&Text', 'Text&Workspace&EEG', 'Text&EEG&Workspace'}
                option2do = 7;
        otherwise
                %option2do = 0;
                error('ERPLAB says: You must specify what to do with the updated EVENTLIST.')
end
if isempty(file2) || strcmpi(file2,'no') || strcmpi(file2,'none')
        if isfield(EEG, 'EVENTLIST')
                if isfield(EEG.EVENTLIST, 'eventinfo')
                        if isempty(EEG.EVENTLIST(indexEL).eventinfo)
                                msgboxText = ['ERPLAB says: EVENTLIST.eventinfo structure is empty!\n'...
                                        'Use Create EVENTLIST before BINLISTER'];
                                error(sprintf(msgboxText));
                        end
                else
                        msgboxText =  ['ERPLAB says: EVENTLIST.eventinfo structure was not found!\n'...
                                'Use Create EVENTLIST before BINLISTER'];
                        error(sprintf(msgboxText));
                end
        else
                msgboxText =  ['ERPLAB says: EVENTLIST structure was not found!\n'...
                        'Use Create EVENTLIST before BINLISTER'];
                error(sprintf(msgboxText));
        end
        if ~isempty(EEG.EVENTLIST(indexEL)) && iswarning==1
                binaux    = [EEG.EVENTLIST(indexEL).eventinfo.bini];
                binhunter = binaux(binaux>0); %8/19/2009
                
                if ~isempty(binhunter) && ismember_bc2(option2do, [2 3 6 7])
                        msgboxText =  ['This dataset already has assigned bins.\n'...;
                                'Would you like to overwrite these bins?'];
                        title = 'ERPLAB: WARNING';
                        button =askquest(sprintf(msgboxText), title);
                        if strcmpi(button,'no')
                                disp('User canceled')
                                return
                        end
                end
        end
        
        %
        % Check for alphanumeric event codes
        %
        codelist = {EEG.EVENTLIST(indexEL).eventinfo.code};
        if nnz(cellfun(@ischar, codelist))>0
                msgboxText = ['Your dataset still has alphanumeric/string codes.\n\n'...
                        'You may try either eliminating nonnumeric information (see Create EVENTLIST)\n'...
                        'or remapping your events (see Create EVENTLIST Advanced)'];
                %title = 'ERPLAB: BDF Parsing Error';
                %errorfound(sprintf(msgboxText), title);
                %return
                error(msgboxText);
        end
        % save original EVENTLIST
        %ELaux = EEG.EVENTLIST(indexEL); % store original EVENTLIST
        
        %
        %  Reset Flags?
        %
        if flagrst==1
                % reset artifact flags
                EEG = resetflag(EEG, 255, indexEL);
        elseif flagrst==2
                % reset user flags
                EEG = resetflag(EEG, 65280, indexEL);
        elseif flagrst==3
                % reset ALL flags
                EEG = resetflag(EEG, indexEL);
        end
end

forbiddenCodeArray = p.Results.Forbidden;
ignoreCodeArray    = p.Results.Ignore;

if strcmpi(p.Results.UpdateEEG, 'on')
        updevent = 1;
else
        updevent = 0;
end
if strcmpi(p.Results.Report, 'on')
        reportable = 1;
else
        reportable = 0;
end
if ismember_bc2({p.Results.Saveas}, {'on','yes'})
        issaveas    = 1;
else
        issaveas    = 0;
end
if strcmpi(outputv, 'EVENTLIST') || strcmpi(outputv, 'EL')
        Voutput = 1; % EVENTLIST
else
        Voutput = 0; % EEG
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
%
% Call (neo)binlister
%
if reportable % workaround for a faster binlister... 02/28/12 JLC
        [EEG, EVENTLIST, binofbins, isparsenum] = binlister(EEG, file1, file2, file3, forbiddenCodeArray, ignoreCodeArray, reportable);
else
        [EEG, EVENTLIST, binofbins, isparsenum] = neobinlister2(EEG, file1, file2, file3, forbiddenCodeArray, ignoreCodeArray, 0);
end
if isparsenum==0
        % parsing was not approved
        msgboxText = ['Bin descriptor file contains errors!\n'...
                'For details, please read command window messages.'];
        title = 'ERPLAB: BDF Parsing Error';
        errorfound(sprintf(msgboxText), title);
        %EEG.EVENTLIST(indexEL) = ELaux;
        return
end
if nnz(binofbins)>=1
        if ~isempty(EVENTLIST)
                if Voutput==1 % EVENTLIST is the output only (for scripting)
                        clear EEG
                        EEG = EVENTLIST;
                        return
                end
                if iseegstruct(EEG) && ismember_bc2(option2do, [2 3 6 7])
                        EEG =  pasteeventlist(EEG, EVENTLIST, 1, indexEL);
                        if updevent && issaveas
                                EEG = pop_overwritevent(EEG, 'code', 'History', 'off');
                        elseif updevent && ~issaveas
                                EEG = pop_overwritevent(EEG, 'code', 'History', 'off');
                        end
                end
                if ismember_bc2(option2do, [4 5 6 7])
                        assignin('base','EVENTLIST',EVENTLIST);  % send EVENTLIST structure to WORKSPACE, August 22, 2008
                        disp('EVENTLIST structure was sent to WORKSPACE.')
                end
                if ismember_bc2(option2do, [1 3 5 7]) && ~isempty(file2) && ~strcmpi(file2,'no') && ~strcmpi(file2,'none')
                        disp('A text file version of your EVENTLIST was created.')
                end
                
                %
                % Generate equivalent command (for history)
                %
                skipfields = {'EEG', 'ERP', 'Saveas', 'Warning', 'History'};
                fn  = fieldnames(p.Results);
                com = sprintf( '%s  = pop_binlister( %s ', inputname(1), inputname(1));
                for q=1:length(fn)
                        fn2com = fn{q};
                        if ~ismember_bc2(fn2com, skipfields)
                                fn2res = p.Results.(fn2com);
                                if ~isempty(fn2res)
                                        if ischar(fn2res)
                                                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no') && ~strcmpi(fn2res,'none')
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
        else
                msgboxText = ['Bin descriptor file contains errors!\n'...
                        'For details, please read command window messages.'];
                title = 'ERPLAB: BDF Parsing Error';
                errorfound(sprintf(msgboxText), title);
                EEG.EVENTLIST(indexEL) = ELaux;
                return
        end
else
        msgboxText =  ['Bins were not found!\n'...
                'Try with other BDF or modify the current one.'];
        title = 'ERPLAB: Binlister Error';
        errorfound(sprintf(msgboxText), title);
        disp('binlister process was cancel.')
        %EEG.EVENTLIST(indexEL) = ELaux;
        return
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
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end

if issaveas && ismember_bc2(option2do, [2 3 6 7]) && iseegstruct(EEG)
        [ALLEEG, EEG, CURRENTSET] = pop_newset( ALLEEG, EEG, CURRENTSET);
end
if exist('ALLEEG', 'var')
        if ~isfield(ALLEEG,'data')
                [ALLEEG(1:length(ALLEEG)).data] = deal([]);
        end
end
return

