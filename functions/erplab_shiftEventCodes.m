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
% in order to select the user-specified event code latency
eventsTable            = struct2table(inEEG.event);


%% Save the originial `urevent` to a separate variable for later use when
% displaying the "Detailed Feedback" table
try
    eventsTable.original_urevent = eventsTable.urevent;
    eventsTable.original_latency = eventsTable.latency;
catch
    eventsTable.original_urevent = eventsTable.item;
    eventsTable.original_latency = eventsTable.latency;
end

%% Convert event codes to a categorical variable type for selection
eventsTable.type       = categorical(eventsTable.type);
if(ischar(eventcodes))
    eventcodes         = categorical(cellstr(eventcodes));
else
    eventcodes         = categorical(eventcodes);
end



%% Select latencies of the user-specified events and shift them
filter_events = ismember(eventsTable.type, eventcodes);
vars          = {'latency'};
eventsTable{filter_events,vars} = eventsTable{filter_events,vars} + sample_shift;




%% Create table of shifted events
tableShiftedEvents = eventsTable(filter_events,:);
tableShiftedEvents = sortrows(tableShiftedEvents, 'original_latency');
numEventsShifted   = height(tableShiftedEvents);



%% Create table of boundary events
codesBoundary         = {'boundary', '-99'};
rowsBoundary          = ismember(eventsTable.type, codesBoundary);
tableBoundary         = eventsTable(rowsBoundary, :);


% Add in boundary codes to the edges of the complete dataset
boundary_edges = {...
    'type','latency','urevent','duration','original_urevent','original_latency';
    'boundary',0,[],NaN,[],0;
    'boundary',inEEG.pnts,[],NaN,[],inEEG.pnts};
tableBoundaryEdges = cell2table(boundary_edges(2:end,:));
tableBoundaryEdges.Properties.VariableNames = boundary_edges(1,:);

if(isempty(tableBoundary))
    tableBoundary = tableBoundaryEdges;
else
    % Sort the table of boundary events by their latency (i.e. column 2)
    % in order to check if there exists boundary-codes at the start/end of
    % the data
    tableBoundary  = sortrows(tableBoundary, 2);

    % If no boundary-code is detected at that start (i.e. latency 0), then
    % add in a boundary-code
    if(tableBoundary.latency(1) ~= 0)
        tableBoundary = [tableBoundaryEdges(1,:); tableBoundary];
    end
    
    % If no boundary-code exists at the end (i.e. latency inEEG.pnts), then
    % add in a boundary code at the end
    if(tableBoundary.latency(end) ~= inEEG.pnts)
        tableBoundary = [tableBoundary; tableBoundaryEdges(2,:)];
    end
end

tableBoundary     = sortrows(tableBoundary, 'original_latency');
numBoundaryEvents = height(tableBoundary);
% display(tableBoundary);



%% Delete shifted-events that cross boundary-events
[nRows_total, ~]        = size(tableShiftedEvents);
deleteOriginalUreventArray = {};

for iRow_shifteventcode = 1:nRows_total
    
    latency_original = tableShiftedEvents{iRow_shifteventcode, 'original_latency'};
    latency_shifted  = tableShiftedEvents{iRow_shifteventcode, 'latency'};
    
    
    % Find nearest boundary code in the direction of the shift
    if(sign(sample_shift) > 0)
        % positive shift => find nearest boundary code GREATER than the
        %                   original latency
        latency_boundary = tableBoundary{tableBoundary.latency > latency_original, 'latency'};
        latency_boundary = latency_boundary(1);
    else
        % negative shift => find nearest boundary code LESSER than the
        %                   original latency
        latency_boundary = tableBoundary{tableBoundary.latency < latency_original, 'latency'};
        latency_boundary = latency_boundary(1);
    end
    
    
    
    if((latency_boundary > min([latency_original, latency_shifted])) && ...
            (latency_boundary < max([latency_original, latency_shifted])) )
        
        % Get the UREVENT code in order to later delete them
        deleteOriginalUrevent      = tableShiftedEvents{iRow_shifteventcode, 'original_urevent'};
        deleteOriginalUreventArray = [deleteOriginalUreventArray; num2str(deleteOriginalUrevent{1})]; %#ok<AGROW>
        
    end
