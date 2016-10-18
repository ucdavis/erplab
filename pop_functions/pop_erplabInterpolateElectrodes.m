function [outputEEG, commandHistory] = pop_erplabInterpolateElectrodes( EEG, varargin )
%pop_erplabInterpolateElectrodes In EEG data, replace specific channels through interpolation with the option to ignore specific channels
%
% FORMAT
%
%    EEG = pop_erplabInterpolateElectrodes(EEG, replace_elecs, ignore_elecs)
%
% INPUT:
%
%     EEG           - EEGLAB dataset
%     replace_elecs - [integer array] indices of channels to interpolate.
%                     For instance, these channels might be bad.
%                     [chanlocs structure] channel location structure containing
%                     either locations of channels to interpolate or a full
%                     channel structure (missing channels in the current
%                     dataset are interpolated).
%     ignore_elecs  - Do not include these electrodes as input for interopolation
%     method        - [string] method used for interpolation (default is 'spherical').
%                     'invdist'/'v4' uses inverse distance on the scalp
%                     'spherical' uses superfast spherical interpolation.
% OPTIONAL INPUT:
%
%    displayFeedback  - Type of feedback to display at Command window
%                        - 'summary'   (default) Print summarized info to Command Window
%                        - 'detailed'  Print event table with latency differences
%                        - 'both'      Print both summarized & detailed info
%
% OUTPUT:
%
%    EEG               - EEGLAB EEG dataset with the specified electrodes replaced through interpolation
%
%
% EXAMPLE: Interpolate electrodes 1,2,3,4,5 while ignoring electrodes 6,7,8,9,10, 11 via spherical interpolation
%
%     replace_elecs  = [1 2 3 4 5];
%     ignore_elecs   = [6 7 8 9 10 11];
%     method         = 'spherical';
%     outputEEG      = pop_erplabInterpolateElectrodes(EEG, replace_elecs, ignore_elecs, method);
%     
%
% Requirements:
%   - EEG_CHECKSET (eeglab function)
%
% See also erplab_interpolateElectrodes.m, eeg_interp.m
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
    help pop_erplabInterpolateElectrodes
    return
end


%% Error Checks

% Error check: Input EEG structure
if isobject(EEG) % eegobj
    whenEEGisanObject % calls a script for showing an error window
    return
end

%% Call GUI
%   When only 1 input is given

if nargin==1
    try
        % Input EEG error check
        serror = erplab_eegscanner(EEG, 'pop_erplabInterpolateElectrodes',...
            0, ... % 0 = do not accept md;
            0, ... % 0 = do not accept empty dataset;
            0, ... % 0 = do not accept epoched EEG;
            0, ... % 0 = do not accept if no event codes
            2);    % 2 = do not care if there exists an ERPLAB EVENTLIST struct
        
        % Quit if there is an error with the input EEG
        if serror; return; end
        
        % Get previous input parameters
        def  = erpworkingmemory('pop_erplabInterpolateElectrodes');
        if isempty(def); def = {}; end
        
        %% Call GUI function
        inputstrMat = gui_erplabInterpolateElectrodes(def);  % GUI
        
        
        % Exit when CANCEL button is pressed
        if isempty(inputstrMat)
            outputEEG      = [];
            commandHistory = 'User selected cancel';
            return;
        end
        
        replaceChannels          = inputstrMat{1};
        ignoreChannels           = inputstrMat{2};
        interpolationMethod      = inputstrMat{3};
        displayEEG               = inputstrMat{4};
        %
        
        % Save the GUI inputs to memory
        erpworkingmemory('pop_erplabInterpolateElectrodes', ...
            {replaceChannels,    ...
            ignoreChannels,      ...
            interpolationMethod, ...
            displayEEG           });
        
        
        %% New output EEG setname w/ suffix
        setnameSuffix = '_interp';
        if length(EEG)==1
            EEG.setname = [EEG.setname setnameSuffix];
        end
    catch
        error_msg = sprintf('Error: ERPLAB GUI\n\n If the problem persists, then restart ERPLAB''s working memory in ERPLAB > Settings > ERPLAB Memory Settings > Reset ERPLAB"s Working Memory');
        error(error_msg); %#ok<SPERR>
    end
    
    %% Run the pop_ command with the user input from the GUI
    [outputEEG, commandHistory] = pop_erplabInterpolateElectrodes(EEG, ...
        'replaceChannels'    , replaceChannels,     ...
        'ignoreChannels'     , ignoreChannels,      ...
        'interpolationMethod', interpolationMethod, ...
        'displayEEG'         , displayEEG,               ...
        'History'            , 'gui');
    
    return;
    
    
    
    
end

%% Parse named input parameters (vs positional input parameters)

inputParameters               = inputParser;
inputParameters.FunctionName  = mfilename;
inputParameters.CaseSensitive = false;

% Required parameters
inputParameters.addRequired('EEG');
% Optional named parameters (vs Positional Parameters)
inputParameters.addParameter('replaceChannels'     , []);
inputParameters.addParameter('ignoreChannels'      , []);
inputParameters.addParameter('interpolationMethod' , 'spherical');
inputParameters.addParameter('DisplayFeedback'     , 'summary'); % old parameter for BoundaryString
inputParameters.addParameter('displayEEG'          , false);
inputParameters.addParameter('History'             , 'script', @ischar); % history from scripting

inputParameters.parse(EEG, varargin{:});





%% Execute corresponding function
replaceChannels     = inputParameters.Results.replaceChannels;
ignoreChannels      = inputParameters.Results.ignoreChannels;
interpolationMethod = inputParameters.Results.interpolationMethod;
displayEEG          = inputParameters.Results.displayEEG;

outputEEG = erplab_interpolateElectrodes(EEG ...
    , replaceChannels       ...
    , ignoreChannels        ...
    , interpolationMethod   ...
    , displayEEG);












%% Generate equivalent history command
%

commandHistory  = ''; %#ok<*NASGU>
skipfields      = {'EEG', 'DisplayFeedback', 'History'};
fn              = fieldnames(inputParameters.Results);
commandHistory         = sprintf( '%s  = pop_erplabInterpolateElectrodes( %s ', inputname(1), inputname(1));
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


