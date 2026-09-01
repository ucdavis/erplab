% DQ_Spectra_GUI
% "ERPLAB Data Quality Metrics" - shows per-channel/per-frequency-band
% spectral power/amplitude for continuous EEG data quality, with optional
% color-heatmap or outlier highlighting, and a spectrum plot for the
% selected channel(s)/band.
%
% NOTE: Migrated from GUIDE (.fig) to a programmatic uifigure-based classdef
% app. Original .fig archived outside ERPLAB.
% Migrated to .m: July 2026 by Kurt Winsler
%
% Calling convention unchanged from the original (non-modal - opens and
% returns immediately, no output captured by any caller):
%   DQ_Spectra_GUI(EEG, avg_fft, fft_labels, yout, yout_lab, chanArray)

classdef DQ_Spectra_GUI < matlab.apps.AppBase

    properties (Access = public)
        UIFigure             matlab.ui.Figure
        Panel1               matlab.ui.container.Panel
        Panel2               matlab.ui.container.Panel
        LabelERPsetTitle     matlab.ui.control.Label
        LabelActiveEegset    matlab.ui.control.Label
        LabelDQType          matlab.ui.control.Label
        DropdownDQType       matlab.ui.control.DropDown
        LabelFreqBand        matlab.ui.control.Label
        DQTable              matlab.ui.control.Table
        LabelPlotInstructions matlab.ui.control.Label
        ButtonPlot           matlab.ui.control.Button
        LabelStdFromMean     matlab.ui.control.Label
        EditStdWindow        matlab.ui.control.EditField
        CheckboxOutliers     matlab.ui.control.CheckBox
        CheckboxHeatmap      matlab.ui.control.CheckBox
        LabelExport          matlab.ui.control.Label
        ButtonMat            matlab.ui.control.Button
        ButtonXls            matlab.ui.control.Button
        ButtonHelp           matlab.ui.control.Button
        ButtonDone           matlab.ui.control.Button
    end

    properties (Access = private)
        EEG
        avg_fft
        yout
        yout_lab
        chanArray
        listch
        orig_data
        orig_RowName
        orig_ColName
        heatmap_on = 0
        outliers_on = 0
        sel_row
        sel_col
    end

    properties (Constant, Access = private)
        OutlierColor = [1 0 0];
    end

    methods (Access = private)

        function startupFcn(app, varargin)
            EEG        = varargin{1};
            avg_fft    = varargin{2};
            fft_labels = varargin{3};
            yout       = varargin{4};
            yout_lab   = varargin{5};
            chanArray  = varargin{6};

            app.LabelERPsetTitle.Text = 'Selected EEGset';
            app.LabelActiveEegset.Text = EEG.setname;

            app.DropdownDQType.Items = {'Power','Amplitude'};
            app.DropdownDQType.ItemsData = [1 2];
            app.DropdownDQType.Value = 2; % default to Amplitude

            selected_DQ_type = app.DropdownDQType.Value;
            if selected_DQ_type == 1
                table_data = (avg_fft).^2; % Power
            else
                table_data = avg_fft; % Amplitude
            end

            app.DQTable.Data = table_data;
            app.orig_data = table_data;

            nchan = EEG.nbchan;
            chanArray = chanArray(chanArray<=nchan);
            app.chanArray = chanArray;

            elec_labels = cell(1,length(chanArray));
            for i=1:length(chanArray)
                elec_labels{i} = EEG.chanlocs(chanArray(i)).labels;
            end
            app.listch = elec_labels;
            app.DQTable.RowName = elec_labels;
            app.orig_RowName = elec_labels;

            app.sel_row = size(avg_fft,1); % set to max on load
            app.sel_col = size(avg_fft,2); % set to max on load

            app.DQTable.ColumnName = fft_labels;
            app.orig_ColName = fft_labels;

            % uifigure components have no FontUnits property, so this size is
            % read as points and cannot take the pixel value that
            % f_get_default_fontsize returns. These per-platform point sizes
            % render alike on each OS.
            if ismac
                app.DQTable.FontSize = 12;
            elseif ispc
                app.DQTable.FontSize = 9;
            else
                app.DQTable.FontSize = 8.5;
            end
            app.heatmap_on = 0;

            app.EditStdWindow.Enable = 'off';
            app.outliers_on = 0;

            app.EEG = EEG;
            app.avg_fft = avg_fft;
            app.yout = yout;
            app.yout_lab = yout_lab;
        end

        % --- Selected Spectral DQ Measure changed ---
        function dqTypeChanged(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            avg_fft = app.avg_fft;

            if selected_DQ_type == 2 % Amplitude
                table_data = avg_fft;
            else
                table_data = avg_fft.^2; % Power
            end

            app.DQTable.Data = table_data;
            app.orig_data = table_data;

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

        % --- Export buttons ---
        function exportXls(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            save_spectral_dq(app.avg_fft, app.orig_RowName, app.orig_ColName, selected_DQ_type, [], 'xlsx')
        end

        function exportMat(app, ~)
            selected_DQ_type = app.DropdownDQType.Value;
            save_spectral_dq(app.avg_fft, app.orig_RowName, app.orig_ColName, selected_DQ_type, [], 'mat')
        end

        function showHelp(app, ~)
            web https://github.com/lucklab/erplab/wiki/Spectral-Data-Quality-(continuous-eeg) -browser
        end

        function doneBtn(app, ~)
            delete(app.UIFigure);
        end

        % --- Color heatmap checkbox ---
        function heatmapToggled(app, ~)
            heatmap_on = app.CheckboxHeatmap.Value;

            if heatmap_on == 1
                app.clearOutliersStyle();
                app.outliers_on = 0;
                app.CheckboxOutliers.Value = 0;
                app.EditStdWindow.Enable = 'off';

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

        function refreshHeatmap(app)
            color_map = viridis;
            data = app.DQTable.Data;
            if ~isnumeric(data) || isempty(data) || any(isnan(data(1,:)))
                disp('Cannot create heatmap if NaN is present')
                return
            end
            data_min = min(data(:));
            range_val = max(data(:)) - data_min;
            range_colormap = size(color_map,1);
            val_increase_per_shade = range_val / range_colormap;

            % Clear styles AND fully cycle Data (empty, then restore) before
            % restyling -- removeStyle alone can leave stale per-cell styles
            % from a previous mode visible on some cells; forcing the table
            % through an empty state invalidates any leftover per-cell
            % style/position association.
            removeStyle(app.DQTable);
            app.DQTable.Data = {};
            drawnow;
            app.DQTable.Data = data;
            drawnow;

            shade_idx = round((data - data_min) / val_increase_per_shade);
            shade_idx = max(1, min(range_colormap, shade_idx));
            % Batch all cells sharing the same shade into one addStyle call
            % each, instead of one call per cell -- calling addStyle
            % per-cell is far too slow for wide tables.
            for shade = unique(shade_idx(:))'
                [r, c] = find(shade_idx == shade);
                addStyle(app.DQTable, uistyle('BackgroundColor', color_map(shade,:)), 'cell', [r c]);
            end
        end

        function clearHeatmapStyle(app)
            removeStyle(app.DQTable);
        end

        % --- Outliers checkbox ---
        function outliersToggled(app, ~)
            outliers_on = app.CheckboxOutliers.Value;

            if outliers_on == 1
                app.EditStdWindow.Enable = 'on';
            else
                app.EditStdWindow.Enable = 'off';
            end

            app.outliers_on = outliers_on;

            if app.outliers_on == 1
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
                app.clearOutliersStyle();
            end
        end

        function refreshOutliers(app)
            data = app.orig_data;

            col_means = mean(data,1);
            col_std   = std(data,0,1);
            chosen_std = str2double(app.EditStdWindow.Value);

            removeStyle(app.DQTable);
            app.DQTable.Data = {};
            drawnow;
            app.DQTable.Data = data;
            drawnow;

            neg_thresh = col_means - chosen_std*col_std;
            pos_thresh = col_means + chosen_std*col_std;
            % Batch every outlier cell into a single addStyle call instead
            % of one call per cell.
            [r, c] = find(data < neg_thresh | data > pos_thresh);
            if ~isempty(r)
                addStyle(app.DQTable, uistyle('BackgroundColor', app.OutlierColor), 'cell', [r c]);
            end
        end

        function clearOutliersStyle(app)
            removeStyle(app.DQTable);
            app.DQTable.Data = app.orig_data;
            app.DQTable.RowName = app.orig_RowName;
        end

        function stdWindowChanged(app, ~)
            app.refreshOutliers();
        end

        % --- Table cell selection (drives which channel(s)/band the Plot button uses) ---
        function tableCellSelectionChanged(app, event)
            if ~isempty(event.Indices)
                app.sel_row = event.Indices(:,1);
                app.sel_col = event.Indices(:,2);
            end
        end

        % --- Plot button: opens a separate classic figure with the spectrum plot ---
        function plotBtn(app, ~)
            chans_to_plot = app.sel_row;
            labels_to_plot = app.sel_col;
            yout = app.yout;
            yout_lab = app.yout_lab;
            msgn = 'whole';

            if numel(unique_bc2(labels_to_plot)) > 1
                errorfound('Sorry, you may only plot one frequency band at a time!', 'ERPLAB: pop_continuousFFT() error');
                return
            elseif any(isnan(yout{unique_bc2(labels_to_plot)}))
                errorfound('Sorry, you cannot plot this frequency band due to NaNs', 'ERPLAB: pop_continuousFFT() error');
                return
            end

            isAmplitude = strcmp(app.DropdownDQType.Items{app.DropdownDQType.ItemsData==app.DropdownDQType.Value}, 'Amplitude');
            p_yout = yout{unique_bc2(labels_to_plot)};

            if numel(chans_to_plot) == 1
                if isAmplitude
                    p_yout_sel = p_yout(:,chans_to_plot);
                else
                    p_yout_sel = (p_yout(:,chans_to_plot)).^2;
                end
                p_yout_lab = yout_lab{unique_bc2(labels_to_plot)}';
                lege = sprintf('EEG Channel: ');
            else
                if isAmplitude
                    p_yout_sel = p_yout(:,chans_to_plot);
                else
                    p_yout_sel = (p_yout(:,chans_to_plot)).^2;
                end
                p_yout_sel = mean(p_yout_sel,2);
                p_yout_lab = yout_lab{unique_bc2(labels_to_plot)}';
                lege = sprintf('EEG Channel Average: ');
            end

            fname = app.EEG.setname;
            if isAmplitude
                titleStr = ['<< ' fname ' >>  ERPLAB Amplitude Spectrum'];
            else
                titleStr = ['<< ' fname ' >>  ERPLAB Power Spectrum'];
            end
            figure('Name',titleStr,'NumberTitle','on', 'Tag','Plotting Spectrum','Color',[1 1 1]);

            if numel(p_yout_lab) == 1 % impulse at one frequency/ create impulse
                plot([p_yout_lab p_yout_lab], [0 p_yout_sel]);
            else
                plot(p_yout_lab,p_yout_sel);
            end

            try
                axis([min(p_yout_lab)  max(p_yout_lab)  min(p_yout_sel)*0.9 max(p_yout_sel)*1.1])
            catch % in the case of impulse
                axis([min(p_yout_lab)*0.99  max(p_yout_lab)*1.01  min(p_yout_sel)*0.99 max(p_yout_sel)*1.01])
            end

            if isfield(app.EEG.chanlocs,'labels')
                for i=1:length(chans_to_plot)
                    lege = sprintf('%s %s', lege, app.EEG.chanlocs(chans_to_plot(i)).labels);
                end
                lege = sprintf('%s *%s', lege, msgn);
                legend(lege)
            else
                legend(['EEG Channel: ' vect2colon(app.chanArray,'Delimiter', 'off') '  *' msgn])
            end

            if isAmplitude
                title('Single-Sided Amplitude Spectrum of y(t)')
                ylabel('Amplitude - absolute single-sided (original units)')
            else
                title('Single-Sided Power Spectrum of y(t)')
                ylabel('Power - absolute single-sided (original units)')
            end
            xlabel('Frequency (Hz)')
        end
    end

    % --- Component initialization ---
    methods (Access = private)

        function createComponents(app)
            % Layout positions below are on a 758x641 design grid, scaled by
            % SX/SY to the panel's actual display size (non-uniform per
            % axis -- measured on DQ_Table_GUI.m, same design grid/machine,
            % reused here as a starting point; verify live and adjust if
            % this file's real on-screen size differs). FontSize is left
            % unscaled -- it's an absolute value independent of the layout
            % grid.
            SX = 1010/758; SY = 770/641;
            P  = @(x,y,w,h) [round(x*SX) round(y*SY) round(w*SX) round(h*SY)];
            FIG_W = round(758*SX); FIG_H = round(641*SY);
            GRAY  = [0.94 0.94 0.94];

            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 FIG_W FIG_H];
            app.UIFigure.Name     = 'ERPLAB Data Quality Metrics - Table Viewer';
            app.UIFigure.Resize   = 'off';
            app.UIFigure.Color    = GRAY;

            app.Panel1 = uipanel(app.UIFigure);
            app.Panel1.Title = 'Data Quality Metrics';
            app.Panel1.Position = P(11, 132, 740, 498);
            app.Panel1.BackgroundColor = GRAY;

            app.LabelERPsetTitle = uilabel(app.Panel1);
            app.LabelERPsetTitle.Position = P(27, 454, 124, 16);
            app.LabelERPsetTitle.Text = 'Selected EEGset';
            app.LabelERPsetTitle.FontSize = 12;
            app.LabelERPsetTitle.BackgroundColor = GRAY;

            app.LabelActiveEegset = uilabel(app.Panel1);
            app.LabelActiveEegset.Position = P(165, 449, 275, 24);
            app.LabelActiveEegset.FontSize = 12;
            app.LabelActiveEegset.BackgroundColor = GRAY;

            app.LabelDQType = uilabel(app.Panel1);
            app.LabelDQType.Position = P(27, 426, 159, 16);
            app.LabelDQType.Text = 'Selected Spectral DQ Measure:';
            app.LabelDQType.FontSize = 12;
            app.LabelDQType.BackgroundColor = GRAY;

            app.DropdownDQType = uidropdown(app.Panel1);
            app.DropdownDQType.Position = P(165, 421, 177, 24);
            app.DropdownDQType.FontSize = 13;
            app.DropdownDQType.BackgroundColor = [1 1 1];
            app.DropdownDQType.ValueChangedFcn = createCallbackFcn(app, @dqTypeChanged, true);

            app.LabelFreqBand = uilabel(app.Panel1);
            app.LabelFreqBand.Position = P(309, 381, 117, 17);
            app.LabelFreqBand.Text = 'Frequency Band Labels';
            app.LabelFreqBand.FontSize = 12;
            app.LabelFreqBand.BackgroundColor = GRAY;

            app.DQTable = uitable(app.Panel1);
            app.DQTable.Position = P(27, 23, 688, 357);
            app.DQTable.ColumnEditable = false;
            app.DQTable.FontSize = 10;
            app.DQTable.CellSelectionCallback = createCallbackFcn(app, @tableCellSelectionChanged, true);

            app.Panel2 = uipanel(app.Panel1);
            app.Panel2.Title = 'Display options';
            app.Panel2.Position = P(463, 386, 264, 97);
            app.Panel2.BackgroundColor = GRAY;

            % Checkboxes + "Std from mean" share one row (freed vertical
            % room that avoided them crowding the panel's top border).
            app.CheckboxHeatmap = uicheckbox(app.Panel2);
            app.CheckboxHeatmap.Position = P(6, 48, 80, 20);
            app.CheckboxHeatmap.Text = 'Color heatmap';
            app.CheckboxHeatmap.FontSize = 13;
            app.CheckboxHeatmap.ValueChangedFcn = createCallbackFcn(app, @heatmapToggled, true);

            app.CheckboxOutliers = uicheckbox(app.Panel2);
            app.CheckboxOutliers.Position = P(90, 48, 65, 20);
            app.CheckboxOutliers.Text = 'Outliers';
            app.CheckboxOutliers.FontSize = 13;
            app.CheckboxOutliers.ValueChangedFcn = createCallbackFcn(app, @outliersToggled, true);

            app.LabelStdFromMean = uilabel(app.Panel2);
            app.LabelStdFromMean.Position = P(159, 50, 65, 15);
            app.LabelStdFromMean.Text = 'Std from mean';
            app.LabelStdFromMean.FontSize = 11;
            app.LabelStdFromMean.BackgroundColor = GRAY;

            app.EditStdWindow = uieditfield(app.Panel2, 'text');
            app.EditStdWindow.Position = P(228, 49, 28, 17);
            app.EditStdWindow.Value = '2';
            app.EditStdWindow.FontSize = 14;
            app.EditStdWindow.ValueChangedFcn = createCallbackFcn(app, @stdWindowChanged, true);

            app.LabelPlotInstructions = uilabel(app.Panel2);
            app.LabelPlotInstructions.Position = P(15, 27, 238, 14);
            app.LabelPlotInstructions.Text = 'Select frequency band and channel to plot';
            app.LabelPlotInstructions.FontSize = 14;
            app.LabelPlotInstructions.BackgroundColor = GRAY;

            app.ButtonPlot = uibutton(app.Panel2, 'push');
            app.ButtonPlot.Position = P(74, 6, 107, 20);
            app.ButtonPlot.Text = 'Plot';
            app.ButtonPlot.FontSize = 14;
            app.ButtonPlot.ButtonPushedFcn = createCallbackFcn(app, @plotBtn, true);

            app.LabelExport = uilabel(app.UIFigure);
            app.LabelExport.Position = P(13, 67, 201, 23);
            app.LabelExport.Text = 'Export these values, writing to:';
            app.LabelExport.HorizontalAlignment = 'center';
            app.LabelExport.FontSize = 12;
            app.LabelExport.BackgroundColor = GRAY;

            app.ButtonMat = uibutton(app.UIFigure, 'push');
            app.ButtonMat.Position = P(32, 32, 84, 35);
            app.ButtonMat.Text = '.. Mat file';
            app.ButtonMat.FontSize = 11;
            app.ButtonMat.ButtonPushedFcn = createCallbackFcn(app, @exportMat, true);

            app.ButtonXls = uibutton(app.UIFigure, 'push');
            app.ButtonXls.Position = P(117, 32, 84, 35);
            app.ButtonXls.Text = '..Excel';
            app.ButtonXls.FontSize = 11;
            app.ButtonXls.ButtonPushedFcn = createCallbackFcn(app, @exportXls, true);

            app.ButtonHelp = uibutton(app.UIFigure, 'push');
            app.ButtonHelp.Position = P(557, 32, 84, 35);
            app.ButtonHelp.Text = '?';
            app.ButtonHelp.FontSize = 20;
            app.ButtonHelp.ButtonPushedFcn = createCallbackFcn(app, @showHelp, true);

            app.ButtonDone = uibutton(app.UIFigure, 'push');
            app.ButtonDone.Position = P(643, 32, 84, 35);
            app.ButtonDone.Text = 'Done';
            app.ButtonDone.FontSize = 14;
            app.ButtonDone.ButtonPushedFcn = createCallbackFcn(app, @doneBtn, true);

            app.UIFigure.Visible = 'on';
        end
    end

    % --- App creation and deletion ---
    methods (Access = public)

        function app = DQ_Spectra_GUI(varargin)
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