end


%% Ensure each `urevent` is unique for indexing
if(iscell(tableShiftedEvents.urevent))
    urevents = cellfun(@num2str, tableShiftedEvents.urevent, ...
        'UniformOutput', false);
elseif(isnumeric(tableShiftedEvents.urevent))
    urevents = arrayfun(@num2str, tableShiftedEvents.urevent, ...
        'UniformOutput', false);
end
assert(numel(unique(urevents)) == numel(urevents));


% Filter out the events to delete and delete them
if(isnumeric(eventsTable.original_urevent))
    urevents_original = arrayfun(@num2str, eventsTable.original_urevent, ...
        'UniformOutput', false);
elseif(iscell(eventsTable.original_urevent))
    urevents_original = cellfun(@num2str, eventsTable.original_urevent, ...
        'UniformOutput', false);
end
    

% Find events to delete (i.e. that crossed a boundary) and then delete them
filter_events2delete = ismember(urevents_original, deleteOriginalUreventArray);
eventsTable(filter_events2delete, :) = [];

% Count the number of event-codes that were deleted
numEventsDeleted = size(deleteOriginalUreventArray, 1);



%% Save the shifted events/latencies back into the EEGLAB EEG dataset
eventsTable.type       = char(eventsTable.type);
outEEG                 = inEEG;
outEEG.event           = table2struct(eventsTable)';
outEEG                 = eeg_checkset(outEEG, 'eventconsistency', 'checkur');





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





