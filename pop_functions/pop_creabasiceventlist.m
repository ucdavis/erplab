% PURPOSE  :	Creates the EVENTLIST structure with the event information
%                 extracted and reorganized from EEG.event (default) or from
%                 an external list (text file). The EVENTLIST structure is
%                 attached to the EEG structure.
%
% FORMAT   :
%
% EEG  = pop_creabasiceventlist( EEG , Parameters);
%
% EXAMPLE  :
%
% EEG  = pop_creabasiceventlist( EEG , 'Eventlist','/Users/etfoo/Documents/MATLAB/Eventlist.txt', 'BoundaryNumeric', { -99 },...
%                               'BoundaryString', { 'boundary' }, 'Warning', 'on' );
%
% INPUTS   :
%
% EEG               - input dataset
%
% The available parameters are as follows:
%
%    'Eventlist'             - name (and path) of eventlist text file to export.
%    'BoundaryString'        - boundary string code to be converted into a numeric code.
%    'BoundaryNumeric'           - numeric code that boundary string code is to be converted to
%    'BoundaryString'        - Name of string code that is to be converted
%    'BoundaryNumeric'       - Numeric code that string code is to be converted to
%    'Warning'               - 'on'- Warn if eventlist will be overwritten. 'off'- Don't warn if eventlist will be overwritten.
%    'AlphanumericCleaning'  - Delete alphabetic character(s) from alphanumeric event codes (if any). 'on'/'off'
%
%
% OUTPUTS
%
% EEG               - (updated) output dataset
%
%
% See also creabasiceventlistGUI.m pop_editeventlist.m pop_overwritevent.m letterkilla.m
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

