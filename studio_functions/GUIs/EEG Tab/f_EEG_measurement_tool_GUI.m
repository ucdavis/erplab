%% Measurement Tool GUI Panel for EEG Tab

function varargout = f_EEG_measurement_tool_GUI(varargin)

% Declare global variables for consistency with ERPLAB Studio framework
global observe_EEGDAT;
global EStudio_gui_erp_totl;

% Add listeners for data synchronization
addlistener(observe_EEGDAT, 'eeg_two_panels_change', @eeg_two_panels_change);
addlistener(observe_EEGDAT, 'count_current_eeg_change', @count_current_eeg_change);
addlistener(observe_EEGDAT, 'Reset_eeg_panel_change', @Reset_eeg_panel_change);

% Initialize panel parameters
[version, reldate, ColorB_def, ColorF_def, errorColorF_def] = geterplabstudiodef;

% Define parent layout and panel for the GUI
parentLayout = varargin{1}; % Parent container passed as input

try
    FonsizeDefault = varargin{2}; % Font settings passed as input
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end

% Define colors
defaultColor = [1, 1, 1]; % White
orangeColor = [1, 0.8, 0.6]; % Light orange
redColor = [1, 0.6, 0.6]; % Light red
highlightColor = [0.8, 0.9, 1]; % Light blue for selected rows

% Handle class to store measurement parameters (in separate file)
measurementParams = MeasurementParams_handleClass();

% initialize with defaults

%%%%%%%%%%%%%%%%%%%%%% Make main measurement tool panel GUI %%%%%%%%%%%%%%%%%%%%%%

% Struct to store GUI panels and GUI information
measurementGUI = struct();

% Create the main box panel for the Measurement Tool
measurementGUI.mainPanel = uiextras.BoxPanel('Parent', parentLayout, ...
                                'Title', 'Measurement Tool', ...
                                'FontSize', FonsizeDefault, ...
                                'ForegroundColor', ColorF_def, ...
                                'BackgroundColor', ColorB_def);

% Layout box to organize sub panels
measurementGUI.mainLayout = uiextras.VBox('Parent', measurementGUI.mainPanel, ...
    'BackgroundColor',ColorB_def, ...
    'Spacing', 5, 'Padding', 5);

rowElement_sizes = [70 -1 80]; % sizes for most rows, [title fillbox/menu button]

% Section 1: Type
measurementGUI.subPanel_type = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_type_title = uicontrol('Style','text', ...
    'Parent',measurementGUI.subPanel_type,...
    'HorizontalAlignment','left', ...
    'String','Type:', ...
    'FontSize',FonsizeDefault, ...
    'BackgroundColor',ColorB_def);

measurementGUI.subPanel_type_menu = uicontrol('Style', 'popupmenu', ...
    'Parent', measurementGUI.subPanel_type, ...
    'String', {'Mean Amplitude', 'Peak Amplitude'}, ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white');

measurementGUI.subPanel_type_button =uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_type, ...
    'String', 'Options', ...
    'FontSize', FonsizeDefault);

set(measurementGUI.subPanel_type,'Sizes',rowElement_sizes);

% Section 2: EEGsets
measurementGUI.subPanel_sets = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_sets_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_sets, ...
    'String', 'EEGsets:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def);

measurementGUI.subPanel_sets_fillbox = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_sets, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white');

measurementGUI.subPanel_sets_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_sets, ...
    'String', 'Browse', ...
    'FontSize', FonsizeDefault, ...
    'Callback', @(src, event) browseEEGsets() );

set(measurementGUI.subPanel_sets,'Sizes',rowElement_sizes);

% Section 3: Event Selection
measurementGUI.subPanel_eventSelect = uiextras.VBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def, 'Spacing', 5);

measurementGUI.subPanel_eventSelect_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_eventSelect, ...
    'String', 'Event selection by:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def);

% Section 3.1: select by event code
measurementGUI.subPanel_event_byCode = uiextras.HBox('Parent', measurementGUI.subPanel_eventSelect,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_event_byCode_check = uicontrol('Style', 'checkbox', ...
    'Parent', measurementGUI.subPanel_event_byCode, ...
    'String', 'Eventcode', ... 
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def, ...
    'Callback',@(src, event) checkByCode() );

measurementGUI.subPanel_event_byCode_fill = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_event_byCode, ...
    'String', '(ANY)', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white', ...
    'Enable','off');

measurementGUI.subPanel_event_byCode_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_event_byCode, ...
    'String', 'Browse', ...
    'FontSize', FonsizeDefault, ...
    'Enable','off', ...
    'Callback', @(src, event) browseEventCodes() );

set(measurementGUI.subPanel_event_byCode,'Sizes',rowElement_sizes);

