% PURPOSE  :	Erases numeric event codes according to a logical expression.
%
% FORMAT   :
%
% EEG = pop_eraseventcodes( EEG, expression )
%
% INPUTS   :
%
% EEG           - input dataset
% expression          - logical expression '=value','>value','<value','~=value', '>=value','<=value'
%
% OUTPUTS  :
%
% EEG           - updated output dataset
%
% EXAMPLE  :
%
% EEG = pop_eraseventcodes( EEG, '>255' ); % deletes all event codes greater than 255
%
% See also inputvalue.m  eraseventcodes.m
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

function [EEG, com] = pop_eraseventcodes( EEG, expression, varargin)
com = '';
if nargin < 1
        help pop_eraseventcodes
        return
end
if isobject(EEG) % eegobj
        whenEEGisanObject % calls a script for showing an error window
        return
end
if nargin==1
        if isempty(EEG(1).data)
                msgboxText =  'pop_eraseventcodes() cannot read an empty dataset!';
                title = 'ERPLAB: pop_eraseventcodes error';
                errorfound(msgboxText, title);
                return
        end
        if ~isempty(EEG(1).epoch)
                msgboxText =  'pop_eraseventcodes has been tested for continuous data only';
                title = 'ERPLAB: pop_eraseventcodes(). Permission denied';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG(1), 'event')
                msgboxText =  'pop_eraseventcodes did not find EEG.event field.';
                title = 'ERPLAB: pop_eraseventcodes(). Permission denied';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG(1).event, 'type')
                msgboxText =  'pop_eraseventcodes did not find EEG.event.type field.';
                title = 'ERPLAB: pop_eraseventcodes(). Permission denied';
                errorfound(msgboxText, title);
                return
        end
        if ~isfield(EEG(1).event, 'latency')
                msgboxText =  'pop_eraseventcodes did not find EEG.event.latency field.';
                title = 'ERPLAB: pop_eraseventcodes(). Permission denied';
                errorfound(msgboxText, title);
                return
        end
        if ischar(EEG(1).event(1).type)
                msgboxText =  ['pop_eraseventcodes only works with numeric event codes.\n'...
                        'We recommend to use Create EEG Eventlist - Basic first.'];
                title = 'ERPLAB: pop_eraseventcodes(). Permission denied';
                errorfound(sprintf(msgboxText), title);
                return
        end
        prompt    = {'expression (>, < ==, ~=):'};
        dlg_title = 'Input event-code condition to delete';
        num_lines = 1;       
        def  = erpworkingmemory('pop_eraseventcodes');
        if isempty(def)
                def = {'>255'};
        end
        
        %
        % Open GUI
        %
        answer = inputvalue(prompt,dlg_title,num_lines,def);
        if isempty(answer)
                disp('User selected Cancel')
                return
        end
        expression = answer{1};
        erpworkingmemory('pop_eraseventcodes', {expression});
        
        EEG.setname = [EEG.setname '_delevents']; % suggested name (si queris no mas!)
        %
        % Somersault
        %
        [EEG, com] = pop_eraseventcodes( EEG, expression, 'Warning', 'on', 'History', 'gui');
        return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('EEG');
p.addRequired('expression', @ischar);
% option(s)
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, expression, varargin{:});

if strcmpi(p.Results.Warning,'on')
        wchmsgon = 1;
else
        wchmsgon = 0;
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
% process multiple datasets April 13, 2011 JLC
%
if length(EEG) > 1
        [ EEG, com ] = eeg_eval( 'pop_eraseventcodes', EEG, 'warning', 'on', 'params', {expression});
        return;
end

%
% subroutine
%
EEG = eraseventcodes( EEG, expression);
EEG.setname = [EEG.setname '_cleaned']; % suggested name (si queris no mas!)
com = sprintf( '%s = pop_eraseventcodes( %s, ''%s'' );', inputname(1), inputname(1), expression);

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
                % EEG = erphistory(EEG, [], com, 1);
                % fprintf('%%Equivalent command:\n%s\n\n', erpcom);
        otherwise %off or none
                com = '';
end

%
% Completion statement
%
msg2end
return


