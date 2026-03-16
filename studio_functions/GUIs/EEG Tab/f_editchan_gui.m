% NOTE: Migrated from App Designer (.mlapp) to plain .m for version control.
% Original archived outside ERPLAB. Edit here, not the .mlapp.
% Migrated to .m: March 2026 by Kurt Winsler

classdef f_editchan_gui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        OkayButton                      matlab.ui.control.Button
        CancelButton                    matlab.ui.control.Button
        ResetlocationinfotableButton    matlab.ui.control.Button
        EditlocsinDropDown              matlab.ui.control.DropDown
        EditlocsinDropDownLabel         matlab.ui.control.Label
        LoadsavechanlocationsPanel      matlab.ui.container.Panel
        GuesschanlocsButton             matlab.ui.control.Button
        SavelocationstolocfileButton    matlab.ui.control.Button
        LoadlocationsfromEEGdataButton  matlab.ui.control.Button
        LoadchanlocsfromlocfileButton   matlab.ui.control.Button
        ChannelLocationHeadplotPanel    matlab.ui.container.Panel
        headplotaxs                     matlab.ui.control.UIAxes
        LocationInformationTablePanel   matlab.ui.container.Panel
        loc_table                       matlab.ui.control.Table
    end


    properties (Access = public)
        output       % EEG/ERP struct with updated chanlocs, or [] if cancelled
        Finishbutton % Set to 1 when dialog closes (waitfor trigger)
        locfile      % Full path of loc file loaded (empty if manual edit or dataset load)
        loccom       % History command from Guess chanlocs (empty if not used)
    end

    properties (Access = private)
        nchl % Description
        ch_n % Description
        xyz % Description
        nchl_orig % Description
        EEG % Description
        ch_labels % Description
        locformat % Description
        tformat % Description
    end


    %%refresh table and topos
    methods (Access = private)
        function refreshtable(app)

            if strcmp(app.tformat,'xyz')
                for i = 1:app.ch_n
                    try
                        ch_xyz(i,:) = [app.nchl(i).X app.nchl(i).Y app.nchl(i).Z];
                    catch
                        ch_xyz(i,:) = [0 0 0];
                    end
                end
                set(app.loc_table,'Data',ch_xyz,'ColumnName',{'X';'Y';'Z'},'RowName',app.ch_labels );
                set(app.loc_table,'ColumnEditable',true(1,2,3));
            end


            if strcmp(app.tformat,'sph')
                for i = 1:app.ch_n
                    try
                        sph_t = app.nchl(i).sph_theta; if isempty(sph_t); sph_t = 0; end
                        sph_p = app.nchl(i).sph_phi;   if isempty(sph_p); sph_p = 0; end
                        ch_sph(i,:) = [sph_t sph_p];
                    catch
                        ch_sph(i,:) = [0 0];
                    end
                end
                set(app.loc_table,'Data',ch_sph,'ColumnName',{'sph_theta';'sph_radius';' '},'RowName',app.ch_labels );
                set(app.loc_table,'ColumnEditable',false);
                set(app.loc_table,'ColumnEditable',true(1,2));
            end

        end

        function refreshhp(app)
            cla(app.headplotaxs);
            hp_fig = figure('Visible','Off');
            topoplot([],app.nchl, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', app.EEG.chaninfo);
            topo_axes = gca;
            topo2 = get(topo_axes,'children');
            copyobj(topo2, app.headplotaxs);
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, varargin)
            %paint GUI
            painterplabapp(app);
            setfonterplab(app);
            % Name & version
            %
            version = geterplabversion;
            set(app.UIFigure,'Name', ['ERPLAB ' version '   -   Channel Location Editor GUI']);
            %             set(app.ChannelLocationHeadplotPanel,'BackgroundColor',[1 1 1]);
            set(app.headplotaxs,'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[]);
            app.headplotaxs.XLabel.String = '';
            app.headplotaxs.YLabel.String = '';
            app.headplotaxs.Title.String = '';

            app.locfile = '';
            app.loccom  = '';

            %to close out gui
            ready = 0;
            if ready == 1
                app.Finishbutton = 1;
            end
            app.EditlocsinDropDown.Value = 'XYZ';
            %%-----------------get the input-------------------------------
            app.output = [];
            %%set title name
            try
                titleName = varargin{2};
                set(app.UIFigure,'Name', ['Estudio' version, '-',32,titleName]);
            catch
                set(app.UIFigure,'Name', ['Estudio ' version '   -   Channel Location Editor GUI']);
            end

            try
                EEG = varargin{1};
            catch
                beep;
                disp('There is no input');
                app.Finishbutton = 1;
                return;
            end

            try
                assert(isstruct(EEG)==1)
                assert(isfield(EEG, 'chanlocs')==1)
            catch
                beep;
                disp('This doesn''t look like a valid dataset. Check input');
                app.Finishbutton = 1;
                return;
            end
            if isempty(EEG)
                beep;
                disp('The dataset is empty');
                app.Finishbutton = 1;
                return;
            end
            % Check for chaninfo
            if isfield(EEG,'chaninfo') == 0
                EEG.chaninfo.icachanind = []; EEG.chaninfo.plotrad = []; EEG.chaninfo.shrink = []; EEG.chaninfo.nosedir = '+X'; EEG.chaninfo.nodatchans = [];
            end

            ch_n = numel(EEG.chanlocs);

            fields_here = fieldnames(EEG.chanlocs);
            field_labels = find(strcmp(fields_here,'labels')==1);
            locs_in = squeeze(struct2cell(EEG.chanlocs))';
            ch_labels = locs_in(:,field_labels);

            % Copy existing chanlocs directly, preserving all coordinate data.
            % Previously used a field-count check (< 12) to gate XYZ loading,
            % which silently skipped all values for datasets without 'urchan'
            % (removed in recent EEGLAB versions). Also stripped theta/radius/
            % sph values from the struct before calling cart2topo, leaving the
            % spherical view always empty. Fix: copy chanlocs as-is, ensure
            % required fields exist, then use cart2all to populate all views.
            nchl = EEG.chanlocs;

            required_fields = {'type','theta','radius','X','Y','Z','sph_theta','sph_phi','sph_radius','ref'};
            for fi = 1:numel(required_fields)
                if ~isfield(nchl, required_fields{fi})
                    [nchl.(required_fields{fi})] = deal([]);
                end
            end

            % If XYZ not set, derive from whichever coordinate system is available
            has_xyz  = any(~cellfun('isempty', {nchl.X}));
            has_topo = any(~cellfun('isempty', {nchl.theta}));
            has_sph  = any(~cellfun('isempty', {nchl.sph_theta}));

            if ~has_xyz
                if has_topo
                    [nchl] = pop_chanedit(nchl, 'convert', 'topo2cart');
                elseif has_sph
                    [nchl] = pop_chanedit(nchl, 'convert', 'sph2cart');
                end
            end
            % Fill in all coordinate systems so both XYZ and spherical views work
            [nchl] = pop_chanedit(nchl, 'convert', 'cart2all');


            %app.locformat = {'channum','X','Y','Z','labels'};
            app.locformat = 'sph';
            app.tformat = 'xyz';

            app.nchl = nchl;
            app.ch_n = ch_n;
            app.ch_labels = ch_labels;
            app.xyz = [];
            app.nchl_orig = nchl;
            app.EEG = EEG;
            if isfield(EEG,'bindata')
                app.LoadlocationsfromEEGdataButton.Text = 'Load locations from ERP data';
            else
                app.LoadlocationsfromEEGdataButton.Text = 'Load locations from EEG data';
            end

            refreshtable(app);
            refreshhp(app);
            painterplabapp(app);
            setfonterplab(app);
        end

        % Callback function
        function headplotButtonDown(app, event)
            set(app.headplot, '')
        end

        % Button pushed function: LoadchanlocsfromlocfileButton
        function load_locfile(app, event)
            % Extension-to-filetype map for readlocs
            ext_fmt = {'.loc','loc'; '.locs','loc'; '.sph','sph'; '.sfp','sfp'; ...
                       '.xyz','xyz'; '.elc','elc'; '.elp','besa'; '.ced','chanedit'};

            app.UIFigure.Visible = 'off';
            [lfile,lpath] = uigetfile({...
                '*.*',          'All files (*.*) - format detected from extension'; ...
                '*.loc;*.locs', 'EEGLAB polar (*.loc, *.locs)'; ...
                '*.sph',        'EEGLAB spherical (*.sph)'; ...
                '*.sfp',        'Cartesian label-X-Y-Z (*.sfp)'; ...
                '*.xyz',        'Cartesian X-Y-Z-label (*.xyz)'; ...
                '*.elc',        'ASA electrode file (*.elc)'; ...
                '*.elp',        'BESA / Polhemus (*.elp)'; ...
                '*.ced',        'EEGLAB channel edit (*.ced)'}, ...
                'Choose a file with channel location information');
            app.UIFigure.Visible = 'on';
            figure(app.UIFigure);

            if isequal(lfile, 0)
                return
            end

            [~,~,ext] = fileparts(lfile);
            fmt_idx = find(strcmpi(ext_fmt(:,1), ext));

            try
                if ~isempty(fmt_idx)
                    lnchl = readlocs([lpath lfile], 'filetype', ext_fmt{fmt_idx,2});
                else
                    lnchl = readlocs([lpath lfile]);  % let readlocs auto-detect
                end
            catch ME
                estudio_warning(['Could not read location file.' newline ME.message], ...
                    'Load channel locations');
                figure(app.UIFigure);
                return
            end

            if isempty(lnchl)
                estudio_warning('No channel locations were found in the file.', ...
                    'Load channel locations');
                figure(app.UIFigure);
                return
            end

            % Match loaded locations to current channels by label
            loaded_labels = {lnchl.labels}';
            if isequal(loaded_labels, app.ch_labels)
                % Exact match — use directly
                app.nchl = lnchl;
            else
                % Try label-by-label matching (handles different channel counts/field sets)
                lfields = fieldnames(lnchl);
                n_matched = 0;
                for i = 1:app.ch_n
                    idx = find(strcmp(app.ch_labels{i}, loaded_labels), 1);
                    if ~isempty(idx)
                        % Copy only fields that exist in both structs
                        for fi = 1:numel(lfields)
                            if isfield(app.nchl, lfields{fi})
                                app.nchl(i).(lfields{fi}) = lnchl(idx).(lfields{fi});
                            end
                        end
                        n_matched = n_matched + 1;
                    end
                end
                if n_matched == 0
                    estudio_warning(['No channel labels in the location file match the current dataset.' ...
                        newline 'The file may be for a different montage. No locations were applied.'], ...
                        'Load channel locations');
                    figure(app.UIFigure);
                    return
                elseif n_matched < app.ch_n
                    fprintf('Load channel locations: matched %d of %d channels by label. Unmatched channels retain their previous locations.\n', ...
                        n_matched, app.ch_n);
                end
            end

            % Ensure all coordinate systems are filled in
            required_fields = {'type','theta','radius','X','Y','Z','sph_theta','sph_phi','sph_radius','ref'};
            for fi = 1:numel(required_fields)
                if ~isfield(app.nchl, required_fields{fi})
                    [app.nchl.(required_fields{fi})] = deal([]);
                end
            end
            has_xyz  = any(~cellfun('isempty', {app.nchl.X}));
            has_topo = any(~cellfun('isempty', {app.nchl.theta}));
            has_sph  = any(~cellfun('isempty', {app.nchl.sph_theta}));
            if ~has_xyz
                if has_topo
                    app.nchl = pop_chanedit(app.nchl, 'convert', 'topo2cart');
                elseif has_sph
                    app.nchl = pop_chanedit(app.nchl, 'convert', 'sph2cart');
                end
            end
            app.nchl = pop_chanedit(app.nchl, 'convert', 'cart2all');

            app.locfile = fullfile(lpath, lfile);
            app.loccom  = '';
            refreshtable(app);
            refreshhp(app);
            figure(app.UIFigure);
        end

        % Button pushed function: LoadlocationsfromEEGdataButton
        function load2dataset(app, event)
            EEG = app.EEG;
            app.UIFigure.Visible = 'off';
            if isfield(EEG,'bindata')
                [lfile,lpath] = uigetfile({'*.erp','ERP (*.erp)'},'Choose a dataset file that has channel location information',...
                    'MultiSelect', 'off');
            else
                [lfile,lpath] = uigetfile({'*.set','EEG (*.set)';'*.erp','ERP (*.erp)'},'Choose a dataset file that has channel location information',...
                    'MultiSelect', 'off');
            end
            app.UIFigure.Visible = 'on';
            figure(app.UIFigure);

            if lfile == 0
                disp('Location load file cancelled')
                return
            end
            %%need to change this. Sep 27, 2023
            if isfield(EEG,'bindata')%%load erp
                EEG_l = pop_loaderp('filename', lfile, 'filepath', lpath );
            else
                EEG_l = pop_loadset(lfile,lpath);
            end
            lnchl = EEG_l.chanlocs;

            loaded_labels = {lnchl.labels}';
            if isequal(loaded_labels, app.ch_labels)
                app.nchl = lnchl;
            else
                lfields = fieldnames(lnchl);
                n_matched = 0;
                for i = 1:app.ch_n
                    idx = find(strcmp(app.ch_labels{i}, loaded_labels), 1);
                    if ~isempty(idx)
                        for fi = 1:numel(lfields)
                            if isfield(app.nchl, lfields{fi})
                                app.nchl(i).(lfields{fi}) = lnchl(idx).(lfields{fi});
                            end
                        end
                        n_matched = n_matched + 1;
                    end
                end
                if n_matched == 0
                    estudio_warning(['No channel labels in the selected dataset match the current dataset.' ...
                        newline 'No locations were applied.'], 'Load channel locations');
                    figure(app.UIFigure);
                    return
                elseif n_matched < app.ch_n
                    fprintf('Load channel locations: matched %d of %d channels by label. Unmatched channels retain their previous locations.\n', ...
                        n_matched, app.ch_n);
                end
            end

            % Ensure all coordinate systems are filled in (same as startup)
            required_fields = {'type','theta','radius','X','Y','Z','sph_theta','sph_phi','sph_radius','ref'};
            for fi = 1:numel(required_fields)
                if ~isfield(app.nchl, required_fields{fi})
                    [app.nchl.(required_fields{fi})] = deal([]);
                end
            end
            has_xyz  = any(~cellfun('isempty', {app.nchl.X}));
            has_topo = any(~cellfun('isempty', {app.nchl.theta}));
            has_sph  = any(~cellfun('isempty', {app.nchl.sph_theta}));
            if ~has_xyz
                if has_topo
                    app.nchl = pop_chanedit(app.nchl, 'convert', 'topo2cart');
                elseif has_sph
                    app.nchl = pop_chanedit(app.nchl, 'convert', 'sph2cart');
                end
            end
            app.nchl = pop_chanedit(app.nchl, 'convert', 'cart2all');

            app.locfile = '';
            app.loccom  = '';
            refreshtable(app);
            refreshhp(app);
            figure(app.UIFigure);
        end

        % Button pushed function: SavelocationstolocfileButton
        function save2locfile(app, event)
            % Extension-to-filetype map for writelocs (read-only formats elc/besa excluded)
            ext_fmt = {'.loc','loc'; '.sph','sph'; '.sfp','sfp'; '.xyz','xyz'; '.ced','chanedit'};

            app.UIFigure.Visible = 'off';
            [sfile,spath] = uiputfile({...
                '*.loc',  'EEGLAB polar (*.loc)'; ...
                '*.sph',  'EEGLAB spherical (*.sph)'; ...
                '*.sfp',  'Cartesian label-X-Y-Z (*.sfp)'; ...
                '*.xyz',  'Cartesian X-Y-Z-label (*.xyz)'; ...
                '*.ced',  'EEGLAB channel edit (*.ced)'}, ...
                'Save channel locations');
            app.UIFigure.Visible = 'on';
            figure(app.UIFigure);

            if isequal(sfile, 0)
                return
            end

            [~,~,ext] = fileparts(sfile);
            fmt_idx = find(strcmpi(ext_fmt(:,1), ext));
            if isempty(fmt_idx)
                fmt = 'loc';  % default if user types an unknown extension
            else
                fmt = ext_fmt{fmt_idx,2};
            end

            try
                writelocs(app.nchl, [spath sfile], 'filetype', fmt);
            catch ME
                estudio_warning(['Could not save location file.' newline ME.message], ...
                    'Save channel locations');
            end
        end

        % Value changed function: EditlocsinDropDown
        function editlocsop(app, event)
            value = app.EditlocsinDropDown.Value;
            if strcmpi(value,'XYZ')
                app.tformat = 'xyz';
            else
                app.tformat = 'sph';
            end
            refreshtable(app);
        end

        % Button pushed function: ResetlocationinfotableButton
        function restlocstable(app, event)
            confirm_reset = questdlg('Reset the locations in this table to the original values?');
            if strcmp(confirm_reset, 'Yes') == 1
                app.nchl    = app.nchl_orig;
                app.locfile = '';
                app.loccom  = '';
                refreshtable(app);
                refreshhp(app);
                loc_table_CellEditCallback(app, event);
            end
        end

        % Button pushed function: CancelButton
        function cancel(app, event)
            app.output =[];
            app.Finishbutton = 1;
        end

        % Button pushed function: OkayButton
        function Okay(app, event)
            app.EEG.chanlocs = app.nchl;
            app.output = app.EEG;
            app.Finishbutton = 1;
        end

        % Cell edit callback: loc_table
        function loc_table_CellEditCallback(app, event)
            %             indices = event.Indices;
            %             newData = event.NewData;
            tdata = app.loc_table.Data;

            % recreate a new channel location structure
            for i = 1:app.ch_n
                nchl(i).labels = app.ch_labels{i};
                nchl(i).type = [];
                nchl(i).theta = [];
                nchl(i).radius = [];
                nchl(i).X = [];%handles.xyz(i,1);
                nchl(i).Y = [];%handles.xyz(i,2);
                nchl(i).Z = [];%handles.xyz(i,3);
                nchl(i).sph_theta = [];
                nchl(i).sph_phi = [];
                nchl(i).sph_radius = 85;
                nchl(i).ref = [];
                if strcmp(app.tformat,'xyz')  % in xyz
                    nchl(i).X = tdata(i,1);
                    nchl(i).Y = tdata(i,2);
                    nchl(i).Z = tdata(i,3);

                elseif strcmp(app.tformat,'sph')  % in sph
                    nchl(i).sph_theta = tdata(i,1);
                    nchl(i).sph_phi = tdata(i,2);
                end
            end

            if strcmp(app.tformat,'xyz')  % in xyz
                [nchl] = pop_chanedit(nchl, 'convert','cart2all');
            else
                [nchl] = pop_chanedit(nchl, 'convert','sph2all');
            end
            app.nchl    = nchl;
            app.locfile = '';
            app.loccom  = '';
            refreshtable(app);
            refreshhp(app);
        end

        % Button pushed function: GuesschanlocsButton
        function geuss_chanlocs(app, event)
            EEG1 = app.EEG;
            if isfield(EEG1,'bindata')
                EEG = eeg_emptyset();
                EEG.nbchan      = EEG1.nchan;
                EEG.trials      = EEG1.nbin;
                EEG.pnts        = EEG1.pnts;
                EEG.srate       = EEG1.srate;
                EEG.xmin        = EEG1.xmin;
                EEG.xmax        = EEG1.xmax;
                EEG.times       = EEG1.times;
                EEG.data        = EEG1.bindata;
                EEG.icaact      = [];
                EEG.icawinv     = [];
                EEG.icasphere   = [];
                EEG.icaweights  = [];
                EEG.icachansind = [];
                EEG.chanlocs    = EEG1.chanlocs;
                EEG.urchanlocs  = [];
                EEG.chaninfo    = [];
                [EEG2, chaninfo, urchans, LASTCOM] =pop_chanedit(EEG);
            else
                [EEG2, chaninfo, urchans, LASTCOM] =pop_chanedit(EEG1);

            end
            EEG1.chanlocs = EEG2.chanlocs;
            app.EEG    = EEG1;
            app.locfile = '';
            app.loccom  = LASTCOM;

             lnchl = EEG1.chanlocs;

            % Sanity check
            loaded = struct2cell(lnchl);
            loaded = squeeze(loaded)';
            loaded_labels = loaded(:,1);
            loaded_n = length(lnchl);

            if isequal(loaded_labels,app.ch_labels)
                % if the labels exactly match, just write to app
                app.nchl = lnchl;
                done_loading = 1;
            end
              app.nchl = app.EEG.chanlocs;
            fields_here = fieldnames(app.nchl);
            field_x = find(strcmp(fields_here,'X')==1);
            field_y = find(strcmp(fields_here,'Y')==1);
            field_z = find(strcmp(fields_here,'Z')==1);
            field_labels = find(strcmp(fields_here,'labels')==1);

            % Remake the xyz num array
            locs_cells = [loaded(:,field_x) loaded(:,field_y) loaded(:,field_z)];
            empty_cells = cellfun('isempty',locs_cells);
            if any(empty_cells(:))
                for i = 1:numel(empty_cells)
                    if empty_cells(i)
                        locs_cells{i} = 0;
                    end
                end

                % Record which chans were missing
                for ir = 1:loaded_n
                    if any(empty_cells(ir,:))
                        missing(ir) = 1;
                    end
                end
            end

            % convert de-nan'd cells to numeric array
            app.xyz = cell2mat(locs_cells);

            %nchl.type = 'nope';
            refreshtable(app);
            refreshhp(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 893 681];
            app.UIFigure.Name = 'MATLAB App';

            % Create LocationInformationTablePanel
            app.LocationInformationTablePanel = uipanel(app.UIFigure);
            app.LocationInformationTablePanel.Title = 'Location Information Table';
            app.LocationInformationTablePanel.Position = [454 103 427 568];

            % Create loc_table
            app.loc_table = uitable(app.LocationInformationTablePanel);
            app.loc_table.ColumnName = {'Column 1'; 'Column 2'; 'Column 3'};
            app.loc_table.RowName = {};
            app.loc_table.CellEditCallback = createCallbackFcn(app, @loc_table_CellEditCallback, true);
            app.loc_table.Position = [0 -2 426 553];

            % Create ChannelLocationHeadplotPanel
            app.ChannelLocationHeadplotPanel = uipanel(app.UIFigure);
            app.ChannelLocationHeadplotPanel.Title = 'Channel Location Headplot';
            app.ChannelLocationHeadplotPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ChannelLocationHeadplotPanel.Position = [12 103 427 568];

            % Create headplotaxs
            app.headplotaxs = uiaxes(app.ChannelLocationHeadplotPanel);
            app.headplotaxs.XTick = [];
            app.headplotaxs.YTick = [];
            app.headplotaxs.Position = [1 -2 426 553];

            % Create LoadsavechanlocationsPanel
            app.LoadsavechanlocationsPanel = uipanel(app.UIFigure);
            app.LoadsavechanlocationsPanel.Title = 'Load/save chan locations';
            app.LoadsavechanlocationsPanel.Position = [10 12 431 85];

            % Create LoadchanlocsfromlocfileButton
            app.LoadchanlocsfromlocfileButton = uibutton(app.LoadsavechanlocationsPanel, 'push');
            app.LoadchanlocsfromlocfileButton.ButtonPushedFcn = createCallbackFcn(app, @load_locfile, true);
            app.LoadchanlocsfromlocfileButton.Position = [12 35 168 25];
            app.LoadchanlocsfromlocfileButton.Text = 'Load chanlocs from loc file';

            % Create LoadlocationsfromEEGdataButton
            app.LoadlocationsfromEEGdataButton = uibutton(app.LoadsavechanlocationsPanel, 'push');
            app.LoadlocationsfromEEGdataButton.ButtonPushedFcn = createCallbackFcn(app, @load2dataset, true);
            app.LoadlocationsfromEEGdataButton.Position = [227 35 177 25];
            app.LoadlocationsfromEEGdataButton.Text = 'Load locations from EEG data';

            % Create SavelocationstolocfileButton
            app.SavelocationstolocfileButton = uibutton(app.LoadsavechanlocationsPanel, 'push');
            app.SavelocationstolocfileButton.ButtonPushedFcn = createCallbackFcn(app, @save2locfile, true);
            app.SavelocationstolocfileButton.Position = [233 4 168 25];
            app.SavelocationstolocfileButton.Text = 'Save locations to loc file';

            % Create GuesschanlocsButton
            app.GuesschanlocsButton = uibutton(app.LoadsavechanlocationsPanel, 'push');
            app.GuesschanlocsButton.ButtonPushedFcn = createCallbackFcn(app, @geuss_chanlocs, true);
            app.GuesschanlocsButton.Position = [13 4 168 25];
            app.GuesschanlocsButton.Text = 'Guess chanlocs';

            % Create EditlocsinDropDownLabel
            app.EditlocsinDropDownLabel = uilabel(app.UIFigure);
            app.EditlocsinDropDownLabel.HorizontalAlignment = 'right';
            app.EditlocsinDropDownLabel.Position = [472 60 68 22];
            app.EditlocsinDropDownLabel.Text = 'Edit locs in ';

            % Create EditlocsinDropDown
            app.EditlocsinDropDown = uidropdown(app.UIFigure);
            app.EditlocsinDropDown.Items = {'XYZ', 'Spherical Matlab co-ord'};
            app.EditlocsinDropDown.ValueChangedFcn = createCallbackFcn(app, @editlocsop, true);
            app.EditlocsinDropDown.Position = [555 60 100 22];
            app.EditlocsinDropDown.Value = 'Spherical Matlab co-ord';

            % Create ResetlocationinfotableButton
            app.ResetlocationinfotableButton = uibutton(app.UIFigure, 'push');
            app.ResetlocationinfotableButton.ButtonPushedFcn = createCallbackFcn(app, @restlocstable, true);
            app.ResetlocationinfotableButton.Position = [693 58 169 30];
            app.ResetlocationinfotableButton.Text = 'Reset location info table';

            % Create CancelButton
            app.CancelButton = uibutton(app.UIFigure, 'push');
            app.CancelButton.ButtonPushedFcn = createCallbackFcn(app, @cancel, true);
            app.CancelButton.Position = [502 12 100 40];
            app.CancelButton.Text = 'Cancel';

            % Create OkayButton
            app.OkayButton = uibutton(app.UIFigure, 'push');
            app.OkayButton.ButtonPushedFcn = createCallbackFcn(app, @Okay, true);
            app.OkayButton.Position = [742 12 100 40];
            app.OkayButton.Text = 'Okay';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = f_editchan_gui(varargin)

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