%% Detailed Feedback
if(strcmpi(displayFeedback, 'detailed') || strcmpi(displayFeedback,'both'))

    
    % Extract both the input events and output events into tables
    Original         = struct2table(inEEG.event);
    Shifted          = struct2table(outEEG.event);
        
    
    % Rename variables
    
    % This is a special case when the `urevent` variable/column does not
    % exist and instead is named `item`. This occurs when the EEG dataset
    % has gone through `Create EVENTLIST`.
    try
        Original.Properties.VariableNames{'urevent'}     = 'Event_Num_Original';
        Shifted.Properties.VariableNames{'urevent'}      = 'Event_Num_Shifted';
    catch
        Original.Properties.VariableNames{'item'}        = 'Event_Num_Original';
        Shifted.Properties.VariableNames{'item'}         = 'Event_Num_Shifted';
    end
    
    Original.Properties.VariableNames{'latency'}         = 'Sample_Num';
    Original.Properties.VariableNames{'type'}            = 'Event_Code';

    Shifted.Properties.VariableNames{'latency'}          = 'Sample_Num';
    Shifted.Properties.VariableNames{'type'}             = 'Event_Code';
    Shifted.Properties.VariableNames{'original_urevent'} = 'Event_Num_Original';

    
    % Delete `duration` variable (since it is unused)
    try
        Original.duration = [];
        Shifted.duration  = [];
    catch
        % do nothing if `duration` does not exist
    end
    
    
    % Convert `urevent` numbers to strings (in order to `join` the tables)
    if(isnumeric(Original.Event_Num_Original) || isnumeric(Shifted.Event_Num_Original))
        
        Shifted.Event_Num_Original  = arrayfun(@num2str,Shifted.Event_Num_Original,  'UniformOutput',false);
        Original.Event_Num_Original = arrayfun(@num2str,Original.Event_Num_Original, 'UniformOutput',false);
    
    elseif(iscell(Original.Event_Num_Original) || iscell(Shifted.Event_Num_Original))
    
        Shifted.Event_Num_Original  = cellfun(@num2str,Shifted.Event_Num_Original,   'UniformOutput',false);
        Original.Event_Num_Original = cellfun(@num2str,Original.Event_Num_Original,  'UniformOutput',false);
    
    end
        
    % Join the input/original events with the output/shifted events 
    Combined_table = innerjoin(Original, Shifted, ...
        'Keys', 'Event_Num_Original');
    
    
    
    % Convert `urevent` to number
    if(isnumeric(Combined_table.Event_Num_Original))
        Combined_table.Event_Num_Original = arrayfun(@str2num, Combined_table.Event_Num_Original, 'UniformOutput', false);
    elseif(iscell(Combined_table.Event_Num_Original))
        Combined_table.Event_Num_Original = cellfun(@str2num, Combined_table.Event_Num_Original, 'UniformOutput', false);
    end
            
    
    % Delete urevents with missing values (i.e. boundary events)
    rows2Delete = cell2mat(cellfun(@isempty, Combined_table.Event_Num_Original, 'UniformOutput', false));
    Combined_table(rows2Delete,:) = [];
    
    Combined_table = sortrows(Combined_table, 'Sample_Num_Shifted');
    
    
    % Calculate the latency differences between the input and output
    Sample_Num_Difference         = (  ...
        Combined_table.Sample_Num_Shifted - Combined_table.Sample_Num_Original );
    
    % Calculate the time differences based on the latency differences
    Time_Difference_ms            = Sample_Num_Difference * (1000/inEEG.srate);
    
    
    Combined_table = [ Combined_table ...
        table(Sample_Num_Difference) ...
        table(Time_Difference_ms)  ];
    
    % Filter & Reposition the variable columns for display
    Display_vars = {...
        'Event_Code_Original'   , ...
        'Event_Num_Original'    , ...
        'Sample_Num_Original'   , ...
        'Sample_Num_Shifted'    , ...
        'Sample_Num_Difference' , ...
        'Time_Difference_ms'    };
    
    Display_table = table( ...
        Combined_table{:, Display_vars{1}}, ...
        Combined_table{:, Display_vars{2}}, ...
        Combined_table{:, Display_vars{3}}, ...
        Combined_table{:, Display_vars{4}}, ...
        Combined_table{:, Display_vars{5}}, ...
        Combined_table{:, Display_vars{6}}, ...
        'VariableNames', Display_vars);
    
    % Write to File
    [path_erplab, ~, ~] = fileparts(which('eegplugin_erplab'));
    path_temp          = fullfile(path_erplab, 'erplab_Box');
    
    % If erplab's temp directory does not exist then create it
    if ~exist(path_temp, 'dir'); mkdir(path_temp); end;
    
    output_filename     = ['erplab-shift_event_codes-' datestr(now, 30) '.csv'];
    output_filespec     = fullfile(path_temp, output_filename);
    
    writetable(Display_table, output_filespec, ...
        'Delimiter',   ',', ...
        'QuoteStrings', true);
    
    % Display to command line    
    fprintf('A CSV-file containing all shift information was created at <a href="matlab: open( %s )">%s </a>\n\n', output_filespec, output_filespec)
    fprintf('For your information, here is a table of the first 10 events in your eventlist:\n');
    display(Display_table(1:10,:));
    
end
    


%% Summarized Feedback
if(strcmpi(displayFeedback, 'summary') || strcmpi(displayFeedback, 'both'))
    numEventCodes        = size(inEEG.event, 2);
    
    fprintf('\n\n\t%9d event codes shifted %+2.3f milliseconds\n', ...
        numEventsShifted, ...
        timeshift*1000);
    fprintf('\t%9d total event codes\n', ...
        numEventCodes);
    fprintf('\t%9d boundary events were detected\n', ...
        numBoundaryEvents);
    fprintf('\t%9d event codes were deleted because they crossed a boundary\n', ...
        numEventsDeleted);
end


%% Warn if previously created EVENTLIST detected
if(isfield(outEEG, 'EVENTLIST') && ~isempty(outEEG.EVENTLIST))
    warning_txt = sprintf('Previously Created ERPLAB EVENTLIST Detected & Deleted \n _________________________________________________________________________\n\n This function changes the timing of your event codes, thus your prior eventlist is now obsolete and WILL BE DELETED. \n\n Remember to re-create a new ERPLAB EVENTLIST\n _________________________________________________________________________\n');
    warning(warning_txt); %#ok<SPWRN>
    
    % DELETE PRIOR EVENTLIST
    outEEG.EVENTLIST = [];
end