% Section 3.2: select by bin number
measurementGUI.subPanel_event_byBin = uiextras.HBox('Parent', measurementGUI.subPanel_eventSelect,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_event_byBin_check = uicontrol('Style', 'checkbox', ...
    'Parent', measurementGUI.subPanel_event_byBin, ...
    'String', 'Bins', ... 
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def, ...
    'Callback',@(src, event) checkByBin() );

measurementGUI.subPanel_event_byBin_fill = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_event_byBin, ...
    'String', '(ANY)', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white', ...
    'Enable','off');

measurementGUI.subPanel_event_byBin_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_event_byBin, ...
    'String', 'Browse', ...
    'FontSize', FonsizeDefault, ...
    'Enable','off', ...
    'Callback', @(src, event) browseBins() );

set(measurementGUI.subPanel_event_byBin,'Sizes',rowElement_sizes);

% Section 4: Channels
measurementGUI.subPanel_channel = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_channel_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_channel, ...
    'String', 'Channels:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def);

measurementGUI.subPanel_channel_fillbox = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_channel, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white');

measurementGUI.subPanel_channel_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_channel, ...
    'String', 'Browse', ...
    'FontSize', FonsizeDefault, ...
    'Callback', @(src, event) browseChannels() );

set(measurementGUI.subPanel_channel,'Sizes',rowElement_sizes);

% Section 5: Window(s)
measurementGUI.subPanel_window = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_window_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_window, ...
    'String', 'Window(s):', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def, ...
    'Enable', 'on'); % Enabled by default, since mean amp is default measurement type

measurementGUI.subPanel_window_fillbox = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_window, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white', ...
    'Enable', 'on'); % Enabled by default, since mean amp is default measurement type

measurementGUI.subPanel_window_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_window, ...
    'String', 'Details', ...
    'FontSize', FonsizeDefault, ...
    'Enable', 'on'); % Enabled by default, since mean amp is default measurement type

set(measurementGUI.subPanel_window,'Sizes',rowElement_sizes);

% Section 6: Point(s)
measurementGUI.subPanel_points = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_points_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_points, ...
    'String', 'Points(s):', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def, ...
    'Enable', 'off'); % Disabled by default, since mean amp is default measurement type

measurementGUI.subPanel_points_fillbox1 = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_points, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white', ...
    'Enable', 'off'); % Disabled by default, since mean amp is default measurement type

measurementGUI.subPanel_points_to = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_points, ...
    'String', 'to', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def, ...
    'Enable', 'off'); % Disabled by default, since mean amp is default measurement type

measurementGUI.subPanel_points_fillbox2 = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_points, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white', ...
    'Enable', 'off'); % Disabled by default, since mean amp is default measurement type

measurementGUI.subPanel_points_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_points, ...
    'String', 'Details', ...
    'FontSize', FonsizeDefault, ...
    'Enable', 'off'); % Disabled by default, since mean amp is default measurement type

set(measurementGUI.subPanel_points,'Sizes',[rowElement_sizes(1) -1 30 -1 rowElement_sizes(3)]);

% Section 7: Baseline
measurementGUI.subPanel_baseline = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_baseline_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_baseline, ...
    'String', 'Baseline:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def);

measurementGUI.subPanel_baseline_fillbox = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_baseline, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white');

measurementGUI.subPanel_baseline_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_baseline, ...
    'String', 'Details', ...
    'FontSize', FonsizeDefault);

set(measurementGUI.subPanel_baseline,'Sizes',rowElement_sizes);

% Section 8: Output
measurementGUI.subPanel_output = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_output_title = uicontrol('Style', 'text', ...
    'Parent', measurementGUI.subPanel_output, ...
    'String', 'Output:', ...
    'HorizontalAlignment', 'left', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', ColorB_def);

measurementGUI.subPanel_baseline_fillbox = uicontrol('Style', 'edit', ...
    'Parent', measurementGUI.subPanel_output, ...
    'String', '', ...
    'FontSize', FonsizeDefault, ...
    'BackgroundColor', 'white');

measurementGUI.subPanel_baseline_button = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_output, ...
    'String', 'Options', ...
    'FontSize', FonsizeDefault);

set(measurementGUI.subPanel_output,'Sizes',rowElement_sizes);

% Section 9: Save Measures Button
measurementGUI.subPanel_save = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

measurementGUI.subPanel_save_cancelButton = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_save, ...
    'String', 'Cancel', ...
    'FontSize', FonsizeDefault + 1);

measurementGUI.subPanel_save_saveButton = uicontrol('Style', 'pushbutton', ...
    'Parent', measurementGUI.subPanel_save, ...
    'String', 'Save measures', ...
    'FontSize', FonsizeDefault + 1, ...
    'FontWeight', 'bold', ...
    'Callback', @(src, event) saveMeasures(src, event));

% Set overall heights of subpanels
set(measurementGUI.mainLayout,'Sizes',[30 30 90 30 30 30 30 30 40]);

