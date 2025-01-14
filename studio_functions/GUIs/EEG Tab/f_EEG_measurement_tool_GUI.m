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

% Handle class to store measurement parameters (in separate file)
measurementParams = MeasurementParams_handleClass();

% initialize with defaults


% Struct to store GUI panels and GUI information
measurementGUI = struct();

% Create the main box panel for the Measurement Tool
measurementGUI.mainPanel = uiextras.BoxPanel('Parent', parentLayout, ...
                                'Title', 'Measurement Tool', ...
                                'FontSize', FonsizeDefault, ...
                                'ForegroundColor', ColorF_def, ...
                                'BackgroundColor', ColorB_def);

EEG_measurement_tool_GUI()

% Return the handle to the Measurement Tool panel
varargout{1} = measurementGUI.mainPanel;

%%%%%%%%%%%%%%%%%%%%%% Main measurement tool panel GUI function %%%%%%%%%%%%%%%%%%%%%%

    function EEG_measurement_tool_GUI()
    % Layout box to organize sub panels
    measurementGUI.mainLayout = uiextras.VBox('Parent', measurementGUI.mainPanel, ...
        'BackgroundColor',ColorB_def, ...
        'Spacing', 5, 'Padding', 5);

    rowElement_sizes = [65 -1 80]; % sizes for most rows, [title fillbox/menu button]

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
        'Callback', @(src, event) browseEEGsets(measurementGUI, measurementParams) );

    set(measurementGUI.subPanel_sets,'Sizes',rowElement_sizes);

    % Section 3: Event Selection
    measurementGUI.subPanel_eventSelect = uiextras.VBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def, 'Spacing', 3);

    measurementGUI.subPanel_eventSelect_title = uicontrol('Style', 'text', ...
        'Parent', measurementGUI.subPanel_eventSelect, ...
        'String', 'Event selection:', ...
        'HorizontalAlignment', 'left', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', ColorB_def);

    measurementGUI.subPanel_eventSelect_radioByEvent = uicontrol('Style', 'radiobutton', ...
        'Parent', measurementGUI.subPanel_eventSelect, ...
        'String', 'Specified event codes (any bin)', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', ColorB_def, ...
        'Enable','on');

    measurementGUI.subPanel_eventSelect_radioByBin = uicontrol('Style', 'radiobutton', ...
        'Parent', measurementGUI.subPanel_eventSelect, ...
        'String', 'Specified bins (any event code)', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', ColorB_def, ...
        'Enable','on');

    measurementGUI.subPanel_eventSelect_radioByEventBin = uicontrol('Style', 'radiobutton', ...
        'Parent', measurementGUI.subPanel_eventSelect, ...
        'String', 'Specified event codes within specified bins', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', ColorB_def, ...
        'Enable','on');

    % Section 3.1: Event select fill
    measurementGUI.subPanel_eventFill = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

    measurementGUI.subPanel_eventFill_title = uicontrol('Style', 'text', ...
        'Parent', measurementGUI.subPanel_eventFill, ...
        'String', '', ... % blank to preserve alignment in fill boxes
        'HorizontalAlignment', 'left', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', ColorB_def);

    measurementGUI.subPanel_eventFill_fillbox = uicontrol('Style', 'edit', ...
        'Parent', measurementGUI.subPanel_eventFill, ...
        'String', '', ...
        'FontSize', FonsizeDefault, ...
        'BackgroundColor', 'white', ...
        'Enable','off');

    measurementGUI.subPanel_eventFill_button = uicontrol('Style', 'pushbutton', ...
        'Parent', measurementGUI.subPanel_eventFill, ...
        'String', 'Browse', ...
        'FontSize', FonsizeDefault, ...
        'Enable','off');

    set(measurementGUI.subPanel_eventFill,'Sizes',rowElement_sizes);

    % Section 4: Channel
    measurementGUI.subPanel_channel = uiextras.HBox('Parent', measurementGUI.mainLayout,'BackgroundColor',ColorB_def);

    measurementGUI.subPanel_channel_title = uicontrol('Style', 'text', ...
        'Parent', measurementGUI.subPanel_channel, ...
        'String', 'Channel:', ...
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
        'Callback', @(src, event) browseChannels(measurementGUI, measurementParams));

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
        'Callback', @(src, event) saveMeasures(src, event, measurementParams));

    % Set overall heights of subpanels
    set(measurementGUI.mainLayout,'Sizes',[30 30 70 30 30 30 30 30 30 40]);
    end

%%%%%%%%%%%%%%%%%%%%%% Call back functions %%%%%%%%%%%%%%%%%%%%%%

%% Browse/select EEGsets %%
    function browseEEGsets(measurementGUI, measurementParams)

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
    end


%% Browse/select channels %%
    function browseChannels(measurementGUI, measurementParams)
        %global observe_EEGDAT;

        % Retrieve EEG data for the selected EEG sets
        selectedSets = measurementParams.sets;
        if isempty(selectedSets)
            errordlg('No EEG sets selected. Please select EEG sets first.', 'Error');
            return;
        end
        EEGData = observe_EEGDAT.ALLEEG(selectedSets);

        % Extract channel labels and numbers for each set
        numSets = length(EEGData);
        channelLabels = cell(numSets, 1);
        channelNumbers = cell(numSets, 1);

        for i = 1:numSets
            if isfield(EEGData(i), 'chanlocs') && ~isempty(EEGData(i).chanlocs)
                channelLabels{i} = {EEGData(i).chanlocs.labels};
                channelNumbers{i} = 1:length(EEGData(i).chanlocs); % Assume sequential numbers
            else
                error('EEG Set %d has no valid channel information.', i);
            end
        end

        % Create the Label Summary Table
        uniqueLabels = unique(horzcat(channelLabels{:})); % All unique channel labels
        labelSummaryData = cell(length(uniqueLabels), numSets + 1); % Preallocate table data
        labelSummaryData(:, 1) = uniqueLabels; % First column: unique labels

        for i = 1:numSets
            for j = 1:length(uniqueLabels)
                % Find the channel number corresponding to this label
                idx = find(strcmp(channelLabels{i}, uniqueLabels{j}), 1);
                if isempty(idx)
                    labelSummaryData{j, i + 1} = '-'; % Mark as missing (plain text)
                else
                    labelSummaryData{j, i + 1} = num2str(idx); % Channel number as string
                end
            end
        end

        % Create the Number Summary Table
        maxChannels = max(cellfun(@length, channelNumbers)); % Maximum channel count
        uniqueNumbers = (1:maxChannels)'; % All unique channel numbers
        numberSummaryData = cell(maxChannels, numSets + 1); % Preallocate table data
        numberSummaryData(:, 1) = num2cell(uniqueNumbers); % First column: unique numbers

        for i = 1:numSets
            for j = 1:maxChannels
                if j > length(channelLabels{i}) % Channel number exceeds available channels
                    numberSummaryData{j, i + 1} = '-'; % Mark as missing (plain text)
                else
                    numberSummaryData{j, i + 1} = channelLabels{i}{j}; % Channel label
                end
            end
        end

        % Convert to tables
        setNames = arrayfun(@(x) sprintf('EEG Set %d', x), 1:numSets, 'UniformOutput', false);
        labelSummaryTable = cell2table(labelSummaryData, ...
                                       'VariableNames', [{'Channel Label'}, setNames]);
        numberSummaryTable = cell2table(numberSummaryData, ...
                                        'VariableNames', [{'Channel Number'}, setNames]);

        % Utility functions
        function labelSummary = summarizeByLabel(tbl)
            % Initialize summary column
            labelSummary = cell(size(tbl, 1), 1);

            for row = 1:size(tbl, 1)
                label = tbl{row, 1}; % Current channel label
                setChans = tbl{row, 2:numSets}; % Current channel nums per set
                %countMissing = sum(setChans == '-');  % Count occurrences of "-" in each set
                countMissing = sum(strcmp(setChans, '-')); % Count occurrences of "-" in each set

                % Format the summary string
                labelSummary{row} = sprintf('in %d/%d EEG sets', numSets-countMissing, numSets);
            end
        end

        function numberSummary = summarizeByNumber(tbl)
            % Initialize summary column
            numberSummary = cell(size(tbl, 1), 1);

            for row = 1:size(tbl, 1)
                % Extract data for the row, ignoring the first column
                rowData = tbl{row, 2:end};

                % Check if labels are consistent across sets
                if all(strcmp(rowData, rowData{1})) && ~strcmp(rowData{1}, '-')
                    numberSummary{row} = rowData{1}; % Uniform label
                else
                    numberSummary{row} = 'label varies across EEGsets';
                end
            end
        end

        % Prepare data for the initial view (default: by label)
        currentView = 'Channel label'; % Default view
        tableData = [labelSummaryTable.(1), summarizeByLabel(labelSummaryTable)];

        % Create dialog
        dlg = dialog('Name', 'Select Channels', 'Position', [200, 200, 500, 500]);

        % "Show table of channels" button
        uicontrol('Style', 'pushbutton', 'Parent', dlg, ...
                  'String', 'Show table of channels for each EEGset', ...
                  'Position', [100, 450, 300, 30], ...
                  'Callback', @(src, event) showChannelTable(labelSummaryTable, numberSummaryTable));

        % "Select by" title
        uicontrol('Style', 'text', ...
                  'Parent', dlg, ...
                  'HorizontalAlignment', 'left', ...
                  'String', 'Select by:', ...
                  'Position', [50, 400, 50, 30]);

        % Radio buttons for selection method
        selectMethodGroup = uibuttongroup('Parent', dlg, ...
                                          'Units', 'pixels', ...
                                          'Position', [100, 400, 350, 30], ...
                                          'SelectionChangedFcn', @(src, event) updateTable());

        uicontrol('Style', 'radiobutton',...
                  'Parent', selectMethodGroup, ...
                  'String', 'Channel label', ...
                  'Position', [20, 5, 120, 20]);

        uicontrol('Style', 'radiobutton', ...
                  'Parent', selectMethodGroup, ...
                  'String', 'Channel number', ...
                  'Position', [150, 5, 130, 20]);

        % "Select all" and "Select none" buttons
        uicontrol('Style', 'pushbutton', 'Parent', dlg, ...
                  'String', 'Select all', ...
                  'Position', [140, 360, 100, 30], ...
                  'Callback', @(src, event) selectAll());

        uicontrol('Style', 'pushbutton', 'Parent', dlg, ...
                  'String', 'Select none', ...
                  'Position', [290, 360, 100, 30], ...
                  'Callback', @(src, event) selectNone());

        % Channel selection table
        t = uitable('Parent', dlg, ...
                    'Data', tableData, ...
                    'ColumnName', {'Channel', 'Info'}, ...
                    'ColumnEditable', [false, false], ...
                    'ColumnWidth',{100,130}, ...
                    'Position', [50, 50, 400, 300], ...
                    'CellSelectionCallback', @(src, event) selectRows(event));

        % OK and Cancel buttons
        uicontrol('Style', 'pushbutton', 'Parent', dlg, ...
                  'String', 'OK', ...
                  'Position', [300, 10, 80, 30], ...
                  'Callback', @(src, event) confirmSelection());

        uicontrol('Style', 'pushbutton', 'Parent', dlg, ...
                  'String', 'Cancel', ...
                  'Position', [150, 10, 80, 30], ...
                  'Callback', @(src, event) close(dlg));

        % Callback functions
        function updateTable()
            % Get selected view
            selectedView = selectMethodGroup.SelectedObject.String;

            switch selectedView
                case 'Channel label'
                    tableData = [labelSummaryTable.(1), summarizeByLabel(labelSummaryTable)];
                    set(t, 'Data', tableData, 'ColumnName', {'Channel label', 'Info'});

                    selectedRows = []; % No rows selected
                    set(t, 'UserData', selectedRows); % Store empty selection

                case 'Channel number'
                    % Convert `numberSummaryTable.(1)` to cells for concatenation
                    channelNumbers = num2cell(numberSummaryTable.(1)); 
                    tableData = [channelNumbers, summarizeByNumber(numberSummaryTable)];
                    set(t, 'Data', tableData, 'ColumnName', {'Channel number', 'Info'});

                    selectedRows = []; % No rows selected
                    set(t, 'UserData', selectedRows); % Store empty selection
            end

            % Update the table display
            currentView = selectedView;
        end

        function selectRows(event)
            if isempty(event.Indices)
                selectedRows = []; % No selection
            else
                selectedRows = unique(event.Indices(:, 1)); % Store selected row indices
            end
            set(t, 'UserData', selectedRows); % Save selected rows in UserData
            highlightRows(selectedRows); % Update row highlights
        end

        function selectAll()
            % Select all rows in the table
            numRows = size(get(t, 'Data'), 1); % Get the number of rows in the table
            selectedRows = (1:numRows)'; % Create an array of all row indices
            set(t, 'UserData', selectedRows); % Store selected rows in UserData
            highlightRows(selectedRows); % Highlight all rows
        end

        function selectNone()
            % Deselect all rows in the table
            selectedRows = []; % No rows selected
            set(t, 'UserData', selectedRows); % Store empty selection
            highlightRows(selectedRows); % Clear row highlights
        end

        function highlightRows(selectedRows)
            % Update the background color of the rows to indicate selection
            data = get(t, 'Data');
            numRows = size(data, 1);

            % Default background color
            defaultColor = [1, 1, 1]; % White
            highlightColor = [0.8, 0.9, 1]; % Light blue for selected rows

            % Set the RowStriping property
            rowColors = repmat(defaultColor, numRows, 1);
            rowColors(selectedRows, :) = repmat(highlightColor, length(selectedRows), 1);

            % Update the table background color
            set(t, 'BackgroundColor', rowColors);
        end

        function confirmSelection()
            selectedRows = t.UserData;

            if isempty(selectedRows)
                errordlg('No channels selected. Please select at least one.', 'Error');
                return;
            end

            % Store selected channels
            switch currentView
                case 'Channel label'
                    measurementParams.channels = labelSummaryTable.(1)(selectedRows);
                    set(measurementGUI.subPanel_channel_fillbox, 'String', strjoin(labelSummaryTable.(1)(selectedRows)));
                case 'Channel number'
                    measurementParams.channels = numberSummaryTable.(1)(selectedRows);
                    set(measurementGUI.subPanel_channel_fillbox, 'String', strjoin(labelSummaryTable.(1)(selectedRows)));
            end

            disp('Selected channels:');
            disp(measurementParams.channels);

            % Close the dialog
            close(dlg);
        end

        %% Callback to display channel by set info (sub dialog)
        function showChannelTable(labelSummaryTable, numberSummaryTable)

            % Extract raw data from tables
            labelData = table2cell(labelSummaryTable);
            numberData = table2cell(numberSummaryTable);

            % Initial table data (default view: by label)
            subTableData = labelData;

            % Create dialog
            subDlg = dialog('Name', 'View table of channels for each EEGset', 'Position', [300, 300, 500, 600]);

            % "Sort" title
            uicontrol('Style', 'text', ...
                      'Parent', subDlg, ...
                      'HorizontalAlignment', 'left', ...
                      'String', 'Sort:', ...
                      'Position', [30, 550, 50, 30]);

            % Radio buttons for selection method
            subSelectMethodGroup = uibuttongroup('Parent', subDlg, ...
                                              'Units', 'pixels', ...
                                              'Position', [80, 560, 350, 30], ...
                                              'SelectionChangedFcn', @(src, event) subUpdateTable());

            uicontrol('Style', 'radiobutton',...
                      'Parent', subSelectMethodGroup, ...
                      'String', 'Alphabetically by label', ...
                      'Position', [20, 5, 150, 20]);

            uicontrol('Style', 'radiobutton', ...
                      'Parent', subSelectMethodGroup, ...
                      'String', 'By channel number', ...
                      'Position', [190, 5, 150, 20]);

            % Channel selection table
            subTable = uitable('Parent', subDlg, ...
                        'Data', subTableData, ...
                        'ColumnName', [{'Channel Label'}, setNames], ...
                        'Position', [50, 50, 400, 500]);

            % Callback functions
            function subUpdateTable()
                % Get selected view
                selectedView = subSelectMethodGroup.SelectedObject.String;

                switch selectedView
                    case 'Alphabetically by label'
                        set(subTable, 'Data', labelData);
                        set(subTable, 'ColumnName', [{'Channel Label'}, setNames]);

                    case 'By channel number'
                        set(subTable, 'Data', numberData);
                        set(subTable, 'ColumnName', [{'Channel Number'}, setNames]);
                end
            end
        end




    end % end browseEEGchannels function





    function saveMeasures(~, ~, measurementParams)
        display(measurementParams)
    end

%% end whole GUI function
end

%%%% Helper functions (maybe move to separate file?) %%%%


