%Author: Guanghui ZHANG && Steve LUCK
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Sep. 2023

% ERPLAB Studio



function varargout = f_EEG_chanoperation_GUI(varargin)
global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

gui_eegtab_chan_optn = struct();

%-----------------------------Name the title----------------------------------------------
% global EEG_chan_operation_gui;
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Channel Operations', ...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Channel Operations',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Channel Operations',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @chanop_help
end

%-----------------------------Draw the panel-------------------------------------
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_erp_bin_operation(FonsizeDefault);
varargout{1} = EEG_chan_operation_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        FontSize_defualt = FonsizeDefault;
        if isempty(FontSize_defualt)
            FontSize_defualt = 12;
        end
        if isempty(observe_EEGDAT.ALLEEG) && isempty(observe_EEGDAT.EEG)
            Enable_label = 'off';
        else
            Enable_label = 'on';
        end
        %%--------------------channel and bin setting----------------------
        gui_eegtab_chan_optn.DataSelBox = uiextras.VBox('Parent', EEG_chan_operation_gui,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_eegtab_chan_optn.erp_history_table = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.edit_bineq = uitable(  ...
            'Parent'        , gui_eegtab_chan_optn.erp_history_table,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {1000}, ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        gui_eegtab_chan_optn.Paras{1} = gui_eegtab_chan_optn.edit_bineq.Data;
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,length(dsnames)),'FontSize',FontSize_defualt);
        gui_eegtab_chan_optn.edit_bineq.KeyPressFcn=  @eeg_chanop_presskey;
        gui_eegtab_chan_optn.equation_selection = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.eq_editor = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Advanced','callback',@eq_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.eq_load = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Load EQ','callback',@eq_load,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.eq_save = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Save EQ','callback',@eq_save,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.eq_clear = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Clear','callback',@eq_clear,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        gui_eegtab_chan_optn.asst_locaInfo = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.ref_asst = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.asst_locaInfo,...
            'String','Reference Asst','callback',@ref_asst,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.locaInfor = uicontrol('Style','checkbox','Parent',gui_eegtab_chan_optn.asst_locaInfo,...
            'String','','callback',@loca_infor,'FontSize',FontSize_defualt,'Value',1,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_eegtab_chan_optn.locaInfor.String =  '<html>Try to Preserve<br />Location Information</html>';
        gui_eegtab_chan_optn.Paras{2} = gui_eegtab_chan_optn.locaInfor.Value;
        set(gui_eegtab_chan_optn.asst_locaInfo,'Sizes',[105 180]);
        %%%----------------Mode-----------------------------------
        gui_eegtab_chan_optn.mode_1 = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.mode_modify_title = uicontrol('Style','text','Parent',gui_eegtab_chan_optn.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_eegtab_chan_optn.mode_modify = uicontrol('Style','radiobutton','Parent',gui_eegtab_chan_optn.mode_1 ,...
            'String','Modify Existing ERPset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_eegtab_chan_optn.mode_modify.KeyPressFcn=  @eeg_chanop_presskey;
        gui_eegtab_chan_optn.mode_modify.String =  '<html>Modify Existing dataset<br />(recursive updating)</html>';
        set(gui_eegtab_chan_optn.mode_1,'Sizes',[55 -1]);
        gui_eegtab_chan_optn.Paras{3} =gui_eegtab_chan_optn.mode_modify.Value;
        %%--------------For create a new ERPset----------------------------
        gui_eegtab_chan_optn.mode_2 = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_eegtab_chan_optn.mode_2,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.mode_create = uicontrol('Style','radiobutton','Parent',gui_eegtab_chan_optn.mode_2 ,...
            'String',{'', ''},'callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_eegtab_chan_optn.mode_create.KeyPressFcn=  @eeg_chanop_presskey;
        gui_eegtab_chan_optn.mode_create.String =  '<html>Create New dataset<br />(independent transformations)</html>';
        set(gui_eegtab_chan_optn.mode_2,'Sizes',[55 -1]);
        
        %%-----------------Run---------------------------------------------
        gui_eegtab_chan_optn.run_title = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_eegtab_chan_optn.run_title,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.cancel = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.run_title,...
            'String','Cancel','callback',@chanop_cancel,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  gui_eegtab_chan_optn.run_title,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.chanop_apply = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.run_title,...
            'String','Run','callback',@chanop_eeg_apply,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_eegtab_chan_optn.run_title,'BackgroundColor',ColorB_def);
        set(gui_eegtab_chan_optn.run_title,'Sizes',[15 105  30 105 15]);
        
        set(gui_eegtab_chan_optn.DataSelBox,'Sizes',[130,30,35,35,35,30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------Equation editor---------------------------------------
    function eq_advanced(Source_editor,~)
        if isempty(observe_EEGDAT.EEG)
            Source_editor.Enable = 'off';
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        
        def  = erpworkingmemory('pop_eegchanoperator');
        if isempty(def)
            def = { [], 1};
        end
        chanopGUI = erpworkingmemory('chanopGUI');
        if  gui_eegtab_chan_optn.mode_modify.Value==1
            chanopGUI.emode=0;
        else
            chanopGUI.emode=1;
        end
        if isfield(chanopGUI,'hmode')
            hmode = chanopGUI.hmode;
            if isnumeric(hmode)
                if numel(hmode)~=1 || (hmode~=0&& hmode~=1)
                    chanopGUI.hmode = 0;
                end
            else
                chanopGUI.hmode = 0;
            end
        else
            chanopGUI.hmode = 0;
        end
        if isfield(chanopGUI,'listname')
            if ~ischar(chanopGUI.listname)
                chanopGUI.listname = '';
            end
        else
            chanopGUI.listname = '';
        end
        localInfor = gui_eegtab_chan_optn.locaInfor.Value;
        chanopGUI.keeplocs = localInfor;
        erpworkingmemory('chanopGUI',chanopGUI);
        
        EEG = observe_EEGDAT.EEG;
        answer = chanoperGUI(EEG, def);
        if isempty(answer)
            return
        end
        chanopGUI = erpworkingmemory('chanopGUI');
        ModeValue = chanopGUI.emode;
        if ModeValue==0
            gui_eegtab_chan_optn.mode_modify.Value=1 ;
            gui_eegtab_chan_optn.mode_create.Value = 0;
        else
            gui_eegtab_chan_optn.mode_modify.Value=0 ;
            gui_eegtab_chan_optn.mode_create.Value = 1;
        end
        localInfor = chanopGUI.keeplocs;
        if localInfor==1
            gui_eegtab_chan_optn.locaInfor.Value=1;
        else
            gui_eegtab_chan_optn.locaInfor.Value=0;
        end
        
        formulas = answer{1};
        wbmsgon  = answer{2};
        keeplocs = answer{3};
        if keeplocs ==1
            gui_eegtab_chan_optn.locaInfor.Value = 1;
        else
            gui_eegtab_chan_optn.locaInfor.Value = 0;
        end
        
        def = {formulas, wbmsgon};
        erpworkingmemory('pop_eegchanoperator', def);
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        
        if ~isempty(def{1,1})
            Eqs = def{1,1};
            for ii = 1:length(def{1,1})
                dsnames{ii,1}  = Eqs{ii};
            end
            gui_eegtab_chan_optn.edit_bineq.Data = dsnames;
            set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        end
    end

%%-------------------Equation Load---------------------------------------
    function eq_load(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        
        [filename, filepath] = uigetfile({'*.txt';'*.*'},'Select a formulas-file');
        if isequal(filename,0)
            return
        else
            fullname = fullfile(filepath, filename);
            disp(['f_EEG_chanoperation_GUI(): For formulas-file, user selected ', fullname])
        end
        
        fid_formula = fopen( fullname );
        try
            formcell    = textscan(fid_formula, '%s','delimiter', '\r');
            formulas    = char(formcell{:});
        catch
            msgboxText =  ['Channel Operations - Please, check your file: '...
                fullname];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if size(formulas,2)>256
            msgboxText =  ['Channel Operations - Formulas length exceed 256 characters,'...
                'Be sure to press [Enter] after you have entered each formula.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        fclose(fid_formula);
        gui_eegtab_chan_optn.edit_bineq.Data = formcell{1,1};
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end


%%------------------------------Save eq.-----------------------------------
    function eq_save(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        Eq_Data =  gui_eegtab_chan_optn.edit_bineq.Data;
        Formula_str = {};
        count = 0;
        for ii = 1:length(Eq_Data)
            if ~isempty(Eq_Data{ii})
                count = count +1;
                Formula_str{count} = Eq_Data{ii};
            end
        end
        msgboxText =  ['Channel Operations >Save'];
        erpworkingmemory('f_EEG_proces_messg',msgboxText);
        observe_EEGDAT.eeg_panel_message =1;
        if isempty(Formula_str)
            msgboxText =  ['Channel Operations >Save - You have not yet written a formula'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        [filename, filepath, filterindex] = uiputfile({'*.txt';'*.*'},'Save formulas-file as',pathName);
        if isequal(filename,0)
            return
        else
            [px, fname, ext] = fileparts(filename);
            ext   = '.txt';
            fname = [ fname ext];
            fullname = fullfile(filepath, fname);
            fid_list   = fopen( fullname , 'w');
            for i=1:length(Formula_str)
                fprintf(fid_list,'%s\n', Formula_str{i});
            end
            
            fclose(fid_list);
            disp(['Saving equation list at <a href="matlab: open(''' fullname ''')">' fullname '</a>'])
        end
        observe_EEGDAT.eeg_panel_message =2;
    end

%%-------------------Equation Clear---------------------------------------
    function eq_clear(~,~)
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        gui_eegtab_chan_optn.edit_bineq.Data = dsnames;
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%-------------------Reference assist--------------------------------------
    function ref_asst(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        
        gui_eegtab_chan_optn.mode_modify.Value = 0;
        gui_eegtab_chan_optn.mode_create.Value = 1;
        
        try
            EEG =  observe_EEGDAT.EEG;
            nchan = EEG.nbchan;
        catch
            EEG.chanlocs = [];
            nchan    = 1;
        end
        listch=[];
        if isempty(EEG.chanlocs)
            for Numofchan=1:nchan
                EEG.chanlocs(Numofchan).labels = ['Ch' num2str(Numofchan)];
            end
        end
        listch = cell(1,nchan);
        for ch =1:nchan
            listch{ch} = [num2str(ch) ' = ' EEG.chanlocs(ch).labels ];
        end
        
        % open reference wizard
        formulalist = f_rerefassistantGUI(nchan, listch);
        if isempty(formulalist)
            return;
        end
        formulas  = char(gui_eegtab_chan_optn.edit_bineq.Data);
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        
        if gui_eegtab_chan_optn.mode_create.Value
            formulalist = cellstr([formulalist{:}]);
            for t=1:length(formulalist)
                [expspliter parts] = regexp(formulalist, '=','match','split');
                formulalist{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '[^n]*ch','nch','ignorecase')), strtrim(parts{t}{2}));
            end
        end
        if isempty(formulas)
            for ii = 1:length(formulalist)
                dsnames{ii,1}  = formulalist{ii};
            end
            gui_eegtab_chan_optn.edit_bineq.Data =dsnames;
        else
            formulas = cellstr(formulas);
            count = 0;
            for ii = 1:length(formulas)
                if ~isempty(formulas{ii})
                    count = count+1;
                    dsnames{count,1}  = formulas{ii};
                end
            end
            
            for ii = 1:length(formulalist)
                dsnames{count+ii,1}  = formulalist{ii};
            end
            clear count;
            gui_eegtab_chan_optn.edit_bineq.Data =dsnames;
        end
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%--------------------Preserve location information------------------------
    function loca_infor(source,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        
        Value = source.Value;
        gui_eegtab_chan_optn.locaInfor.Value = Value;
    end

%%------------------Modify Existing ERPset---------------------------------------
    function mode_modify(Source_editor,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        gui_eegtab_chan_optn.mode_modify.Value = 1;
        gui_eegtab_chan_optn.mode_create.Value = 0;
        
        FormulaArrayIn = gui_eegtab_chan_optn.edit_bineq.Data;
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_eegchanoperator');
            try FormulaArrayIn_default = def{1};catch FormulaArrayIn_default = '';end
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn_default, 'recu');
                def{1} = formulaArray;
                erpworkingmemory('pop_eegchanoperator',def);
            end
        else
            [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn, 'recu');
        end
        if val ==1
            for ii = 1:100
                try
                    formulaArray{ii,1}  = formulaArray{ii};
                catch
                    formulaArray{ii,1}  = '';
                end
            end
            gui_eegtab_chan_optn.edit_bineq.Data =formulaArray;
            set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_eegchanoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_eegchanoperator',def);
        end
    end

%%------------------Create New ERPset---------------------------------------
    function mode_create(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_chanop',1);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [1 1 1];
        EEG_chan_operation_gui.TitleColor= [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [1 1 1];
        
        gui_eegtab_chan_optn.mode_modify.Value = 0;
        gui_eegtab_chan_optn.mode_create.Value = 1;
        FormulaArrayIn = char(gui_eegtab_chan_optn.edit_bineq.Data);
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_eegchanoperator');
            try
                FormulaArrayIn_default = def{1};
            catch
                FormulaArrayIn_default = '';
            end
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn_default, 'norecu');
                def{1} = formulaArray;
                erpworkingmemory('pop_eegchanoperator',def);
            else
                for ii = 1:100
                    formulaArray{ii,1}  = '';
                end
            end
        else
            [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn, 'norecu');
        end
        if val ==1
            for ii = 1:100
                try
                    formulaArray{ii,1}  = formulaArray{ii};
                catch
                    formulaArray{ii,1}  = '';
                end
            end
            gui_eegtab_chan_optn.edit_bineq.Data =formulaArray;
            set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_eegchanoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_eegchanoperator',def);
        end
    end

%%-----------------------cancel--------------------------------------------
    function chanop_cancel(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Channel Operations > Cancel');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        estudioworkingmemory('EEGTab_chanop',0);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
        EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
        %%
        Data =  gui_eegtab_chan_optn.Paras{1};
        gui_eegtab_chan_optn.edit_bineq.Data=Data;
        locaInfor = gui_eegtab_chan_optn.Paras{2};
        gui_eegtab_chan_optn.locaInfor.Value=locaInfor;
        mode_modify = gui_eegtab_chan_optn.Paras{3};
        gui_eegtab_chan_optn.mode_modify.Value=mode_modify;
        gui_eegtab_chan_optn.mode_create.Value=~mode_modify;
        observe_EEGDAT.eeg_panel_message =2;
    end

%%---------------------Run-------------------------------------------------
    function chanop_eeg_apply(~,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=4
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Channel Operations > Apply');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        estudioworkingmemory('EEGTab_chanop',0);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
        EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
        
        pathName_def =  erpworkingmemory('EEG_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray) || any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        Eq_Data =  gui_eegtab_chan_optn.edit_bineq.Data;
        Formula_str = {};
        count = 0;
        for ii = 1:length(Eq_Data)
            if ~isempty(Eq_Data{ii})
                count = count +1;
                Formula_str{count} = Eq_Data{ii};
            end
        end
        
        if isempty(Formula_str)
            msgboxText =  ['Channel Operations - You have not yet written a formula'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        %%check the format of equations
        if gui_eegtab_chan_optn.mode_modify.Value
            editormode = 0;
        else
            editormode = 1;
        end
        [option, recall, goeson] = checkformulas(cellstr(Formula_str), ['pop_eegchanoperator'], editormode);
        if goeson==0
            msgboxText =  ['Channel Operations - error might be found and please see Command Window'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        %%%Create a new ERPset for the bin-operated ERPsets
        if gui_eegtab_chan_optn.locaInfor.Value==1
            keeplocs ='on';
        else
            keeplocs ='off';
        end
        gui_eegtab_chan_optn.Paras{1} = gui_eegtab_chan_optn.edit_bineq.Data;
        gui_eegtab_chan_optn.Paras{2} = gui_eegtab_chan_optn.locaInfor.Value;
        gui_eegtab_chan_optn.Paras{3} =gui_eegtab_chan_optn.mode_modify.Value;
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)%%Bin Operations for each selected ERPset
            EEG = ALLEEG(EEGArray(Numofeeg));
            [EEG, LASTCOM] = pop_eegchanoperator(EEG, Formula_str, 'Warning', 'off', 'Saveas', 'off','ErrorMsg', 'command','KeepChLoc',keeplocs, 'History', 'gui');
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out EEG,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
        end
        
        Save_file_label = [];
        if gui_eegtab_chan_optn.mode_create.Value
            Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_chop');
            if isempty(Answer)
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG_out = Answer{1};
                Save_file_label = Answer{2};
            end
        end
        
        if gui_eegtab_chan_optn.mode_modify.Value%% If select "Modify Existing EEGset (recursive updating)"
            ALLEEG(EEGArray)=ALLEEG_out;
        elseif gui_eegtab_chan_optn.mode_create.Value==1 %% If select "Create New EEGset (independent transformations)"
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_out(Numofeeg);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                checkfileindex = checkfilexists([EEG.filepath,filesep,EEG.filename]);
                if Save_file_label==1 && checkfileindex==1
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                [ALLEEG EEG,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
            end
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        if gui_eegtab_chan_optn.mode_create.Value%%Save the labels of the selected ERPsets
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=6
            return;
        end
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            Enable_label = 'off';
        end
        if ~isempty(observe_EEGDAT.EEG)
            EEGArray =  estudioworkingmemory('EEGArray');
            if isempty(EEGArray) || min(EEGArray(:)) <=0 || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
                EEGArray = observe_EEGDAT.CURRENTSET;
                estudioworkingmemory('EEGArray',EEGArray);
            end
            ChaNumAll = [];
            for Numofeeg = 1:numel(EEGArray)
                ChaNumAll(Numofeeg) = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)).nbchan;
            end
            
            if numel(EEGArray)>1 && numel(unique(ChaNumAll)) >1
                Enable_label = 'off';
                for ii = 1:100
                    if ii==1
                        dsnames{ii,1} = '<html><font color="red">The number of channels should be the same for the selected EEGsets!';
                    else
                        dsnames{ii,1} = '';
                    end
                end
                gui_eegtab_chan_optn.edit_bineq.Data = dsnames;
                set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            else
                Enable_label = 'on';
                chanopDataor =  gui_eegtab_chan_optn.edit_bineq.Data;
                for ii = 1:100
                    chanopDataorcell = char(chanopDataor{ii,1});
                    aa  = '<html><font color="red">The number of channels should be the same for the selected EEGsets!';
                    if isempty(chanopDataorcell) || strcmpi(chanopDataorcell,aa)
                        dsnames{ii,1} = '';
                    else
                        dsnames{ii,1} = chanopDataorcell;
                    end
                end
                gui_eegtab_chan_optn.edit_bineq.Data = dsnames;
                set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            end
        end
        if  EEGUpdate==1
            Enable_label = 'off';
        end
        gui_eegtab_chan_optn.mode_modify.Enable=Enable_label;
        gui_eegtab_chan_optn.mode_create.Enable=Enable_label;
        gui_eegtab_chan_optn.eq_save.Enable = Enable_label;
        gui_eegtab_chan_optn.eq_editor.Enable = Enable_label;
        gui_eegtab_chan_optn.eq_load.Enable = Enable_label;
        gui_eegtab_chan_optn.eq_clear.Enable = Enable_label;
        gui_eegtab_chan_optn.chanop_apply.Enable = Enable_label;
        gui_eegtab_chan_optn.ref_asst.Enable = Enable_label;
        gui_eegtab_chan_optn.locaInfor.Enable = Enable_label;
        gui_eegtab_chan_optn.cancel.Enable = Enable_label;
        observe_EEGDAT.count_current_eeg =7;
    end



%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
%     function eeg_two_panels_change(~,~)
%         if observe_EEGDAT.eeg_two_panels==0
%             return;
%         end
%         ChangeFlag =  estudioworkingmemory('EEGTab_chanop');
%         if ChangeFlag~=1
%             return;
%         end
%         chanop_eeg_apply();
%         estudioworkingmemory('EEGTab_chanop',0);
%         gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
%         gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
%         EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
%         gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
%         gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
%     end


%%--------------press return to execute "Apply"----------------------------
    function eeg_chanop_presskey(hObject, eventdata)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_chanop');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            chanop_eeg_apply();
            estudioworkingmemory('EEGTab_chanop',0);
            gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
            gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
            EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
            gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
            gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end


%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=6
            return;
        end
        estudioworkingmemory('EEGTab_chanop',0);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
        %         EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_eegtab_chan_optn.edit_bineq.Data= dsnames;
        gui_eegtab_chan_optn.locaInfor.Value=1;
        gui_eegtab_chan_optn.mode_modify.Value = 1;
        gui_eegtab_chan_optn.mode_create.Value = 0;
        observe_EEGDAT.Reset_eeg_paras_panel=7;
    end
end


%%----------------check if the file already exists-------------------------
function checkfileindex = checkfilexists(filenamex)%%Jan 10 2024
checkfileindex=1;
[pathstr, file_name, ext] = fileparts(filenamex);
filenamex = [pathstr,filesep, file_name,'.set'];

if exist(filenamex, 'file')~=0
    msgboxText =  ['This EEG Data already exist.\n'...;
        'Would you like to overwrite it?'];
    title  = 'Estudio: WARNING!';
    button = askquest(sprintf(msgboxText), title);
    if strcmpi(button,'no')
        checkfileindex=0;
    else
        checkfileindex=1;
    end
end
end
