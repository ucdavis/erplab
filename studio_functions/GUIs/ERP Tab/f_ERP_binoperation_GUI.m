%Author: Guanghui ZHANG--zhang.guanghui@foxmail.com
%Center for Mind and Brain
%University of California, Davis
%Davis, CA, USA
%Feb. 2022

% ERPLAB Studio

function varargout = f_ERP_binoperation_GUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'erp_between_panels_change',@erp_between_panels_change);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

gui_erp_bin_operation = struct();

%-----------------------------Name the title----------------------------------------------
% global ERP_bin_operation_gui;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'Bin Operations', 'Padding', 5,...
        'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Bin Operations', 'Padding',...
        5,'BackgroundColor',ColorB_def);
else
    ERP_bin_operation_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Bin Operations', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def); %'HelpFcn', @binop_help
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
            'String','Advanced','callback',@eq_advanced,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_bin_operation.eq_load = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Load EQ','callback',@eq_load,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_bin_operation.eq_save = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Save EQ','callback',@eq_save,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F
        gui_erp_bin_operation.eq_clear = uicontrol('Style','pushbutton','Parent',gui_erp_bin_operation.equation_selection,...
            'String','Clear','callback',@eq_clear,'FontSize',FontSize_defualt,'Enable',Enable_label,'BackgroundColor',[1 1 1]); % 2F

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

