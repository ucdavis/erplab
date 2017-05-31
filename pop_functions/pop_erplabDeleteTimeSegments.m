function [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments( EEG, varargin )
% POP_ERPLABDELETETIMESEGMENTS Deletes data segments between 2 consecutive event codes (strings or numerics) if the size of the time segment
% is greater than a user-specified threshold (in msec)
%
% FORMAT:
%
%   EEG = pop_erplabDeleteTimeSegments(EEG, timeThresholdMS, startEventcodeBufferMS, endEventcodeBufferMS, ignoreUseEventcodes, ignoreUseType, displayEEG);
%
%
% INPUT:
%
%   EEG                      - (EEG-set) continuous EEG dataset (EEGLAB's EEG struct)
%   timeThresholdMS          - (int) user-specified time threshold between event codes. 
%   startEventcodeBufferMS   - (int) time buffer around start event code, preserves this data surrounding the start event code
%   endEventcodeBufferMS     - (int) time buffer around end   event code, preserves this data surrounding the end   event code
%
%
% OPTIONAL INPUT:
%
%   ignoreUseEventcodes      - (array) event code numbers to use or ignore. (Default: [])
%   ignoreUseType            - (string) How to interpret the ignoreUseEventcode array. (Default: 'ignore')
%                              - 'ignore' - (string) look for time spec between all event codes EXCEPT for the listed eventcodes
%                              - 'use'    - (string) look for time spec between these specific event codes 
%   displayEEG               - (true/false)  - (boolean) Display a plot of the EEG when finished. (Default: false)
%
% OUTPUT:
%
%   EEG                      - (EEG-set) continuous EEG dataset (EEGLAB's EEG struct)
%
%
% EXAMPLE: 
%
%   Delete data segments when there is greater than 3000 ms (3 secs) 
%   in between any consecutive event codes. Do not ignore any eventcodes. 
%   Display EEG plot at the end
%
%   EEG = pop_erplabDeleteTimeSegments(EEG, ...
%                                   'timeThresholdMS'       , 3000,     ...
%                                   'startEventcodeBufferMS', 100,      ...
%                                   'endEventcodeBufferMS'  , 200,      ...
%                                   'ignoreUseEventcodes'   , [],       ...
%                                   'ignoreUseType'         , 'ignore', ...
%                                   'displayEEG'            , true);   
%
%
%
%
% Requirements:
%   - none
%
% See also ...
%
%
% *** This function is part of ERPLAB Toolbox ***
% Author: Jason Arita
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2009


%% Return help if given no input
if nargin < 1
    help pop_erplabDeleteTimeSegments
    return
end


%% Error Checks

% Error check: Input EEG structure
if isobject(EEG) % eegobj
    whenEEGisanObject % calls a script for showing an error window
    return
end

%% Call GUI
% When only 1 input is given the GUI is then called
if nargin==1
     % Input validation setttings
    serror = erplab_eegscanner(EEG, 'pop_erplabDeleteTimeSegments',...
        0, ... % 0 = do not accept md;
        0, ... % 0 = do not accept empty dataset;
        0, ... % 0 = do not accept epoched EEG;
        0, ... % 0 = do not accept if no event codes
        2);    % 2 = do not care if there exists an ERPLAB EVENTLIST struct

    % Quit if there is an error with the input EEG
    if serror; return; end

    %% Warn if previously created EVENTLIST detected
    if(isfield(EEG, 'EVENTLIST') && ~isempty(EEG.EVENTLIST))
        warning_txt = sprintf('Previously Created ERPLAB EVENTLIST Detected\n _________________________________________________________________________\n\n Running this function changes your event codes, and so your prior Eventlist will be deleted. \n\n Re-create a new ERPLAB Eventlist afterwards.\n _________________________________________________________________________\n');
        warndlg2(warning_txt);
    end
    
    
    % Get previous input parameters
    def  = erpworkingmemory('pop_erplabDeleteTimeSegments');
    if isempty(def); def = {}; end % if no parameters, clear DEF var
    
        

    %% Call GUI: gui_erplabDeleteTimeSegments to get the input parameters
    inputstrMat = c(def);  % GUI
    
    
    % Exit when CANCEL button is pressed
    if isempty(inputstrMat)
        outputEEG      = [];
        commandHistory = 'User selected cancel';
        return;
    end

    timeThresholdMS           = inputstrMat{1};
    startEventcodeBufferMS    = inputstrMat{2};
    endEventcodeBufferMS      = inputstrMat{3};
    ignoreUseEventcodes       = inputstrMat{4};
    ignoreUseType             = inputstrMat{5};
    displayEEG                = inputstrMat{6};

    % Save the GUI inputs to memory
    erpworkingmemory('pop_erplabDeleteTimeSegments',    ...
        { timeThresholdMS,                              ...
          startEventcodeBufferMS,                       ...
          endEventcodeBufferMS,                         ...
          ignoreUseEventcodes,                          ...
          ignoreUseType,                                ...
          displayEEG });
    

    %% New output EEG setname w/ suffix
    setnameSuffix = '_del';
    if length(EEG)==1
        EEG.setname = [EEG.setname setnameSuffix];
    end

    %% Run the pop_ command with the user input from the GUI
    [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments(EEG, ...
        'timeThresholdMS'           , timeThresholdMS,              ...
        'startEventcodeBufferMS'    , startEventcodeBufferMS,       ...
        'endEventcodeBufferMS'      , endEventcodeBufferMS,         ...
        'ignoreUseEventcodes'       , ignoreUseEventcodes,          ...
        'ignoreUseType'             , ignoreUseType,                ...
        'displayEEG'                , displayEEG,                   ...
        'History'                   , 'gui');
    
    
    return;
end


%% Parse named input parameters (vs positional input parameters)
%
% Input:
%  EEG                      - continuous EEG dataset (EEGLAB's EEG struct)
%  timeThresholdMS          - user-specified time threshold
%  startEventcodeBufferMS   - time buffer around first event code
%  endEventcodeBufferMS     - time buffer around last event code
%  ignoreUseEventcodes      - array of event code numbers to either ignore or use
%  ignoreUseType            - string describing how to interpret the ignoreUseEvencode array 
%  displayEEG               - (true|false)

inputParameters               = inputParser;
inputParameters.FunctionName  = mfilename;
inputParameters.CaseSensitive = false;

% Required parameters
inputParameters.addRequired('EEG');

% Optional named parameters (vs Positional Parameters)
inputParameters.addParameter('timeThresholdMS'          , 0);
inputParameters.addParameter('startEventcodeBufferMS'   , 0);
inputParameters.addParameter('endEventcodeBufferMS'     , 0);
inputParameters.addParameter('ignoreUseEventcodes'      , []);
inputParameters.addParameter('ignoreUseType'            , 'ignore');
inputParameters.addParameter('displayEEG'               , false);
inputParameters.addParameter('History'                  , 'script', @ischar); % history from scripting

inputParameters.parse(EEG, varargin{:});





%% Execute corresponding function
timeThresholdMS         = inputParameters.Results.timeThresholdMS;
startEventcodeBufferMS  = inputParameters.Results.startEventcodeBufferMS;
endEventcodeBufferMS    = inputParameters.Results.endEventcodeBufferMS;
ignoreUseEventcodes     = inputParameters.Results.ignoreUseEventcodes;
ignoreUseType           = inputParameters.Results.ignoreUseType;
displayEEG              = inputParameters.Results.displayEEG;


% FORMAT:
%
%   EEG = erplab_deleteTimeSegments(EEG, timeThresholdMS, startEventcodeBufferMS, endEventcodeBufferMS, ignoreEventCodes, ignoreUseType, displayEEG);
%
outputEEG = erplab_deleteTimeSegments(EEG ...
    , timeThresholdMS           ...
    , startEventcodeBufferMS    ...
    , endEventcodeBufferMS      ...
    , ignoreUseEventcodes       ...
    , ignoreUseType             ...
    , displayEEG                );












%% Generate equivalent history command
%

commandHistory  = ''; %#ok<*NASGU>
skipfields      = {'EEG', 'History'};
fn              = fieldnames(inputParameters.Results);
commandHistory         = sprintf( '%s  = pop_erplabDeleteTimeSegments( %s ', inputname(1), inputname(1));
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
                elseif(islogical(fn2res))
                    fn2resstr = num2str(fn2res);
                    fnformat = '%s';
                    commandHistory = sprintf( ['%s, ''%s'', ' fnformat], commandHistory, fn2com, fn2resstr);
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
