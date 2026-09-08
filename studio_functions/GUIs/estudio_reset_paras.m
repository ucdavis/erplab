% PURPOSE: ERPLAB Studio "Reset" dialog. Collects which tabs to restore to default
%          parameters and which datasets to clear, or performs a full factory reset.
%
% FORMAT:
%
% app = estudio_reset_paras(resetparas, enableflags)
%
% resetparas  - 1x6 logical, initial checkbox state:
%               [eegParams eegClear erpParams erpClear decodeParams decodeClear]
% enableflags - 1x3, which tab's checkboxes are selectable [EEG ERP Decode]
%
% app.output  - 1x7 on Continue or Full Reset, [] on Cancel. Elements 1-6 mirror
%               resetparas; element 7 is 1 only for a Full Reset, which also wipes
%               the Studio working-memory file before returning.
%
% NOTE: Migrated from App Designer (.mlapp) to plain .m for version control.
% Original estudio_reset_paras.mlapp archived outside ERPLAB. Edit here, not the .mlapp.
% Migrated to .m: September 2026 by Kurt Winsler
%
% *** This function is part of ERPLAB Studio Toolbox ***

classdef estudio_reset_paras < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        ClearallBESTMVPCdatasetsCheckBox  matlab.ui.control.CheckBox
        FullResetButton              matlab.ui.control.Button
        FullResetNoteLabel           matlab.ui.control.Label
        SelectivePanel               matlab.ui.container.Panel
        FullResetPanel               matlab.ui.container.Panel
        RestoredefaultparametersforPatternClassificationTabCheckBox  matlab.ui.control.CheckBox
        ContinueButton               matlab.ui.control.Button
        CancelButton                 matlab.ui.control.Button
        ClearallERPdatasetsCheckBox  matlab.ui.control.CheckBox
        RestoredefaultparametersforERPTabCheckBox  matlab.ui.control.CheckBox
        ClearallEEGdatasetsCheckBox  matlab.ui.control.CheckBox
        RestoredefaultparametersforEEGTabCheckBox  matlab.ui.control.CheckBox
    end


    properties (Access = public)
        output % Description
        Finishbutton % Description
    end

    methods (Access = private)


    end

    methods (Access = public)

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            painterplabapp(app);
            setfonterplab(app);
            % painterplabapp colours every label; this one reads as body text
            app.FullResetNoteLabel.BackgroundColor = 'none';
            % Name & version
            %
            version = geterplabversion;
            set(app.UIFigure,'Name', ['ERPLAB ' version '   -   EStudio reset parameters GUI']);
            try
                resetparas = varargin{1};
            catch
                resetparas = [0 0 0 0 0 0];
            end
            if isempty(resetparas) || numel(resetparas)~=6
                resetparas = [0 0 0 0 0 0];
            end
            app.RestoredefaultparametersforEEGTabCheckBox.Value = resetparas(1);
            app.ClearallEEGdatasetsCheckBox.Value = resetparas(2);
            app.RestoredefaultparametersforERPTabCheckBox.Value = resetparas(3);
            app.ClearallERPdatasetsCheckBox.Value = resetparas(4);
            app.RestoredefaultparametersforPatternClassificationTabCheckBox.Value = resetparas(5);
            app.ClearallBESTMVPCdatasetsCheckBox.Value = resetparas(6);
            try
                resetparas1 = varargin{2};
            catch
                resetparas1 = [1 1 1];
            end
            if resetparas1(1)==0
                app.RestoredefaultparametersforEEGTabCheckBox.Value = 0;
                app.ClearallEEGdatasetsCheckBox.Value = 0;
                app.RestoredefaultparametersforEEGTabCheckBox.Enable = 'off';
                app.ClearallEEGdatasetsCheckBox.Enable = 'off';
            else
                app.RestoredefaultparametersforEEGTabCheckBox.Enable = 'on';
                app.ClearallEEGdatasetsCheckBox.Enable = 'on';
            end
            if resetparas1(2)==0
                app.RestoredefaultparametersforERPTabCheckBox.Value = 0;
                app.ClearallERPdatasetsCheckBox.Value = 0;
                app.RestoredefaultparametersforERPTabCheckBox.Enable = 'off';
                app.ClearallERPdatasetsCheckBox.Enable = 'off';
            else
                app.RestoredefaultparametersforERPTabCheckBox.Enable = 'on';
                app.ClearallERPdatasetsCheckBox.Enable = 'on';
            end

            if resetparas1(3)==0
                app.RestoredefaultparametersforPatternClassificationTabCheckBox.Value = 0;
                app.ClearallBESTMVPCdatasetsCheckBox.Value = 0;
                app.RestoredefaultparametersforPatternClassificationTabCheckBox.Enable = 'off';
                app.ClearallBESTMVPCdatasetsCheckBox.Enable = 'off';
            else
                app.RestoredefaultparametersforPatternClassificationTabCheckBox.Enable = 'on';
                app.ClearallBESTMVPCdatasetsCheckBox.Enable = 'on';
            end

        end

        % Value changed function: 
        % RestoredefaultparametersforEEGTabCheckBox
        function eeg_panel_paras(app, event)
            value = app.RestoredefaultparametersforEEGTabCheckBox.Value;

        end

        % Value changed function: ClearallEEGdatasetsCheckBox
        function cler_alleeg(app, event)
            value = app.ClearallEEGdatasetsCheckBox.Value;

        end

        % Value changed function: 
        % RestoredefaultparametersforERPTabCheckBox
        function erp_panel_paras(app, event)
            value = app.RestoredefaultparametersforERPTabCheckBox.Value;

        end

        % Value changed function: ClearallERPdatasetsCheckBox
        function clear_allerp(app, event)
            value = app.ClearallERPdatasetsCheckBox.Value;

        end

        % Button pushed function: CancelButton
        function cancel_button(app, event)
            app.output =[];
            app.Finishbutton = 1;
        end

        % Button pushed function: FullResetButton
        function button_full_reset(app, event)
            answer = uiconfirm(app.UIFigure, ...
                ['Are you sure you want to restore all ERPLAB studio settings to ' ...
                 'defaults and clear all loaded datasets and parameters?'], ...
                'ERPLAB Studio: Full Reset', ...
                'Options', {'Yes','No'}, 'DefaultOption', 2, 'CancelOption', 2);
            if ~strcmpi(answer,'Yes')
                return
            end
            do_full_reset(app);
        end

        % Wipe the Studio working-memory file, then tell the caller to reset every
        % panel and clear every dataset. The 7th output element flags the full reset.
        % Kept separate from the confirmation so it can be exercised without the dialog.
        function do_full_reset(app)
            etudioamnesia(0);
            app.output = [1 1 1 1 1 1 1];
            app.Finishbutton = 1;
        end

        % Button pushed function: ContinueButton
        function button_continue(app, event)
            resetparas(1)= app.RestoredefaultparametersforEEGTabCheckBox.Value;
            resetparas(2)=app.ClearallEEGdatasetsCheckBox.Value;
            resetparas(3)= app.RestoredefaultparametersforERPTabCheckBox.Value;
            resetparas(4)=app.ClearallERPdatasetsCheckBox.Value;
            resetparas(5)= app.RestoredefaultparametersforPatternClassificationTabCheckBox.Value;
            resetparas(6)= app.ClearallBESTMVPCdatasetsCheckBox.Value;

            resetparas(7) = 0;   % not a full reset

            app.output =resetparas;
            app.Finishbutton = 1;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 497 414];
            app.UIFigure.Name = 'MATLAB App';

            % --- Section 1: pick what to reset -------------------------------
            app.SelectivePanel = uipanel(app.UIFigure);
            app.SelectivePanel.Title = 'Reset selected parameters and data';
            app.SelectivePanel.Position = [15 134 467 265];

            % Create RestoredefaultparametersforEEGTabCheckBox
            app.RestoredefaultparametersforEEGTabCheckBox = uicheckbox(app.SelectivePanel);
            app.RestoredefaultparametersforEEGTabCheckBox.ValueChangedFcn = createCallbackFcn(app, @eeg_panel_paras, true);
            app.RestoredefaultparametersforEEGTabCheckBox.Text = 'Restore default parameters for EEG Tab';
            app.RestoredefaultparametersforEEGTabCheckBox.Position = [16 219 237 22];

            % Create ClearallEEGdatasetsCheckBox
            app.ClearallEEGdatasetsCheckBox = uicheckbox(app.SelectivePanel);
            app.ClearallEEGdatasetsCheckBox.ValueChangedFcn = createCallbackFcn(app, @cler_alleeg, true);
            app.ClearallEEGdatasetsCheckBox.Text = 'Clear all EEG datasets';
            app.ClearallEEGdatasetsCheckBox.Position = [16 187 142 22];

            % Create RestoredefaultparametersforERPTabCheckBox
            app.RestoredefaultparametersforERPTabCheckBox = uicheckbox(app.SelectivePanel);
            app.RestoredefaultparametersforERPTabCheckBox.ValueChangedFcn = createCallbackFcn(app, @erp_panel_paras, true);
            app.RestoredefaultparametersforERPTabCheckBox.Text = 'Restore default parameters for ERP Tab';
            app.RestoredefaultparametersforERPTabCheckBox.Position = [16 155 237 22];

            % Create ClearallERPdatasetsCheckBox
            app.ClearallERPdatasetsCheckBox = uicheckbox(app.SelectivePanel);
            app.ClearallERPdatasetsCheckBox.ValueChangedFcn = createCallbackFcn(app, @clear_allerp, true);
            app.ClearallERPdatasetsCheckBox.Text = 'Clear all ERP datasets';
            app.ClearallERPdatasetsCheckBox.Position = [16 123 141 22];

            % Create RestoredefaultparametersforPatternClassificationTabCheckBox
            app.RestoredefaultparametersforPatternClassificationTabCheckBox = uicheckbox(app.SelectivePanel);
            app.RestoredefaultparametersforPatternClassificationTabCheckBox.Text = 'Restore default parameters for Pattern Classification Tab';
            app.RestoredefaultparametersforPatternClassificationTabCheckBox.Position = [16 91 330 22];

            % Create ClearallBESTMVPCdatasetsCheckBox
            app.ClearallBESTMVPCdatasetsCheckBox = uicheckbox(app.SelectivePanel);
            app.ClearallBESTMVPCdatasetsCheckBox.Text = 'Clear all BEST/MVPC datasets';
            app.ClearallBESTMVPCdatasetsCheckBox.Position = [16 59 186 22];

            % --- Section 2: start over completely ----------------------------
            app.FullResetPanel = uipanel(app.UIFigure);
            app.FullResetPanel.Title = 'Reset everything';
            app.FullResetPanel.Position = [15 15 467 105];

            % Create FullResetButton
            app.FullResetButton = uibutton(app.FullResetPanel, 'push');
            app.FullResetButton.ButtonPushedFcn = createCallbackFcn(app, @button_full_reset, true);
            app.FullResetButton.Position = [138 44 190 33];
            app.FullResetButton.Text = 'Reset ERPLAB Studio';
            app.FullResetButton.FontWeight = 'bold';

            % Create FullResetNoteLabel
            app.FullResetNoteLabel = uilabel(app.FullResetPanel);
            app.FullResetNoteLabel.Position = [10 6 447 34];
            app.FullResetNoteLabel.HorizontalAlignment = 'center';
            app.FullResetNoteLabel.WordWrap = 'on';
            app.FullResetNoteLabel.Text = ['Clear all datasets, restore default parameters, ' ...
                'reset Studio working memory'];

            % action row for this section: two 111 px buttons in the panel's 465 px
            % inner width -> three exactly equal 81 px gaps
            app.CancelButton = uibutton(app.SelectivePanel, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @cancel_button, true);
            app.CancelButton.Position = [81 12 111 33];
            app.CancelButton.Text = 'Cancel';

            app.ContinueButton = uibutton(app.SelectivePanel, 'push');
            app.ContinueButton.ButtonPushedFcn = createCallbackFcn(app, @button_continue, true);
            app.ContinueButton.Position = [273 12 111 33];
            app.ContinueButton.Text = 'Continue';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = estudio_reset_paras(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
