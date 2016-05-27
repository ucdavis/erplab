% PURPOSE  : shuffles event codes or bin indices (e.g. for permutation analysis)
%
% FORMAT   :
%
% EEG = pop_eventshuffler(EEG, parameters)
%
% INPUTS   :
%
% EEG           - input dataset
%
% The available parameters are as follows:
%
%        'Values' 	- codes or bin indices to shuffle. It can be any numerical value or the string 'all'
%        'Field'        - for shuffling numeric event codes->'code'
%                         for shuffling bin indices->'bini'
%
% OUTPUTS  :
%
% EEG              - updated dataset
%
%
% EXAMPLE  : Shuffle event codes 121 and 149
%
% EEG = pop_eventshuffler(EEG, 'Values', [121 149], 'Field', 'code');
%
%
% See also eventshuffler.m
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

function [EEG, com] = pop_eventshuffler(EEG, varargin)
com = '';
if nargin < 1
        help pop_eventshuffler
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end

%
% Gui is working...
%
if nargin==1     
        ndts = length(EEG);
        for hh=1:ndts
                if ndts==1
                        hhx = evalin('base', 'CURRENTSET');
                else
                        hhx = hh;
                end
                if ~isfield(EEG(hh), 'event')
                        msgboxText =  'pop_eventshuffler did not find EEG.event field at dataset #%g';
                        title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                        errorfound(sprintf(msgboxText, hhx), title);
                        return
                end
                if ~isfield(EEG(hh).event, 'type')
                        msgboxText =  'pop_eventshuffler did not find EEG.event.type field at dataset #%g';
                        title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                        errorfound(sprintf(msgboxText, hhx), title);
                        return
                end
                if ~isfield(EEG(hh).event, 'latency')
                        msgboxText =  'pop_eventshuffler did not find EEG.event.latency field at dataset #%g';
                        title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                        errorfound(sprintf(msgboxText, hhx), title);
                        return
                end
                if ischar(EEG(hh).event(1).type) && ~isfield(EEG(hh), 'EVENTLIST')
                        msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset #%g.\n'...
                                'We recommend to use Create EEG Eventlist to convert them into numeric ones.'];
                        title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                        errorfound(sprintf(msgboxText, hhx), title);
                        return
                elseif ischar(EEG(hh).event(1).type) && isfield(EEG(hh), 'EVENTLIST')
                        if isempty(EEG(hh).EVENTLIST)
                                msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset #%g.\n'...
                                        'We recommend to use Create EEG Eventlist Advance first.'];
                                title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                                errorfound(sprintf(msgboxText, hhx), title);
                                return
                        end
                end
        end
        
        def = erpworkingmemory('pop_eventshuffler');
        
        if isempty(def)
                def = {[] 0};
        end
        
        %
        % call GUI
        %
        answer = shuffleGUI(def);
        
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        
        valueatfield = answer{1};
        specfield    = answer{2};
        
        if specfield==0
                specfieldstr = 'code';
        elseif specfield==1
                specfieldstr = 'bini';
        elseif specfield==2
                specfieldstr = 'data';
                valueatfield = 'off';
        else
                error('invalid field')
        end
        if ~isnumeric(valueatfield) && ~strcmpi(valueatfield, 'all') && ~strcmpi(valueatfield, 'off')
                valueatfield = str2num(valueatfield);
                if isempty(valueatfield)
                        msgboxText =  'Invalid value for "codes to shuffle"';
                        title = 'ERPLAB: pop_eventshuffler(). Error';
                        errorfound(sprintf(msgboxText), title);
                        return
                end
        elseif ~isnumeric(valueatfield) && strcmpi(valueatfield, 'all')
                fprintf('User selected all %s\n', specfieldstr )
        elseif isnumeric(valueatfield)
                fprintf('User specified %s = %s \n', specfieldstr, vect2colon(valueatfield))
        end
        
        erpworkingmemory('pop_eventshuffler', {valueatfield specfield});
        
        %
        % Somersault
        %
        if length(EEG)==1
                EEG.setname = [EEG.setname '_' specfieldstr '_shuffled']; % suggested name (si queris no mas!)
        end
        [EEG, com] = pop_eventshuffler(EEG, 'Values', valueatfield, 'Field', specfieldstr, 'History', 'gui');
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
p.addParamValue('Values', []);
p.addParamValue('Field', 'code', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});
valueatfield = p.Results.Values;

if strcmpi(p.Results.Field, 'code')%
        specfield = 0;
elseif strcmpi(p.Results.Field, 'bin') || strcmpi(p.Results.Field, 'bini')
        specfield = 1;
elseif strcmpi(p.Results.Field, 'data') || strcmpi(p.Results.Field, 'sample') || strcmpi(p.Results.Field, 'samples')
        specfield = 2;
else
        error('ERPLAB says: invalid shuffling type')
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
if ischar(valueatfield) && ~strcmpi(valueatfield, 'all') && ~strcmpi(valueatfield, 'off')
        msgboxText =  'Invalid value for event to shuffle.';
        title = 'ERPLAB: pop_eventshuffler(). Error';
        errorfound(sprintf(msgboxText), title);
        return
end
if specfield~=2 && ~isempty(EEG(1).epoch)
        msgboxText =  'pop_eventshuffler has been tested for continuous data only';
        if shist == 1; % gui
                title = 'ERPLAB: pop_eventshuffler(). Permission denied';
                errorfound(msgboxText, title);
                return
        else
                error(msgboxText)
        end
end

%
% process multiple datasets. Updated August 23, 2013 JLC
%
options1 = {'Values', p.Results.Values, 'Field', p.Results.Field, 'History', 'gui'};
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_eventshuffler', EEG, 'warning', 'on', 'params', options1);
        return;
end;

%
% subroutine
%
fprintf('Shuffling %s...please wait...\n', p.Results.Field);
EEG = eventshuffler(EEG, valueatfield, specfield);

% com = sprintf( '%s = pop_eventshuffler( %s, %s);', inputname(1), inputname(1), 'all');
skipfields = {'EEG','History'};
fn  = fieldnames(p.Results);
com = sprintf( '%s  = pop_eventshuffler( %s ', inputname(1), inputname(1));
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
                %fprintf('%%%Equivalent command:\n%s\n\n', com);
                displayEquiComERP(com);
        case 2 % from script
                EEG = erphistory(EEG, [], com, 1);
        case 3
                % implicit
                %EEG = erphistory(EEG, [], com, 1);
                %fprintf('%%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return