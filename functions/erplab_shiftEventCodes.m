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
%                     - 'detailed'  - Print event table with sample_num differences
%                                     to Command Window
%                     - 'both'      - Print both summarized & detailed info
%                                      to Command Window
%   displayEEG        - true/false  - Display a plot of the EEG when finished
%
%
% OUTPUT:
%
%    EEG         - EEGLAB EEG dataset with sample_num shift.
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
elseif length(varargin) > 4   % only want 4 optional inputs at most
    error('ERPLAB:erplab_deleteTimeSegments:TooManyInputs', ...
        'requires at most 4 optional inputs');
else
    disp('Working...')
end

% Error check input TIMESHIFT variable
assert(isnumeric(timeshift), 'Error: TIMESHIFT input variable must be numeric');
assert(length(timeshift) == 1, 'Error: TIMESHIFT input variable must be a single number');




%% Handle optional variables
optargs = {'earlier', 'summary', false}; % Default optional inputs

% Put defaults into the valuesToUse cell array,
% and overwrite the ones specified in varargin.
optargs(1:length(varargin)) = varargin;     % if vargin is empty, optargs keep their default values. If vargin is specified then it overwrites

% Place optional args into variable names
[sample_rounding, displayFeedback, displayEEG] = optargs{:};

% %% Warn if previously created EVENTLIST detected
% if(isfield(inEEG, 'EVENTLIST') && ~isempty(inEEG.EVENTLIST) && warningPopup)
%     warning_txt = sprintf('Previously Created ERPLAB EVENTLIST Detected\n _________________________________________________________________________\n\n This function changes your event codes, thus your prior eventlist is now obsolete and WILL BE DELETED. \n\n Remember to re-create a new ERPLAB EVENTLIST\n _________________________________________________________________________\n');
%     warndlg2(warning_txt);
% end

%% Convert time shift to seconds
timeshift = timeshift/1000;

%% Convert the shift time into samples to shift
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
            

%% Convert EEG.data structure to a Matlab table
% in order to select the user-specified event code sample_num
table_events            = struct2table(inEEG.event);


%% Clean/standardize the events table

% Convert variable names to standardized variable names
if(ismember('urevent', table_events.Properties.VariableNames))
    table_events.Properties.VariableNames{'urevent'}    = 'order_num';
end

% This is a special case when the `urevent` variable/column does not
% exist and instead is named `item`. This occurs when the EEG dataset
% has gone through `Create EVENTLIST`.
if(ismember('item', table_events.Properties.VariableNames))
    table_events.Properties.VariableNames{'item'}       = 'order_num';
end

% Special case where 'urevent', 'item', 'order_num' fields do not exist in
% the inEEG.event structure
if(~ismember('order_num', table_events.Properties.VariableNames))
    order_num    = array2table([1:size(table_events)]', ...
        'VariableNames', {'order_num'});
    table_events = [table_events, order_num];
end

if(ismember('latency', table_events.Properties.VariableNames))
    table_events.Properties.VariableNames{'latency'}    = 'sample_num';
end


% Convert order number to numeric, if it is in a cell
% First, replace boundary order_num (i.e. empty arrays) with NaN
if(iscell(table_events.order_num))
    table_events.order_num(cellfun('isempty', table_events.order_num)) = {NaN};
    table_events.order_num = cell2mat(table_events.order_num);
end


%% Save the original `order_num` 
% This is to a separate variable for later use when displaying the 
% "Detailed Feedback" table
table_events.original_order_num  = table_events.order_num;
table_events.original_sample_num = table_events.sample_num;



table_events_original = table_events;



%% Convert event codes to a categorical variable type for selection
table_events.type       = categorical(table_events.type);
if(ischar(eventcodes))
    eventcodes         = categorical(cellstr(eventcodes));
else
    eventcodes         = categorical(eventcodes);
end





%% Select latencies of the user-specified events and shift them
filter_events = ismember(table_events.type, eventcodes);
vars          = {'sample_num'};
table_events{filter_events,vars} = table_events{filter_events,vars} + sample_shift;




%% Create table of shifted events
tableShiftedEvents = table_events(filter_events,:);
tableShiftedEvents = sortrows(tableShiftedEvents, 'original_sample_num');
numEventsShifted   = height(tableShiftedEvents);



%% Create table of boundary events
codesBoundary         = {'boundary', '-99'};
rowsBoundary          = ismember(table_events.type, codesBoundary);
tableBoundary         = table_events(rowsBoundary, {'type', 'sample_num'});


% Add in boundary codes to the edges of the complete dataset
boundary_edges = {...
    'type'    , 'sample_num';
    'boundary', 0;
    'boundary', inEEG.pnts};
