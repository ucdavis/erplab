%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_binoperation_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_two_panels_change',@erp_two_panels_change);

gui_erp_bin_operation = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_bin_operation_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'ERP Bin Operations', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @binop_help); % Create boxpanel
elseif nargin == 1
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Bin Operations', 'Padding',...
        5,'BackgroundColor',ColorB_def, 'HelpFcn', @binop_help);
else
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERP Bin Operations', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def, 'HelpFcn', @binop_help);
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
varargout{1} = ERP_bin_operation_gui;

    function drawui_erp_bin_operation(FonsizeDefault)
        FontSize_defualt = FonsizeDefault;
        Enable_label = 'off';
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        gui_erp_bin_operation.DataSelBox = uiextras.VBox('Parent', ERP_bin_operation_gui,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_erp_bin_operation.erp_history_table = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_bin_operation.edit_bineq = uitable(  ...
            'Parent'        , gui_erp_bin_operation.erp_history_table,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {1000}, ...
            'ColumnName'    , [], ...
            'RowName'       , []);
        set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,length(dsnames)),'FontSize',FontSize_defualt);
        gui_erp_bin_operation.Paras{1} = gui_erp_bin_operation.edit_bineq.Data;
        gui_erp_bin_operation.edit_bineq.KeyPressFcn = @erp_binop_presskey;
        gui_erp_bin_operation.equation_selection = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_bin_operation.eq_editor = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Eq. Advanced','callback',@eq_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_bin_operation.eq_load = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Load Eq.','callback',@eq_load,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_bin_operation.eq_clear = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Clear Eq.','callback',@eq_clear,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        %%%----------------Mode-----------------------------------
        gui_erp_bin_operation.mode_1 = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        gui_erp_bin_operation.mode_modify_title = uicontrol('Style','text','Parent',gui_erp_bin_operation.mode_1 ,...
            'String','Mode:','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        gui_erp_bin_operation.mode_modify = uicontrol('Style','radiobutton','Parent',gui_erp_bin_operation.mode_1 ,...
            'String','Modify Existing ERPset','callback',@mode_modify,'Value',1,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_erp_bin_operation.mode_modify.String =  '<html>Modify Existing ERPset<br />(recursive updating)</html>';
        gui_erp_bin_operation.Paras{2} = gui_erp_bin_operation.mode_modify.Value;
        gui_erp_bin_operation.mode_modify.KeyPressFcn = @erp_binop_presskey;
        set(gui_erp_bin_operation.mode_1,'Sizes',[55 -1]);
        %%--------------For create a new ERPset----------------------------
        gui_erp_bin_operation.mode_2 = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_bin_operation.mode_2);
        gui_erp_bin_operation.mode_create = uicontrol('Style','radiobutton','Parent',gui_erp_bin_operation.mode_2 ,...
            'String',{'', ''},'callback',@mode_create,'Value',0,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',ColorB_def); % 2F
        gui_erp_bin_operation.mode_create.String =  '<html>Create New ERPset<br />(independent transformations)</html>';
        set(gui_erp_bin_operation.mode_2,'Sizes',[55 -1]);
        gui_erp_bin_operation.mode_create.KeyPressFcn = @erp_binop_presskey;
        
        
        %%-----------------Run---------------------------------------------
        gui_erp_bin_operation.run_title = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        uiextras.Empty('Parent',  gui_erp_bin_operation.run_title);
        gui_erp_bin_operation.cancel= uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.run_title,...
            'String','Cancel','callback',@binop_cancel,'FontSize',FontSize_defualt,'Enable','off','BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_erp_bin_operation.run_title);
        gui_erp_bin_operation.run = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.run_title,...
            'String','Run','callback',@apply_run,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        uiextras.Empty('Parent',  gui_erp_bin_operation.run_title);
        set(gui_erp_bin_operation.run_title, 'Sizes',[15 105  30 105 15]);
        
        gui_erp_bin_operation.note_title = uiextras.HBox('Parent', gui_erp_bin_operation.DataSelBox,'BackgroundColor',ColorB_def);
        
        uicontrol('Style','text','Parent',gui_erp_bin_operation.note_title,...
            'String','Note: Operates on all bins and channels','FontSize',FontSize_defualt,'BackgroundColor',ColorB_def); % 2F
        
        set(gui_erp_bin_operation.DataSelBox,'Sizes',[130,30,35,35,30 30]);
        estudioworkingmemory('ERPTab_binop',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

% %%------------------help---------------------------------------------
    function binop_help(~,~)%% It seems that it can be ignored
        web('https://github.com/lucklab/erplab/wiki/ERP-Bin-Operations','-browser');
    end


%%-------------------Equation editor---------------------------------------
    function eq_advanced(Source_editor,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);
        def  = erpworkingmemory('pop_binoperator');
        if isempty(def)
            def = { [], 1};
        end
        binopGUI = erpworkingmemory('binopGUI');
        if gui_erp_bin_operation.mode_modify.Value ==1
            binopGUI.emode =0;
        else
            binopGUI.emode =1;
        end
        erpworkingmemory('binopGUI',binopGUI);
        
        ERP = observe_ERPDAT.ERP;
        answer = binoperGUI(ERP, def);
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        
        binopGUI = erpworkingmemory('binopGUI');
        ModeValue = binopGUI.emode;
        if ModeValue ==0
            gui_erp_bin_operation.mode_modify.Value =1;
            gui_erp_bin_operation.mode_create.Value = 0;
        else
            gui_erp_bin_operation.mode_modify.Value =0;
            gui_erp_bin_operation.mode_create.Value = 1;
        end
        formulas = answer{1};
        wbmsgon  = answer{2};
        
        def = {formulas, wbmsgon};
        erpworkingmemory('pop_binoperator', def);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        if ~isempty(def{1,1})
            Eqs = def{1,1};
            for ii = 1:length(def{1,1})
                dsnames{ii,1}  = Eqs{ii};
            end
            gui_erp_bin_operation.edit_bineq.Data = dsnames;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
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
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);

        
        [filename, filepath] = uigetfile({'*.txt';'*.*'},'Select a formulas-file');
        if isequal(filename,0)
            disp('User selected Cancel')
            return
        else
            fullname = fullfile(filepath, filename);
            disp(['f_ERP_binoperation_GUI(): For formulas-file, user selected ', fullname])
        end
        
        fid_formula = fopen( fullname );
        try
            formcell    = textscan(fid_formula, '%s','delimiter', '\r');
            formulas    = char(formcell{:});
        catch
            msgboxText =  ['ERP Bin Operations - Please, check your file:\n '...
                fullname '\n'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        if size(formulas,2)>256
            msgboxText =  ['ERP Bin Operations - Formulas length exceed 256 characters.\n'...
                'Be sure to press [Enter] after you have entered each formula.'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        fclose(fid_formula);
        gui_erp_bin_operation.edit_bineq.Data = formcell{1,1};
        set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%-------------------Equation Clear---------------------------------------
    function eq_clear(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_erp_bin_operation.edit_bineq.Data = dsnames;
        set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end



%%------------------Modify Existing ERPset---------------------------------------
    function mode_modify(Source_editor,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);
        gui_erp_bin_operation.mode_modify.Value = 1;
        gui_erp_bin_operation.mode_create.Value = 0;
        FormulaArrayIn = char(gui_erp_bin_operation.edit_bineq.Data);
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_binoperator');
            FormulaArrayIn_default = def{1};
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn_default, 'recu');
                def{1} = formulaArray;
                erpworkingmemory('pop_binoperator',def);
            end
        else
            [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn, 'recu');
        end
        if val ==1
            gui_erp_bin_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_binoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_binoperator',def);
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
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);
        
        gui_erp_bin_operation.mode_modify.Value = 0;
        gui_erp_bin_operation.mode_create.Value = 1;
        FormulaArrayIn = char(gui_erp_bin_operation.edit_bineq.Data);
        if isempty(FormulaArrayIn)
            val = 0;
            def =  erpworkingmemory('pop_binoperator');
            try
                FormulaArrayIn_default = def{1};
            catch
                for ii = 1:100
                    FormulaArrayIn_default{ii,1} = '';
                end
            end
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn_default, 'norecu');
                def{1} = formulaArray;
                erpworkingmemory('pop_binoperator',def);
            end
        else
            [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn, 'norecu');
        end
        if val ==1
            gui_erp_bin_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  erpworkingmemory('pop_binoperator');
            def{1} = formulaArray;
            erpworkingmemory('pop_binoperator',def);
        end
        
    end

%%---------------------Run-------------------------------------------------
    function apply_run(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        
        pathName_def =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName_def)
            pathName_def =cd;
        end
        Selectederp_Index= estudioworkingmemory('selectederpstudio');
        if isempty(Selectederp_Index)
            Selectederp_Index = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = Selectederp_Index;
            estudioworkingmemory('selectederpstudio',Selectederp_Index);
        end
        Eq_Data =  gui_erp_bin_operation.edit_bineq.Data;
        
        Formula_str = {};
        count = 0;
        for ii = 1:length(Eq_Data)
            if ~isempty(Eq_Data{ii})
                count = count +1;
                Formula_str{count} = Eq_Data{ii};
            end
        end
        
        if isempty(Formula_str)
            msgboxText =  ['ERP Bin Operations - You have not yet written a formula'];
            erpworkingmemory('f_ERP_proces_messg',msgboxText);
            observe_ERPDAT.Process_messg =4;
            return;
        end
        
        gui_erp_bin_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.run.ForegroundColor = [0 0 0];
        ERP_bin_operation_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_binop',0);
        
        
        %%check the format of equations
        if gui_erp_bin_operation.mode_modify.Value
            editormode = 0;
        else
            editormode = 1;
        end
        [option, recall, goeson] = checkformulas(cellstr(Formula_str), ['pop_binoperator'], editormode);
        if goeson==0
            return
        end
        
        gui_erp_bin_operation.Paras{1} = gui_erp_bin_operation.edit_bineq.Data;
        gui_erp_bin_operation.Paras{2} = gui_erp_bin_operation.mode_modify.Value;
        
        %%%Create a new ERPset for the bin-operated ERPsets
        Save_file_label = [];
        if gui_erp_bin_operation.mode_create.Value
            if numel(Selectederp_Index) > 1
                Answer = f_ERP_save_multi_file(observe_ERPDAT.ALLERP,Selectederp_Index,'_binop');
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
                Answer = f_ERP_save_single_file(strcat(ERP.erpname,'_binop'),ERP.filename,Selectederp_Index);
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
        elseif   gui_erp_bin_operation.mode_modify.Value
            ALLERP_out = observe_ERPDAT.ALLERP;
        end
        
        if isempty(Save_file_label)
            Save_file_label =0;
        end
        
        try
            erpworkingmemory('f_ERP_proces_messg','ERP Bin Operations');
            observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
            ALLERPCOM = evalin('base','ALLERPCOM');
            for Numofselectederp = 1:numel(Selectederp_Index)%%Bin Operations for each selected ERPset
                ERP = ALLERP_out(Selectederp_Index(Numofselectederp));
                [ERP ERPCOM]= pop_binoperator( ERP, Formula_str, 'Warning', 'on', 'ErrorMsg', 'command', 'Saveas', 'off', 'History', 'gui');
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                
                if gui_erp_bin_operation.mode_modify.Value%% If select "Modify Existing ERPset (recursive updating)"
                    ERP.erpname = strcat(ERP.erpname,'_binop');
                    observe_ERPDAT.ALLERP(Selectederp_Index(Numofselectederp)) = ERP;
                    observe_ERPDAT.ERP= observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
                elseif gui_erp_bin_operation.mode_create.Value %% If select "Create New ERPset (independent transformations)"
                    observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = ERP;
                    if Save_file_label==1
                        [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ALLERP_out(Selectederp_Index(Numofselectederp)).erpname,...
                            'filename', ALLERP_out(Selectederp_Index(Numofselectederp)).filename, 'filepath',ALLERP_out(Selectederp_Index(Numofselectederp)).filepath);
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    end
                end
            end
            
            [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            if gui_erp_bin_operation.mode_create.Value%%Save the labels of the selected ERPsets
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

%%---------------------------cancel----------------------------------------
    function binop_cancel(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.run.ForegroundColor = [0 0 0];
        ERP_bin_operation_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_binop',0);
        
        gui_erp_bin_operation.edit_bineq.Data= gui_erp_bin_operation.Paras{1};
        mode_modify = gui_erp_bin_operation.Paras{2};
        gui_erp_bin_operation.mode_modify.Value = mode_modify;
        gui_erp_bin_operation.mode_create.Value = ~mode_modify;
    end


%%--------Setting current ERPset/session history based on the current updated ERPset------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=8
            return;
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP)
            Enable_label = 'off';
            for ii = 1:100
                if ii==1
                    dsnames{ii,1} = '<html><font color="red">The number of bins and channles should be the same for the selected ERPset!';
                else
                    dsnames{ii,1} = '';
                end
            end
            gui_erp_bin_operation.edit_bineq.Data = dsnames;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        else
            Enable_label = 'on';
            binopDataor =  gui_erp_bin_operation.edit_bineq.Data;
            for ii = 1:100
                binopDataorcell = char(binopDataor{ii,1});
                if isempty(binopDataorcell)
                    dsnames{ii,1} = '';
                else
                    dsnames{ii,1} = binopDataorcell;
                end
            end
            gui_erp_bin_operation.edit_bineq.Data = dsnames;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if ViewerFlag==1;
           Enable_label = 'off';  
        end
        gui_erp_bin_operation.mode_modify.Enable=Enable_label;
        gui_erp_bin_operation.mode_create.Enable=Enable_label;
        gui_erp_bin_operation.eq_editor.Enable = Enable_label;
        gui_erp_bin_operation.eq_load.Enable = Enable_label;
        gui_erp_bin_operation.eq_clear.Enable = Enable_label;
        gui_erp_bin_operation.run.Enable = Enable_label;
        gui_erp_bin_operation.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=9;
    end


%%-------execute "apply" before doing any change for other panels----------
    function erp_two_panels_change(~,~)
        if  isempty(observe_ERPDAT.ALLERP)|| isempty(observe_ERPDAT.ERP)
            return;
        end
        ChangeFlag =  estudioworkingmemory('ERPTab_binop');
        if ChangeFlag~=1
            return;
        end
        apply_run();
        gui_erp_bin_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.run.ForegroundColor = [0 0 0];
        ERP_bin_operation_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_binop',0);
    end

%%--------------press return to execute "Apply"----------------------------
    function erp_binop_presskey(~,eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('ERPTab_binop');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            apply_run();
            gui_erp_bin_operation.run.BackgroundColor =  [1 1 1];
            gui_erp_bin_operation.run.ForegroundColor = [0 0 0];
            ERP_bin_operation_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
            gui_erp_bin_operation.cancel.BackgroundColor =  [1 1 1];
            gui_erp_bin_operation.cancel.ForegroundColor = [0 0 0];
            estudioworkingmemory('ERPTab_binop',0);
        else
            return;
        end
    end

end