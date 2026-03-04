% EEG_Tab_rename_gui
% Rename EEGset dialog for ERPLAB Studio EEG Tab.
%
% NOTE: This file was migrated from MATLAB App Designer (.mlapp) format to a
% plain .m classdef file to allow version control and code editing. The
% original EEG_Tab_rename_gui.mlapp has been archived outside the ERPLAB
% directory. Any future edits should be made here, not in the .mlapp file.
%
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain, University of California, Davis
% Migrated to .m: March 2026 by Kurt Winsler

classdef EEG_Tab_rename_gui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        ApplyButton           matlab.ui.control.Button
        CancelButton          matlab.ui.control.Button
        ResetButton           matlab.ui.control.Button
        UITable               matlab.ui.control.Table
        ClearFilepathCheckBox matlab.ui.control.CheckBox
    end

    properties (Access = public)
        Output        % New setnames cell array, or [] if cancelled
        Finishbutton  % Set to 1 when dialog closes (waitfor trigger)
        ClearFilepath % true if user wants to clear saved filepath on rename
        ALLERP
        ERPArray
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            painterplabapp(app);
            setfonterplab(app);
            version = geterplabversion;
            set(app.UIFigure, 'Name', ['Estudio ' version '   -   Rename EEG set GUI']);

            try ALLERP = varargin{1}; catch; ALLERP = []; end
            if isempty(ALLERP)
                return;
            end
            app.ALLERP = ALLERP;

            try ERPArray = varargin{2}; catch; ERPArray = []; end
            if isempty(ERPArray) || numel(ERPArray) ~= length(ALLERP) || any(ERPArray < 1)
                ERPArray = 1:length(ALLERP);
            end
            app.ERPArray = ERPArray;

            for Numoferp = 1:numel(ALLERP)
                rowNames{Numoferp} = ERPArray(Numoferp);
                data{Numoferp,1}   = ALLERP(Numoferp).setname;
                data{Numoferp,2}   = ALLERP(Numoferp).setname;
            end
            app.UITable.RowName = rowNames;
            app.UITable.Data    = data;

            app.Finishbutton  = 0;
            app.Output        = [];
            app.ClearFilepath = true; % checked by default
        end

        % Button pushed function: ResetButton
        function reset_erpname(app, ~)
            ALLERP   = app.ALLERP;
            ERPArray = app.ERPArray;
            for Numoferp = 1:numel(ALLERP)
                rowNames{Numoferp} = ERPArray(Numoferp);
                data{Numoferp,1}   = ALLERP(Numoferp).setname;
                data{Numoferp,2}   = ALLERP(Numoferp).setname;
            end
            app.UITable.RowName = rowNames;
            app.UITable.Data    = data;
        end

        % Button pushed function: CancelButton
        function cancel(app, ~)
            app.Output        = [];
            app.ClearFilepath = false;
            app.Finishbutton  = 1;
        end

        % Button pushed function: ApplyButton
        function apply(app, ~)
            data     = app.UITable.Data;
            ALLERP   = app.ALLERP;
            ERPArray = app.ERPArray;
            for Numoferp = 1:numel(ALLERP)
                newName = data{Numoferp,2};
                [~, newName, ~] = fileparts(newName);
                if ~isempty(newName)
                    setname{Numoferp} = newName;
                else
                    setname{Numoferp} = ALLERP(ERPArray(Numoferp)).setname;
                end
            end
            app.Output        = setname;
            app.ClearFilepath = app.ClearFilepathCheckBox.Value;
            app.Finishbutton  = 1;
        end

        % Cell edit callback: UITable
        function cell_edit_changes(app, ~)
        end
    end

    % Component initialization
    methods (Access = private)

        function createComponents(app)

            app.UIFigure          = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 360];
            app.UIFigure.Name     = 'MATLAB App';

            % Table showing original / new setnames
            app.UITable                    = uitable(app.UIFigure);
            app.UITable.ColumnName         = {'Original setname'; 'New setname'};
            app.UITable.RowName            = {};
            app.UITable.ColumnEditable     = [false true];
            app.UITable.CellEditCallback   = createCallbackFcn(app, @cell_edit_changes, true);
            app.UITable.Position           = [15 100 613 245];

            % Checkbox: clear saved filepath on rename (checked by default)
            app.ClearFilepathCheckBox          = uicheckbox(app.UIFigure);
            app.ClearFilepathCheckBox.Text     = 'Clear saved filename and path (so next Save uses the new name)';
            app.ClearFilepathCheckBox.Value    = true;
            app.ClearFilepathCheckBox.Position = [15 62 550 25];

            % Buttons
            app.ResetButton                    = uibutton(app.UIFigure, 'push');
            app.ResetButton.ButtonPushedFcn    = createCallbackFcn(app, @reset_erpname, true);
            app.ResetButton.Position           = [15 16 119 39];
            app.ResetButton.Text               = 'Reset';

            app.CancelButton                   = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn   = createCallbackFcn(app, @cancel, true);
            app.CancelButton.Position          = [354 16 119 39];
            app.CancelButton.Text              = 'Cancel';

            app.ApplyButton                    = uibutton(app.UIFigure, 'push');
            app.ApplyButton.ButtonPushedFcn    = createCallbackFcn(app, @apply, true);
            app.ApplyButton.Position           = [509 16 119 39];
            app.ApplyButton.Text               = 'Apply';

            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        function app = EEG_Tab_rename_gui(varargin)
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