tableBoundaryEdges = cell2table(boundary_edges(2:end,:));
tableBoundaryEdges.Properties.VariableNames = boundary_edges(1,:);

if(isempty(tableBoundary))
    tableBoundary = tableBoundaryEdges;
else
    % Sort the table of boundary events by their sample_num (i.e. column 2)
    % in order to check if there exists boundary-codes at the start/end of
    % the data
    tableBoundary  = sortrows(tableBoundary, 2);

    % If no boundary-code is detected at that start (i.e. sample_num 0), then
    % add in a boundary-code
    if(tableBoundary.sample_num(1) ~= 0)
        tableBoundary = [tableBoundaryEdges(1,:); tableBoundary];
    end
    
    % If no boundary-code exists at the end (i.e. sample_num inEEG.pnts), then
    % add in a boundary code at the end
    if(tableBoundary.sample_num(end) ~= inEEG.pnts)
        tableBoundary = [tableBoundary; tableBoundaryEdges(2,:)];
    end
end

tableBoundary     = sortrows(tableBoundary, 'sample_num');
numBoundaryEvents = height(tableBoundary);



%% Delete shifted-events that cross boundary-events
[nRows_total, ~]        = size(tableShiftedEvents);
deleteOriginalorder_numArray = {};

for iRow_shifteventcode = 1:nRows_total
    
    sample_num_original = tableShiftedEvents{iRow_shifteventcode, 'original_sample_num'};
    sample_num_shifted  = tableShiftedEvents{iRow_shifteventcode, 'sample_num'};
    
    
    % Find nearest boundary code in the direction of the shift
    if(sign(sample_shift) > 0)
        % positive shift => find nearest boundary code GREATER than the
        %                   original sample_num
        sample_num_boundary = tableBoundary{tableBoundary.sample_num > sample_num_original, 'sample_num'};
        sample_num_boundary = sample_num_boundary(1);
    else
        % negative shift => find nearest boundary code LESSER than the
        %                   original sample_num
        sample_num_boundary = tableBoundary{tableBoundary.sample_num < sample_num_original, 'sample_num'};
        sample_num_boundary = sample_num_boundary(1);
    end
    
    
    
    if((sample_num_boundary > min([sample_num_original, sample_num_shifted])) && ...
            (sample_num_boundary < max([sample_num_original, sample_num_shifted])) )
        
        % Get the order_num code in order to later delete them
        deleteOriginalorder_num      = tableShiftedEvents{iRow_shifteventcode, 'original_order_num'};
        deleteOriginalorder_numArray = [deleteOriginalorder_numArray; num2str(deleteOriginalorder_num)]; %#ok<AGROW>
        
    end
end


%% Ensure each `order_num` is unique for indexing
if(iscell(tableShiftedEvents.order_num))
    order_nums = cellfun(@num2str, tableShiftedEvents.order_num, ...
        'UniformOutput', false);
elseif(isnumeric(tableShiftedEvents.order_num))
    order_nums = arrayfun(@num2str, tableShiftedEvents.order_num, ...
        'UniformOutput', false);
end
assert(numel(unique(order_nums)) == numel(order_nums));


% Filter out the events to delete and delete them
if(isnumeric(table_events.original_order_num))
    order_nums_original = arrayfun(@num2str, table_events.original_order_num, ...
        'UniformOutput', false);
elseif(iscell(table_events.original_order_num))
    order_nums_original = cellfun(@num2str, table_events.original_order_num, ...
        'UniformOutput', false);
end
    

% Find events to delete (i.e. that crossed a boundary) and then delete them
filter_events2delete = ismember(order_nums_original, deleteOriginalorder_numArray);
table_events(filter_events2delete, :) = [];

% Count the number of event-codes that were deleted
numEventsDeleted = size(deleteOriginalorder_numArray, 1);









%% Printing Detailed Feedback

