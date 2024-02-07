%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022 && Nov. 2023

% ERPLAB Studio

function varargout = f_ERP_chanoperation_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

gui_erp_chan_operation = struct();
%-----------------------------Name the title----------------------------------------------
% global ERP_chan_operation_gui;
try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
if nargin == 0
    fig = figure(); % Parent figure
    ERP_chan_operation_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'ERP Channel Operations', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @chanop_help); % Create boxpanel
elseif nargin == 1
    ERP_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Channel Operations', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @chanop_help);
else
    ERP_chan_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Channel Operations', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def, 'HelpFcn', @chanop_help);
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
varargout{1} = ERP_chan_operation_gui;

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
        Enable_label = 'off';
        %%--------------------channel and bin setting----------------------
        gui_erp_chan_operation.DataSelBox = uiextras.VBox('Parent', ERP_chan_operation_gui);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_erp_chan_operation.erp_history_table = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.edit_bineq = uitable(  ...
            'Parent'        , gui_erp_chan_operation.erp_history_table,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {1000}, ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,length(dsnames)),'FontSize',FontSize_defualt);
        gui_erp_chan_operation.edit_bineq.KeyPressFcn= @erp_chanop_presskey;
        gui_erp_chan_operation.Paras{1} = gui_erp_chan_operation.edit_bineq.Data;
        
        gui_erp_chan_operation.equation_selection = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.eq_editor = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.equation_selection,...
            'String','Eq. Advanced','callback',@eq_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_chan_operation.eq_load = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.equation_selection,...
            'String','Load Eq.','callback',@eq_load,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_chan_operation.eq_clear = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.equation_selection,...
            'String','Clear Eq.','callback',@eq_clear,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        
        gui_erp_chan_operation.asst_locaInfo = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.ref_asst = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.asst_locaInfo,...
            'String','Reference Asst','callback',@ref_asst,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_chan_operation.locaInfor = uicontrol('Style','checkbox','Parent',gui_erp_chan_operation.asst_locaInfo,...
            'String','Load Eq.','callback',@loca_infor,'FontSize',FontSize_defualt,'Value',1,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_erp_chan_operation.locaInfor.String =  '<html>Try to Preserve<br />Location Information</html>';
        gui_erp_chan_operation.Paras{2} =gui_erp_chan_operation.locaInfor.Value;
        set(gui_erp_chan_operation.asst_locaInfo,'Sizes',[105 180]);
        gui_erp_chan_operation.locaInfor.KeyPressFcn= @erp_chanop_presskey;
        %%%----------------Mode-----------------------------------
        gui_erp_chan_operation.mode_1 = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.mode_modify_title = uicontrol('Style','text','Parent',gui_erp_chan_operation.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_chan_operation.mode_modify = uicontrol('Style','radiobutton','Parent',gui_erp_chan_operation.mode_1 ,...
            'String','Modify Existing ERPset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_erp_chan_operation.mode_modify.KeyPressFcn= @erp_chanop_presskey;
        gui_erp_chan_operation.mode_modify.String =  '<html>Modify Existing ERPset<br />(recursive updating)</html>';
        set(gui_erp_chan_operation.mode_1,'Sizes',[55 -1]);
        gui_erp_chan_operation.Paras{3} = gui_erp_chan_operation.mode_modify.Value;
        %%--------------For create a new ERPset----------------------------
        gui_erp_chan_operation.mode_2 = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_chan_operation.mode_2,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.mode_create = uicontrol('Style','radiobutton','Parent',gui_erp_chan_operation.mode_2 ,...
            'String',{'', ''},'callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_erp_chan_operation.mode_create.String =  '<html>Create New ERPset<br />(independent transformations)</html>';
        gui_erp_chan_operation.mode_create.KeyPressFcn= @erp_chanop_presskey;
        set(gui_erp_chan_operation.mode_2,'Sizes',[55 -1]);
        %%-----------------Run---------------------------------------------
        gui_erp_chan_operation.run_title = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        
        
        uiextras.Empty('Parent',  gui_erp_chan_operation.run_title,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.cancel = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.run_title,...
            'String','Cancel','callback',@chanop_cancel,'FontSize',FontSize_defualt,'Enable','off','BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',  gui_erp_chan_operation.run_title,'BackgroundColor',ColorB_def);
        gui_erp_chan_operation.run = uicontrol('Style','pushbutton','Parent',gui_erp_chan_operation.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_erp_chan_operation.run_title,'BackgroundColor',ColorB_def);
        set(gui_erp_chan_operation.run_title,'Sizes',[15 105  30 105 15]);
        
        gui_erp_chan_operation.note_title = uiextras.HBox('Parent', gui_erp_chan_operation.DataSelBox,'BackgroundColor',ColorB_def);
        uicontrol('Style','text','Parent',gui_erp_chan_operation.note_title,...
            'String','Note: Operates on all bins and channels','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        set(gui_erp_chan_operation.DataSelBox,'Sizes',[130,30,35,35,35,30 30]);
        
        estudioworkingmemory('ERPTab_chanop',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

% %%------------------Edit bin---------------------------------------------
    function chanop_help(~,~)%% It seems that it can be ignored
        web('https://github.com/lucklab/erplab/wiki/EEG-and-ERP-Channel-Operations','-browser');
    end

%%-------------------Equation editor---------------------------------------
    function eq_advanced(Source_editor,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        
        def  = erpworkingmemory('pop_erpchanoperator');
        if isempty(def)
            def = { [], 1};
        end
        chanopGUI = erpworkingmemory('chanopGUI');
        if  gui_erp_chan_operation.mode_modify.Value==1
            chanopGUI.emode=0;
        else
            chanopGUI.emode=1;
        end
        localInfor = gui_erp_chan_operation.locaInfor.Value;
        chanopGUI.keeplocs = localInfor;
        erpworkingmemory('chanopGUI',chanopGUI);
        
        ERP = observe_ERPDAT.ERP;
        answer = chanoperGUI(ERP, def);
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        chanopGUI = erpworkingmemory('chanopGUI');
        ModeValue = chanopGUI.emode;
        if ModeValue==0
            gui_erp_chan_operation.mode_modify.Value=1 ;
            gui_erp_chan_operation.mode_create.Value = 0;
        else
            gui_erp_chan_operation.mode_modify.Value=0 ;
            gui_erp_chan_operation.mode_create.Value = 1;
        end
        localInfor = chanopGUI.keeplocs;
        if localInfor==1
            gui_erp_chan_operation.locaInfor.Value=1;
        else
            gui_erp_chan_operation.locaInfor.Value=0;
        end
        
        formulas = answer{1};
        wbmsgon  = answer{2};
        keeplocs = answer{3};
        if keeplocs ==1
            gui_erp_chan_operation.locaInfor.Value = 1;
        else
            gui_erp_chan_operation.locaInfor.Value = 0;
        end
        
        def = {formulas, wbmsgon};
        erpworkingmemory('pop_erpchanoperator', def);
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        
        if ~isempty(def{1,1})
            Eqs = def{1,1};
            for ii = 1:length(def{1,1})
                dsnames{ii,1}  = Eqs{ii};
            end
            gui_erp_chan_operation.edit_bineq.Data = dsnames;
            set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        end
        
    end

%%-------------------Equation Load---------------------------------------
    function eq_load(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        
        
        [filename, filepath] = uigetfile({'*.txt';'*.*'},'Select a formulas-file');
        if isequal(filename,0)
            disp('User selected Cancel')
            return
        else
            fullname = fullfile(filepath, filename);
            disp(['f_ERP_chanoperation_GUI(): For formulas-file, user selected ', fullname])
        end
        fid_formula = fopen( fullname );
        try
            formcell    = textscan(fid_formula, '%s','delimiter', '\r');
            formulas    = char(formcell{:});
        catch
            msgboxText =  ['ERP Channel Operations - Please, check your file:\n '...
                fullname '\n'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if size(formulas,2)>256
            msgboxText =  ['ERP Channel Operations - Formulas length exceed 256 characters,'...
                'Be sure to press [Enter] after you have entered each formula.'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        fclose(fid_formula);
        gui_erp_chan_operation.edit_bineq.Data = formcell{1,1};
        set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%-------------------Equation Clear---------------------------------------
    function eq_clear(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        gui_erp_chan_operation.edit_bineq.Data = dsnames;
        set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%-------------------Reference assist--------------------------------------
    function ref_asst(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        gui_erp_chan_operation.mode_modify.Value = 0;
        gui_erp_chan_operation.mode_create.Value = 1;
        
        ERPLAB =  observe_ERPDAT.ERP;
        nchan = ERPLAB.nchan;
        listch=[];
        if isempty(ERPLAB.chanlocs)
            for e=1:nchan
                ERPLAB.chanlocs(e).labels = ['Ch' num2str(e)];
            end
        end
        listch = cell(1,nchan);
        for ch =1:nchan
            listch{ch} = [num2str(ch) ' = ' ERPLAB.chanlocs(ch).labels ];
        end
        
        % open reference wizard
        formulalist = f_rerefassistantGUI(nchan, listch);
        if isempty(formulalist)
            return;
        end
        formulas  = char(gui_erp_chan_operation.edit_bineq.Data);
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        
        if gui_erp_chan_operation.mode_create.Value
            formulalist = cellstr([formulalist{:}]);
            for t=1:length(formulalist)
                [expspliter parts] = regexp(formulalist, '=','match','split');
                formulalist{t} = sprintf('%s = %s', strtrim(regexprep(parts{t}{1}, '[^n]*ch','nch','ignorecase')), strtrim(parts{t}{2}));
            end
            %             formulalist = char(formulalist);
        end
        
        if isempty(formulas)
            for ii = 1:length(formulalist)
                dsnames{ii,1}  = formulalist{ii};
            end
            gui_erp_chan_operation.edit_bineq.Data =dsnames;
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
            gui_erp_chan_operation.edit_bineq.Data =dsnames;
        end
        set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%--------------------Preserve location information------------------------
    function loca_infor(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        Value = source.Value;
        gui_erp_chan_operation.locaInfor.Value = Value;
    end


%%------------------Modify Existing ERPset---------------------------------------
    function mode_modify(Source_editor,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        
        gui_erp_chan_operation.mode_modify.Value = 1;
        gui_erp_chan_operation.mode_create.Value = 0;
        
        FormulaArrayIn = gui_erp_chan_operation.edit_bineq.Data;
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_erpchanoperator');
            FormulaArrayIn_default = def{1};
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn_default, 'recu');
                def{1} = formulaArray;
                erpworkingmemory('pop_erpchanoperator',def);
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
            gui_erp_chan_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_erpchanoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_erpchanoperator',def);
        end
    end

%%------------------Create New ERPset---------------------------------------
    function mode_create(Source_create,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_chan_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_chan_operation.run.ForegroundColor = [1 1 1];
        ERP_chan_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_chan_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_chanop',1);
        
        
        gui_erp_chan_operation.mode_modify.Value = 0;
        gui_erp_chan_operation.mode_create.Value = 1;
        FormulaArrayIn = char(gui_erp_chan_operation.edit_bineq.Data);
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_erpchanoperator');
            FormulaArrayIn_default = def{1};
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_chan_testsyntaxtype(FormulaArrayIn_default, 'norecu');
                def{1} = formulaArray;
                erpworkingmemory('pop_erpchanoperator',def);
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
            gui_erp_chan_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_erpchanoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_erpchanoperator',def);
        end
    end
%%------------------------------cancel-------------------------------------
    function chanop_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('ERPTab_chanop',0);
        gui_erp_chan_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.run.ForegroundColor = [0 0 0];
        ERP_chan_operation_gui.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.cancel.ForegroundColor = [0 0 0];
        
        gui_erp_chan_operation.edit_bineq.Data= gui_erp_chan_operation.Paras{1};
        gui_erp_chan_operation.locaInfor.Value=gui_erp_chan_operation.Paras{2};
        mode_modify = gui_erp_chan_operation.Paras{3};
        gui_erp_chan_operation.mode_modify.Value=mode_modify;
        gui_erp_chan_operation.mode_create.Value = ~mode_modify;
    end


%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=6
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index =  length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selectederp_Index;
            estudioworkingmemory('selectederpstudio',Selectederp_Index);
        end
        
        Eq_Data =  gui_erp_chan_operation.edit_bineq.Data;
        Formula_str = {};
        count = 0;
        for ii = 1:length(Eq_Data)
            if ~isempty(Eq_Data{ii})
                count = count +1;
                Formula_str{count} = Eq_Data{ii};
            end
        end
        if isempty(Formula_str)
            msgboxText =  ['ERP Channel Operations - You have not yet written a formula'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        estudioworkingmemory('ERPTab_chanop',0);
        gui_erp_chan_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.run.ForegroundColor = [0 0 0];
        ERP_chan_operation_gui.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.cancel.ForegroundColor = [0 0 0];
        
        %%check the format of equations
        if gui_erp_chan_operation.mode_modify.Value
            editormode = 0;
        else
            editormode = 1;
        end
        [option, recall, goeson] = checkformulas(cellstr(Formula_str), ['pop_erpchanoperator'], editormode);
        if goeson==0
            return;
        end
        
        %%%Create a new ERPset for the bin-operated ERPsets
        Save_file_label = [];
        if gui_erp_chan_operation.mode_create.Value
            if numel(Selectederp_Index) > 1
                Answer = f_ERP_save_multi_file(observe_ERPDAT.ALLERP,Selectederp_Index,'_chop');
                if isempty(Answer)
                    beep;
                    disp('User selected Cancel');
                    return;
                end
                if ~isempty(Answer{1})
                    ALLERP_out = Answer{1};
                    Save_file_label = Answer{2};
                end
                
            elseif numel(Selectederp_Index)== 1
                ALLERP_out = observe_ERPDAT.ALLERP;
                ERP = observe_ERPDAT.ALLERP(Selectederp_Index);
                ERP.filepath = pathName_def;
                Answer = f_ERP_save_single_file(strcat(ERP.erpname,'_chop'),ERP.filename,Selectederp_Index);
                if isempty(Answer)
                    beep;
                    disp('User selectd cancal');
                    return;
                end
                Save_file_label =0;
                if ~isempty(Answer)
                    ERPName = Answer{1};
                    if ~isempty(ERPName)
                        ERP.erpname = ERPName;
                    end
                    fileName_full = Answer{2};
                    if isempty(fileName_full)
                        ERP.filename = ERP.erpname;
                        Save_file_label =0;
                    elseif ~isempty(fileName_full)
                        
                        [pathstr, file_name, ext] = fileparts(fileName_full);
                        ext = '.erp';
                        if strcmp(pathstr,'')
                            pathstr = cd;
                        end
                        ERP.filename = [file_name,ext];
                        ERP.filepath = pathstr;
                        Save_file_label =1;
                    end
                    
                end
                ALLERP_out(Selectederp_Index) = ERP;clear ERP;
            end
        elseif   gui_erp_chan_operation.mode_modify.Value
            ALLERP_out = observe_ERPDAT.ALLERP;
        end
        
        if isempty(Save_file_label)
            Save_file_label =0;
        end
        if gui_erp_chan_operation.locaInfor.Value
            keeplocs =1;
        else
            keeplocs =0;
        end
        gui_erp_chan_operation.Paras{1} = gui_erp_chan_operation.edit_bineq.Data;
        gui_erp_chan_operation.Paras{2} =gui_erp_chan_operation.locaInfor.Value;
        gui_erp_chan_operation.Paras{3} = gui_erp_chan_operation.mode_modify.Value;
        
        try
            erpworkingmemory('f_ERP_proces_messg','ERP Bin Operations');
            observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
            ALLERPCOM = evalin('base','ALLERPCOM');
            for Numofselectederp = 1:numel(Selectederp_Index)%%Bin Operations for each selected ERPset
                ERP = ALLERP_out(Selectederp_Index(Numofselectederp));
                [ERP, ERPCOM] = pop_erpchanoperator(ERP, Formula_str, 'Warning', 'off', 'Saveas', 'off','ErrorMsg', 'command','KeepLocations',keeplocs, 'History', 'gui');
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                if gui_erp_chan_operation.mode_modify.Value%% If select "Modify Existing ERPset (recursive updating)"
                    ERP.erpname = strcat(ERP.erpname,'_chop');
                    observe_ERPDAT.ALLERP(Selectederp_Index(Numofselectederp)) = ERP;
                    observe_ERPDAT.ERP= observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                elseif gui_erp_chan_operation.mode_create.Value %% If select "Create New ERPset (independent transformations)"
                    observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
                    if Save_file_label==1
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ALLERP_out(Selectederp_Index(Numofselectederp)).erpname,...
                            'filename', ALLERP_out(Selectederp_Index(Numofselectederp)).filename, 'filepath',ALLERP_out(Selectederp_Index(Numofselectederp)).filepath);
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    end
                end
            end
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            if gui_erp_chan_operation.mode_create.Value%%Save the labels of the selected ERPsets
                try
                    Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(Selectederp_Index)+1:length(observe_ERPDAT.ALLERP)];
                    observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(Selectederp_Index)+1;
                catch
                    Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                    observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
                end
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            end
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = 1;
            observe_ERPDAT.Process_messg =2;
            return;
        catch
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            Selected_ERP_afd =observe_ERPDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
            erpworkingmemory('f_ERP_bin_opt',1);
            observe_ERPDAT.Count_currentERP = 1;
            observe_ERPDAT.Process_messg =3;%%
            return;
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=7
            return;
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP)
            Enable_label = 'off';
            for ii = 1:100
                if ii==1
                    dsnames{ii,1} = '<html><font color="red">The number of bins and channles should be the same for the selected ERPset!';
                else
                    dsnames{ii,1} = '';
                end
            end
            gui_erp_chan_operation.edit_bineq.Data = dsnames;
            set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        else
            Selectederp_Index= estudioworkingmemory('selectederpstudio');
            if isempty(Selectederp_Index) || any(Selectederp_Index>length(observe_ERPDAT.ALLERP))
                Selectederp_Index = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                estudioworkingmemory('selectederpstudio',Selectederp_Index);
            end
            Enable_label = 'on';
            chanopDataor =  gui_erp_chan_operation.edit_bineq.Data;
            for ii = 1:100
                chanopDataorcell = char(chanopDataor{ii,1});
                if isempty(chanopDataorcell)
                    dsnames{ii,1} = '';
                else
                    dsnames{ii,1} = chanopDataorcell;
                end
            end
            gui_erp_chan_operation.edit_bineq.Data = dsnames;
            set(gui_erp_chan_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        end
        if ViewerFlag==1
            Enable_label = 'off';
        end
        gui_erp_chan_operation.mode_modify.Enable=Enable_label;
        gui_erp_chan_operation.mode_create.Enable=Enable_label;
        gui_erp_chan_operation.eq_editor.Enable = Enable_label;
        gui_erp_chan_operation.eq_load.Enable = Enable_label;
        gui_erp_chan_operation.eq_clear.Enable = Enable_label;
        gui_erp_chan_operation.run.Enable = Enable_label;
        gui_erp_chan_operation.ref_asst.Enable = Enable_label;
        gui_erp_chan_operation.locaInfor.Enable = Enable_label;
        gui_erp_chan_operation.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=8;
    end


%%-------execute "apply" before doing any change for other panels----------
    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_chanop');
        if ChangeFlag~=1
            return;
        end
        apply_run();
        estudioworkingmemory('ERPTab_chanop',0);
        gui_erp_chan_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.run.ForegroundColor = [0 0 0];
        ERP_chan_operation_gui.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.cancel.ForegroundColor = [0 0 0];
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_chanop_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_chanop');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            estudioworkingmemory('ERPTab_chanop',0);
            gui_erp_chan_operation.run.BackgroundColor =  [1 1 1];
            gui_erp_chan_operation.run.ForegroundColor = [0 0 0];
            ERP_chan_operation_gui.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_chan_operation.cancel.BackgroundColor =  [1 1 1];
            gui_erp_chan_operation.cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=7
            return;
        end
        estudioworkingmemory('ERPTab_chanop',0);
        gui_erp_chan_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.run.ForegroundColor = [0 0 0];
        ERP_chan_operation_gui.TitleColor= [ 0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_chan_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_chan_operation.cancel.ForegroundColor = [0 0 0];
        for ii = 1:1000
            dsnames{ii,1} = '';
        end
        gui_erp_chan_operation.edit_bineq.Data = dsnames;
        gui_erp_chan_operation.locaInfor.Value=1;
        gui_erp_chan_operation.mode_modify.Value = 1;
        gui_erp_chan_operation.mode_create.Value = 0;
        observe_ERPDAT.Reset_erp_paras_panel=8;
    end
end