function [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments( EEG, varargin )
% Deletes data segments between 2 event codes if the size of the segment
% is greater than a user-specified threshold (in msec)
%
% USAGE
%
% EEG = erplab_deleteTimeSegments(EEG, inputMaxDistanceMS, inputStartPeriodBufferMS, inputEndPeriodBufferMS, ignoreEventCodes);
%
%
% Input:
%
%  EEG                      - continuous EEG dataset (EEGLAB's EEG struct)
%  maxDistanceMS            - user-specified time threshold
%  startEventCodeBufferMS   - time buffer around first event code
%  endEventCodeBufferMS     - time buffer around end event code
%
% Optional
%  ignoreEventCodes         - array of event code numbers to ignore
%  displayEEGPLOTGUI        - (true|false)
%
% Output:
%
% EEG                       - continuous EEG dataset (EEGLAB's EEG struct)
%
%
% Example: Delete segment of data between any two event codes when it is
%          longer than 3000 ms (3 secs).
%
%      EEG = erplab_deleteTimeSegments(EEG, 3000, 100, 200, []);
%
%
% Requirements:
%   -
%
% See also
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
    inputstrMat = gui_erplabDeleteTimeSegments(def);  % GUI
    
    
    % Exit when CANCEL button is pressed
    if isempty(inputstrMat)
        outputEEG      = [];
        commandHistory = 'User selected cancel';
        return;
    end

    maxDistanceMS             = inputstrMat{1};
    startEventCodeBufferMS    = inputstrMat{2};
    endEventCodeBufferMS      = inputstrMat{3};
    ignoreEventCodes          = inputstrMat{4}; 
    displayEEG                = inputstrMat{5};

    % Save the GUI inputs to memory
    erpworkingmemory('pop_erplabDeleteTimeSegments',    ...
        { maxDistanceMS,                                ...
          startEventCodeBufferMS,                       ...
          endEventCodeBufferMS,                         ...
          ignoreEventCodes,                             ...
          displayEEG });
    

    %% New output EEG setname w/ suffix
    setnameSuffix = '_del';
    if length(EEG)==1
        EEG.setname = [EEG.setname setnameSuffix];
    end

    %% Run the pop_ command with the user input from the GUI
    [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments(EEG,   ...
        'maxDistanceMS'             , maxDistanceMS,            ...
        'startEventCodeBufferMS'    , startEventCodeBufferMS,   ...
        'endEventCodeBufferMS'      , endEventCodeBufferMS,     ...
        'ignoreEventCodes'          , ignoreEventCodes,         ...
        'displayEEG'                , displayEEG,               ...
        'History'                   , 'gui');
    
    
    return;
end


%% Parse named input parameters (vs positional input parameters)
%
% Input:
%  EEG                      - continuous EEG dataset (EEGLAB's EEG struct)
%  maxDistanceMS            - user-specified time threshold
%  startEventCodeBufferMS   - time buffer around first event code
%  endEventCodeBufferMS     - time buffer around last event code
%  ignoreEventCodes         - array of event code numbers to ignore
%  displayEEGPLOTGUI        - (true|false)

inputParameters               = inputParser;
inputParameters.FunctionName  = mfilename;
inputParameters.CaseSensitive = false;

% Required parameters
inputParameters.addRequired('EEG');

% Optional named parameters (vs Positional Parameters)
inputParameters.addParameter('maxDistanceMS'            , 0);
inputParameters.addParameter('startEventCodeBufferMS'   , 0);
inputParameters.addParameter('endEventCodeBufferMS'     , 0);
inputParameters.addParameter('ignoreEventCodes'         , []);
inputParameters.addParameter('displayEEG'               , false);
inputParameters.addParameter('History'                  , 'script', @ischar); % history from scripting

inputParameters.parse(EEG, varargin{:});





%% Execute corresponding function
maxDistanceMS           = inputParameters.Results.maxDistanceMS;
startEventCodeBufferMS  = inputParameters.Results.startEventCodeBufferMS;
endEventCodeBufferMS    = inputParameters.Results.endEventCodeBufferMS;
ignoreEventCodes        = inputParameters.Results.ignoreEventCodes;
displayEEG              = inputParameters.Results.displayEEG;

outputEEG = erplab_deleteTimeSegments(EEG ...
    , maxDistanceMS             ...
    , startEventCodeBufferMS    ...
    , endEventCodeBufferMS      ...
    , ignoreEventCodes          ...
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