function [EEG, com] = pop_creabasiceventlist(EEG, varargin)
com = '';
if nargin < 1
        help pop_creabasiceventlist
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        serror = erplab_eegscanner(EEG, 'pop_creabasiceventlist', 2, 0, 0, 0, 2);
        if serror
                return
        end
        if isfield(EEG(1).event, 'type')
                if ~all(cellfun(@isnumeric, { EEG(1).event.type }))
                        msgboxText = ['Some or all of your events contain a text-based event label, '...
                                'and not a numeric event code.\n\nERPLAB must have a numeric code '...
                                'for every event (a text label can also be present).  For labels such as "S14", '...
                                'you can automatically create an equivalent numeric event code (e.g., 14) by '...
                                'checking the box labeled "Create numeric equivalents of nonnumeric event codes '...
                                'when possible" when creating the EventList.\n\nFor labels that cannot be automatically '...
                                'converted (e.g., "RESP"), or for ambiguous cases (e.g., when you have both "S14" and '...
                                '"R14"), you can flexibly create numeric versions using the Advanced button at EVENTLIST GUI.\n'];
                        
                        title_msg = 'ERPLAB: Warning';
                        %button    = askquest(sprintf(msgboxText), title_msg);
                        button = askquestpoly(sprintf(msgboxText), title_msg, {'Continue'});
                        if ~strcmpi(button,'Continue')
                                disp('User selected Cancel')
                                return
                        end
                end
        end
        
        def  = erpworkingmemory('pop_creabasiceventlist');
        if isempty(def)
                def = {'' 'boundary' -99 1 1};
        end
        
        %
        % Call GUI
        %
        if length(EEG)>1
                multieeg = 1; % when multi eeg
        else
                multieeg = 0; % just single eeg
        end
        inputstrMat = creabasiceventlistGUI(def, multieeg);  % GUI
        
        if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
                disp('User selected Cancel')
                return
        elseif strcmp(inputstrMat,'advanced')
                %[EEG, com ] = pop_editeventlist(EEG, 'History', 'off');
                [EEG, com ] = pop_editeventlist(EEG);
                return
        end
        
        elname   = inputstrMat{1};
        boundarystrcode    = inputstrMat{2};
        newboundarynumcode = inputstrMat{3};
        rwwarn   = inputstrMat{4};
        alphanum = inputstrMat{5};
        
        erpworkingmemory('pop_creabasiceventlist', {elname, boundarystrcode, newboundarynumcode, rwwarn, alphanum});
        
        if rwwarn==1
                striswarning = 'on';
        else
                striswarning = 'off';
        end
        if alphanum==1
                stralphanum = 'on';
        else
                stralphanum = 'off';
        end
        if length(EEG)==1
                EEG.setname = [EEG.setname '_elist']; %suggest a new name
        end
        
        [EEG, com] = pop_creabasiceventlist(EEG, 'Eventlist', elname, 'BoundaryString', boundarystrcode,...
                'BoundaryNumeric', newboundarynumcode,'Warning', striswarning, 'AlphanumericCleaning', stralphanum, 'History', 'gui');
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
p.addParamValue('Eventlist', '', @ischar);
p.addParamValue('BoundaryString', 'boundary');
p.addParamValue('BoundaryNumeric', -99);
p.addParamValue('Stringboundary', []); % old parameter for BoundaryString
p.addParamValue('Newboundary', []);    % old parameter for BoundaryNumeric
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('AlphanumericCleaning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

elname  = p.Results.Eventlist;      % Event List file
boundarystrcode_old    = p.Results.Stringboundary; % current string for boundaries (old versions)
newboundarynumcode_old = p.Results.Newboundary;    % new numeric code for replacing string boundaries (old versions)

if isempty(boundarystrcode_old)
        boundarystrcode    = p.Results.BoundaryString; % current string for boundaries
else
        boundarystrcode    = boundarystrcode_old; % current string for boundaries
end
if isempty(newboundarynumcode_old)
        newboundarynumcode = p.Results.BoundaryNumeric;    % new numeric code for replacing string boundaries
else
        newboundarynumcode = newboundarynumcode_old;    % new numeric code for replacing string boundaries
        
end

boundarystrcode    = strtrim(boundarystrcode);
boundarystrcode    = regexprep(boundarystrcode, '''|"','');

if strcmpi(p.Results.Warning, 'on')
        rwwarn = 1;
else
        rwwarn = 0;
end
if strcmpi(p.Results.AlphanumericCleaning, 'on')
        alphanum = 1;
else
        alphanum = 0;
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
% process multiple datasets. Updated August 23, 2013 JLC
%
if length(EEG) > 1
        options1 = {'Eventlist', p.Results.Eventlist, 'BoundaryString', p.Results.BoundaryString,...
                'BoundaryNumeric', p.Results.BoundaryNumeric,'Warning', p.Results.Warning,...
                'AlphanumericCleaning', p.Results.AlphanumericCleaning, 'History', 'gui'};
        [ EEG, com ] = eeg_eval( 'pop_creabasiceventlist', EEG, 'warning', 'on', 'params', options1);
        return;
end

%
% Event consistency
%
EEG = eeg_checkset(EEG, 'eventconsistency');
auxEvent = EEG.event;

if isfield(EEG, 'EVENTLIST')
        auxEVENTLIST = EEG.EVENTLIST; % keep old EVENTLIST just in case
        if rwwarn
                if isfield(EEG.EVENTLIST, 'eventinfo')
                        if ~isempty(EEG.EVENTLIST.eventinfo)
                                if nargin==1
                                        question   = ['dataset %s  already has attached an EVENTLIST structure.\n'...
                                                'So, pop_creabasiceventlist()  will totally overwrite it.\n'...
                                                'Do you want to continue anyway?'];
                                        title      = 'ERPLAB: binoperator, Overwriting Confirmation';
                                        button     = askquest(sprintf(question, EEG.setname), title);
                                        
                                        if ~strcmpi(button,'yes')
                                                disp('User selected Cancel')
                                                return
                                        end
                                else
                                        fprintf('\n\nWARNING: Previous EVENTLIST structure will be overwritten.\n\n')
                                end
                                %if ischar(EEG.event(1).type)
                                %        [ EEG.event.type ] = EEG.EVENTLIST.eventinfo.code;
                                %end
                                EEG.EVENTLIST = [];
                        end
                end
        end
else
        auxEVENTLIST = 'none';
end
field2del = {'bepoch','bini','binlabel', 'code', 'codelabel','enable','flag','item'};
tf  = ismember_bc2(field2del,fieldnames(EEG.event)');

if rwwarn && nnz(tf)>0
        question = ['The EEG.event field of %s contains subfield name(s) reserved for ERPLAB.\n\n'...
                'What would you like to do?\n\n'];
        
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        title      = 'ERPLAB: pop_creabasiceventlist, Overwriting Confirmation';
        oldcolor    = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button      = questdlg(sprintf(question, EEG.setname), title,'Cancel','Overwrite them', 'Continue as it is', 'Overwrite them');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor)
        
        if strcmpi(button,'Continue as it is')
                fprintf('|WARNING: Fields found in EEG.event that has ERPLAB''s reserved names will not be overwritten.\n\n');
        elseif strcmpi(button,'Cancel') || strcmpi(button,'')
                return
        elseif strcmpi(button,'Overwrite them')
                %bepoch bini binlabel codelabel duration enable flag item latency type urevent
                EEG.event = rmfield(EEG.event, field2del(tf));
                fprintf('|WARNING: Fields found in EEG.event that has ERPLAB''s reserved names were overwritten.\n\n')
        end
end
if alphanum==1
        alphanstr = 'on';
else
        alphanstr = 'off';
end

% Warning
if rwwarn==0
        striswarning = 'off';
else
        striswarning = 'on';
end

% Send EVENTLIST to...
if strcmp(elname,'') || strcmp(elname,'no') || strcmp(elname,'none')
        stroption2do = 'EEG';
else
        stroption2do = 'EEG&Text';
end

EEG = pop_editeventlist(EEG, 'SendEL2', stroption2do, 'ExportEL', elname,...
        'BoundaryString', boundarystrcode,'BoundaryNumeric', newboundarynumcode, 'Warning', striswarning,...
        'AlphanumericCleaning', alphanstr, 'History', 'off');
EEG = pop_overwritevent(EEG, 'code', 'History', 'off');

if rwwarn
        if ~all(cellfun(@isnumeric, { EEG.event.type }))
                msgboxText = ['Some or all of your events still contain a text-based event label, '...
                        'and not a numeric event code.\n\nERPLAB must have a numeric code '...
                        'for every event (a text label can also be present).  For labels such as "S14", '...
                        'you can automatically create an equivalent numeric event code (e.g., 14) by '...
                        'checking the box labeled "Create numeric equivalents of nonnumeric event codes '...
                        'when possible" when creating the EventList.\n\nFor labels that cannot be automatically '...
                        'converted (e.g., "RESP"), or for ambiguous cases (e.g., when you have both "S14" and '...
                        '"R14"), you can flexibly create numeric versions using the Advanced button at EVENTLIST GUI.\n\n'...
                        'Would you like to continue anyway?'];
                title_msg      = 'ERPLAB: Warning';
                button    = askquest(sprintf(msgboxText), title_msg);
                
                if ~strcmpi(button,'yes')
                        if isempty(auxEVENTLIST) || isstruct(auxEVENTLIST)
                                EEG.EVENTLIST = auxEVENTLIST;
                        else
                                EEG = rmfield(EEG, 'EVENTLIST');
                        end
                        EEG.event = auxEvent;
                        disp('User selected Cancel')
                        return
                end
        end
end

%
% Generate equivalent command (for history)
%
skipfields = {'EEG', 'Warning', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_creabasiceventlist( %s ', inputname(1), inputname(1));
for q=1:length(fn)
        fn2com = fn{q}; % get fieldname
        if ~ismember_bc2(fn2com, skipfields)
                fn2res = p.Results.(fn2com); % get content of current field
                if ~isempty(fn2res)
                        if iscell(fn2res)
                                com = sprintf( '%s, ''%s'', {', com, fn2com);
                                for c=1:length(fn2res)
                                        getcont = fn2res{c};
                                        if ischar(getcont)
                                                fnformat = '''%s''';
                                        else
                                                fnformat = '%s';
                                                getcont = num2str(getcont);
                                        end
                                        com = sprintf( [ '%s ' fnformat], com, getcont);
                                end
                                com = sprintf( '%s }', com);
                        else
                                if ischar(fn2res)
                                        if ~strcmpi(fn2res,'off')
                                                com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
                                        end
                                else
                                        %if iscell(fn2res)
                                        %        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                                        %        fnformat = '{%s}';
                                        %else
                                        fn2resstr = vect2colon(fn2res, 'Sort','on');
                                        fnformat = '%s';
                                        %end
                                        com = sprintf( ['%s, ''%s'', ' fnformat], com, fn2com, fn2resstr);
                                end
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
end


%
% Completion statement
%
prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end
return