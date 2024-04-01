% PURPOSE : converts an epoched dataset into a continuous one. Segments of data will be concatenated using a 'boundary' event.
%
% FORMAT   :
%
% EEG = epoch2continuous(EEG);
%   or EEG2 = pop_epoch2continuous(EEG,'Warning','off');
%
% INPUTS   :
%
% EEG          	- epoched EEG dataset
% Warning       - String specifying popup warning status. 'on' for on.
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
    
    %         question = ['This tool converts an epoched dataset into a continuous one by concatenating all its epochs using boundary events.\n\n'...
    %                     'Would you like to proceed?'];
    %         title    = 'ERPLAB: pop_epoch2continuous() ';
    %         button   = askquest(sprintf(question), title);
    %
    %         if ~strcmpi(button,'yes')
    %                 disp('User selected Cancel')
    %                 return
    %         end
    
    %%GH Mar 2024
    app = feval('estudio_epoch2contn_gui',[1]);
    waitfor(app,'Finishbutton',1);
    try
        RestoreEvent = app.output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
        app.delete; %delete app from view
        pause(0.1); %wait for app to leave
    catch
        return;
    end
    if isempty(RestoreEvent)
        return;
    end
    
    if isempty(RestoreEvent) || numel(RestoreEvent)~=1 || (RestoreEvent~=0 && RestoreEvent~=1)
        RestoreEvent=1;
    end
    if RestoreEvent==1
        RestoreEventStr = 'on';
    else
        RestoreEventStr = 'off';
    end
    
    %
    % Somersault
    %
    [EEG, com] = pop_epoch2continuous(EEG, 'RestoreEvent',RestoreEventStr,'History', 'gui');
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
p.addParamValue('RestoreEvent', 'on', @ischar); % history from scripting

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



RestoreEvent = p.Results.RestoreEvent;%%GH Mar 2024
if strcmpi(RestoreEvent,'on')
    event =  EEG.event;
    for Numofevent = 1:length(event)
        expression = event(Numofevent).type;
        expression = strrep(expression,'(','=');
        expression = strrep(expression,')','');
        tokave = regexpi(expression, '[n]*b[in]*(\d+)\s*=', 'tokens','ignorecase');
        if ~isempty(tokave)
            expression  = strrep(expression,strcat('B',tokave{1,1},'='),'');
            if iscell(expression)
                expression = expression{1,1};
            end
            EEG.event(Numofevent).type=expression;
            EEG.event(Numofevent).urevent=expression;
        end
    end
    
end

% com = sprintf('%s = pop_epoch2continuous(%s);', inputname(1), inputname(1));
com = sprintf( '%s = pop_bdfrecovery( %s ', inputname(1), inputname(1) );
skipfields = {'History'};
fn     = fieldnames(p.Results);
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                com = sprintf( '%s, ''%s'', ''%s''', com, fn2com, fn2res);
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
        %EEG = erphistory(EEG, [], com, 1);
        %fprintf('%%Equivalent command:\n%s\n\n', erpcom);
    otherwise %off or none
        com = '';
end
%
% Completion statement
%
msg2end