%% Return the handle to the Measurement Tool panel
varargout{1} = measurementGUI.mainPanel;

%%%%%%%%%%%%%%%%%%%%%% Call back functions %%%%%%%%%%%%%%%%%%%%%%

%% Section 1 - Measurement type %%

%% Section 2 - Browse/select EEGsets %%
function browseEEGsets()

    EEGData = observe_EEGDAT.ALLEEG;

    % Retrieve EEG data from observe_EEGDAT
    if isempty(EEGData)
        errordlg('No EEG sets are currently loaded.', 'Error');
        return;
    end

    eegSetNames = arrayfun(@(x) {sprintf('EEG Set %d: %s', x, EEGData(x).setname)}, ...
                       1:length(EEGData))'; % Ensure column vector (Nx1)

    % Create dialog and table
    dlg = dialog('Name', 'Select EEG Sets', 'Position', [300, 300, 400, 300]);

    uitableWidth = 380;

    t = uitable('Parent', dlg, ...
            'Data', eegSetNames, ...
            'ColumnName', {'EEG Sets'}, ...
            'ColumnEditable', false, ...
            'ColumnWidth', {uitableWidth - 20}, ...
            'RowStriping', 'on', ...
            'Position', [10, 50, uitableWidth, 200], ...
            'CellSelectionCallback', @(src, event) handleSelection(src, event));

    % Store selected rows in the dialog's UserData
    dlg.UserData = [];

    % Add OK and Cancel buttons
    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'OK', ...
              'Position', [200, 10, 80, 30], ...
              'Callback', @(src, event) confirmSelection(dlg, t));

    uicontrol('Parent', dlg, 'Style', 'pushbutton', 'String', 'Cancel', ...
              'Position', [100, 10, 80, 30], ...
              'Callback', @(src, event) close(dlg));

    % Callback to capture selected rows
    function handleSelection(src, event)
        if ~isempty(event.Indices)
            dlg.UserData = unique(event.Indices(:, 1)); % Store selected row indices
        end
    end

    % Callback to confirm selection
    function confirmSelection(dlg, table)
        selectedRows = dlg.UserData;
        if isempty(selectedRows)
            errordlg('No EEG sets selected. Please select at least one.', 'Error');
        else
            % Get selected EEG set indices
            selectedIndices = cellfun(@(x) sscanf(x, 'EEG Set %d:'), eegSetNames(selectedRows));
            selectedIndices_str = strjoin(arrayfun(@num2str, selectedIndices, 'UniformOutput', false), ' ');
            set(measurementGUI.subPanel_sets_fillbox, 'String', selectedIndices_str);

            measurementParams.sets = selectedIndices; % indeces

            close(dlg);
        end
    end
end % end browseEEGsets function


%% Section 3 - Browse/select events %%

% 3.1 by event code
function checkByCode()

    if measurementGUI.subPanel_event_byCode_check.Value == 1
        set(measurementGUI.subPanel_event_byCode_fill, 'Enable', 'on')
        set(measurementGUI.subPanel_event_byCode_fill, 'String', '')
        set(measurementGUI.subPanel_event_byCode_button, 'Enable', 'on')
    else 
        set(measurementGUI.subPanel_event_byCode_fill, 'Enable', 'off')
        set(measurementGUI.subPanel_event_byCode_fill, 'String', '(ANY)')
        set(measurementGUI.subPanel_event_byCode_button, 'Enable', 'off')
    end

end

