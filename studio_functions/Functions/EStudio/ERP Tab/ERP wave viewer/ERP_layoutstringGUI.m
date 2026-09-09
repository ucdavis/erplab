% ERP_layoutstringGUI
% "Plot Organization > Customize Grid Locations" dialog for the ERP Wave Viewer.
%
% NOTE: Migrated from GUIDE (.fig) to a programmatic uifigure-based classdef
% app. Original .fig archived outside ERPLAB.
% Migrated to .m: July 2026 by Kurt Winsler
%
% Calling convention unchanged from the original:
%   app = feval('ERP_layoutstringGUI', plotArrayFormt, GridinforData, plotBox, AllabelArray);
%   waitfor(app, 'Finishbutton', 1);
%   def = app.output;   % {Data, Labels_used, Labels_usedIndex}, or [] if cancelled

classdef ERP_layoutstringGUI < matlab.apps.AppBase

    properties (Access = public)
        UIFigure         matlab.ui.Figure
        LayoutTable      matlab.ui.control.Table
        LabelsTable      matlab.ui.control.Table
        RowsEditField    matlab.ui.control.EditField
        ColumnsEditField matlab.ui.control.EditField
        RowsLabel        matlab.ui.control.Label
        ColumnsLabel     matlab.ui.control.Label
        MessageLabel     matlab.ui.control.Label
        SetDefaultButton matlab.ui.control.Button
        ClearAllButton   matlab.ui.control.Button
        ImportButton     matlab.ui.control.Button
        ExportButton     matlab.ui.control.Button
        OKButton         matlab.ui.control.Button
        CancelButton     matlab.ui.control.Button
    end

    properties (Access = public)
        output       % {Data, Labels_used, Labels_usedIndex}, or [] if cancelled
        Finishbutton % Set to 1 when dialog closes (waitfor trigger)
    end

    properties (Access = private)
        AllabelArray      % all available labels (channels/bins/erpsets) to place in the grid
        GridinforData_def % layout as passed in; restored by "Set Default"
        usedIndex         % which AllabelArray entries are already selected in the main viewer (marked '*')
        SelectedLabelIdx = 1 % index into AllabelArray currently highlighted in LayoutTable
    end

    properties (Constant, Access = private)
        LegendText = sprintf([' In the right panel:\n Blue labels: unused.\n Red labels: ' ...
            'used more than once.\n Black labels: used once.\n *: Selected in main GUI.']);
        UnusedColor   = [0 0 1];
        DupColor      = [1 0 0];
        UsedColor     = [0 0 0];
        HighlightColor = [1 1 0];
    end

    methods (Access = private)

        function startupFcn(app, varargin)
            try
                plotArrayFormt = varargin{1};
            catch
                plotArrayFormt = arrayfun(@(ii) sprintf('chan-%d', ii), 1:100, 'UniformOutput', false)';
            end

            try
                GridinforData = varargin{2};
            catch
                GridinforData = '';
            end
            app.GridinforData_def = GridinforData;

            try
                plotBox = varargin{3};
            catch
                plotBox = f_getrow_columnautowaveplot(plotArrayFormt);
            end

            try
                AllabelArray = varargin{4};
            catch
                AllabelArray = plotArrayFormt;
            end
            app.AllabelArray = AllabelArray;

            app.usedIndex = zeros(length(AllabelArray),1);
            for jj = 1:length(AllabelArray)
                for ii = 1:length(plotArrayFormt)
                    if strcmp(AllabelArray{jj}, plotArrayFormt{ii})
                        app.usedIndex(jj) = 1;
                    end
                end
            end

            [~,~,~,~,~,ColorBviewer_def] = geterplabstudiodef;
            app.UIFigure.Color            = ColorBviewer_def;
            app.RowsLabel.BackgroundColor    = ColorBviewer_def;
            app.ColumnsLabel.BackgroundColor = ColorBviewer_def;
            app.MessageLabel.BackgroundColor = ColorBviewer_def;
            app.UIFigure.Name = 'Plot Organization > Customize Grid Locations';

            Numrows    = plotBox(1);
            Numcolumns = plotBox(2);
            app.RowsEditField.Value    = num2str(Numrows);
            app.ColumnsEditField.Value = num2str(Numcolumns);
            app.MessageLabel.Text = app.LegendText;

            app.applyTableDimensions(Numrows, Numcolumns);
            app.LayoutTable.Data = GridinforData;
            app.refreshLabelsTable();
            app.highlightSelectedLabel();

            app.output       = [];
            app.Finishbutton = 0;
        end

        % --- shared table-dimension bookkeeping (columns/rows/format) ---
        function applyTableDimensions(app, nrows, ncols)
            colNames = arrayfun(@(c) sprintf('C%d',c), 1:ncols, 'UniformOutput', false);
            rowNames = arrayfun(@(r) sprintf('R%d',r), 1:nrows, 'UniformOutput', false);
            app.LayoutTable.ColumnEditable = true(1,ncols);
            app.LayoutTable.ColumnName     = colNames;
            app.LayoutTable.RowName        = rowNames;
            app.LayoutTable.ColumnFormat   = repmat({'char'}, 1, ncols);
        end

        % --- rebuild the labels list (text + per-row color) from the current grid ---
        function refreshLabelsTable(app)
            Data = app.LayoutTable.Data;
            [LabelStrout, LabelColors] = f_MarkLabels_gridlocations_ERP_Waveiwer(Data, app.usedIndex, app.AllabelArray);
            app.LabelsTable.Data = LabelStrout;
            removeStyle(app.LabelsTable);
            for ii = 1:size(LabelColors,1)
                addStyle(app.LabelsTable, uistyle('FontColor', LabelColors(ii,:)), 'row', ii);
            end
            if app.SelectedLabelIdx > numel(app.AllabelArray)
                app.SelectedLabelIdx = 1;
            end
            app.LabelsTable.Selection = app.SelectedLabelIdx;
        end

        % --- yellow-highlight every grid cell matching the currently selected label ---
        function highlightSelectedLabel(app)
            removeStyle(app.LayoutTable);
            try
                labelText = app.AllabelArray{app.SelectedLabelIdx};
            catch
                labelText = app.AllabelArray{1};
            end
            Data = app.LayoutTable.Data;
            cellIdx = [];
            for r = 1:size(Data,1)
                for c = 1:size(Data,2)
                    if strcmp(Data{r,c}, labelText)
                        cellIdx = [cellIdx; r c]; %#ok<AGROW>
                    end
                end
            end
            if ~isempty(cellIdx)
                addStyle(app.LayoutTable, uistyle('BackgroundColor', app.HighlightColor), 'cell', cellIdx);
            end
        end

        % --- re-validate grid contents against AllabelArray, refresh labels/message ---
        function revalidateGrid(app)
            Data = app.LayoutTable.Data;
            [Data, EmptyStr] = f_checktable_gridlocations_waviewer(Data, app.AllabelArray);
            app.LayoutTable.Data = Data;
            app.refreshLabelsTable();
            app.highlightSelectedLabel();
            if ~strcmp(EmptyStr,',') && ~strcmp(string(EmptyStr)," ") && ~isempty(EmptyStr)
                app.MessageLabel.Text = sprintf('%s do(es) not match with items in the right panel.', EmptyStr);
            else
                app.MessageLabel.Text = app.LegendText;
            end
        end

        % --- Button pushed: Cancel ---
        function cancelBtn(app, ~)
            app.output       = [];
            app.Finishbutton = 1;
        end

        % --- Button pushed: OK ---
        function okBtn(app, ~)
            app.MessageLabel.Text = '';
            Data = app.LayoutTable.Data;
            Data = f_checktable_gridlocations_waviewer(Data, app.AllabelArray);

            Labels_used = app.uniqueStr(Data);
            if ~isempty(Labels_used)
                Labels_new = '';
                count = 0;
                for ii = 1:length(Labels_used)
                    if ~isempty(Labels_used{ii,1})
                        count = count+1;
                        Labels_new{count,1} = char(Labels_used{ii,1});
                    end
                end
                Labels_used = Labels_new;
            end

            Labels_usedIndex = [];
            if ~isempty(Labels_used) && ~isempty(app.AllabelArray)
                count = 0;
                for ii = 1:length(app.AllabelArray)
                    for jj = 1:length(Labels_used)
                        if strcmp(app.AllabelArray{ii}, Labels_used{jj})
                            count = count+1;
                            Labels_usedIndex(count) = ii; %#ok<AGROW>
                        end
                    end
                end
            end
            app.output       = {Data, Labels_used, Labels_usedIndex};
            app.Finishbutton = 1;
        end

        % --- Button pushed: Clear All ---
        function clearAllBtn(app, ~)
            app.MessageLabel.Text = '';
            Data = app.LayoutTable.Data;
            Data(:) = {''};
            app.LayoutTable.Data = Data;
            app.refreshLabelsTable();
            app.highlightSelectedLabel();
            app.MessageLabel.Text = app.LegendText;
        end

        % --- Labels table selection changed ---
        function labelsTableSelectionChanged(app, event)
            app.MessageLabel.Text = app.LegendText;
            idx = event.Indices;
            if ~isempty(idx)
                app.SelectedLabelIdx = idx(1,1);
            end
            app.highlightSelectedLabel();
        end

        % --- Grid cell edited ---
        function layoutTableCellEdit(app, ~)
            app.revalidateGrid();
        end

        % --- Button pushed: Set Default (revert to the layout as passed in) ---
        function setDefaultBtn(app, ~)
            app.MessageLabel.Text = '';
            GridinforData = app.GridinforData_def;
            [Numrows, Numcolumns] = size(GridinforData);
            app.applyTableDimensions(Numrows, Numcolumns);
            app.LayoutTable.Data = GridinforData;
            app.RowsEditField.Value    = num2str(Numrows);
            app.ColumnsEditField.Value = num2str(Numcolumns);
            app.refreshLabelsTable();
            app.highlightSelectedLabel();
            app.MessageLabel.Text = app.LegendText;
        end

        % --- Columns edit field changed ---
        function columnsEditFieldChanged(app, ~)
            app.MessageLabel.Text = '';
            Data = app.LayoutTable.Data;
            columNum = str2double(app.ColumnsEditField.Value);
            if isnan(columNum) || columNum <= 0
                app.MessageLabel.Text = '"Columns" should be a positive number.';
                app.ColumnsEditField.Value = num2str(size(Data,2));
                return;
            end
            RowsNum = str2double(app.RowsEditField.Value);
            if isnan(RowsNum) || RowsNum <= 0
                RowsNum = size(Data,1);
            end
            DataNew = app.reflowGrid(Data, RowsNum, columNum);
            app.applyTableDimensions(RowsNum, columNum);
            app.LayoutTable.Data = DataNew;
            app.revalidateGrid();
        end

        % --- Rows edit field changed ---
        function rowsEditFieldChanged(app, ~)
            app.MessageLabel.Text = '';
            Data = app.LayoutTable.Data;
            RowsNum = str2double(app.RowsEditField.Value);
            if isnan(RowsNum) || RowsNum <= 0
                app.MessageLabel.Text = '"Rows" should be a positive number.';
                app.RowsEditField.Value = num2str(size(Data,1));
                return;
            end
            columNum = str2double(app.ColumnsEditField.Value);
            if isnan(columNum) || columNum <= 0
                columNum = size(Data,2);
            end
            DataNew = app.reflowGrid(Data, RowsNum, columNum);
            app.applyTableDimensions(RowsNum, columNum);
            app.LayoutTable.Data = DataNew;
            app.revalidateGrid();
        end

        % --- Button pushed: Import ---
        function importBtn(app, ~)
            [filename, filepath] = erplab_uigetfile({'*.tsv;*.txt'}, 'Load Gird Locations');
            if isequal(filename,0)
                return;
            end
            try
                DataInput = readtable([filepath,filename], 'FileType','text', 'PreserveVariableNames', true);
                CellNum = 2;
            catch
                app.MessageLabel.Text = sprintf('Cannot import:%s%s', filepath, filename);
                return;
            end
            if isempty(DataInput)
                app.MessageLabel.Text = 'The file is empty.';
                return;
            end

            DataInput = table2cell(DataInput);
            [~, columns] = size(DataInput);
            if columns==1
                app.MessageLabel.Text = 'Import is invalid';
                return;
            end
            DataInput = DataInput(:,2:end);

            DataOutput = app.gridlocationTranscell(DataInput, CellNum);
            [Data, EmptyStr] = f_checktable_gridlocations_waviewer(DataOutput, app.AllabelArray);

            Numrows    = size(Data,1);
            Numcolumns = size(Data,2);
            app.applyTableDimensions(Numrows, Numcolumns);
            app.LayoutTable.Data       = Data;
            app.ColumnsEditField.Value = num2str(Numcolumns);
            app.RowsEditField.Value    = num2str(Numrows);
            app.refreshLabelsTable();
            app.highlightSelectedLabel();
            if ~strcmp(EmptyStr,',') && ~strcmp(string(EmptyStr)," ") && ~isempty(EmptyStr)
                app.MessageLabel.Text = sprintf('%s do(es) not match with items in the right panel.', EmptyStr);
            else
                app.MessageLabel.Text = app.LegendText;
            end
        end

        % --- Button pushed: Export ---
        function exportBtn(app, ~)
            pathstr = pwd;
            namedef = 'GridLocations_viewer';
            [erpfilename, erppathname, ~] = erplab_uiputfile({'*.tsv'}, 'Save Grid Locations as', fullfile(pathstr,namedef));
            if isequal(erpfilename,0)
                disp('User selected Cancel')
                return
            end
            [~, erpfilename, ~] = fileparts(erpfilename);
            ext = '.tsv';
            erpFilename = char(strcat(erppathname, erpfilename, ext));

            Data = app.LayoutTable.Data;
            Data = f_checktable_gridlocations_waviewer(Data, app.AllabelArray);
            [nrows, ncols] = size(Data);
            Data = app.gridlocationRespaceAddnan(Data);

            formatSpec = '';
            for jj = 1:ncols+1
                if jj==ncols+1
                    formatSpec = strcat(formatSpec,'%s');
                else
                    formatSpec = strcat(formatSpec,'%s\t',32);
                end
                if jj==1
                    columName{1,jj} = '';
                else
                    columName{1,jj} = ['Column',32,num2str(jj-1)];
                end
            end
            formatSpec = strcat(formatSpec,'\n');

            fileID = fopen(erpFilename,'w');
            fprintf(fileID, formatSpec, columName{1,:});
            for row = 1:nrows
                rowdata = cell(1,ncols+1);
                rowdata{1,1} = char(['Row',num2str(row)]);
                for jj = 1:ncols
                    rowdata{1,jj+1} = Data{row,jj};
                end
                fprintf(fileID, formatSpec, rowdata{1,:});
            end
            fclose(fileID);
            disp(['The file for ERP Viewer Grid layout was created at <a href="matlab: open(''' erpFilename ''')">' erpFilename '</a>'])
        end
    end

    % --- pure data helpers (no GUI state) ---
    methods (Static, Access = private)

        function Labels_used = uniqueStr(Data)
            Labels_used{1,1} = Data{1,1};
            for ii = 1:size(Data,1)
                for jj = 1:size(Data,2)
                    if ismember_bc2(Data{ii,jj}, Labels_used)
                    else
                        if ~isempty(char(Data{ii,jj}))
                            Labels_used{length(Labels_used)+1,1} = Data{ii,jj};
                        end
                    end
                end
            end
        end

        function DataNew = reflowGrid(Data, nrows, ncols)
            % Re-flows existing cell contents (row-major) into a new nrows x ncols grid.
            DataOld = reshape(Data', 1, []);
            DataNew = cell(nrows, ncols);
            count = 0;
            for r = 1:nrows
                for c = 1:ncols
                    count = count+1;
                    if count <= numel(DataOld)
                        DataNew{r,c} = DataOld{count};
                    else
                        DataNew{r,c} = '';
                    end
                end
            end
        end

        function DataOutput = gridlocationTranscell(DataInput, CellNum)
            % Converts an imported tsv/txt table (as a cell array) into the
            % LayoutTable's plain-string grid format.
            if CellNum~=1
                if strcmpi(DataInput{1,size(DataInput,2)},'<missing>')
                    DataInputTras = cell(size(DataInput,1), size(DataInput,2)-1);
                    for ii = 1:size(DataInput,1)
                        for jj = 1:size(DataInput,2)-1
                            DataInputTras{ii,jj} = DataInput{ii,jj};
                        end
                    end
                    DataInput = DataInputTras;
                end
                if strcmpi(DataInput{size(DataInput,1),1},'<missing>')
                    DataInputTras1 = cell(size(DataInput,1)-1, size(DataInput,2));
                    for ii = 1:size(DataInput,1)-1
                        for jj = 1:size(DataInput,2)
                            DataInputTras1{ii,jj} = DataInput{ii,jj};
                        end
                    end
                    DataInput = DataInputTras1;
                end
            end

            DataOutput = cell(size(DataInput,1),size(DataInput,2));
            if CellNum==1
                if iscell(DataInput)
                    DataNum = zeros(size(DataInput,1),1);
                    for ii = 1:size(DataInput,1)
                        chanlabels = regexp(DataInput{ii,1},'.*?\s+', 'match');
                        DataNum(ii) = length(chanlabels);
                    end
                    for ii = 1:size(DataInput,1)
                        for jj = 1:max(DataNum(:))
                            DataOutput{ii,jj} = char('');
                        end
                    end
                    for ii = 1:size(DataInput,1)
                        chanlabels = regexp(DataInput{ii,1},'.*?\s+', 'match');
                        for jj = 1:length(chanlabels)
                            if ischar(chanlabels{jj})
                                DataOutput{ii,jj} = strtrim(char(chanlabels{jj}));
                            elseif isnumeric(chanlabels{jj})
                                DataOutput{ii,jj} = num2str(chanlabels{jj});
                            end
                        end
                    end
                    return;
                end
            else
                for ii = 1:size(DataInput,1)
                    for jj = 1:size(DataInput,2)
                        if ~ismissing(DataInput{ii,jj})
                            if ~isempty(DataInput{ii,jj})
                                if ischar(DataInput{ii,jj})
                                    DataOutput{ii,jj} = char(DataInput{ii,jj});
                                elseif isnumeric(DataInput{ii,jj})
                                    if isnan(DataInput{ii,jj})
                                        DataOutput{ii,jj} = char('');
                                    else
                                        DataOutput{ii,jj} = char(num2str(DataInput{ii,jj}));
                                    end
                                else
                                    DataOutput{ii,jj} = char('');
                                end
                            else
                                DataOutput{ii,jj} = char('');
                            end
                        else
                            DataOutput{ii,jj} = char('');
                        end
                    end
                end
                return;
            end

            if isnumeric(DataInput)
                for ii = 1:size(DataInput,1)
                    for jj = 1:size(DataInput,2)
                        DataOutput{ii,jj} = num2str(DataInput(ii,jj));
                    end
                end
            end
        end

        function data = gridlocationRespaceAddnan(data)
            % Sanitizes label text for tsv export: strips spaces, replaces
            % filesystem-unsafe characters, and marks empty cells with a space.
            [nrows,ncols] = size(data);
            for ii = 1:nrows
                for jj = 1:ncols
                    labx = strrep(char(data{ii,jj}), ' ', '');
                    if ~isempty(labx)
                        labx = regexprep(labx,'\\|\/|\*|\#|\$|\@','_');
                    else
                        labx = ' ';
                    end
                    data{ii,jj} = labx;
                end
            end
        end
    end

    % --- Component initialization ---
    methods (Access = private)

        function createComponents(app)
            % Extracted from the original .fig: 628 x 578, with the message
            % legend box at height 53. A uifigure uilabel's line-height (web
            % renderer) is noticeably taller than the classic uicontrol text
            % style's (Java renderer) at the same FontSize, so the original
            % box is too short for its 5-line legend text under uifigure.
            % TABLE_Y_SHIFT gives that box more room by pushing the two big
            % tables up (and growing the figure by the same amount, so their
            % margin from the top of the window is unchanged).
            TABLE_Y_SHIFT = 20;
            FIG_W = 628; FIG_H = 578 + TABLE_Y_SHIFT;

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 FIG_W FIG_H];
            app.UIFigure.Name     = 'ERP_layoutstringGUI';
            app.UIFigure.Resize   = 'off';

            % Main grid layout table
            app.LayoutTable = uitable(app.UIFigure);
            app.LayoutTable.Position = [11 110+TABLE_Y_SHIFT 456 459];
            app.LayoutTable.ColumnEditable   = true;
            app.LayoutTable.CellEditCallback = createCallbackFcn(app, @layoutTableCellEdit, true);

            % Labels list: single-column table so per-row font color
            % (blue/red/black) can be applied via addStyle.
            app.LabelsTable = uitable(app.UIFigure);
            app.LabelsTable.Position = [480 111+TABLE_Y_SHIFT 139 458];
            app.LabelsTable.ColumnName  = {' '};
            app.LabelsTable.RowName     = {};
            app.LabelsTable.ColumnWidth = {'auto'};
            app.LabelsTable.ColumnEditable = false;
            app.LabelsTable.SelectionType = 'row';
            app.LabelsTable.Multiselect    = 'off';
            app.LabelsTable.CellSelectionCallback = createCallbackFcn(app, @labelsTableSelectionChanged, true);
            app.LabelsTable.FontSize = 12;

            % Rows / Columns controls
            app.RowsLabel = uilabel(app.UIFigure);
            app.RowsLabel.Position = [6 19 49 19];
            app.RowsLabel.Text = 'Rows';
            app.RowsLabel.HorizontalAlignment = 'center';
            app.RowsLabel.FontSize = 12;

            app.RowsEditField = uieditfield(app.UIFigure, 'text');
            app.RowsEditField.Position = [54 16 56 28];
            app.RowsEditField.HorizontalAlignment = 'center';
            app.RowsEditField.FontSize = 12;
            app.RowsEditField.ValueChangedFcn = createCallbackFcn(app, @rowsEditFieldChanged, true);

            app.ColumnsLabel = uilabel(app.UIFigure);
            app.ColumnsLabel.Position = [132 20 49 19];
            app.ColumnsLabel.Text = 'Columns';
            app.ColumnsLabel.HorizontalAlignment = 'center';
            app.ColumnsLabel.FontSize = 12;

            app.ColumnsEditField = uieditfield(app.UIFigure, 'text');
            app.ColumnsEditField.Position = [181 16 56 28];
            app.ColumnsEditField.HorizontalAlignment = 'center';
            app.ColumnsEditField.FontSize = 12;
            app.ColumnsEditField.ValueChangedFcn = createCallbackFcn(app, @columnsEditFieldChanged, true);

            % Message / legend text
            app.MessageLabel = uilabel(app.UIFigure);
            app.MessageLabel.Position = [150 54 470 53+TABLE_Y_SHIFT];
            app.MessageLabel.HorizontalAlignment = 'left';
            app.MessageLabel.VerticalAlignment   = 'top';
            app.MessageLabel.WordWrap = 'on';
            app.MessageLabel.FontSize = 12;

            % Buttons
            app.SetDefaultButton = uibutton(app.UIFigure, 'push');
            app.SetDefaultButton.Position = [263 10 75 42];
            app.SetDefaultButton.Text = 'Set Default';
            app.SetDefaultButton.FontSize = 12;
            app.SetDefaultButton.ButtonPushedFcn = createCallbackFcn(app, @setDefaultBtn, true);

            app.ClearAllButton = uibutton(app.UIFigure, 'push');
            app.ClearAllButton.Position = [360 10 75 42];
            app.ClearAllButton.Text = 'Clear All';
            app.ClearAllButton.FontSize = 12;
            app.ClearAllButton.ButtonPushedFcn = createCallbackFcn(app, @clearAllBtn, true);

            app.ImportButton = uibutton(app.UIFigure, 'push');
            app.ImportButton.Position = [54 78 60 31];
            app.ImportButton.Text = 'Import';
            app.ImportButton.FontSize = 12;
            app.ImportButton.ButtonPushedFcn = createCallbackFcn(app, @importBtn, true);

            app.ExportButton = uibutton(app.UIFigure, 'push');
            app.ExportButton.Position = [53 47 61 31];
            app.ExportButton.Text = 'Export';
            app.ExportButton.FontSize = 12;
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @exportBtn, true);

            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.Position = [450 11 76 42];
            app.CancelButton.Text = 'Cancel';
            app.CancelButton.FontSize = 12;
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @cancelBtn, true);

            app.OKButton = uibutton(app.UIFigure, 'push');
            app.OKButton.Position = [537 10 76 42];
            app.OKButton.Text = 'OK';
            app.OKButton.FontSize = 12;
            app.OKButton.ButtonPushedFcn = createCallbackFcn(app, @okBtn, true);

            app.UIFigure.Visible = 'on';
        end
    end

    % --- App creation and deletion ---
    methods (Access = public)

        function app = ERP_layoutstringGUI(varargin)
            createComponents(app)
            registerApp(app, app.UIFigure)
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))
            if nargout == 0
                clear app
            end
        end

        function delete(app)
            delete(app.UIFigure)
        end
    end
end
