function [EEG, commandHistory] = pop_erplabShiftEventTime( EEG, varargin )
%POP_ERPLABSHIFTEVENTTIME In EEG data, shift the timing of user-specified event codes.
%
% FORMAT
%
%    EEG = pop_erplabShiftEventTime(inEEG, eventcodes, timeshift)
%
% INPUT:
%
%    EEG              EEGLAB EEG dataset
%    eventcodes       list of event codes to shift
%    timeshift        time in sec. If timeshift is positive, the EEG event code time-values are shifted to the right (e.g. increasing delay).
%                       - If timeshift is negative, the event code time-values are shifted to the left (e.g decreasing delay).
%                       - If timeshift is 0, the EEG's time values are not shifted.
%    rounding         Type of rounding to use
%                       - 'nearest'    (default) Round to the nearest integer          
%                       - 'floor'      Round to nearest ingtowards positive infinity
%                       - 'ceiling'    Round to nearest integer towards negative infinity
% 
% OPTIONAL INPUT:
%
%    displayFeedback  Type of feedback to display at Command window
%                        - 'summary'   (default) Print summarized info to Command Window
%                        - 'detailed'  Print event table with latency differences
%                        - 'both'      Print both summarized & detailed info
%
% OUTPUT:
%
%    EEG               EEGLAB EEG dataset with latency shift.
%
%
% EXAMPLE:
%
%     eventcodes = {'22', '19'};
%     timeshift  = 0.015;
%     rounding   = 'floor';
%     outputEEG  = erplabShiftEventTime(inputEEG, eventcodes, timeshift, rounding);
%     
%
% Requirements:
%   - EEG_CHECKSET (eeglab function)
%
% See also eegtimeshift.m erptimeshift.m
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Jason Arita
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009

commandHistory = '';

% Return help if given no input
if nargin < 1
    help pop_erplabShiftEventTime
    return
end


% Input testing
if isobject(EEG) % eegobj
    whenEEGisanObject % calls a script for showing an error window
    return
end

%% Call GUI
% When only 1 input is given the GUI is then called
if nargin==1
    
    % Input EEG error check
    serror = erplab_eegscanner(EEG, 'pop_erplabShiftEventTime',...
        0, ... % 0 = do not accept md;
        0, ... % 0 = do not accept empty dataset;
        0, ... % 0 = do not accept epoched EEG;
        0, ... % 0 = do not accept if no event codes
        2);    % 2 = do not care if there exists an ERPLAB EVENTLIST struct
    
    % Quit if there is an error with the input EEG
    if serror
        return
    end
    
    %     % Get previous input parameters
    def  = erpworkingmemory('pop_erplabShiftEventTime');
    if isempty(def)
        def = {};
    end
    
    
    % Call GUI
    inputstrMat = erplabShiftEventTimeGUI(def);  % GUI
    
    % Exit when CANCEL button is pressed
    if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
        commandHistory = 'User selected cancel';
        return;
    end
    
    eventcodes          = inputstrMat{1};
    timeshift           = inputstrMat{2};
    rounding            = inputstrMat{3};
    %     displayFeedback     = inputstrMat{4};
    %
    %     erpworkingmemory('pop_erplabShiftEventTime', ...
    %         {eventcodes, timeshift, rounding, displayFeedback});
    %
    
    % New output EEG name
    if length(EEG)==1
        EEG.setname = [EEG.setname '_eventTimeshifted'];
    end
    
    
    [EEG, commandHistory] = pop_erplabShiftEventTime(EEG, ...
        'Eventcodes'    , eventcodes,  ...
        'Timeshift'     , timeshift,   ...
        'Rounding'      , rounding,    ...
        'History'       , 'gui');
    
    
    return
end




%% Parse named input parameters (vs positional input parameters)

inputParameters               = inputParser;
inputParameters.FunctionName  = mfilename;
inputParameters.CaseSensitive = false;

% Required parameters
inputParameters.addRequired('EEG');
% Optional named parameters (vs Positional Parameters)
inputParameters.addParameter('Eventcodes'         , []);
inputParameters.addParameter('Timeshift'          , 0);
inputParameters.addParameter('Rounding'           , 'nearest');
inputParameters.addParameter('DisplayFeedback'    , 'summary'); % old parameter for BoundaryString
inputParameters.addParameter('History'            , 'script', @ischar); % history from scripting

inputParameters.parse(EEG, varargin{:});




















%% Generate equivalent command (for history)
%
skipfields  = {'EEG', 'DisplayFeedback', 'History'};
fn          = fieldnames(inputParameters.Results);
commandHistory         = sprintf( '%s  = pop_erplabShiftEventTime( %s ', inputname(1), inputname(1));
for q=1:length(fn)
    fn2com = fn{q}; % get fieldname
    if ~ismember(fn2com, skipfields)
        fn2res = inputParameters.Results.(fn2com); % get content of current field
        if ~isempty(fn2res)
            if iscell(fn2res)
                commandHistory = sprintf( '%s, ''%s'', {', commandHistory, fn2com);
                for c=1:length(fn2res)
                    getcont = fn2res{c};
                    if ischar(getcont)
                        fnformat = '''%s''';
                    else
                        fnformat = '%s';
                        getcont = num2str(getcont);
                    end
                    commandHistory = sprintf( [ '%s ' fnformat], commandHistory, getcont);
                end
                commandHistory = sprintf( '%s }', commandHistory);
            else
                if ischar(fn2res)
                    if ~strcmpi(fn2res,'off')
                        commandHistory = sprintf( '%s, ''%s'', ''%s''', commandHistory, fn2com, fn2res);
                    end
                else
                    %if iscell(fn2res)
                    %        fn2resstr = vect2colon(cell2mat(fn2res), 'Sort','on');
                    %        fnformat = '{%s}';
                    %else
                    fn2resstr = vect2colon(fn2res, 'Sort','on');
                    fnformat = '%s';
                    %end
                    commandHistory = sprintf( ['%s, ''%s'', ' fnformat], commandHistory, fn2com, fn2resstr);
                end
            end
        end
    end
end
commandHistory = sprintf( '%s );', commandHistory);

% get history from script. EEG
switch inputParameters.Results.History
    case 'gui' % from GUI
        commandHistory = sprintf('%s %% GUI: %s', commandHistory, datestr(now));
        %fprintf('%%Equivalent command:\n%s\n\n', commandHistory);
        displayEquiComERP(commandHistory);
    case 'script' % from script
        EEG = erphistory(EEG, [], commandHistory, 1);
    case 'implicit'
        % implicit
    otherwise %off or none
        commandHistory = '';
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

end