function browseEventCodes()

    % Retrieve EEG data for the selected EEG sets
    selectedSets = measurementParams.sets;
    if isempty(selectedSets)
        errordlg('No EEG sets selected. Please select EEG sets first.', 'Error');
        return;
    end
    EEGData = observe_EEGDAT.ALLEEG(selectedSets);

    % Check that each EEG set has event information
    if ~all(arrayfun(@(x) isfield(x, 'event') && ~isempty(x.event) || ...
                          (isfield(x, 'EVENTLIST') && isfield(x.EVENTLIST, 'eventinfo')), EEGData))
        error('One or more EEG sets are missing valid event information.');
    end

    % deactivate button (so no double clicking)
    set(measurementGUI.subPanel_event_byCode_button, 'String', '...')
    set(measurementGUI.subPanel_event_byCode_button, 'Enable', 'off')

    %% **Step 1: Extract and Count Event Codes**
    numSets = length(EEGData);
    eventCodeLists = cell(numSets, 1);
    eventCounts = cell(numSets, 1);

    for setIdx = 1:numSets
        if isfield(EEGData(setIdx), 'EVENTLIST') && isfield(EEGData(setIdx).EVENTLIST, 'eventinfo')
            % **Binned EEG set** - Use EVENTLIST instead of EEG.event
            rawEventCodes = {EEGData(setIdx).EVENTLIST.eventinfo.code};  
        else
            % **Unbinned EEG set** - Use EEG.event
            rawEventCodes = {EEGData(setIdx).event.type};
        end

        % Convert event codes to strings (ensuring consistency)
        rawEventCodes = cellfun(@num2str, rawEventCodes, 'UniformOutput', false);

        % Handle epoched EEG cases (extract numbers inside parentheses)
        cleanedEventCodes = regexprep(rawEventCodes, '^B\d+\((\d+)\)$', '$1');

        % Convert event codes to a **unique sorted list**
        [uniqueCodes, ~, eventIdx] = unique(cleanedEventCodes);
        eventCodeLists{setIdx} = uniqueCodes; % Store unique event codes
        eventCounts{setIdx} = accumarray(eventIdx, 1); % Count occurrences
    end

    % **Create a master list of all unique event codes across EEG sets**
    allEventCodes = eventCodeLists{1}; % Start with first set
    for setIdx = 2:numSets
        allEventCodes = union(allEventCodes, eventCodeLists{setIdx}, 'stable'); % Ensure all codes are included
    end

    % Initialize table data
    eventTableData = cell(length(allEventCodes), numSets + 1); % +1 for event code column
    eventTableData(:, 1) = allEventCodes; % First column: Event codes

    % Fill in event counts for each EEG set
    for setIdx = 1:numSets
        [matchedCodes, eventIdx] = ismember(eventCodeLists{setIdx}, allEventCodes);
        eventCountsForSet = zeros(size(allEventCodes)); % Default to zero occurrences
        eventCountsForSet(eventIdx(matchedCodes)) = eventCounts{setIdx}(matchedCodes);
        eventTableData(:, setIdx + 1) = num2cell(eventCountsForSet); % Assign counts
    end

    setNames = arrayfun(@(x) sprintf('EEG Set %d', x), 1:numSets, 'UniformOutput', false);
    columnNames = [{'Event code'}, setNames];

    rowColors = repmat(defaultColor, length(allEventCodes), 1); % Initialize all rows as white

    eventTable = cell2table(eventTableData, 'VariableNames', columnNames);

    %% **Step 2: Create GUI**
    dlg = uifigure('Name', 'Select Event Codes', 'Position', [200, 200, 500, 600]);

    dlg.CloseRequestFcn = @(src, event) closePanel();

    % "Select all" and "Select none" buttons
    uibutton(dlg, ...
             'Text', 'Select all', ...
             'Position', [140, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectAll());

    uibutton(dlg, ...
             'Text', 'Select none', ...
             'Position', [290, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectNone());

    % Event selection table
    t = uitable(dlg, ...
        'Data', eventTableData, ...
        'ColumnName', columnNames, ...
        'Position', [50, 150, 400, 350], ...
        'RowStriping', 'on', ...
        'CellSelectionCallback', @(src, event) selectRows(event));

    % OK and Cancel buttons
    uibutton(dlg, ...
             'Text', 'OK', ...
             'Position', [300, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) confirmSelection());

    uibutton(dlg, ...
             'Text', 'Cancel', ...
             'Position', [150, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) close(dlg));

    %% **Step 3: Callbacks**

    % Handle row selection
    function selectRows(event)
        if isempty(event.Indices)
            selectedRows = []; % No selection
        else
            selectedRows = unique(event.Indices(:, 1)); % Store row indices
        end
        set(t, 'UserData', selectedRows); % Save selected rows
        highlightRows(selectedRows)
    end

    % Select all event codes
    function selectAll()
        numRows = size(get(t, 'Data'), 1); % Get number of rows
        selectedRows = (1:numRows)'; % Select all rows
        set(t, 'UserData', selectedRows); % Store selected rows
        highlightRows(selectedRows)
    end

    % Deselect all event codes
    function selectNone()
        selectedRows = []; % No rows selected
        set(t, 'UserData', selectedRows); % Store empty selection
        highlightRows(selectedRows)
    end

    % Highlight selected rows
    function highlightRows(selectedRows)

        % Copy the row colors (i.e. orange/red from warnings)
        updatedColors = rowColors;

        updatedColors(selectedRows, :) = repmat(highlightColor, length(selectedRows), 1);

        % Apply updated colors to the table
        t.BackgroundColor = updatedColors;
    end

    % Confirm selected event codes
    function confirmSelection()
        selectedRows = t.UserData;
        if isempty(selectedRows)
            uialert(dlg, 'No event codes selected. Please select at least one.', 'Error', 'Icon', 'warning');
            return;
        end

        % Extract selected event codes
        selectedEventCodes = eventTableData(selectedRows, 1);
        measurementParams.eventCodes = selectedEventCodes;

        % Update GUI display
        eventCodesStr = strjoin(selectedEventCodes, ' ');
        set(measurementGUI.subPanel_event_byCode_fill, 'String', eventCodesStr);

        close(dlg)
    end

    % cancel selection
    function closePanel()

        % reactivate button (so no double clicking)
        set(measurementGUI.subPanel_event_byCode_button, 'String', 'Browse')
        set(measurementGUI.subPanel_event_byCode_button, 'Enable', 'on')

        % Close the dialog
        delete(dlg);
    end

end




% 3.2 by bin
function checkByBin()

    if measurementGUI.subPanel_event_byBin_check.Value == 1
        set(measurementGUI.subPanel_event_byBin_fill, 'Enable', 'on')
        set(measurementGUI.subPanel_event_byBin_fill, 'String', '')
        set(measurementGUI.subPanel_event_byBin_button, 'Enable', 'on')
    else 
        set(measurementGUI.subPanel_event_byBin_fill, 'Enable', 'off')
        set(measurementGUI.subPanel_event_byBin_fill, 'String', '(ANY)')
        set(measurementGUI.subPanel_event_byBin_button, 'Enable', 'off')
    end
    
end

function browseBins()

    % Retrieve EEG data for the selected EEG sets
    selectedSets = measurementParams.sets;
    if isempty(selectedSets)
        errordlg('No EEG sets selected. Please select EEG sets first.', 'Error');
        return;
    end
    EEGData = observe_EEGDAT.ALLEEG(selectedSets);
    numSets = length(EEGData);

    % Check if all EEG sets have been binned (must contain EEG.EVENTLIST.bdf)
    if ~all(arrayfun(@(x) isfield(x, 'EVENTLIST') && isfield(x.EVENTLIST, 'bdf'), EEGData))
        errordlg('One or more EEG sets do not contain bin definitions (EVENTLIST.bdf). Binning is required.', 'Error');
        return;
    end

    % Deactivate the browse button to prevent multiple clicks
    set(measurementGUI.subPanel_event_byBin_button, 'String', '...')
    set(measurementGUI.subPanel_event_byBin_button, 'Enable', 'off')

    %% **Extract and Organize Bin Data**
    
    % Determine the maximum bin index across all EEG sets
    maxBins = max(arrayfun(@(x) length(x.EVENTLIST.bdf), EEGData));
    binIndices = (1:maxBins)'; % Bin numbers

    % Initialize table data
    binTableData = cell(maxBins, 2); % Columns: Bin index, Bin label
    binTableData(:, 1) = num2cell(binIndices); % First column: bin numbers

    binLabelsBySet = cell(numSets, 1); % Stores bin labels for each EEG set

    for setIdx = 1:numSets
        numBinsInSet = length(EEGData(setIdx).EVENTLIST.bdf);
        binLabelsBySet{setIdx} = cell(maxBins, 1); % Initialize empty bin labels
        
        for binIdx = 1:numBinsInSet
            binLabelsBySet{setIdx}{binIdx} = EEGData(setIdx).EVENTLIST.bdf(binIdx).description;
        end
    end

    % Determine consistency of bin labels across sets
    rowColors = repmat([1, 1, 1], maxBins, 1); % Default white
    isSelectable = true(maxBins, 1); % Assume all rows are selectable
    warningFlag = false;
    errorFlag = false;

    for binIdx = 1:maxBins
        labels = cellfun(@(x) x{binIdx}, binLabelsBySet, 'UniformOutput', false);
        uniqueLabels = unique(labels(~cellfun(@isempty, labels))); % Ignore empty entries
        
        if any(cellfun(@isempty, labels)) % Check if any EEG set is missing this bin
            binTableData{binIdx, 2} = 'Bin missing from some EEGsets';
            rowColors(binIdx, :) = [1, 0.6, 0.6]; % Red for missing bins
            isSelectable(binIdx) = false; % Make row un-selectable
            errorFlag = true;
        elseif length(uniqueLabels) == 1
            binTableData{binIdx, 2} = uniqueLabels{1}; % Consistent label
        else
            binTableData{binIdx, 2} = '(label varies across EEGsets)';
            rowColors(binIdx, :) = [1, 0.8, 0.6]; % Light orange for inconsistent labels
            warningFlag = true;
        end
    end

    % Create table column names
    columnNames = {'Bin Index', 'Bin Label'};

    % Create dialog
    dlg = uifigure('Name', 'Select Bins', 'Position', [200, 200, 500, 600]);
    dlg.CloseRequestFcn = @(src, event) closePanel();

    % Show table of bin labels button
    uibutton(dlg, ...
             'Text', 'Show table of bin labels', ...
             'Position', [100, 560, 300, 30], ...
             'ButtonPushedFcn', @(btn, event) showBinTable());

    % Select all / Select none buttons
    uibutton(dlg, ...
             'Text', 'Select all', ...
             'Position', [140, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectAll());

    uibutton(dlg, ...
             'Text', 'Select none', ...
             'Position', [290, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectNone());

    % Bin selection table
    t = uitable(dlg, ...
        'Data', binTableData, ...
        'ColumnName', columnNames, ...
        'Position', [50, 150, 400, 350], ...
        'RowStriping', 'on', ...
        'BackgroundColor', rowColors, ...
        'CellSelectionCallback', @(src, event) selectRows(event));

    % Warning message if needed
    if warningFlag && errorFlag
        uilabel(dlg, ...
                'Text', 'Warning: Rows in orange indicate inconsistent bin labels.', ...
                'FontColor', '#F80', ...
                'Position', [30, 110, 470, 20]);
        uilabel(dlg, ...
                'Text', 'Warning: Rows in red indicate missing bins from some EEG sets.', ...
                'FontColor', 'red', ...
                'Position', [30, 90, 470, 20]);
    elseif warningFlag
        uilabel(dlg, ...
                'Text', 'Warning: Rows in orange indicate inconsistent bin labels.', ...
                'FontColor', '#F80', ...
                'Position', [30, 100, 470, 20]);
    elseif errorFlag
        uilabel(dlg, ...
                'Text', 'Warning: Rows in red indicate missing bins from some EEG sets.', ...
                'FontColor', 'red', ...
                'Position', [30, 100, 470, 20]);
    end

    % OK and Cancel buttons
    uibutton(dlg, ...
             'Text', 'OK', ...
             'Position', [300, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) confirmSelection());

    uibutton(dlg, ...
             'Text', 'Cancel', ...
             'Position', [150, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) closePanel());

    %% **Callback Functions**
    
    function showBinTable()
        % Create a sub-dialog to display bin labels per EEG set
        subDlg = uifigure('Name', 'Bin Labels Across EEG Sets', 'Position', [300, 300, 600, 600]);

        % Prepare table data
        labelTableData = cell(maxBins, numSets + 1);
        labelTableData(:, 1) = num2cell(binIndices); % Bin indices

        for setIdx = 1:numSets
            labels = binLabelsBySet{setIdx};
            labels(cellfun(@isempty, labels)) = {'-'}; % Mark missing labels
            labelTableData(:, setIdx + 1) = labels;
        end

        setNames = arrayfun(@(x) sprintf('EEG Set %d', x), 1:numSets, 'UniformOutput', false);
        columnNames = [{'Bin Index'}, setNames];

        % Display table
        uitable(subDlg, ...
                'Data', labelTableData, ...
                'ColumnName', columnNames, ...
                'Position', [20, 20, 560, 500]);
    end

    function selectRows(event)
        if isempty(event.Indices)
            selectedRows = [];
        else
            selectedRows = unique(event.Indices(:, 1));
            selectedRows = selectedRows(isSelectable(selectedRows)); % Keep only selectable rows
        end
        set(t, 'UserData', selectedRows);
        highlightRows(selectedRows);
    end

    function selectAll()
        selectedRows = find(isSelectable);
        set(t, 'UserData', selectedRows);
        highlightRows(selectedRows);
    end

    function selectNone()
        set(t, 'UserData', []);
        highlightRows([]);
    end

    % Highlight selected rows
    function highlightRows(selectedRows)

        % Copy the row colors (i.e. orange/red from warnings)
        updatedColors = rowColors;

        % Highlight valid selected rows
        for idx = selectedRows'
            if isSelectable(idx) % Only highlight rows that are selectable
                updatedColors(idx, :) = highlightColor;
            end
        end

        % Apply updated colors to the table
        t.BackgroundColor = updatedColors;
    end

    function confirmSelection()
        selectedRows = t.UserData;
        if isempty(selectedRows)
            uialert(dlg, 'No bins selected. Please select at least one.', 'Error', 'Icon', 'warning');
            return;
        end

        % Extract selected bin numbers
        measurementParams.binNums = binIndices(selectedRows);

        % set in GUI
        binStr = strjoin(arrayfun(@num2str, binIndices(selectedRows), 'UniformOutput', false), ' ');
        set(measurementGUI.subPanel_event_byBin_fill, 'String', binStr);
        closePanel();
    end

    function closePanel()
        set(measurementGUI.subPanel_event_byBin_button, 'String', 'Browse')
        set(measurementGUI.subPanel_event_byBin_button, 'Enable', 'on')
        delete(dlg);
    end

end



%% Section 4 - Browse/select channels %%
function browseChannels()

    % deactivate button (so no double clicking)
    set(measurementGUI.subPanel_channel_button, 'String', '...')
    set(measurementGUI.subPanel_channel_button, 'Enable', 'off')

    % Retrieve EEG data for the selected EEG sets
    selectedSets = measurementParams.sets;
    if isempty(selectedSets)
        errordlg('No EEG sets selected. Please select EEG sets first.', 'Error');
        return;
    end
    EEGData = observe_EEGDAT.ALLEEG(selectedSets);

    % check that each set has channel info
    if ~all(arrayfun(@(x) isfield(x, 'chanlocs') && ~isempty(x.chanlocs), EEGData))
        error('One or more EEG sets are missing valid channel information.');
    end

    %% Make channel selection table
    % Extract the maximum number of channels across all EEG sets
    numSets = length(EEGData);
    maxChannels = max(arrayfun(@(x) length(x.chanlocs), EEGData)); % Get max channels
    channelNumbers = (1:maxChannels)'; % Column for channel numbers
    channelLabels = cell(numSets, 1);

    % Initialize the table data
    channelTableData = cell(maxChannels, numSets + 1); % +1 for the "Channel Number" column
    channelTableData(:, 1) = num2cell(channelNumbers); % Fill first column with channel numbers

    % Fill in channel labels for each EEG set
    for setIdx = 1:numSets

        channelLabels{setIdx} = {EEGData(setIdx).chanlocs.labels};

        % Assign labels or '-' for each channel number
        for chanIdx = 1:maxChannels
            if chanIdx <= length(channelLabels{setIdx})
                channelTableData{chanIdx, setIdx + 1} = channelLabels{setIdx}{chanIdx}; % Label
            else
                channelTableData{chanIdx, setIdx + 1} = '-'; % Missing
            end
        end
    end

    % Determine row status and apply row colors

    isSelectable = false(maxChannels, 1); % Preallocate as false
    warningFlag = false; % If there should be warning text for orange rows
    errorFlag = false; % If there should be warning text for red rows

    rowColors = repmat(defaultColor, maxChannels, 1); % Initialize all rows as white

    for chanIdx = 1:maxChannels
        rowData = channelTableData(chanIdx, 2:end); % Skip channel number column

        % Check if the row has any missing values
        if any(strcmp(rowData, '-'))
            % Missing data: Mark row as red and un-selectable
            rowColors(chanIdx, :) = redColor;
            isSelectable(chanIdx) = false;
            errorFlag = true; % At least one row is red
        else
            % Check for inconsistent labels
            uniqueLabels = unique(rowData);
            if length(uniqueLabels) > 1
                % Inconsistent data: Mark row as orange
                rowColors(chanIdx, :) = orangeColor;
                isSelectable(chanIdx) = true;
                warningFlag = true; % At least one row is orange
            else
                % Consistent data: Mark row as white (default)
                rowColors(chanIdx, :) = defaultColor;
                isSelectable(chanIdx) = true;
            end
        end
    end

    % Create the table
    setNames = arrayfun(@(x) sprintf('EEG Set %d', x), 1:numSets, 'UniformOutput', false);
    columnNames = [{'Channel Number'}, setNames];
    channelTable = cell2table(channelTableData, 'VariableNames', columnNames);

    %% Create the alphabetical label summary table 
    % (pops up when "Show channels alphabetically by label" button is pressed)
    uniqueLabels = unique(horzcat(channelLabels{:}), 'stable'); % All unique channel labels
    labelSummaryData = cell(length(uniqueLabels), numSets + 1); % Preallocate table data
    labelSummaryData(:, 1) = uniqueLabels; % First column: unique labels

    for setIdx = 1:numSets
        for labelIdx = 1:length(uniqueLabels)
            % Find the channel number corresponding to this label
            idx = find(strcmp(channelLabels{setIdx}, uniqueLabels{labelIdx}), 1);
            if isempty(idx)
                labelSummaryData{labelIdx, setIdx + 1} = '-'; % Mark as missing
            else
                labelSummaryData{labelIdx, setIdx + 1} = num2str(idx); % Channel number as string
            end
        end
    end

    % Convert to table
    labelSummaryTable = cell2table(labelSummaryData, 'VariableNames', [{'Channel Label'}, setNames]);

    % Create dialog using uifigure
    dlg = uifigure('Name', 'Select Channels', 'Position', [200, 200, 500, 600]);

    % "Show table of channels" button
    uibutton(dlg, ...
             'Text', 'Show channels alphabetically by label', ...
             'Position', [100, 560, 300, 30], ...
             'ButtonPushedFcn', @(btn, event) showChannelTable());

    % "Select all" and "Select none" buttons
    uibutton(dlg, ...
             'Text', 'Select all', ...
             'Position', [140, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectAll());

    uibutton(dlg, ...
             'Text', 'Select none', ...
             'Position', [290, 510, 100, 30], ...
             'ButtonPushedFcn', @(btn, event) selectNone());

    % Channel selection table
    t = uitable(dlg, ...
        'Data', channelTableData, ...
        'ColumnName', columnNames, ...
        'Position', [50, 150, 400, 350], ...
        'RowStriping', 'on', ...
        'BackgroundColor', rowColors, ...
        'CellSelectionCallback', @(src, event) selectRows(event));

    % Warning information if needed
    if warningFlag && errorFlag
        uilabel(dlg, ...
                'Text', 'Warning: Channel numbers in orange indicate inconsistent labels across EEG sets', ...
                'FontColor', '#F80', ...
                'Position', [30, 110, 470, 20]);

        uilabel(dlg, ...
                'Text', 'Warning: Channel numbers in red indicate at least one EEG set is missing this channel', ...
                'FontColor', 'red', ...
                'Position', [30, 70, 470, 20]);

    elseif warningFlag && ~errorFlag
        uilabel(dlg, ...
                'Text', 'Warning: Channel numbers in orange indicate inconsistent labels across EEG sets', ...
                'FontColor', '#F80', ...
                'Position', [30, 90, 470, 20]);

    elseif ~warningFlag && errorFlag
        uilabel(dlg, ...
                'Text', 'Warning: Channel numbers in red indicate at least one EEG set is missing this channel', ...
                'FontColor', 'red', ...
                'Position', [30, 90, 470, 20]);
    end

    % OK and Cancel buttons
    uibutton(dlg, ...
             'Text', 'OK', ...
             'Position', [300, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) confirmSelection());

    uibutton(dlg, ...
             'Text', 'Cancel', ...
             'Position', [150, 10, 80, 30], ...
             'ButtonPushedFcn', @(btn, event) cancelSelection());

    % Callback to display channel label summary (sub-dialog)
    function showChannelTable()
        % Create a sub-dialog to display the label summary table
        subDlg = uifigure('Name', 'View table of channels for each EEGset', ...
            'Position', [300, 300, 500, 600]);

        % Channel table
        uitable(subDlg, ...
                'Data', table2cell(labelSummaryTable), ...
                'ColumnName', labelSummaryTable.Properties.VariableNames, ...
                'Position', [20, 20, 460, 500]);
    end

    % Callback to highlight selected rows
    function selectRows(event)
        if isempty(event.Indices)
            selectedRows = []; % No selection
        else
            % Filter selected rows using isSelectable
            selectedRows = unique(event.Indices(:, 1)); % Get row indices
            selectedRows = selectedRows(isSelectable(selectedRows)); % Keep only selectable rows
        end

        set(t, 'UserData', selectedRows); % Save filtered selected rows in UserData
        highlightRows(selectedRows); % Update row highlights
    end

    % Select all selectable rows
    function selectAll()
        selectedRows = find(isSelectable); % Rows marked as selectable
        set(t, 'UserData', selectedRows); % Store selected rows in UserData
        highlightRows(selectedRows); % Highlight all valid rows
    end

    % Deselect all rows
    function selectNone()
        selectedRows = []; % No rows selected
        set(t, 'UserData', selectedRows); % Store empty selection
        highlightRows(selectedRows); % Clear row highlights
    end

    % Highlight selected rows
    function highlightRows(selectedRows)

        % Copy the row colors (i.e. orange/red from warnings)
        updatedColors = rowColors;

        % Highlight valid selected rows
        for idx = selectedRows'
            if isSelectable(idx) % Only highlight rows that are selectable
                updatedColors(idx, :) = highlightColor;
            end
        end

        % Apply updated colors to the table
        t.BackgroundColor = updatedColors;
    end

    % Confirm selected channels
    function confirmSelection()
        selectedRows = t.UserData;

        if isempty(selectedRows)
            uialert(dlg, 'No channels selected. Please select at least one.', 'Error', 'Icon', 'warning');
            return;
        end

        % Extract selected channel numbers
        channelNumbers = cell2mat(channelTableData(selectedRows, 1));
        measurementParams.channels = channelNumbers;

        % Update GUI display
        channelNumbers_str = strjoin(arrayfun(@num2str, channelNumbers, 'UniformOutput', false), ' ');
        set(measurementGUI.subPanel_channel_fillbox, 'String', channelNumbers_str);

        % reactivate button (so no double clicking)
        set(measurementGUI.subPanel_channel_button, 'String', 'Browse')
        set(measurementGUI.subPanel_channel_button, 'Enable', 'on')

        % Close the dialog
        close(dlg);
    end

    % cancel selection
    function cancelSelection()

        % reactivate button (so no double clicking)
        set(measurementGUI.subPanel_channel_button, 'String', 'Browse')
        set(measurementGUI.subPanel_channel_button, 'Enable', 'on')

        % Close the dialog
        close(dlg);
    end

end % end browseEEGchannels function





function saveMeasures(~, ~)
    display(measurementParams)
end

%% end whole GUI function
end

%%%% Helper functions (maybe move to separate file?) %%%%


