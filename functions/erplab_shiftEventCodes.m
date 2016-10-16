function [ outEEG ] = erplab_shiftEventCodes(inEEG, eventcodes, timeshift, varargin)
%ERPLAB_SHIFTEVENTS_EEG Shift the timing of user-specified event codes.
%
% FORMAT:
%
%    EEG = erplab_shiftEventCodes(inEEG, eventcodes, timeshift)
%
%
% INPUT:
%
%    inEEG            - EEGLAB EEG dataset
%    eventcodes       - list of event codes to shift
%    timeshift        - time in milliseconds. If timeshift is positive, the EEG event code time-values are shifted to the right (e.g. increasing delay).
%                       If timeshift is negative, the event code time-values are shifted to the left (e.g decreasing delay).
%                       If timeshift is 0, the EEG's time values are not shifted.
%
% OPTIONAL INPUT:
%
%   rounding          - 'earlier'   - Round to earlier timestamp
%                     - 'later'     - Round to later timestamp
%                     - 'nearest'   - Round to nearest timestamp   
%   displayFeedback   - 'summary'   - (default) Print summarized info to Command Window
%                     - 'detailed'  - Print event table with latency differences
%                                     to Command Window
%                     - 'both'      - Print both summarized & detailed info
%                                      to Command Window
%   displayEEG        - true/false  - Display a plot of the EEG when finished
%
%
% OUTPUT:
%
%    EEG         - EEGLAB EEG dataset with latency shift.
%
%
% EXAMPLE:
%
%    eventcodes = {22, 19};
%    timeshift  = 0.015;
%    rounding   = 'later'
%    outEEG     = erplab_shiftEventCodes(inEEG, eventcodes, timeshift, rounding);
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


%% Error check the input variables
if nargin < 1
    help erplab_shiftEventCodes
    return
elseif nargin < 3
    error('ERPLAB:erplab_shiftEventCodes: needs at least 3 inputs: EEG, eventcodes, timeshift')
elseif length(varargin) > 3   % only want 3 optional inputs at most
    error('ERPLAB:erplab_deleteTimeSegments:TooManyInputs', ...
        'requires at most 2 optional inputs');
else
    disp('Working...')
end



%% Handle optional variables
optargs = {'earlier', 'summary', false}; % Default optional inputs

% Put defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;     % if vargin is empty, optargs keep their default values. If vargin is specified then it overwrites

% Place optional args into variable names
[sample_rounding, displayFeedback, displayEEG] = optargs{:};



%% Convert time shift to seconds
timeshift = timeshift/1000;

% Convert the shift time into samples to shift
switch sample_rounding
    case 'earlier'
        % Round to nearest integer earlier, towards negative infinity
        sample_shift = floor(timeshift * inEEG.srate);  
    case 'later'
        % Round to nearest integer later, towards positive infinity
        sample_shift = ceil(timeshift * inEEG.srate);   
    case 'nearest'
        % Round to the nearest integer
        sample_shift = round(timeshift * inEEG.srate);  
    otherwise
        error('Unrecognized rounding input. Valid options are: "earlier", "later", or "nearest".');
end
            

% Convert EEG.data structure to a Matlab table
% in order to select the user-specified event code latency
eventsTable            = struct2table(inEEG.event);

% Save the originial `urevent` to a separate variable for later use when
% displaying the "Detailed Feedback" table
eventsTable.original_urevent = eventsTable.urevent;


% Convert event codes to a categorical variable type for selection
eventsTable.type       = categorical(eventsTable.type);
if(ischar(eventcodes))
    eventcodes         = categorical(cellstr(eventcodes));
else
    eventcodes             = categorical(eventcodes);
end

% Select latencies of the user-specified events and shift them
rows                   = ismember(eventsTable.type, eventcodes);
vars                   = {'latency'};
eventsTable{rows,vars} = eventsTable{rows,vars}+sample_shift;

% Save the shifted events/latencies back into the EEGLAB EEG dataset
eventsTable.type       = char(eventsTable.type);
outEEG                 = inEEG;
outEEG.event           = table2struct(eventsTable)';

% check for out of bound events / Re-sort ur events
outEEG                  = eeg_checkset(outEEG, 'eventconsistency', 'checkur');