if(strcmpi(displayFeedback, 'detailed') || strcmpi(displayFeedback,'both'))

    
    % Extract both the input events and output events into tables
    table_events_display          = table_events;
        
    
    % Rename variables
    table_events_display.Properties.VariableNames{'type'} = 'event_code';
    
    % Delete `duration` variable (since it is unused)
    try
        table_events_display.duration           = [];
        table_events_display.order_num          = [];
        table_events_display.original_order_num = [];
    catch
        % do nothing if `duration` does not exist
    end

    % Convert and rename (shifted) sample number to time position
    table_events_display.Properties.VariableNames{'sample_num'} = 'shifted_time_position';
    table_events_display.shifted_time_position = table_events_display.shifted_time_position * (1000/inEEG.srate);
    
    % Convert and rename original sample number to original time position
    table_events_display.Properties.VariableNames{'original_sample_num'} = 'original_time_position';
    table_events_display.original_time_position = table_events_display.original_time_position * (1000/inEEG.srate);
    
            
    % Calculate the sample_num differences between the input and output
    time_difference_ms         = table_events_display.shifted_time_position - table_events_display.original_time_position;

    table_events_display = [ table_events_display ...
        table(time_difference_ms)  ];
    
    %% Setup table for printing to command window
    % Filter & Reposition the variable columns for display
    Display_vars = {...
        'event_code'   , ...
        'original_time_position'    , ...
        'shifted_time_position' , ...
        'time_difference_ms'    };
    
    Display_table = table( ...
        table_events_display{:, Display_vars{1}}, ...
        table_events_display{:, Display_vars{2}}, ...
        table_events_display{:, Display_vars{3}}, ...
        table_events_display{:, Display_vars{4}}, ...
        'VariableNames', Display_vars);
    
    %% Write to File
    [path_erplab, ~, ~] = fileparts(which('eegplugin_erplab'));
    path_temp          = fullfile(path_erplab, 'erplab_Box');
    
    % If erplab's temp directory does not exist then create it
    if ~exist(path_temp, 'dir'); mkdir(path_temp); end;
    
    output_filename     = ['erplab-shift_event_codes-' datestr(now, 30) '.csv'];
    output_filespec     = fullfile(path_temp, output_filename);
    
    try
        writetable(Display_table, output_filespec, ...
            'Delimiter',   ',', ...
            'QuoteStrings', true);
    catch
        writetable(Display_table, output_filespec, ...
            'Delimiter',   ',');
    end
    
    %% Display to command line    
    fprintf('A CSV-file containing all shift information was created at <a href="matlab: open( ''%s'' )">%s </a>\n\n', output_filespec, output_filespec)
    fprintf('For your information, here is a table of the first 10 events in your eventlist:\n');
    display(Display_table(1:10,:));
    
end
    


%% Print Summarized Feedback

if(strcmpi(displayFeedback, 'summary') || strcmpi(displayFeedback, 'both'))
    numEventCodes        = size(inEEG.event, 2);
    
    fprintf('\n\n\t%9d event codes shifted %+2.3f milliseconds\n', ...
        numEventsShifted, ...
        timeshift*1000);
    fprintf('\t%9d total event codes\n', ...
        numEventCodes);
    fprintf('\t%9d boundary events were detected\n', ...
        numBoundaryEvents);
    fprintf('\t%9d event codes that were shifted were subsequently deleted because they crossed a boundary\n\n', ...
        numEventsDeleted);
end






%% Save the shifted events/latencies back into the EEGLAB EEG dataset

% Convert order_num from numeric back to cell 
table_events.order_num = num2cell(table_events.order_num);

% Replace boundary order_num (i.e. NaNs) with {[]}
table_events.order_num(cellfun(@isnan, table_events.order_num)) = {[]};

% Convert table variable names to standardized variable names
if(ismember('order_num', table_events.Properties.VariableNames))
    table_events.Properties.VariableNames{'order_num'}    = 'urevent';
end

if(ismember('sample_num', table_events.Properties.VariableNames))
    table_events.Properties.VariableNames{'sample_num'}    = 'latency';
end

table_events.type       = char(table_events.type);
outEEG                 = inEEG;
outEEG.event           = table2struct(table_events)';
outEEG                 = eeg_checkset(outEEG, 'eventconsistency', 'checkur');

%% Warn if previously created EVENTLIST detected

if(isfield(outEEG, 'EVENTLIST') && ~isempty(outEEG.EVENTLIST))
    warning_txt = sprintf('Previously Created ERPLAB EVENTLIST Detected & Deleted \n _________________________________________________________________________\n\n\tThis function changes the timing of your event codes, thus your prior eventlist is now obsolete and WILL BE DELETED. \n\n\tRemember to re-create a new ERPLAB EVENTLIST\n _________________________________________________________________________\n');
    warning(warning_txt); %#ok<SPWRN>
    
    % DELETE PRIOR EVENTLIST
    outEEG.EVENTLIST = [];
end

%% Display input EEG plot to user with rejection windows marked
if displayEEG
   
    eegplotoptions = {               ...
        'events'   , outEEG.event,   ...
        'srate'    , outEEG.srate,   ...
        'winlength', 20              };

    % If channel labels exist then display labels instead of numbers
    if ~isempty(outEEG.chanlocs)
        eegplotoptions = [ eegplotoptions {'eloc_file', outEEG.chanlocs}];
    end
    
    % Run EEGPLOT
    eegplot(outEEG.data, eegplotoptions{:});   
    
end

