%Author: Guanghui ZHANG && Steve LUCK
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Sep. 2023

% ERPLAB Studio



function varargout = f_EEG_chanoperation_GUI(varargin)
global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_reset_def_paras_change',@eeg_reset_def_paras_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);

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
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'EEG Channel Operations', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Channel Operations', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EEG_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Channel Operations', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
        gui_eegtab_chan_optn.DataSelBox = uiextras.VBox('Parent', EEG_chan_operation_gui);
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
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,length(dsnames)),'FontSize',FontSize_defualt);
        gui_eegtab_chan_optn.edit_bineq.KeyPressFcn=  @eeg_chanop_presskey;
        gui_eegtab_chan_optn.equation_selection = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.eq_editor = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Eq. Advanced','callback',@eq_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.eq_load = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Load Eq.','callback',@eq_load,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.eq_clear = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.equation_selection,...
            'String','Clear Eq.','callback',@eq_clear,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        gui_eegtab_chan_optn.asst_locaInfo = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        gui_eegtab_chan_optn.ref_asst = uicontrol('Style','pushbutton','Parent',gui_eegtab_chan_optn.asst_locaInfo,...
            'String','Reference Asst','callback',@ref_asst,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_eegtab_chan_optn.locaInfor = uicontrol('Style','checkbox','Parent',gui_eegtab_chan_optn.asst_locaInfo,...
            'String','Load Eq.','callback',@loca_infor,'FontSize',FontSize_defualt,'Value',1,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_eegtab_chan_optn.locaInfor.String =  '<html>Try to Preserve<br />Location Information</html>';
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
        
        gui_eegtab_chan_optn.note_title = uiextras.HBox('Parent', gui_eegtab_chan_optn.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_eegtab_chan_optn.note_title,...
            'String','Note: Operates on channels','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        set(gui_eegtab_chan_optn.DataSelBox,'Sizes',[130,30,35,35,35,30 30]);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

% %%------------------Edit bin---------------------------------------------
    function chanop_cancel(~,~)%% It seems that it can be ignored
        web('https://github.com/lucklab/erplab/wiki/EEG-and-ERP-Channel-Operations','-browser');
    end


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
        chanopGUI.hmode = 0;
        chanopGUI.listname = [];
        localInfor = gui_eegtab_chan_optn.locaInfor.Value;
        chanopGUI.keeplocs = localInfor;
        erpworkingmemory('chanopGUI',chanopGUI);
        
        EEG = observe_EEGDAT.EEG;
        answer = chanoperGUI(EEG, def);
        if isempty(answer)
            disp('User selected Cancel')
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
            disp('User selected Cancel')
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
            msgboxText =  ['EEG Channel Operations - Please, check your file:\n '...
                fullname '\n'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        if size(formulas,2)>256
            msgboxText =  ['EEG Channel Operations - Formulas length exceed 256 characters,'...
                'Be sure to press [Enter] after you have entered each formula.'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        fclose(fid_formula);
        gui_eegtab_chan_optn.edit_bineq.Data = formcell{1,1};
        set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
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
            FormulaArrayIn_default = def{1};
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
    function mode_create(Source_create,~)
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
            FormulaArrayIn_default = def{1};
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
        erpworkingmemory('f_EEG_proces_messg','EEG Channel Operations > Apply');
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
        if isempty(EEGArray) || min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) || max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG)
            EEGArray = observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        
        if isempty(EEGArray)
            EEGArray = observe_EEGDAT.CURRENTSET;
            if isempty(EEGArray)
                msgboxText =  ['EEG Channel Operations - No EEGset was selected'];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                return;
            end
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
            msgboxText =  ['EEG Channel Operations - You have not yet written a formula'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
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
            msgboxText =  ['EEG Channel Operations - See Command Window'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        
        %%%Create a new ERPset for the bin-operated ERPsets
        Save_file_label = [];
        if gui_eegtab_chan_optn.mode_create.Value
            
            if numel(EEGArray) > 1
                Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray,'_chop');
                if isempty(Answer)
                    beep;
                    disp('User selected Cancel');
                    return;
                end
                if ~isempty(Answer{1})
                    ALLEEG_out = Answer{1};
                    Save_file_label = Answer{2};
                end
                
            elseif numel(EEGArray)== 1
                ALLEEG_out = observe_EEGDAT.ALLEEG;
                EEG = observe_EEGDAT.ALLEEG(EEGArray);
                EEG.filepath = pathName_def;
                Answer = f_EEG_save_single_file(strcat(EEG.setname,'_chop'),EEG.filename,EEGArray);
                if isempty(Answer)
                    beep;
                    disp('User selectd cancal');
                    return;
                end
                Save_file_label =0;
                if ~isempty(Answer)
                    EEGName = Answer{1};
                    if ~isempty(EEGName)
                        EEG.setname = EEGName;
                    end
                    fileName_full = Answer{2};
                    if isempty(fileName_full)
                        EEG.filename = EEG.setname;
                        Save_file_label =0;
                    elseif ~isempty(fileName_full)
                        [pathstr, file_name, ext] = fileparts(fileName_full);
                        ext = '.set';
                        if strcmp(pathstr,'')
                            pathstr = cd;
                        end
                        EEG.filename = [file_name,ext];
                        EEG.filepath = pathstr;
                        Save_file_label =1;
                    end
                    
                end
                ALLEEG_out(EEGArray) = EEG;clear EEG;
            end
        elseif   gui_eegtab_chan_optn.mode_modify.Value
            ALLEEG_out = observe_EEGDAT.ALLEEG;
        end
        
        if isempty(Save_file_label)
            Save_file_label =0;
        end
        
        if gui_eegtab_chan_optn.locaInfor.Value==1
            keeplocs ='on';
        else
            keeplocs ='off';
        end
        
        %         try
        ALLEEG = observe_EEGDAT.ALLEEG;
        for Numofeeg = 1:numel(EEGArray)%%Bin Operations for each selected ERPset
            EEG = ALLEEG_out(EEGArray(Numofeeg));
            [EEG, LASTCOM] = pop_eegchanoperator(EEG, Formula_str, 'Warning', 'off', 'Saveas', 'off','ErrorMsg', 'command','KeepChLoc',keeplocs, 'History', 'gui');
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            if gui_eegtab_chan_optn.mode_modify.Value%% If select "Modify Existing EEGset (recursive updating)"
                EEG.setname = strcat(EEG.setname,'_chop');
                ALLEEG(EEGArray(Numofeeg)) = EEG;
                %                     observe_EEGDAT.EEG= observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            elseif gui_eegtab_chan_optn.mode_create.Value %% If select "Create New EEGset (independent transformations)"
                [ALLEEG EEG,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                if Save_file_label==1
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                end
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        end
        estudioworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
        %         catch
        %             observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        %             observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        %             Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
        %             estudioworkingmemory('EEGArray',Selected_EEG_afd);
        %             assignin('base','EEG',observe_EEGDAT.EEG);
        %             assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        %             assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        %
        %             observe_EEGDAT.count_current_eeg=1;
        %             observe_EEGDAT.eeg_panel_message =3;%%
        %         end
        
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function count_current_eeg_change(~,~)
        if isempty(observe_EEGDAT.EEG)
            Enable_label = 'off';
        end
        if observe_EEGDAT.count_current_eeg ~=5
            return;
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
                    if isempty(chanopDataorcell)
                        dsnames{ii,1} = '';
                    else
                        dsnames{ii,1} = chanopDataorcell;
                    end
                end
                gui_eegtab_chan_optn.edit_bineq.Data = dsnames;
                set(gui_eegtab_chan_optn.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            end
        end
        gui_eegtab_chan_optn.mode_modify.Enable=Enable_label;
        gui_eegtab_chan_optn.mode_create.Enable=Enable_label;
        gui_eegtab_chan_optn.eq_editor.Enable = Enable_label;
        gui_eegtab_chan_optn.eq_load.Enable = Enable_label;
        gui_eegtab_chan_optn.eq_clear.Enable = Enable_label;
        gui_eegtab_chan_optn.chanop_apply.Enable = Enable_label;
        gui_eegtab_chan_optn.ref_asst.Enable = Enable_label;
        gui_eegtab_chan_optn.locaInfor.Enable = Enable_label;
        gui_eegtab_chan_optn.cancel.Enable = Enable_label;
        observe_EEGDAT.count_current_eeg =6;
    end



%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_chanop');
        if ChangeFlag~=1
            return;
        end
        chanop_eeg_apply();
        estudioworkingmemory('EEGTab_chanop',0);
        gui_eegtab_chan_optn.chanop_apply.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.chanop_apply.ForegroundColor = [0 0 0];
        EEG_chan_operation_gui.TitleColor= [0.0500    0.2500    0.5000];
        gui_eegtab_chan_optn.cancel.BackgroundColor =  [1 1 1];
        gui_eegtab_chan_optn.cancel.ForegroundColor = [0 0 0];
    end


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
end