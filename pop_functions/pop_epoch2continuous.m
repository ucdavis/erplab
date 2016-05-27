% PURPOSE : converts an epoched dataset into a continuous one. Segments of data will be concatenated using a 'boundary' event.
%
% FORMAT   :
%
% EEG = epoch2continuous(EEG);
%
% INPUTS   :
%
% EEG          	- epoched EEG dataset
%
% OUTPUTS
%
% EEG             - continuous dataset (concatenated using a 'boundary' event)
%
%
% See also epoch2continuous.m
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Javier Lopez-Calderon
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% July 7, 2011
%
% Feedback would be appreciated and credited.
% NOTE: No ICA fields have been tested until this version.
% BUG #1: EEG.epoch.eventlatency cell vs single value. Steven Raaijmakers

function [EEG, com] = pop_epoch2continuous(EEG, varargin)
com = '';
if nargin<1
        help pop_epoch2continuous
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
        if isempty(EEG.data)
                msgboxText = 'pop_epoch2continuous() cannot read an empty dataset!';
                title = 'ERPLAB: pop_epoch2continuous';
                errorfound(msgboxText, title);
                return
        end
        if isempty(EEG.epoch)
                msgboxText = 'pop_epoch2continuous is intended to work with epoched datasets only. ';
                title = 'ERPLAB: pop_epoch2continuous ';
                errorfound(msgboxText, title);
                return
        end
        
        question = ['This tool converts an epoched dataset into a continuous one by concatenating all its epochs using boundary events.\n\n'...
                    'Would you like to proceed?'];
        title    = 'ERPLAB: pop_epoch2continuous() ';
        button   = askquest(sprintf(question), title);
        
        if ~strcmpi(button,'yes')
                disp('User selected Cancel')
                return
        end
        
        %
        % Somersault
        %
        [EEG, com] = pop_epoch2continuous(EEG, 'History', 'gui');
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
p.addParamValue('Warning', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(EEG, varargin{:});

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
% subroutine
%
EEG = epoch2continuous(EEG);
EEG.setname   = [EEG.setname '_ep2con'];
EEG.EVENTLIST = []; % remove EVENTLIST structure

com = sprintf('%s = pop_epoch2continuous(%s);', inputname(1), inputname(1));

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
end
%
% Completion statement
%
msg2end