%% Display input EEG plot to user with rejection windows marked
if displayEEG
   
    eegplotoptions = { ...
        'events',       outEEG.event,          ...
        'srate',        outEEG.srate,          ...
        'winlength',    20 };

    % If channel labels exist then display labels instead of numbers
    if ~isempty(outEEG.chanlocs)
        eegplotoptions = [ eegplotoptions {'eloc_file', outEEG.chanlocs}];
    end
    
    % Run EEGPLOT
    eegplot(outEEG.data, eegplotoptions{:});   
    
    
end


%% Detailed Feedback
if(strcmpi(displayFeedback, 'detailed') || strcmpi(displayFeedback,'both'))

    
    % Extract both the input events and output events into tables
    Original         = struct2table(inEEG.event);
    Shifted          = struct2table(outEEG.event);
        
    
    % Rename variables
    Original.Properties.VariableNames{'urevent'} = 'Original_Position';
    Original.Properties.VariableNames{'latency'} = 'Latency_Sample';
    Original.Properties.VariableNames{'type'}    = 'Event_Code';

    Shifted.Properties.VariableNames{'urevent'} = 'Shifted_Position';
    Shifted.Properties.VariableNames{'latency'} = 'Latency_Sample';
    Shifted.Properties.VariableNames{'type'}    = 'Event_Code';
    Shifted.Properties.VariableNames{'original_urevent'} = 'Original_Position';

    
    % Delete `duration` variable (since it is unused)
    try
        Original.duration = [];
        Shifted.duration  = [];
    catch
        % do nothing if `duration` does not exist
    end
    
    
    % Convert `urevent` numbers to strings (in order to `join` the tables)
    Shifted.Original_Position  = cellfun(@num2str,Shifted.Original_Position,'UniformOutput',false);
    Original.Original_Position = cellfun(@num2str,Original.Original_Position, 'UniformOutput',false);
    
    % Join the input/original events with the output/shifted events 
    Combined_table = innerjoin(Original, Shifted, ...
        'Keys', 'Original_Position');
    
    
    
    % Convert `urevent` to number
    Combined_table.Original_Position = cellfun(@str2num, Combined_table.Original_Position, 'UniformOutput', false);
    
    
    % Delete urevents with missing values (i.e. boundary events)
    rows2Delete = cell2mat(cellfun(@isempty, Combined_table.Original_Position, 'UniformOutput', false));
    Combined_table(rows2Delete,:) = [];
    
    Combined_table = sortrows(Combined_table, 'Latency_Sample_Shifted');
    
    
    % Calculate the latency differences between the input and output
    Latency_Difference         = (  ...
        Combined_table.Latency_Sample_Original - Combined_table.Latency_Sample_Shifted  );
    
    % Calculate the time differences based on the latency differences
    Time_Difference            = Latency_Difference * (1000/inEEG.srate);
    
    
    Combined_table = [ Combined_table ...
        table(Latency_Difference) ...
        table(Time_Difference)  ];
    
    % Reposition the variable columns
    Combined_table = Combined_table(:, [1 4 2 5 3 6 7 8 9]);
    
    
    
    % Write to File
    [path_erplab, ~, ~] = fileparts(which('eegplugin_erplab'));
    path_temp   = fullfile(path_erplab, 'erplab_Box');
    
    % If erplab's temp directory does not exist then create it
    if ~exist(path_temp, 'dir'); mkdir(path_temp); end;
    
    
    output_filename = ['erplab-shift_event_codes-' datestr(now, 30) '.csv'];
    output_filespec = fullfile(path_temp, output_filename);
    
    writetable(Combined_table, output_filespec, ...
        'Delimiter',   ',', ...
        'QuoteStrings', true);
    
    disp(Combined_table);
    disp(['A new shift event code file was created at <a href="matlab: open(''' output_filespec ''')">' output_filespec '</a>'])
    
end
    


%% Summarized Feedback
if(strcmpi(displayFeedback, 'summary') || strcmpi(displayFeedback, 'both'))
    numEventCodesShifted = height(eventsTable(rows,:));
    numEventCodes        = height(eventsTable);
    
    fprintf('\n\n%7d of %7d event codes shifted %+2.3f seconds\n\n' ...
        , numEventCodesShifted ...
        , numEventCodes ...
        , timeshift);
end




