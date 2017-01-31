function [outputEEG, commandHistory] = pop_erplabSelectChannelInterpolation( EEG, varargin )
%pop_erplabSelectChannelInterpolation In EEG data, replace specific channels through interpolation with the option to ignore specific channels
%
% FORMAT
%
%    EEG = pop_erplabSelectChannelInterpolation(inEEG, replaceChannels, ignoreChannels)
%
% INPUT:
%
%    EEG                EEGLAB EEG dataset
%    replaceChannels       list of event codes to shift
%    ignoreChannels        time in sec. If ignoreChannels is positive, the EEG event code time-values are shifted to the right (e.g. increasing delay).
%                       - If ignoreChannels is negative, the event code time-values are shifted to the left (e.g decreasing delay).
%                       - If ignoreChannels is 0, the EEG's time values are not shifted.
%    interpolationMethod         Type of interpolationMethod to use
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
%    EEG               EEGLAB EEG dataset with the specified channels replaced through interpolation
%
%
% EXAMPLE:
%
%     replaceChannels       = {'22', '19'};
%     ignoreChannels        = 0.015;
%     interpolationMethod   = 'floor';
%     outputEEG             = pop_erplabSelectChannelInterpolation(EEG, replaceChannels, ignoreChannels, interpolationMethod);
%     
%
% Requirements:
%   - EEG_CHECKSET (eeglab function)
%
% See also eegignoreChannels.m erpignoreChannels.m
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
    help pop_erplabSelectChannelInterpolation
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
    
     % Input EEG error check
    serror = erplab_eegscanner(EEG, 'pop_erplabSelectChannelInterpolation',...
        0, ... % 0 = do not accept md;
        0, ... % 0 = do not accept empty dataset;
        0, ... % 0 = do not accept epoched EEG;
        0, ... % 0 = do not accept if no event codes
        2);    % 2 = do not care if there exists an ERPLAB EVENTLIST struct
    
    % Quit if there is an error with the input EEG
    if serror; return; end
    
    % Get previous input parameters
    def  = erpworkingmemory('pop_erplabSelectChannelInterpolation');
    if isempty(def); def = {}; end
    
    % Call GUI function 
    inputstrMat = gui_erplab_selectiveEegInterpolation(def);  % GUI
    
    % Exit when CANCEL button is pressed
    if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
        commandHistory = 'User selected cancel';
        return;
    end
    
    replaceChannels          = inputstrMat{1};
    ignoreChannels           = inputstrMat{2};
    interpolationMethod      = inputstrMat{3};
%     displayFeedback          = inputstrMat{4};
    %
    
    % Save the GUI inputs to memory
    erpworkingmemory('pop_erplabSelectChannelInterpolation', ...
        {replaceChannels,    ...
        ignoreChannels,      ...
        interpolationMethod});
%         displayFeedback });
    
    
    % New output EEG set name
    if length(EEG)==1
        EEG.setname = [EEG.setname '_channelInterpolated'];
    end
    
    
    
    [outputEEG, commandHistory] = pop_erplabSelectChannelInterpolation(EEG, ...
        'replaceChannels'    , replaceChannels,     ...
        'ignoreChannels'     , ignoreChannels,      ...
        'interpolationMethod', interpolationMethod, ...
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
inputParameters.addParameter('History'             , 'script', @ischar); % history from scripting

inputParameters.parse(EEG, varargin{:});





%% Execute corresponding function
replaceChannels     = inputParameters.Results.replaceChannels;
ignoreChannels      = inputParameters.Results.ignoreChannels;
interpolationMethod = inputParameters.Results.interpolationMethod;

outputEEG = erplab_selectiveEegInterpolation(EEG ...
    , replaceChannels       ...
    , ignoreChannels        ...
    , interpolationMethod   );












%% Generate equivalent history command
%

commandHistory  = ''; %#ok<*NASGU>
skipfields      = {'EEG', 'DisplayFeedback', 'History'};
fn              = fieldnames(inputParameters.Results);
commandHistory         = sprintf( '%s  = pop_erplabSelectChannelInterpolation( %s ', inputname(1), inputname(1));
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




% function runGUI(EEG) 
%  % Input EEG error check
%     serror = erplab_eegscanner(EEG, 'pop_erplabSelectChannelInterpolation',...
%         0, ... % 0 = do not accept md;
%         0, ... % 0 = do not accept empty dataset;
%         0, ... % 0 = do not accept epoched EEG;
%         0, ... % 0 = do not accept if no event codes
%         2);    % 2 = do not care if there exists an ERPLAB EVENTLIST struct
%     
%     % Quit if there is an error with the input EEG
%     if serror
%         return
%     end
%     
%     % Get previous input parameters
%     def  = erpworkingmemory('pop_erplabSelectChannelInterpolation');
%     if isempty(def)
%         def = {};
%     end
%     
%     % Call GUI
%     inputstrMat = gui_erplab_selectiveEegInterpolation(def);  % GUI
%     
%     % Exit when CANCEL button is pressed
%     if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
%         commandHistory = 'User selected cancel';
%         return;
%     end
%     
%     replaceChannels          = inputstrMat{1};
%     ignoreChannels           = inputstrMat{2};
%     interpolationMethod      = inputstrMat{3};
%     %     displayFeedback     = inputstrMat{4};
%     %
%     %     erpworkingmemory('pop_erplabSelectChannelInterpolation', ...
%     %         {replaceChannels, ignoreChannels, interpolationMethod, displayFeedback});
%     %
%     
%     % New output EEG name
%     if length(EEG)==1
%         EEG.setname = [EEG.setname '_interpolated'];
%     end
%     
%     
%     
%     [EEG, commandHistory] = pop_erplabSelectChannelInterpolation(EEG, ...
%         'replaceChannels'    , replaceChannels,  ...
%         'ignoreChannels'     , ignoreChannels,   ...
%         'interpolationMethod', interpolationMethod,    ...
%         'History'            , 'gui');
%     
%     
%     return
% end