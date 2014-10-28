% PURPOSE  : Overwrites EEG.event.type using information from EEG.EVENTLIST.eventinfo
%
% FORMAT   :
%
% EEG = pop_overwritevent(EEG, mainfield)
%
% INPUT
%
% EEG         - continuous dataset having a EVENTLIST structure
% mainfield   - name of field from EEG.EVENTLIST.eventinfo to be copied into EEG.event.type. 'code','codelabel', or 'binlabel'.
%
% OUTPUTS  :
%
% EEG         - continuous dataset with updated EEG.event.type
%
%
% EXAMPLE: replace EEG.event.type with bin labels
%
% EEG = pop_overwritevent(EEG, 'binlabel')
%
%
% See also overwriteventGUI.m update_EEG_event_field.m
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

function [EEG, com] = pop_overwritevent(EEG, mainfield, varargin)
com='';
if nargin<1
        help pop_overwritevent
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1        
        serror = erplab_eegscanner(EEG, 'pop_overwritevent', 0, 0, 0, 2, 1);
        if serror
                return
        end
        
        %
        % open GUI
        %
        answer = overwriteventGUI;
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        mainfield    = answer{1};
        removenctype = answer{2}; % remove remaining event codes
        
        if removenctype==1
                rrcstr = 'on';
        else
                rrcstr = 'off';
        end        
        iserrorf   = 0;
        testfield1 = unique_bc2([EEG.EVENTLIST.eventinfo.(mainfield)]);        
        if isempty(testfield1)
                iserrorf = 1;
        end
        if isnumeric(testfield1)
                testfield1 = num2str(testfield1);
        end
        if strcmp(testfield1,'"')
                iserrorf = 1;
        end
        if iserrorf
                msgboxText =  ['Sorry, EEG.EVENTLIST.eventinfo.'  mainfield ' field is empty!\n\n'...
                        'You should assign values to this field before overwriting EEG.event'];
                title = 'ERPLAB: pop_overwritevent Error';
                errorfound(sprintf(msgboxText), title);
                EEG = pop_overwritevent(EEG);
                return
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_overwritevent(EEG, mainfield, 'RemoveRemCodes', rrcstr,'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('mainfield');
% option(s)
p.addParamValue('RemoveRemCodes', 'off', @ischar); % preserve remaining codes (non-captured (by binlister) event types)
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, mainfield, varargin{:});

if strcmpi(p.Results.RemoveRemCodes,'on') || strcmpi(p.Results.RemoveRemCodes,'yes')
        removenctype = 1;
else
        removenctype = 0;
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
if ~ismember_bc2({mainfield}, {'code','codelabel','binlabel','bini'})
        error(['Field "' mainfield '" is not an EEG.EVENTLIST.eventinfo''s structure field'])
end

iserrorf   = 0;
testfield1 = unique_bc2([EEG.EVENTLIST.eventinfo.(mainfield)]);

if isempty(testfield1)
        iserrorf = 1;
end
if isnumeric(testfield1)
        testfield1 = num2str(testfield1);
end
if strcmp(testfield1,'"')
        iserrorf = 1;
end
if iserrorf
        msgboxText =  ['Sorry, EEG.EVENTLIST.eventinfo.%s field is empty!\n'...
                'You should assign values to this field before overwriting EEG.event'];
        error('prog:input', msgboxText, mainfield)
else
        disp(['EEG.EVENTLIST.eventinfo.'  mainfield ' will replace your EEG.event.type structure.'])
end

%
% subroutine
%
%
% Replace fields  (needs more thought...)
%
EEG = update_EEG_event_field(EEG, mainfield, 'type', removenctype);

skipfields = {'EEG', 'mainfield', 'History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_overwritevent( %s, ''%s'' ', inputname(1), inputname(1), mainfield);
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
% com = sprintf( '%s = pop_overwritevent( %s, ''%s'');', inputname(1), inputname(1), mainfield);

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
prefunc = dbstack;
nf = length(unique_bc2({prefunc.name}));
if nf==1
        msg2end
end
return
