% DQ_Table_GUI
% "ERPLAB Data Quality Measures - Table Viewer" - shows per-channel/per-time-window
% Data Quality measures for an ERPset, with optional color-heatmap or outlier
% highlighting.
%
% NOTE: Migrated from GUIDE (.fig) to a programmatic uifigure-based classdef
% app. Original .fig archived outside ERPLAB.
% Migrated to .m: July 2026 by Kurt Winsler
%
% Calling convention unchanged from the original (non-modal - opens and
% returns immediately, no output captured by any caller):
%   DQ_Table_GUI(ERP, ALLERP, current_ERP, guiwin_num)
%   DQ_Table_GUI(ERP, ALLERP, current_ERP, guiwin_num, 'EEG')

classdef DQ_Table_GUI < matlab.apps.AppBase

    properties (Access = public)
        UIFigure              matlab.ui.Figure
        Panel1                matlab.ui.container.Panel
        Panel2                matlab.ui.container.Panel
        LabelERPsetTitle      matlab.ui.control.Label
        DropdownActiveErpset  matlab.ui.control.DropDown
        LabelDQType           matlab.ui.control.Label
        DropdownDQType        matlab.ui.control.DropDown
        CheckboxSDCorrection  matlab.ui.control.CheckBox
        LabelBin              matlab.ui.control.Label
        PopupBin              matlab.ui.control.DropDown
        LabelTimeWindows      matlab.ui.control.Label
        DQTable               matlab.ui.control.Table
        LabelStdFromMean      matlab.ui.control.Label
        CheckboxHeatmap       matlab.ui.control.CheckBox
        CheckboxTextLabels    matlab.ui.control.CheckBox
        CheckboxOutliers      matlab.ui.control.CheckBox
        LabelChannels         matlab.ui.control.Label
        EditChannels          matlab.ui.control.EditField
        EditStdWindow         matlab.ui.control.EditField
        ButtonBrowseChan      matlab.ui.control.Button
        LabelOpenNewWin       matlab.ui.control.Label
        DropdownNewErpWin     matlab.ui.control.DropDown
        ButtonSelectERP       matlab.ui.control.Button
        LabelExport           matlab.ui.control.Label
        ButtonMat             matlab.ui.control.Button
        ButtonXls             matlab.ui.control.Button
        ButtonHelp            matlab.ui.control.Button
        ButtonDone            matlab.ui.control.Button
    end

    properties (Access = private)
        ERP
        ALLERP
        orig_data
        orig_RowName
        orig_indxlistch
        indxlistch
        listch
        heatmap_on = 0
        outliers_on = 0
    end

    properties (Constant, Access = private)
        PointwiseStr = {'Point-wise SEM', 'Point-wise SEM, GrandAvg RMS', ...
            'Point-wise SEM Pool ERPSETs, RMS GrandAvg Combine','Point-wise SEM Pool ERPSETs, mean GrandAvg combine',...
            'Point-wise SEM (Corrected), GrandAvg RMS', ...
            'Point-wise SEM Pool ERPSETs(Corrected), RMS GrandAvg Combine',...
            'Point-wise SEM Pool ERPSETs(Corrected), mean GrandAvg combine'};
        OutlierColor = [1 0 0];
    end

    methods (Access = private)

        function startupFcn(app, varargin)
            ERP          = varargin{1};
            ALLERP       = varargin{2};
            current_ERP  = varargin{3};
            guiwin_num   = varargin{4};
            if numel(varargin) >= 5 && strcmpi(varargin{5}, 'EEG')
                datatype = 'EEG';
            else
                datatype = 'ERP';
            end

            if guiwin_num ~= 1
                offset_GUI = 25 * randi([1 10],1);
                figpos = app.UIFigure.Position;
                app.UIFigure.Position = [figpos(1)-offset_GUI, figpos(2)-offset_GUI, figpos(3), figpos(4)];
            end

            try
                assert(isempty(ERP)==0)
                assert(isfield(ERP,'dataquality'))
                assert(strcmp(ERP.dataquality(1).type,'empty')==0)
            catch
                beep
                warning('Data Quality not present in current ERPset?')
                delete(app.UIFigure);
                return
            end

            n_erp = numel(ALLERP);
            if n_erp == 0
                % case of showing aSME preavg
                erp_names = ERP.erpname;
                app.LabelERPsetTitle.Text = 'Selected EEGset:';
                app.LabelOpenNewWin.Visible = 'off';
                app.DropdownNewErpWin.Visible = 'off';
                app.ButtonSelectERP.Visible = 'off';
                app.DropdownActiveErpset.Items = {erp_names};
                app.DropdownActiveErpset.ItemsData = 1;
                app.DropdownActiveErpset.Value = 1;
                app.DropdownActiveErpset.Enable = 'off';
            else
                erp_names = cell(1,n_erp);
                for i = 1:n_erp
                    erp_names{i} = ALLERP(i).erpname;
                end
                if strcmpi(datatype, 'EEG')
                    app.LabelERPsetTitle.Text  = 'Selected EEGset:';
                    app.LabelOpenNewWin.Text   = 'Open new EEGset Window';
                    app.ButtonSelectERP.Text   = 'Select EEGset';
                else
                    app.LabelERPsetTitle.Text  = 'Selected ERPset:';
                    app.LabelOpenNewWin.Text   = 'Open new ERPset Window';
                    app.ButtonSelectERP.Text   = 'Select ERPset';
                end
                app.DropdownActiveErpset.Items     = erp_names;
                app.DropdownActiveErpset.ItemsData = 1:n_erp;
                app.DropdownActiveErpset.Value     = current_ERP;
                app.DropdownNewErpWin.Items        = erp_names;
                app.DropdownNewErpWin.ItemsData    = 1:n_erp;
                app.DropdownNewErpWin.Value        = current_ERP;
            end

            n_dq = numel(ERP.dataquality);
            type_names = cell(1,n_dq);
            for i=1:n_dq
                type_names{i} = ERP.dataquality(i).type;
            end
            app.DropdownDQType.Items     = type_names;
            app.DropdownDQType.ItemsData = 1:n_dq;

            where_aSME      = strcmpi('aSME', type_names);
            where_aSME_corr = strcmpi('aSME (Corrected)', type_names);
            if any(where_aSME)
                indx_type = find(where_aSME,1);
            elseif any(where_aSME_corr)
                indx_type = find(where_aSME_corr,1);
            else
                indx_type = n_dq;
            end
            app.DropdownDQType.Value = indx_type;

            try
                [n_elec, n_tw, n_bin] = size(ERP.dataquality(indx_type).data);
            catch
                [n_elec, n_tw, n_bin] = size(ERP.dataquality.data);
            end
            if n_elec == 0
                n_bin = ERP.nbin;
            end

            n_bin_names = numel(ERP.bindescr);
            bin_names = cell(1,n_bin);
            if n_bin_names == n_bin
                for i=1:n_bin
                    bin_names{i} = ['BIN ' num2str(i) ' - ' ERP.bindescr{i}];
                end
            else
                for i=1:n_bin
                    bin_names{i} = ['BIN ' num2str(i)];
                end
            end
            app.PopupBin.Items     = bin_names;
            app.PopupBin.ItemsData = 1:n_bin;
            app.PopupBin.Value     = 1;

            selected_DQ_type = app.DropdownDQType.Value;
            selected_bin     = app.PopupBin.Value;
            table_data = ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);

            pSEM = 0;
            if isempty(table_data)
                if any(strcmpi(app.PointwiseStr, ERP.dataquality(selected_DQ_type).type)) && isempty(ERP.binerror) == 0
                    table_data = ERP.binerror(:,:,selected_bin);
                    pSEM = 1;
                else
                    table_data = nan(1);
                    disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
                end
            end

            app.DQTable.Data = table_data;
            app.orig_data = table_data;

            if isfield(ERP.chanlocs,'labels') && numel(ERP.chanlocs) == n_elec
                elec_labels = cell(1,n_elec);
                for i=1:n_elec
                    elec_labels{i} = ERP.chanlocs(i).labels;
                end
            else
                elec_labels = cell(1,ERP.nchan);
                for i=1:ERP.nchan
                    elec_labels{i} = i;
                end
            end
            app.DQTable.RowName = elec_labels;
            app.orig_RowName = elec_labels;

            % Time-window labels. Point-wise measures (pSEM) have one column
            % per sample point rather than per time-window, so label each
            % column with its latency instead of a window range.
            if pSEM == 1
                tw_labels = cell(1, size(table_data,2));
                for i = 1:numel(tw_labels)
                    tw_labels{i} = num2str(round(ERP.times(i)));
                end
            elseif isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && app.CheckboxTextLabels.Value == 1
                tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
            elseif isempty(ERP.dataquality(selected_DQ_type).times)
                tw_labels = [];
            elseif n_tw == 0
                tw_labels = 'No data here. Perhaps it was cleared?';
            else
                tw_labels = cell(1,n_tw);
                for i=1:n_tw
                    tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
                end
            end
            app.DQTable.ColumnName = tw_labels;

            desired_fontsize = erpworkingmemory('fontsizeGUI');
            try
                app.DQTable.FontSize = desired_fontsize;
            catch
                app.DQTable.FontSize = 11;
            end
            app.heatmap_on = 0;

            app.prepareChannelList(ERP);
            app.orig_indxlistch = app.indxlistch;

            app.EditStdWindow.Enable       = 'off';
            app.EditChannels.Enable        = 'off';
            app.ButtonBrowseChan.Enable    = 'off';
            app.CheckboxSDCorrection.Enable = 'off';
            app.CheckboxSDCorrection.Visible = 'off';

            app.outliers_on = 0;
            app.ERP = ERP;
            if n_erp == 0
                app.ALLERP = ERP;
            else
                app.ALLERP = ALLERP;
            end
        end

        % --- shared "Prepare List of current Channels" logic ---
        function prepareChannelList(app, ERP)
            nchan = ERP.nchan;
            if ~isfield(ERP.chanlocs,'labels')
                for e=1:nchan
                    ERP.chanlocs(e).labels = ['Ch' num2str(e)];
                end
            end
            listch = cell(1,nchan);
            for ch = 1:nchan
                listch{ch} = [num2str(ch) ' = ' ERP.chanlocs(ch).labels];
            end
            app.listch = listch;

            chanArray = 1:ERP.nchan;
            app.indxlistch = chanArray;
            app.EditChannels.Value = vect2colon(chanArray, 'Delimiter', 'off');
        end

        % --- Selected DQ Measure changed ---
        function dqTypeChanged(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            selected_bin     = app.PopupBin.Value;

            pSEM = 0;
            if isempty(app.ERP.dataquality(selected_DQ_type).data)
                if any(strcmpi(app.PointwiseStr, app.ERP.dataquality(selected_DQ_type).type)) && isempty(app.ERP.binerror) == 0
                    table_data = app.ERP.binerror(:,:,selected_bin);
                    pSEM = 1;
                else
                    table_data = nan(1);
                    disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
                end
            else
                if strcmp(app.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(app.ERP.binerror) == 0
                    table_data = app.ERP.dataquality(selected_DQ_type).data.SD_bias(:,:,selected_bin);
                    app.CheckboxSDCorrection.Enable = 'on';
                    app.CheckboxSDCorrection.Visible = 'on';
                else
                    table_data = app.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
                    app.CheckboxSDCorrection.Enable = 'off';
                    app.CheckboxSDCorrection.Visible = 'off';
                end
            end

            app.DQTable.Data = table_data;
            app.orig_data = table_data;

            ERP = app.ERP;
            if strcmp(app.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(app.ERP.binerror) == 0
                [~, n_tw, ~] = size(ERP.dataquality(selected_DQ_type).data.SD_bias);
            else
                [~, n_tw, ~] = size(ERP.dataquality(selected_DQ_type).data);
            end
            if pSEM == 1
                tw_labels = cell(1, size(table_data,2));
                for i = 1:numel(tw_labels)
                    tw_labels{i} = num2str(round(ERP.times(i)));
                end
            elseif isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && app.CheckboxTextLabels.Value == 1
                tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
            elseif isempty(ERP.dataquality(selected_DQ_type).times)
                tw_labels = [];
            elseif n_tw == 0
                tw_labels = {'No data here - measure cleared?'};
            else
                tw_labels = cell(1,n_tw);
                for i=1:n_tw
                    tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
                end
            end
            app.DQTable.ColumnName = tw_labels;

            if app.heatmap_on
                app.refreshHeatmap();
            end
            if app.outliers_on
                app.clearHeatmapStyle();
                app.heatmap_on = 0;
                app.refreshOutliers();
                app.CheckboxOutliers.Value = 1;
            end
        end

        % --- Selected BIN changed ---
        function binChanged(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            selected_bin     = app.PopupBin.Value;

            if isempty(app.ERP.dataquality(selected_DQ_type).data)
                if any(strcmpi(app.PointwiseStr, app.ERP.dataquality(selected_DQ_type).type)) && isempty(app.ERP.binerror) == 0
                    table_data = app.ERP.binerror(:,:,selected_bin);
                else
                    table_data = nan(1);
                    disp('DQ data not found for this DQ type and bin. Perhaps it has been cleared?');
                end
            else
                table_data = app.ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
            end

            app.DQTable.Data = table_data;
            app.orig_data = table_data;

            % if user switches bin and both heatmap & outliers on,
            % use shortcircuit to clear outliers and redraw heatmap only
            if app.heatmap_on
                app.clearOutliersStyle();
                app.refreshHeatmap();
                app.outliers_on = 0;
                app.CheckboxOutliers.Value = 0;
            end

            % if only outliers on, then clear heatmap and redraw outliers
            if app.outliers_on
                app.clearHeatmapStyle();
                app.heatmap_on = 0;
                app.refreshOutliers();
                app.CheckboxOutliers.Value = 1;
            end
        end

        % --- Text labels checkbox changed ---
        function textLabelsChanged(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            ERP = app.ERP;

            pSEM = isempty(ERP.dataquality(selected_DQ_type).data) && ...
                any(strcmpi(app.PointwiseStr, ERP.dataquality(selected_DQ_type).type)) && ...
                isempty(ERP.binerror) == 0;

            if strcmp(app.ERP.dataquality(selected_DQ_type).type,'SD Across Trials') && isempty(app.ERP.binerror) == 0
                [~, n_tw, ~] = size(ERP.dataquality(selected_DQ_type).data.SD_bias);
            else
                [~, n_tw, ~] = size(ERP.dataquality(selected_DQ_type).data);
            end
            if pSEM
                tw_labels = cell(1, size(app.DQTable.Data,2));
                for i = 1:numel(tw_labels)
                    tw_labels{i} = num2str(round(ERP.times(i)));
                end
            elseif isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && app.CheckboxTextLabels.Value == 1
                tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
            elseif isempty(ERP.dataquality(selected_DQ_type).times)
                tw_labels = [];
            elseif n_tw == 0
                tw_labels = {'No data here - measure cleared?'};
            else
                tw_labels = cell(1,n_tw);
                for i=1:n_tw
                    tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
                end
            end
            app.DQTable.ColumnName = tw_labels;

            if app.heatmap_on
                app.refreshHeatmap();
            end
        end

        % --- Export buttons ---
        function exportXls(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            save_data_quality(app.ERP, [], 'xlsx', selected_DQ_type)
        end

        function exportMat(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            save_data_quality(app.ERP, [], 'mat', selected_DQ_type)
        end

        function showHelp(app, ~)
            web https://github.com/lucklab/erplab/wiki/ERPLAB-Data-Quality-Metrics -browser
        end

        function doneBtn(app, ~)
            delete(app.UIFigure);
        end

        % --- Color heatmap checkbox ---
        function heatmapToggled(app, ~)
            heatmap_on = app.CheckboxHeatmap.Value;

            if heatmap_on == 1
                % if heatmap_on, then outliers not possible so clear outliers
                app.clearOutliersStyle();
                app.outliers_on = 0;
                app.CheckboxOutliers.Value = 0;
                app.EditStdWindow.Enable    = 'off';
                app.EditChannels.Enable     = 'off';
                app.ButtonBrowseChan.Enable = 'off';

                app.refreshHeatmap();
                app.heatmap_on = 1;
            else
                app.clearHeatmapStyle();
                app.heatmap_on = 0;

                % if outliers is on, then keep outliers active
                if app.outliers_on == 1
                    app.refreshOutliers();
                end
            end
        end

        function refreshHeatmap(app)
            color_map = viridis;
            data = app.DQTable.Data;
            if ~isnumeric(data) || isempty(data)
                disp('Cannot show text-labels while color heatmap is activated')
                return
            end
            data_min = min(data(:));
            range_val = max(data(:)) - data_min;
            range_colormap = size(color_map,1); % as in, 256 shades?
            val_increase_per_shade = range_val / range_colormap;

            % Clear styles AND fully cycle Data (empty, then restore) before
            % restyling -- removeStyle alone left stale per-cell styles from
            % a previous mode visible on some cells for wide tables; forcing
            % the table through an empty state invalidates any leftover
            % per-cell style/position association.
            removeStyle(app.DQTable);
            app.DQTable.Data = {};
            drawnow;
            app.DQTable.Data = data;
            drawnow;
            shade_idx = round((data - data_min) / val_increase_per_shade);
            shade_idx = max(1, min(range_colormap, shade_idx));
            % Batch all cells sharing the same shade into one addStyle call
            % each, instead of one call per cell -- calling addStyle
            % per-cell is far too slow for wide tables (e.g. point-wise
            % measures with one column per sample point).
            for shade = unique(shade_idx(:))'
                [r, c] = find(shade_idx == shade);
                addStyle(app.DQTable, uistyle('BackgroundColor', color_map(shade,:)), 'cell', [r c]);
            end
        end

        function clearHeatmapStyle(app)
            removeStyle(app.DQTable);
        end

        % --- Open new ERPset/EEGset window ---
        function selectERPBtn(app, ~)
            selected_erpset = app.DropdownNewErpWin.Value;
            sel_ERP = app.ALLERP(selected_erpset);
            DQ_Table_GUI(sel_ERP, app.ALLERP, selected_erpset, 2);
        end

        % --- Outliers checkbox ---
        function outliersToggled(app, ~)
            outliers_on = app.CheckboxOutliers.Value;

            if outliers_on == 1
                app.EditStdWindow.Enable    = 'on';
                app.EditChannels.Enable     = 'on';
                app.ButtonBrowseChan.Enable = 'on';
            else
                app.EditStdWindow.Enable    = 'off';
                app.EditChannels.Enable     = 'off';
                app.ButtonBrowseChan.Enable = 'off';
            end

            app.outliers_on = outliers_on;

            if app.outliers_on == 1
                % if heatmap is currently on, stop it and turn its state off
                % before applying outliers fxn
                if app.heatmap_on == 1
                    app.clearHeatmapStyle();
                    app.heatmap_on = 0;
                    app.CheckboxHeatmap.Value = 0;
                    app.refreshOutliers();
                else
                    app.clearOutliersStyle();
                    app.refreshOutliers();
                end
            else
                % outliers off - redraw initial data/channels without outliers
                app.clearOutliersStyle();
            end
        end

        function refreshOutliers(app)
            data = app.orig_data;
            chans_to_use = app.indxlistch;
            data = data(chans_to_use,:);
            n_elec = length(chans_to_use);
            ERPtouse = app.ERP.chanlocs;

            elec_labels = cell(1,n_elec);
            for i=1:n_elec
                elec_labels{i} = ERPtouse(chans_to_use(i)).labels;
            end

            % Clear styles AND fully cycle Data (empty, then repopulate)
            % before restyling -- removeStyle alone left stale per-cell
            % styles from a previous mode visible on some cells for wide
            % tables; forcing the table through an empty state invalidates
            % any leftover per-cell style/position association.
            removeStyle(app.DQTable);
            app.DQTable.Data = {};
            drawnow;
            app.DQTable.RowName = elec_labels;
            app.DQTable.Data = data;
            drawnow;

            col_means = mean(data,1);
            col_std   = std(data,0,1);
            chosen_std = str2double(app.EditStdWindow.Value);

            neg_thresh = col_means - chosen_std*col_std;
            pos_thresh = col_means + chosen_std*col_std;
            % Batch every outlier cell into a single addStyle call instead
            % of one call per cell -- far too slow for wide tables (e.g.
            % point-wise measures with one column per sample point).
            [r, c] = find(data < neg_thresh | data > pos_thresh);
            if ~isempty(r)
                addStyle(app.DQTable, uistyle('BackgroundColor', app.OutlierColor), 'cell', [r c]);
            end
        end

        function clearOutliersStyle(app)
            removeStyle(app.DQTable);
            app.DQTable.Data = app.orig_data;
            app.DQTable.RowName = app.orig_RowName;
            app.indxlistch = app.orig_indxlistch;
            app.EditChannels.Value = vect2colon(app.orig_indxlistch, 'Delimiter', 'off');
        end

        function stdWindowChanged(app, ~)
            app.refreshOutliers();
        end

        function chWindowChanged(app, ~)
            ch = app.EditChannels.Value;
            nch = length(app.listch);

            ch_val = eval(ch); % allows MATLAB range syntax (e.g. 1:5, [1 3 5])

            if ~isempty(ch)
                tf = app.checkchannels(ch_val, nch, 1);
                if tf
                    return
                end
                app.EditChannels.Value = vect2colon(ch_val, 'Delimiter', 'off');
                app.indxlistch = ch_val;
                app.refreshOutliers();
            else
                msgboxText =  'Not valid channel';
                title = 'ERPLAB: channel GUI input';
                errorfound(msgboxText, title);
                return
            end
        end

        function browseChannelsBtn(app, ~)
            listch = app.listch;
            indxlistch = app.indxlistch;
            indxlistch = indxlistch(indxlistch<=length(listch));
            titlename = 'Select Channel(s)';
            if ~isempty(listch)
                ch = browsechanbinGUI(listch, indxlistch, titlename);
                if ~isempty(ch)
                    app.EditChannels.Value = vect2colon(ch, 'Delimiter', 'off');
                    app.indxlistch = ch;
                    app.refreshOutliers();
                else
                    disp('User selected Cancel')
                    return
                end
            else
                msgboxText =  'No channel information was found';
                title = 'ERPLAB: ploterp GUI input';
                errorfound(msgboxText, title);
                return
            end
        end

        % --- Selected ERPset dropdown changed ---
        function activeErpsetChanged(app, ~)
            newactive = app.DropdownActiveErpset.Value;
            ERPs = app.ALLERP;
            ERP = ERPs(newactive);

            n_dq = numel(ERP.dataquality);
            type_names = cell(1,n_dq);
            for i=1:n_dq
                type_names{i} = ERP.dataquality(i).type;
            end
            app.DropdownDQType.Items     = type_names;
            app.DropdownDQType.ItemsData = 1:n_dq;
            app.DropdownDQType.Value     = n_dq;

            [n_elec, n_tw, n_bin] = size(ERP.dataquality(n_dq).data);
            if n_elec == 0
                n_bin = ERP.nbin;
            end

            n_bin_names = numel(ERP.bindescr);
            bin_names = cell(1,n_bin);
            if n_bin_names == n_bin
                for i=1:n_bin
                    bin_names{i} = ['BIN ' num2str(i) ' - ' ERP.bindescr{i}];
                end
            else
                for i=1:n_bin
                    bin_names{i} = ['BIN ' num2str(i)];
                end
            end
            app.PopupBin.Items     = bin_names;
            app.PopupBin.ItemsData = 1:n_bin;

            selected_DQ_type = app.DropdownDQType.Value;
            selected_bin     = app.PopupBin.Value;

            table_data = ERP.dataquality(selected_DQ_type).data(:,:,selected_bin);
            app.DQTable.Data = table_data;
            app.orig_data = table_data;

            if isfield(ERP.chanlocs,'labels') && numel(ERP.chanlocs) == n_elec
                elec_labels = cell(1,n_elec);
                for i=1:n_elec
                    elec_labels{i} = ERP.chanlocs(i).labels;
                end
            else
                elec_labels = cell(1,ERP.nchan);
                for i=1:ERP.nchan
                    elec_labels{i} = i;
                end
            end
            app.DQTable.RowName = elec_labels;

            if isfield(ERP.dataquality(selected_DQ_type),'time_window_labels') && isempty(ERP.dataquality(selected_DQ_type).time_window_labels) == 0 && app.CheckboxTextLabels.Value == 1
                tw_labels = ERP.dataquality(selected_DQ_type).time_window_labels;
            elseif isempty(ERP.dataquality(selected_DQ_type).times)
                tw_labels = [];
            else
                tw_labels = cell(1,n_tw);
                for i=1:n_tw
                    tw_labels{i} = [num2str(ERP.dataquality(selected_DQ_type).times(i,1)) ' : ' num2str(ERP.dataquality(selected_DQ_type).times(i,2))];
                end
            end
            if n_tw == 0
                tw_labels = 'No data here. Perhaps it was cleared?';
            end
            app.DQTable.ColumnName = tw_labels;

            desired_fontsize = erpworkingmemory('fontsizeGUI');
            app.DQTable.FontSize = desired_fontsize;
            app.heatmap_on = app.CheckboxHeatmap.Value;

            app.prepareChannelList(ERP);

            app.EditStdWindow.Enable    = 'off';
            app.EditChannels.Enable     = 'off';
            app.ButtonBrowseChan.Enable = 'off';

            app.ERP = ERP;
            app.ALLERP = ERPs;

            % clear all previously set options
            app.CheckboxOutliers.Value = 0;
            app.CheckboxTextLabels.Value = 0;
            app.EditStdWindow.Enable    = 'off';
            app.EditChannels.Enable     = 'off';
            app.ButtonBrowseChan.Enable = 'off';

            if app.heatmap_on == 1
                app.clearOutliersStyle();
                app.outliers_on = 0;
                app.CheckboxOutliers.Value = 0;
                app.refreshHeatmap();
                app.heatmap_on = 1;
            else
                app.clearHeatmapStyle();
                app.heatmap_on = 0;
                if app.outliers_on == 1
                    app.refreshOutliers();
                end
            end
        end

        % --- Apply SD Correction checkbox ---
        function sdCorrectionToggled(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            selected_bin     = app.PopupBin.Value;

            if app.CheckboxSDCorrection.Value == 1
                table_data = app.ERP.dataquality(selected_DQ_type).data.SD_unbias(:,:,selected_bin); % SD (Gurland & Tripathi, 1971)
            else
                table_data = app.ERP.dataquality(selected_DQ_type).data.SD_bias(:,:,selected_bin); % SD (Divided by N-1)
            end
            app.DQTable.Data = table_data;
            app.orig_data = table_data;
        end
    end

    methods (Static, Access = private)
        function tf = checkchannels(chx, nchan, showmsg)
            if nargin<3
                showmsg = 1;
            end
            tf = 0; % no problem by default

            if ~mod(chx, 1) == 0
                if showmsg
                    msgboxText =  'Invalid channel indexing.';
                    title = 'ERPLAB: basicfilterGUI() error:';
                    errorfound(msgboxText, title);
                end
                tf = 1;
            end

            if isempty(chx)
                if showmsg
                    msgboxText =  'Invalid channel indexing.';
                    title = 'ERPLAB: basicfilterGUI() error:';
                    errorfound(msgboxText, title);
                end
                tf = 1;
                return
            end
            if ~isempty(find(chx>nchan, 1))
                if showmsg
                    msgboxText =  ['You only have %g channels,\n'...
                        'so you cannot specify indices greater than this.'];
                    title = 'ERPLAB: basicfilterGUI() error:';
                    errorfound(sprintf(msgboxText, nchan), title);
                end
                tf = 1;
                return
            end
            if ~isempty(find(chx<1, 1))
                if showmsg
                    msgboxText =  'You cannot use zero or a negative number as a channel indexing';
                    title = 'ERPLAB: basicfilterGUI() error:';
                    errorfound(msgboxText, title);
                end
                tf = 1;
                return
            end
            if length(chx)>length(unique_bc2(chx))
                if showmsg
                    msgboxText =  ['Repeated channels are not allowed.\n'...
                        'Therefore, ERPLAB will get rid of them.'];
                    title = 'ERPLAB: basicfilterGUI() error:';
                    errorfound(sprintf(msgboxText), title, [1 1 0], [0 0 0], 0)
                end
                tf = 0;
                return
            end
        end
    end

    % --- Component initialization ---
    methods (Access = private)

        function createComponents(app)
            % Layout positions below are on a 758x641 design grid, scaled by
            % SX/SY to the panel's actual 1010x770 display size (non-uniform
            % per axis). FontSize is left unscaled -- it's an absolute value
            % independent of the layout grid.
            SX = 1010/758; SY = 770/641;
            P  = @(x,y,w,h) [round(x*SX) round(y*SY) round(w*SX) round(h*SY)];
            FS = @(sz) sz;

            FIG_W = round(758*SX); FIG_H = round(641*SY);
            GRAY  = [0.94 0.94 0.94];
            WHITE = [1 1 1];

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 FIG_W FIG_H];
            app.UIFigure.Name     = 'ERPLAB Data Quality Measures - Table Viewer';
            app.UIFigure.Resize   = 'off';
            app.UIFigure.Color    = GRAY;

            % --- Panel1: Data Quality Measures ---
            app.Panel1 = uipanel(app.UIFigure);
            app.Panel1.Title = 'Data Quality Measures';
            app.Panel1.Position = P(11, 132, 740, 498);
            app.Panel1.BackgroundColor = GRAY;

            app.LabelERPsetTitle = uilabel(app.Panel1);
            app.LabelERPsetTitle.Position = P(27, 462, 124, 16);
            app.LabelERPsetTitle.Text = 'Selected ERPSET:';
            app.LabelERPsetTitle.FontSize = FS(12);
            app.LabelERPsetTitle.BackgroundColor = GRAY;

            app.DropdownActiveErpset = uidropdown(app.Panel1);
            app.DropdownActiveErpset.Position = P(165, 457, 275, 24);
            app.DropdownActiveErpset.FontSize = FS(12);
            app.DropdownActiveErpset.ValueChangedFcn = createCallbackFcn(app, @activeErpsetChanged, true);

            app.LabelDQType = uilabel(app.Panel1);
            app.LabelDQType.Position = P(27, 434, 159, 16);
            app.LabelDQType.Text = 'Selected DQ Measure:';
            app.LabelDQType.FontSize = FS(12);
            app.LabelDQType.BackgroundColor = GRAY;

            app.DropdownDQType = uidropdown(app.Panel1);
            app.DropdownDQType.Position = P(165, 429, 177, 24);
            app.DropdownDQType.FontSize = FS(13);
            app.DropdownDQType.BackgroundColor = WHITE;
            app.DropdownDQType.ValueChangedFcn = createCallbackFcn(app, @dqTypeChanged, true);

            app.CheckboxSDCorrection = uicheckbox(app.Panel1);
            app.CheckboxSDCorrection.Position = P(344, 435, 122, 17);
            app.CheckboxSDCorrection.Text = 'Apply SD Correction';
            app.CheckboxSDCorrection.FontSize = FS(12);
            app.CheckboxSDCorrection.ValueChangedFcn = createCallbackFcn(app, @sdCorrectionToggled, true);

            app.LabelBin = uilabel(app.Panel1);
            app.LabelBin.Position = P(27, 411, 180, 17);
            app.LabelBin.Text = 'Selected BIN:';
            app.LabelBin.FontSize = FS(12);

            app.PopupBin = uidropdown(app.Panel1);
            app.PopupBin.Position = P(165, 405, 177, 24);
            app.PopupBin.FontSize = FS(13);
            app.PopupBin.BackgroundColor = WHITE;
            app.PopupBin.ValueChangedFcn = createCallbackFcn(app, @binChanged, true);

            app.LabelTimeWindows = uilabel(app.Panel1);
            app.LabelTimeWindows.Position = P(276, 381, 117, 17);
            app.LabelTimeWindows.Text = 'Time-windows';
            app.LabelTimeWindows.FontSize = FS(12);
            app.LabelTimeWindows.BackgroundColor = GRAY;

            app.DQTable = uitable(app.Panel1);
            app.DQTable.Position = P(27, 22, 699, 357);
            app.DQTable.ColumnEditable = false;
            app.DQTable.FontSize = FS(10);

            % --- Panel2: Display options (nested inside Panel1) ---
            app.Panel2 = uipanel(app.Panel1);
            app.Panel2.Title = 'Display options';
            app.Panel2.Position = P(482, 382, 245, 101);
            app.Panel2.BackgroundColor = GRAY;

            app.CheckboxHeatmap = uicheckbox(app.Panel2);
            app.CheckboxHeatmap.Position = P(12, 62, 140, 20);
            app.CheckboxHeatmap.Text = 'Color heatmap';
            app.CheckboxHeatmap.FontSize = FS(13);
            app.CheckboxHeatmap.ValueChangedFcn = createCallbackFcn(app, @heatmapToggled, true);

            app.CheckboxOutliers = uicheckbox(app.Panel2);
            app.CheckboxOutliers.Position = P(124, 67, 79, 17);
            app.CheckboxOutliers.Text = 'Outliers';
            app.CheckboxOutliers.FontSize = FS(13);
            app.CheckboxOutliers.ValueChangedFcn = createCallbackFcn(app, @outliersToggled, true);

            app.CheckboxTextLabels = uicheckbox(app.Panel2);
            app.CheckboxTextLabels.Position = P(12, 36, 104, 18);
            app.CheckboxTextLabels.Text = 'Text labels';
            app.CheckboxTextLabels.FontSize = FS(13);
            app.CheckboxTextLabels.ValueChangedFcn = createCallbackFcn(app, @textLabelsChanged, true);

            app.LabelStdFromMean = uilabel(app.Panel2);
            app.LabelStdFromMean.Position = P(102, 46, 98, 16);
            app.LabelStdFromMean.Text = 'Std from mean';
            app.LabelStdFromMean.FontSize = FS(11);
            app.LabelStdFromMean.BackgroundColor = GRAY;

            app.EditStdWindow = uieditfield(app.Panel2, 'text');
            app.EditStdWindow.Position = P(202, 48, 28, 16);
            app.EditStdWindow.Value = '2';
            app.EditStdWindow.FontSize = FS(14);
            app.EditStdWindow.BackgroundColor = WHITE;
            app.EditStdWindow.ValueChangedFcn = createCallbackFcn(app, @stdWindowChanged, true);

            app.LabelChannels = uilabel(app.Panel2);
            app.LabelChannels.Position = P(119, 27, 58, 16);
            app.LabelChannels.Text = 'Channels';
            app.LabelChannels.FontSize = FS(11);
            app.LabelChannels.BackgroundColor = GRAY;

            app.EditChannels = uieditfield(app.Panel2, 'text');
            app.EditChannels.Position = P(184, 28, 46, 17);
            app.EditChannels.Value = 'All';
            app.EditChannels.FontSize = FS(14);
            app.EditChannels.BackgroundColor = WHITE;
            app.EditChannels.ValueChangedFcn = createCallbackFcn(app, @chWindowChanged, true);

            app.ButtonBrowseChan = uibutton(app.Panel2, 'push');
            app.ButtonBrowseChan.Position = P(183, 7, 46, 16);
            app.ButtonBrowseChan.Text = 'Browse';
            app.ButtonBrowseChan.FontSize = FS(11);
            app.ButtonBrowseChan.BackgroundColor = WHITE;
            app.ButtonBrowseChan.ButtonPushedFcn = createCallbackFcn(app, @browseChannelsBtn, true);

            % --- Top-level figure controls ---
            app.LabelOpenNewWin = uilabel(app.UIFigure);
            app.LabelOpenNewWin.Position = P(262, 63, 151, 16);
            app.LabelOpenNewWin.Text = 'Open New ERPset Window';
            app.LabelOpenNewWin.HorizontalAlignment = 'center';
            app.LabelOpenNewWin.FontSize = FS(12);
            app.LabelOpenNewWin.BackgroundColor = GRAY;

            app.DropdownNewErpWin = uidropdown(app.UIFigure);
            app.DropdownNewErpWin.Position = P(263, 42, 151, 20);
            app.DropdownNewErpWin.FontSize = FS(14);

            app.ButtonSelectERP = uibutton(app.UIFigure, 'push');
            app.ButtonSelectERP.Position = P(413, 42, 121, 17);
            app.ButtonSelectERP.Text = 'Select ERPset';
            app.ButtonSelectERP.FontSize = FS(12);
            app.ButtonSelectERP.BackgroundColor = WHITE;
            app.ButtonSelectERP.ButtonPushedFcn = createCallbackFcn(app, @selectERPBtn, true);

            app.LabelExport = uilabel(app.UIFigure);
            app.LabelExport.Position = P(13, 67, 201, 23);
            app.LabelExport.Text = 'Export these values, writing to:';
            app.LabelExport.HorizontalAlignment = 'center';
            app.LabelExport.FontSize = FS(12);
            app.LabelExport.BackgroundColor = GRAY;

            app.ButtonMat = uibutton(app.UIFigure, 'push');
            app.ButtonMat.Position = P(32, 32, 84, 35);
            app.ButtonMat.Text = '.. Mat file';
            app.ButtonMat.FontSize = FS(11);
            app.ButtonMat.BackgroundColor = WHITE;
            app.ButtonMat.ButtonPushedFcn = createCallbackFcn(app, @exportMat, true);

            app.ButtonXls = uibutton(app.UIFigure, 'push');
            app.ButtonXls.Position = P(117, 32, 84, 35);
            app.ButtonXls.Text = '..Excel';
            app.ButtonXls.FontSize = FS(11);
            app.ButtonXls.BackgroundColor = WHITE;
            app.ButtonXls.ButtonPushedFcn = createCallbackFcn(app, @exportXls, true);

            app.ButtonHelp = uibutton(app.UIFigure, 'push');
            app.ButtonHelp.Position = P(557, 32, 84, 35);
            app.ButtonHelp.Text = '?';
            app.ButtonHelp.FontSize = FS(20);
            app.ButtonHelp.BackgroundColor = WHITE;
            app.ButtonHelp.ButtonPushedFcn = createCallbackFcn(app, @showHelp, true);

            app.ButtonDone = uibutton(app.UIFigure, 'push');
            app.ButtonDone.Position = P(643, 32, 84, 35);
            app.ButtonDone.Text = 'Done';
            app.ButtonDone.FontSize = FS(14);
            app.ButtonDone.BackgroundColor = WHITE;
            app.ButtonDone.ButtonPushedFcn = createCallbackFcn(app, @doneBtn, true);

            app.UIFigure.Visible = 'on';
        end
    end

    % --- App creation and deletion ---
    methods (Access = public)

        function app = DQ_Table_GUI(varargin)
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
