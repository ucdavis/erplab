function [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments( EEG, varargin )
% POP_ERPLABDELETETIMESEGMENTS Deletes data segments between if the length of time between any 2 consecutive event codes (string or number)
% is greater than a user-specified threshold (msec)
%
% FORMAT:
%
%   EEG = pop_erplabDeleteTimeSegments(EEG, 'timeThresholdMS', TIME_in_ms, 'beforeEventcodeBufferMS', TIME_in_ms, 'afterEventcodeBufferMS', TIME_in_ms);
%
%
% INPUT:
%
%   EEG                      - (EEG-set) continuous EEG dataset (EEGLAB's EEG struct)
%   timeThresholdMS          - (int) user-specified time threshold between event codes. 
%   beforeEventcodeBufferMS   - (int) time buffer before an event code in a block of trials, preserves this data before an event code
%   afterEventcodeBufferMS     - (int) time buffer after an event code in a block of trials, preserves this data after an event code
%
%
%   *Update (7/1/21): old key-pair input names (startEventcodeBufferMS &
%   endEventcodeBufferMS) will continue to work but a Warning message will
%   appear to requst use of new key-pair input names
%   (beforeEventcodeBufferMS & endEventcodeBufferMS, respectively). 
%
% OPTIONAL INPUT:
%
%   ignoreUseEventcodes      - (array) event code numbers to use or ignore. (Default: [])
%   ignoreBoundary           - (0/1) If true (1), adds boundary events
%                               to list of event codes to ignore.
%                               (Default: 0)
%   ignoreUseType            - (string) How to interpret the ignoreUseEventcode array. (Default: 'ignore')
%                              - 'ignore' - (string) look for time spec between all event codes EXCEPT for the listed eventcodes
%                              - 'use'    - (string) look for time spec between these specific event codes 
%   displayEEG               - (true/false)  - (boolean) Display a plot of the EEG when finished. (Default: false)
%
% OUTPUT:
%
%   EEG                      - (EEG-struct) continuous EEG dataset (EEGLAB's EEG struct)
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
%                                   'beforeEventcodeBufferMS', 100,      ...
%                                   'afterEventcodeBufferMS'  , 200,      ...
%                                   'ignoreUseEventcodes'   , [],       ...
%                                   'ignoreUseType'         , 'ignore', ...
%                                   'ignoreBoundary', 0, ...
%                                   'displayEEG', true);   
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
%
% Updated:
% Aaron Matthew Simmons, UCD,2021

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
    if isempty(def) 
        def = {[7000], [3000], [3000], [], ['ignore'], 0, 0}; 
    end % if no working memory, use defaults
    
        

    %% Call GUI: gui_erplabDeleteTimeSegments to get the input parameters
    inputstrMat = gui_erplabDeleteTimeSegments(def);  % GUI
    
    
    % Exit when CANCEL button is pressed
    if isempty(inputstrMat)
        outputEEG      = [];
        commandHistory = 'User selected cancel';
        return;
    end

    timeThresholdMS           = inputstrMat{1};
    beforeEventcodeBufferMS   = inputstrMat{2}; 
    afterEventcodeBufferMS    = inputstrMat{3};
    ignoreUseEventcodes       = inputstrMat{4};
    ignoreUseType             = inputstrMat{5};
    displayEEG                = inputstrMat{6};
    ignoreBoundary            = inputstrMat{7}; 

    % Save the GUI inputs to memory
    erpworkingmemory('pop_erplabDeleteTimeSegments',    ...
        { timeThresholdMS,                              ...
          beforeEventcodeBufferMS,                       ...
          afterEventcodeBufferMS,                         ...
          ignoreUseEventcodes,                          ...
          ignoreUseType,                                ...
          displayEEG,                                   ...
          ignoreBoundary});
    

    %% New output EEG setname w/ suffix
    setnameSuffix = '_del';
    if length(EEG)==1
        EEG.setname = [EEG.setname setnameSuffix];
    end

    %% Run the pop_ command with the user input from the GUI
    [outputEEG, commandHistory] = pop_erplabDeleteTimeSegments(EEG, ...
        'timeThresholdMS'           , timeThresholdMS,              ...
        'beforeEventcodeBufferMS'   , beforeEventcodeBufferMS,       ...
        'afterEventcodeBufferMS'    , afterEventcodeBufferMS,         ...
        'ignoreUseEventcodes'       , ignoreUseEventcodes,          ...
        'ignoreUseType'             , ignoreUseType,                ...
        'displayEEG'                , displayEEG,                   ...
        'ignoreBoundary'            , ignoreBoundary,               ...
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
inputParameters.KeepUnmatched = true; 
% Required parameters
inputParameters.addRequired('EEG');

% Optional named parameters (vs Positional Parameters)


inputParameters.addParameter('timeThresholdMS'          , 0);
inputParameters.addParameter('beforeEventcodeBufferMS'   , 0);
inputParameters.addParameter('afterEventcodeBufferMS'     , 0);
% inputParameters.addParameter('startEventcodeBufferMS', 0);
% inputParameters.addParameter('endEventcodeBufferMS', 0);
inputParameters.addParameter('ignoreUseEventcodes'      , []);
inputParameters.addParameter('ignoreUseType'            , 'ignore');
inputParameters.addParameter('displayEEG'               , false);
inputParameters.addParameter('ignoreBoundary'           , false);
inputParameters.addParameter('History'                  , 'script', @ischar); % history from scripting


inputParameters.parse(EEG, varargin{:});


%% Execute corresponding function
timeThresholdMS         = inputParameters.Results.timeThresholdMS;

% Keeps inputs backwards compatible(<v8.24) when previous inputs called
% ("start/end"EventcodeBufferMS) -AMS
if ~isempty(fieldnames(inputParameters.Unmatched))
    beforeEventcodeBufferMS = inputParameters.Unmatched.startEventcodeBufferMS;
    afterEventcodeBufferMS = inputParameters.Unmatched.endEventcodeBufferMS; 
    warning('ERPLAB:Warning', 'Please use update input argument names (beforeEventcodeBufferMS & afterEventcodeBufferMS will work but are outdated)'); 
    
else
    beforeEventcodeBufferMS  = inputParameters.Results.beforeEventcodeBufferMS;
    afterEventcodeBufferMS    = inputParameters.Results.afterEventcodeBufferMS;
end
ignoreUseEventcodes     = inputParameters.Results.ignoreUseEventcodes;
ignoreUseType           = inputParameters.Results.ignoreUseType;
displayEEG              = inputParameters.Results.displayEEG;
ignoreBoundary          = inputParameters.Results.ignoreBoundary; 


% FORMAT:
%
%   EEG = erplab_deleteTimeSegments(EEG, timeThresholdMS, startEventcodeBufferMS, endEventcodeBufferMS, ignoreEventCodes, ignoreUseType, displayEEG);
%
outputEEG = erplab_deleteTimeSegments(EEG ...
    , timeThresholdMS           ...
    , beforeEventcodeBufferMS    ...
    , afterEventcodeBufferMS      ...
    , ignoreUseEventcodes       ...
    , ignoreUseType             ...
    , ignoreBoundary            ...
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
