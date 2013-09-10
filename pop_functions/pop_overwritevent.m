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
        if length(EEG)>1
                msgboxText =  'Unfortunately, this function does not work with multiple datasets';
                title = 'ERPLAB: multiple inputs';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG.epoch)
                msgboxText =  'pop_overwritevent has been tested for continuous data only';
                title = 'ERPLAB: pop_overwritevent Permission';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.data)
                msgboxText =  'pop_overwritevent() error: cannot work with an empty dataset!';
                title = 'ERPLAB: No data';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG, 'EVENTLIST')
                msgboxText = ['EEG.EVENTLIST structure was not found!\n\n'...
                        'Use Create EVENTLIST before overwriting EEG.event'];
                title = 'ERPLAB: pop_overwritevent Error';
                errorfound(sprintf(msgboxText), title);
                return
        end
        if ~isfield(EEG.EVENTLIST, 'eventinfo')
                msgboxText = ['EEG.EVENTLIST.eventinfo structure was not found!\n\n'...
                        'Use Create EVENTLIST before overwriting EEG.event'];
                title = 'ERPLAB: pop_overwritevent Error';
                errorfound(sprintf(msgboxText), title);
                return
        else
                if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty!\n\n'...
                                'Use Create EVENTLIST before overwriting EEG.event'];
                        title = 'ERPLAB: pop_overwritevent Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                else
                        disp('EEG.EVENTLIST.eventinfo was successfully found.')
                end
        end
        mainfield = overwriteventGUI;
        if isempty(mainfield)
                disp('User selected Cancel')
                return
        end
        
        iserrorf   = 0;
        testfield1 = unique([EEG.EVENTLIST.eventinfo.(mainfield)]);
        
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
        [EEG, com] = pop_overwritevent(EEG, mainfield, 'History', 'gui');
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
p.addParamValue('History', 'script', @ischar); % history from scripting
p.parse(EEG, mainfield, varargin{:});

if strcmpi(p.Results.History,'implicit')
        shist = 3; % implicit
elseif strcmpi(p.Results.History,'script')
        shist = 2; % script
elseif strcmpi(p.Results.History,'gui')
        shist = 1; % gui
else
        shist = 0; % off
end
if ~ismember({mainfield}, {'code','codelabel','binlabel'})
        error(['Field "' mainfield '" is not an EEG.EVENTLIST.eventinfo''s structure field'])
end

iserrorf   = 0;
testfield1 = unique([EEG.EVENTLIST.eventinfo.(mainfield)]);

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
EEG = update_EEG_event_field(EEG, mainfield);
com = sprintf( '%s = pop_overwritevent( %s, ''%s'');', inputname(1), inputname(1), mainfield);

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
nf = length(unique({prefunc.name}));
if nf==1
        msg2end
end
return
