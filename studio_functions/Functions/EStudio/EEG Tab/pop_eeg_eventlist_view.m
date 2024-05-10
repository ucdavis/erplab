% PURPOSE:  pop_eeg_eventlist_view.m
%           display eventlist

% FORMAT:
% [ALLEEG, erpcom] = pop_eeg_eventlist_view( ALLEEG, 'EEGArray',EEGArray,...
%         'Saveas', 'off', 'History', 'gui');

% Inputs:
%
%ALLEEG           -ALLEEG structure
%EEGArray         -index(es) of eegsets



% *** This function is part of ALLEEGLAB Studio ***
% Author: Guanghui Zhang & Steven Luck
% ghzhang@ucdavis.edu, sjluck@ucdavis.edu
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% May 2024




function [ALLEEG, erpcom] = pop_eeg_eventlist_view(ALLEEG, varargin)
erpcom = '';

if nargin < 1
    help pop_eeg_eventlist_view
    return
end
if isempty(ALLEEG)
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: pop_eeg_eventlist_view() error';
    errorfound(msgboxText, title);
    return
end
if isempty(ALLEEG(1))
    msgboxText =  'Cannot handle an empty EEGset';
    title = 'ERPLAB: pop_eeg_eventlist_view() error';
    errorfound(msgboxText, title);
    return
end



if nargin==1
    EEGArray = [1:length(ALLEEG)];
    [ALLEEG, erpcom] = pop_eeg_eventlist_view( ALLEEG, 'EEGArray',EEGArray,...
        'Saveas', 'off', 'History', 'gui');
    return
end

%
% Parsing inputs
%
p = inputParser;
p.FunctionName  = mfilename;
p.CaseSensitive = false;
p.addRequired('ALLEEG');
% option(s)
p.addParamValue('EEGArray', [],@isnumeric);
p.addParamValue('Saveas', 'off', @ischar);
p.addParamValue('History', 'script', @ischar); % history from scripting

p.parse(ALLEEG, varargin{:});


EEGArray = p.Results.EEGArray;

if isempty(EEGArray) || any(EEGArray(:)>length(ALLEEG)) || any(EEGArray(:)<1)
    EEGArray = [1:length(ALLEEG)];
end

feval("EEG_evenlist_gui",ALLEEG(EEGArray));

if strcmpi(p.Results.Saveas,'on')
    issaveas = 1;
else
    issaveas = 0;
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
% History
%

skipfields = {'ALLEEG', 'Saveas','History'};
fn     = fieldnames(p.Results);
erpcom = sprintf( '%s = pop_eeg_eventlist_view( %s ', inputname(1), inputname(1) );
for q=1:length(fn)
    fn2com = fn{q};
    if ~ismember_bc2(fn2com, skipfields)
        fn2res = p.Results.(fn2com);
        if ~isempty(fn2res)
            if ischar(fn2res)
                if ~strcmpi(fn2res,'off') && ~strcmpi(fn2res,'no')
                    erpcom = sprintf( '%s, ''%s'', ''%s''', erpcom, fn2com, fn2res);
                end
            else
                erpcom = sprintf( '%s, ''%s'', %s', erpcom, fn2com, vect2colon(fn2res,'Repeat','on'));
            end
        end
    end
end
erpcom = sprintf( '%s );', erpcom);

%
% Save ALLEEGset from GUI
%
if issaveas
    for ii = 1:length(ALLEEG)
        [ALLEEG(ii), ~] = pop_saveset( ALLEEG(ii), 'filename',ALLEEG(ii).filename,'filepath',[ALLEEG(ii).filepath,filesep]);
    end
end


% get history from script. ALLEEG
switch shist
    case 1 % from GUI
        displayEquiComERP(erpcom);
    case 2 % from script
        for ii = 1:length(EEGArray)
            ALLEEG(EEGArray(ii)) = eegh(erpcom, ALLEEG(EEGArray(ii)));
        end
    case 3
        % implicit
    otherwise %off or none
        erpcom = '';
        return
end
return