%%-------------------Equation editor---------------------------------------
    function eq_advanced(Source_editor,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=7
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);
        def  = estudioworkingmemory('pop_binoperator');
        if isempty(def)
            def = { [], 1};
        end
        binopGUI = estudioworkingmemory('binopGUI');
        if gui_erp_bin_operation.mode_modify.Value ==1
            binopGUI.emode =0;
        else
            binopGUI.emode =1;
        end
        if isfield(binopGUI,'hmode')
            hmode = binopGUI.hmode;
            if numel(hmode)~=1 || (hmode~=0&& hmode~=1)
                binopGUI.hmode = 0;
            end
        else
            binopGUI.hmode = 0;
        end
        if isfield(binopGUI,'listname')
            if ~ischar(binopGUI.listname)
                binopGUI.listname = '';
            end
        else
            binopGUI.listname = '';
        end
        estudioworkingmemory('binopGUI',binopGUI);

        ERP = observe_ERPDAT.ERP;
        answer = binoperGUI(ERP, def);
        if isempty(answer)
            observe_ERPDAT.Process_messg =2;
            return
        end
        binopGUI= estudioworkingmemory('binopGUI');
        try ModeValue = binopGUI.emode;catch ModeValue=0; end
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
        estudioworkingmemory('pop_binoperator', def);
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end
        gui_erp_bin_operation.run.BackgroundColor =  [ 0.5137    0.7569    0.9176];
        gui_erp_bin_operation.run.ForegroundColor = [1 1 1];
        ERP_bin_operation_gui.TitleColor= [ 0.5137    0.7569    0.9176];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        gui_erp_bin_operation.cancel.ForegroundColor = [1 1 1];
        estudioworkingmemory('ERPTab_binop',1);


        [filename, filepath] = uigetfile({'*.txt';'*.*'},'Select a formulas-file');
        if isequal(filename,0)
            return
        else
            fullname = fullfile(filepath, filename);
            disp(['f_ERP_binoperation_GUI(): For formulas-file, user selected ', fullname])
        end

        fid_formula = fopen( fullname );
        formcell    = textscan(fid_formula, '%s','delimiter', '\r');
        formulas    = char(formcell{:});

        if size(formulas,2)>256
            msgboxText =  ['Bin Operations - Formulas length exceed 256 characters.'...
                'Be sure to press [Enter] after you have entered each formula.'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        fclose(fid_formula);
        gui_erp_bin_operation.edit_bineq.Data = formcell{1,1};
        set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
    end

%%-----------------------------Save equation-------------------------------
    function eq_save(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
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
        msgboxText =  ['Bin Operations >Save'];
        estudioworkingmemory('f_ERP_proces_messg',msgboxText);
        observe_ERPDAT.Process_messg =1;
        if isempty(Formula_str)
            msgboxText =  ['Bin Operations >Save - You have not yet written a formula'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_ERPDAT.Process_messg =2;
            return;
        end
        %         pathName =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathName)
        pathName =[cd,filesep];
        %         end

        [filename, filepath, filterindex] = uiputfile({'*.txt';'*.*'},'Save formulas-file as', pathName);
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
        observe_ERPDAT.Process_messg =2;
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
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
            def =  estudioworkingmemory('pop_binoperator');
            if isempty(def)
                def = { [], 1};
            end
            FormulaArrayIn_default = def{1};
            if ~isempty(FormulaArrayIn_default)
                [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn_default, 'recu');
                def{1} = formulaArray;
                estudioworkingmemory('pop_binoperator',def);
            end
        else
            [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn, 'recu');
        end
        if val ==1
            gui_erp_bin_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  estudioworkingmemory('pop_binoperator');
            if isempty(def)
                def = { [], 1};
            end
            def{1} = formulaArray;
            estudioworkingmemory('pop_binoperator',def);
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
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
            def =  estudioworkingmemory('pop_binoperator');
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
                estudioworkingmemory('pop_binoperator',def);
            end
        else
            [val, formulaArray]= f_testsyntaxtype(FormulaArrayIn, 'norecu');
        end
        if val ==1
            gui_erp_bin_operation.edit_bineq.Data =formulaArray;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
            def =  estudioworkingmemory('pop_binoperator');
            if isempty(def)
                def = { [], 1};
            end
            def{1} = formulaArray;
            estudioworkingmemory('pop_binoperator',def);
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
        end

        %         pathName_def =  estudioworkingmemory('EEG_save_folder');
        %         if isempty(pathName_def)
        pathName_def =[cd,filesep];
        %         end
        ERPArray= estudioworkingmemory('selectederpstudio');
        if isempty(ERPArray)
            ERPArray = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP = ERPArray;
            estudioworkingmemory('selectederpstudio',ERPArray);
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
            msgboxText =  ['Bin Operations - You have not yet written a formula'];
            titlNamerro = 'Warning for ERP Tab';
            estudio_warning(msgboxText,titlNamerro);
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
        estudioworkingmemory('f_ERP_proces_messg','Bin Operations');
        observe_ERPDAT.Process_messg =1; %%Marking for the procedure has been started.
        try  ALLERPCOM = evalin('base','ALLERPCOM');catch ALLERPCOM =''; end;
        ALLERP =  observe_ERPDAT.ALLERP;
        binAllold = [1:observe_ERPDAT.ERP.nbin];
        ALLERP_out = [];
        for Numoferp = 1:numel(ERPArray)%%Bin Operations for each selected ERPset
            ERP = ALLERP(ERPArray(Numoferp));
            [ERP ERPCOM]= pop_binoperator( ERP, Formula_str, 'Warning', 'on', 'ErrorMsg', 'command', 'Saveas', 'off', 'History', 'gui');
            if isempty(ERPCOM)
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if Numoferp ==numel(ERPArray)
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
            else
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            if isempty(ALLERP_out)
                ALLERP_out = ERP;
            else
                ALLERP_out(length(ALLERP_out)+1) = ERP;
            end
        end
        Save_file_label = 0;
        if gui_erp_bin_operation.mode_create.Value
            Answer = f_ERP_save_multi_file(ALLERP_out,1:numel(ERPArray),'_binop');
            if isempty(Answer)
                observe_ERPDAT.Process_messg =2;
                return;
            end
            if ~isempty(Answer{1})
                ALLERP_out = Answer{1};
                Save_file_label = Answer{2};
            end
        end

        if gui_erp_bin_operation.mode_modify.Value%% If select "Modify Existing ERPset (recursive updating)"
            ALLERP(ERPArray) = ALLERP_out;
        elseif gui_erp_bin_operation.mode_create.Value %% If select "Create New ERPset (independent transformations)"
            for Numoferp = 1:numel(ERPArray)
                ERP = ALLERP_out(Numoferp);
                if Save_file_label==1
                    [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ALLERP_out(Numoferp).erpname,...
                        'filename', ALLERP_out(Numoferp).filename, 'filepath',ALLERP_out(Numoferp).filepath);
                    ERPCOM = f_erp_save_history(ERP.erpname,ERP.filename,ERP.filepath);
                    if Numoferp ==numel(ERPArray)
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,2);
                    else
                        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
                    end
                else
                    ERP.filename = '';
                    ERP.filepath = '';
                    ERP.saved = 'no';
                end
                ALLERP(length(ALLERP)+1) = ERP;
            end
        end
        observe_ERPDAT.ALLERP = ALLERP;
        if gui_erp_bin_operation.mode_create.Value%%Save the labels of the selected ERPsets
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1:length(observe_ERPDAT.ALLERP)];
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(ERPArray)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            estudioworkingmemory('selectederpstudio',Selected_ERP_afd);
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        estudioworkingmemory('f_ERP_bin_opt',1);

        binAllNew = [1:observe_ERPDAT.ERP.nbin];
        bindiff = setdiff(binAllNew,binAllold);
        binArray =  estudioworkingmemory('ERP_BinArray');
        if ~isempty(bindiff) && ~isempty(binArray) && numel(binArray)==numel(binAllold)
            binArray = [binArray,bindiff];
            estudioworkingmemory('ERP_BinArray',binArray);
        end

        observe_ERPDAT.Count_currentERP = 1;
        observe_ERPDAT.Process_messg =2;
        return;
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
            observe_ERPDAT.Count_currentERP=eegpanelIndex+1;%%call the functions from the other panel
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
        if observe_ERPDAT.Count_currentERP~=9
            return;
        end
        if  isempty(observe_ERPDAT.ERP) || isempty(observe_ERPDAT.ALLERP)
            Enable_label = 'off';
            for ii = 1:100
                dsnames{ii,1} = '';
            end
            gui_erp_bin_operation.edit_bineq.Data = dsnames;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        else
            ERPArray= estudioworkingmemory('selectederpstudio');
            if isempty(ERPArray) || any(ERPArray>length(observe_ERPDAT.ALLERP))
                ERPArray = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                estudioworkingmemory('selectederpstudio',ERPArray);
            end

            binNumAll = [];
            for Numoferp = 1:numel(ERPArray)
                binNumAll(Numoferp) =observe_ERPDAT.ALLERP(ERPArray(Numoferp)).nbin;
            end

            Enable_label = 'on';
            binopDataor =  gui_erp_bin_operation.edit_bineq.Data;
            for ii = 1:100
                binopDataorcell = char(binopDataor{ii,1});
                aa = '<html><font color="red">The number of bins should be the same for the selected ERPsets!';
                if isempty(binopDataorcell) || strcmpi(binopDataorcell,aa)
                    dsnames{ii,1} = '';
                else
                    dsnames{ii,1} = binopDataorcell;
                end
                if numel(unique(binNumAll)) >1
                    dsnames{1,1} = aa;
                    Enable_label = 'off';
                end
            end
            gui_erp_bin_operation.edit_bineq.Data = dsnames;
            set(gui_erp_bin_operation.edit_bineq,'ColumnEditable',true(1,1000),'ColumnWidth',{1000});
        end
        ViewerFlag=estudioworkingmemory('ViewerFlag');
        if isempty(ViewerFlag) || (ViewerFlag~=0 && ViewerFlag~=1)
            ViewerFlag=0;estudioworkingmemory('ViewerFlag',0);
        end
        if ViewerFlag==1
            Enable_label = 'off';
        end
        gui_erp_bin_operation.mode_modify.Enable=Enable_label;
        gui_erp_bin_operation.mode_create.Enable=Enable_label;
        gui_erp_bin_operation.eq_editor.Enable = Enable_label;
        gui_erp_bin_operation.eq_load.Enable = Enable_label;
        gui_erp_bin_operation.eq_save.Enable = Enable_label;
        gui_erp_bin_operation.eq_clear.Enable = Enable_label;
        gui_erp_bin_operation.run.Enable = Enable_label;
        gui_erp_bin_operation.cancel.Enable = Enable_label;
        observe_ERPDAT.Count_currentERP=10;
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

    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=9
            return;
        end
        gui_erp_bin_operation.run.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.run.ForegroundColor = [0 0 0];
        ERP_bin_operation_gui.TitleColor= [0.05,0.25,0.50];%% the default is [0.0500    0.2500    0.5000]
        gui_erp_bin_operation.cancel.BackgroundColor =  [1 1 1];
        gui_erp_bin_operation.cancel.ForegroundColor = [0 0 0];
        estudioworkingmemory('ERPTab_binop',0);
        for ii = 1:100
            dsnames{ii,1} = '';
        end
        gui_erp_bin_operation.edit_bineq.Data = dsnames;
        gui_erp_bin_operation.mode_modify.Value = 1;
        gui_erp_bin_operation.mode_create.Value = 0;
        observe_ERPDAT.Reset_erp_paras_panel=10;
    end

end
