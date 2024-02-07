% ERPset selector panel
%
% Author: Guanghui ZHANG && Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2022 & 2023 Oct

% ERPLAB Toolbox
%


function varargout = f_ERP_erpsetsGUI(varargin)
global observe_ERPDAT;
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);
addlistener(observe_ERPDAT,'Reset_erp_panel_change',@Reset_erp_panel_change);

ERPsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end

sel_path = cd;
estudioworkingmemory('ERP_save_folder',sel_path);
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_erpset(FonsizeDefault);

varargout{1} = box_erpset_gui;

% Draw the ui
    function drawui_erpset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        vBox = uiextras.VBox('Parent', box_erpset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        
        %%-----------------------ERPset display---------------------------------------
        ERPlistName =  getERPsets();
        Edit_label = 'off';
        
        ERPsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            2,'String', ERPlistName,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label);
        try ERPsetops.butttons_datasets.Value=1; catch end;
        set(vBox, 'Sizes', 290);
        
        %%---------------------Options for ERPsets-----------------------------------------------------
        ERPsetops.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.dupeselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.renameselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.suffix = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.importexport = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @imp_erp,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.export = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Export',...
            'Callback', @exp_erp,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save',...
            'Callback', @savechecked,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save As...', ...
            'Callback', @savecheckedas,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        ERPsetops.dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder',...
            'Callback', @toggledots,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(buttons4,'Sizes',[70 70 115])
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------duplicate the selected ERPsets-----------------------------
    function duplicateSelected(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Duplicate');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        
        ChanArray= estudioworkingmemory('ERP_ChanArray');
        BinArray= estudioworkingmemory('ERP_BinArray');
        
        try
            for Numofselecterp = 1:numel(SelectedERP)
                New_ERP = observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp));
                
                New_ERP.filename = '';
                New_ERP.erpname = char(strcat(New_ERP.erpname, '_Duplicated'));
                if isempty(BinArray) || any(BinArray(:)>New_ERP.nbin) || any(BinArray<=0)
                    BinArray = [1:New_ERP.nbin];
                end
                if isempty(ChanArray) || any(ChanArray(:)>New_ERP.nchan) || any(ChanArray(:)<=0)
                    ChanArray  = [1:New_ERP.nchan];
                end
                New_ERP = f_ERP_duplicate(New_ERP,length(observe_ERPDAT.ALLERP),BinArray,ChanArray);
                if isempty(New_ERP)
                    beep;
                    disp('User selected cancal!');
                    return;
                end
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = New_ERP;
                ERPlistName =  getERPsets();
                %%Reset the display in ERPset panel
                ERPsetops.butttons_datasets.String = ERPlistName;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
            end
            try
                Selected_ERP_afd =  [length(observe_ERPDAT.ALLERP)-numel(SelectedERP)+1:length(observe_ERPDAT.ALLERP)];
                ERPsetops.butttons_datasets.Value = Selected_ERP_afd;
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP)-numel(SelectedERP)+1;
            catch
                Selected_ERP_afd = length(observe_ERPDAT.ALLERP);
                ERPsetops.butttons_datasets.Value =  Selected_ERP_afd;
                observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(observe_ERPDAT.CURRENTERP);
            SelectedERP =Selected_ERP_afd;
            estudioworkingmemory('selectederpstudio',SelectedERP);
            observe_ERPDAT.Process_messg =2;
            observe_ERPDAT.Count_currentERP = 2;
        catch
            observe_ERPDAT.Process_messg =3;
            observe_ERPDAT.Count_currentERP = 2;
            return;
        end
    end



%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Rename');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        for Numofselecterp = 1:length(SelectedERP)
            try
                erpName = char(observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp)).erpname);
                new = f_ERP_rename_gui(erpName,SelectedERP(Numofselecterp));
                observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp)).erpname = cell2mat(new);
                ERPlistName =  getERPsets();
                ERPsetops.butttons_datasets.String = ERPlistName;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
                observe_ERPDAT.Process_messg =2;
            catch
                ERPlistName =  getERPsets();
                ERPsetops.butttons_datasets.String = ERPlistName;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
                observe_ERPDAT.Process_messg =3;
            end
        end
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Add Suffix');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.ALLERP;
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        
        new = f_ERP_suffix_gui('Suffix');
        if ~isempty(new)
            for Numofselecterp = 1:length(SelectedERP)
                observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp)).erpname = char(strcat( observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp)).erpname,'_',new{1}));
            end
            observe_ERPDAT.Process_messg =2;
        else
            beep;
            disp('User selected cancel');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        ERPlistName =  getERPsets();
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = length(ERPlistName)+1;
    end



%----------------------- Import-----------------------------------
    function imp_erp( ~, ~ )
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Import');
        observe_ERPDAT.Process_messg =1;
        %-----------Setting for import-------------------------------------
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        [ind,tf] = listdlg('ListString',{'ERPSS Text','Universal Text','Neuroscan (*.arg)'},'SelectionMode','single',...
            'PromptString','Please select a type to import from...','Name','Import','OKString','Select');
        
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        
        if isempty(ind)
            beep;
            disp(['User selected cancel']);
            return;
        end
        ALLERPCOM = evalin('base','ALLERPCOM');
        
        try
            if tf%Import start
                %%-------------------------------------------------------------------------------
                %%-----------------------Import ERPSS text---------------------------------------
                %%-------------------------------------------------------------------------------
                if ind == 1
                    %                     pop_importerpss_studio();
                    answer = importERPSS_GUI; %(gui was modified)
                    
                    if isempty(answer)
                        disp('User selected Cancel')
                        return
                    end
                    
                    fname      = answer{1}; % filename (+ whole path)
                    dformat    = answer{2}; % data format
                    dtranspose = answer{3}; % transpose data  (Fixed)
                    if dformat==0
                        dformatstr = 'explicit'; % points at columns
                    else
                        dformatstr = 'implicit'; % points at rows
                    end
                    if dtranspose==0
                        orienpoint = 'column';   % points at columns
                    else
                        orienpoint = 'row';      % points at rows
                    end
                    
                    [ERP, ALLERP, ERPCOM] = pop_importerpss('Filename', fname, 'Format', dformatstr, 'Pointat', orienpoint, 'History', 'script');
                    ERP = erphistory(ERP, [], ERPCOM,1);
                    
                    try
                        Selected_erpset = [length(ALLERP)-length(fname)+1:length(ALLERP)];
                    catch
                        beep;
                        disp('Fail to import the ERPsets, please try again or restart EStudio!');
                        return
                    end
                    ALLERP = f_erp_remv_Calibrate(ALLERP, Selected_erpset);
                    Answer = f_ERP_save_multi_file(ALLERP,Selected_erpset,'_erpss');
                    if isempty(Answer)
                        beep;
                        disp('User selected Cancel');
                        return;
                    end
                    Save_file_label = 0;
                    if ~isempty(Answer{1})
                        ALLERP_advance = Answer{1};
                        Save_file_label = Answer{2};
                    end
                    if Save_file_label==1
                        for Numoferpset = 1:length(Selected_erpset)
                            ERP = ALLERP_advance(Selected_erpset(Numoferpset));
                            [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                            ERP = erphistory(ERP, [], ERPCOM,1);
                        end
                    end
                    observe_ERPDAT.ALLERP=ALLERP_advance; clear ALLERP_advance;clear ALLERP
                else
                    %%------------------------------------------------------------------------
                    %%----------------------- Import Universal text-----------------------
                    %%------------------------------------------------------------------------
                    if ind == 2
                        
                        def  = erpworkingmemory('pop_importerp');
                        if isempty(def)
                            def = {'','','',0,1,0,0,1000,[-200 800]};
                        end
                        %
                        % Call GUI
                        %
                        getlista = importerpGUI(def);
                        
                        if isempty(getlista)
                            disp('User selected Cancel')
                            return
                        end
                        
                        filename    = getlista{1};
                        filepath    = getlista{2};
                        ftype       = getlista{3};
                        includetime = getlista{4};
                        timeunit    = getlista{5};
                        elabel      = getlista{6};
                        transpose   = getlista{7};
                        fs          = getlista{8};
                        xlim        = getlista{9};
                        
                        erpworkingmemory('pop_importerp', {filename, filepath, ftype,includetime,timeunit,elabel,transpose,fs,xlim});
                        
                        filetype = {'text'};
                        if includetime==0
                            inctimestr = 'off';
                        else
                            inctimestr = 'on';
                        end
                        if elabel==0
                            elabelstr = 'off';
                        else
                            elabelstr = 'on';
                        end
                        if transpose==0
                            orienpoint = 'column'; % points at columns
                        else
                            orienpoint = 'row';    % points at rows
                        end
                        
                        %
                        % Somersault
                        %
                        [ERP, ERPCOM] = pop_importerp('Filename', filename, 'Filepath', filepath, 'Filetype', filetype, 'Time', inctimestr,...
                            'Timeunit', timeunit, 'Elabel', elabelstr, 'Pointat', orienpoint, 'Srate', fs, 'Xlim', xlim, 'Saveas', 'off',...
                            'History', 'gui');
                        
                        %                         [ERP, ERPCOM] = pop_importerp();
                        if  length(observe_ERPDAT.ALLERP)==1 && strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
                            Selected_erpset_indx = 1;
                        else
                            Selected_erpset_indx = length(observe_ERPDAT.ALLERP)+1;
                        end
                        try
                            filename = ERP.erpname;
                        catch
                            filename = strcat('Sub',num2str(Selected_erpset_indx),'-universal');
                        end
                        if isempty(filename)
                            filename = strcat('Sub',num2str(Selected_erpset_indx),'-universal');
                        end
                        ERP.erpname = filename;
                        %%------------------------------------------------------------------------
                        %%------------------------Import Neuroscan (.avg)----------------
                        %%------------------------------------------------------------------------
                    elseif ind == 3  %%
                        [filename, filepath] = uigetfile({'*.avg';'Neuroscan average file (*.avg)'},'Select a file (Neuroscan)', 'MultiSelect', 'on');
                        if ~iscell(filename) && ~ischar(filename) && filename==0
                            disp('User selected Cancel')
                            return
                        end
                        
                        [ERP, ERPCOM]= pop_importavg(filename, filepath, 'Saveas','off','History', 'gui');
                        
                        [pathstr, file_name, ext] = fileparts(filename{1,1});
                        ERP.erpname = file_name;
                        if  length(observe_ERPDAT.ALLERP)==1 && strcmp(observe_ERPDAT.ALLERP(1).erpname,'No ERPset loaded')
                            Selected_erpset_indx = 1;
                        else
                            Selected_erpset_indx = length(observe_ERPDAT.ALLERP)+1;
                        end
                    end
                    ERP = erphistory(ERP, [], ERPCOM,1);
                    
                    Answer = f_ERP_save_single_file(ERP.erpname,ERP.filename,Selected_erpset_indx);
                    if isempty(Answer)
                        beep;
                        %                         disp('User selectd cancal');
                        return;
                    end
                    
                    if ~isempty(Answer)
                        ERPName = Answer{1};
                        if ~isempty(ERPName)
                            ERP.erpname = ERPName;
                        end
                        fileName_full = Answer{2};
                        if isempty(fileName_full)
                            ERP.filename = ERP.erpname;
                        elseif ~isempty(fileName_full)
                            
                            [pathstr, file_name, ext] = fileparts(fileName_full);
                            ext = '.erp';
                            if strcmp(pathstr,'')
                                pathstr = cd;
                            end
                            ERP.filename = [file_name,ext];
                            ERP.filepath = pathstr;
                            %%----------save the current sdata as--------------------
                            [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                            ERP = erphistory(ERP, [], ERPCOM,1);
                        end
                    end
                    observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) =ERP;
                end
            end
            
            [~, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
            assignin('base','ALLERPCOM',ALLERPCOM);
            assignin('base','ERPCOM',ERPCOM);
            
            ERPlistName =  getERPsets();
            
            if isempty(observe_ERPDAT.ALLERP)
                Edit_label = 'off';
            else
                Edit_label = 'on';
            end
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.Process_messg =2;
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        catch
            observe_ERPDAT.Process_messg =3;
            disp(['User selected cancel']);
            return;
        end
        
        ERPsetops.butttons_datasets.Value = length(observe_ERPDAT.ALLERP);
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.dotstoggle.Enable=Edit_label;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        ERPsetops.butttons_datasets.Min=1;
        ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 1;
    end



%-----------------------Export-----------------------------------
    function exp_erp( ~, ~ )
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Export');
        observe_ERPDAT.Process_messg =1;
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        Selected_erpset= ERPsetops.butttons_datasets.Value;
        if isempty(Selected_erpset)
            Selected_erpset = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',SelectedERP);
        end
        
        checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_erpset);
        
        ChanArray= estudioworkingmemory('ERP_ChanArray');
        if isempty(ChanArray) || any(ChanArray<=0) || any(ChanArray>observe_ERPDAT.ERP.nchan)
            ChanArray = [1:observe_ERPDAT.ERP.nchan];
            estudioworkingmemory('ERP_ChanArray',ChanArray);
        end
        
        BinArray = estudioworkingmemory('ERP_BinArray');
        if isempty(BinArray) || any(BinArray<=0) || any(BinArray>observe_ERPDAT.ERP.nbin)
            BinArray = [1:observe_ERPDAT.ERP.nbin];
            estudioworkingmemory('ERP_BinArray',BinArray);
        end
        
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',ColorB_def);
        [ind,tf] = listdlg('ListString',{'ERPSS Text','Universal Text'},'SelectionMode','single','PromptString','Please select a type to export to...','Name','Export ERP to','OKString','Ok');
        set(0,'DefaultUicontrolBackgroundColor',[1 1 1]);
        if isempty(ind)
            beep;
            disp(['User selected cancel']);
            return;
        end
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        for Numoferpset = 1:length(Selected_erpset)
            
            if Selected_erpset(Numoferpset) > length(observe_ERPDAT.ALLERP)
                beep;
                msgboxText =  ['ERPsets>Export: Index of selected ERP is lager than the length of ALLERP'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_ERP_proces_messg',msgboxText);
                observe_ERPDAT.Process_messg =4;
                return;
            end
            ERP_export_erp = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
            if checked_ERPset_Index_bin_chan(1) ==1 || checked_ERPset_Index_bin_chan(2) ==2
                BinArray = [1:ERP_export_erp.nbin];
                ChanArray = [1:ERP_export_erp.nchan];
            end
            if ind==1
                try
                    ERP_export_erp.filename =fullfile(pathName,ERP_export_erp.filename);
                    Answer_erpss = f_erp2ascGUI(ERP_export_erp,BinArray,ChanArray);
                    if isempty(Answer_erpss)
                        return;
                    end
                    ERP = Answer_erpss{1};
                    FileName = Answer_erpss{2};
                    
                    [observe_ERPDAT.ERP, ERPCOM] = pop_erp2asc(ERP,FileName,'History', 'gui');
                    [observe_ERPDAT.ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
                    assignin('base','ALLERPCOM',ALLERPCOM);
                    assignin('base','ERPCOM',ERPCOM);
                    observe_ERPDAT.Process_messg =2;
                catch
                    beep;
                    msgboxText =  ['ERPsets>Export: cannot be saved as ERPs'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_ERP_proces_messg',msgboxText);
                    observe_ERPDAT.Process_messg =4;
                    return
                end
            elseif ind ==2
                try
                    ERP_export_erp.filename =fullfile(pathName,ERP_export_erp.filename);
                    ERP = ERP_export_erp;
                    def  = estudioworkingmemory('f_export2textGUI');
                    if isempty(def)
                        def = {1,1000, 1, 1, 4, ''};
                    end
                    
                    %
                    % Call GUI
                    %
                    def_x = def;
                    def_x{6} = ERP.filename;
                    answer_export = f_export2textGUI(ERP,def_x,BinArray,ChanArray);
                    if isempty(answer_export)
                        beep;
                        disp('User selected cancel');
                        return;
                    end
                    estudioworkingmemory('f_export2textGUI',answer_export);
                    istime    = answer_export{1};
                    tunit     = answer_export{2};
                    islabeled = answer_export{3};
                    transpa   = answer_export{4};
                    prec      = answer_export{5};
                    
                    filename  = answer_export{6};
                    ERP = answer_export{7};
                    binArray  = [1:ERP.nbin];
                    if istime
                        time = 'on';
                    else
                        time = 'off';
                    end
                    if islabeled
                        elabel = 'on';
                    else
                        elabel = 'off';
                    end
                    if transpa
                        tra = 'on';
                    else
                        tra = 'off';
                    end
                    try
                        [ERP, ERPCOM] = pop_export2text(ERP, filename, binArray, 'time', time, 'timeunit', tunit, 'electrodes', elabel,...
                            'transpose', tra, 'precision', prec, 'History', 'gui');
                        [observe_ERPDAT.ERP, ALLERPCOM] = erphistory(ERP_export_erp, ALLERPCOM, ERPCOM);
                        assignin('base','ALLERPCOM',ALLERPCOM);
                        assignin('base','ERPCOM',ERPCOM);
                        observe_ERPDAT.Process_messg =2;
                    catch
                        beep;
                        msgboxText =  ['ERPsets>Export: Failed to save selected ERPsets'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_ERP_proces_messg',msgboxText);
                        observe_ERPDAT.Process_messg =4;
                        return;
                    end
                catch
                    observe_ERPDAT.Process_messg =3;
                    return;
                end
            end
        end
    end



%%---------------------Load ERP--------------------------------------------
    function load(~,~)
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Load');
        observe_ERPDAT.Process_messg =1;
        ALLERPCOM = evalin('base','ALLERPCOM');
        try
            [filename, filepath] = uigetfile({'*.erp','ERP (*.erp)';...
                '*.mat','ERP (*.mat)'}, ...
                'Load ERP', ...
                'MultiSelect', 'on');
            if isequal(filename,0)
                disp('User selected Cancel');
                return;
            end
            
            if numel(findobj('tag', 'erpsets')) > 0
                [ERP, observe_ERPDAT.ALLERP, ERPCOM] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'off', 'multiload', 'off',...
                    'History', 'gui');
            else
                [ERP, observe_ERPDAT.ALLERP, ERPCOM] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'off', 'multiload', 'off',...
                    'History', 'gui'); %If eeglab is not open, don't update
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
            assignin('base','ALLERP',observe_ERPDAT.ALLERP);
        catch
            return;
        end
        
        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        
        ERPlistName =  getERPsets();
        
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.dotstoggle.Enable=Edit_label;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        ERPsetops.butttons_datasets.Min=1;
        ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        f_redrawERP();
    end



%%----------------------Clear the selected ERPsets-------------------------
    function cleardata(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Clear');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP = ERPsetops.butttons_datasets.Value;
        ERPset_remained = setdiff(1:length(observe_ERPDAT.ALLERP),SelectedERP);
        
        if isempty(ERPset_remained)
            observe_ERPDAT.ALLERP = [];
            observe_ERPDAT.ERP = [];
            observe_ERPDAT.CURRENTERP  = 1;
            assignin('base','ERP',observe_ERPDAT.ERP)
        else
            observe_ERPDAT.ALLERP = observe_ERPDAT.ALLERP(ERPset_remained);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP  = length(observe_ERPDAT.ALLERP);
        end
        
        ERPlistName =  getERPsets();
        if isempty(observe_ERPDAT.ALLERP)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        
        ERPsetops.butttons_datasets.String = ERPlistName;
        ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.dotstoggle.Enable=Edit_label;
        ERPsetops.butttons_datasets.Min =1;
        ERPsetops.butttons_datasets.Max =length(ERPlistName)+1;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        f_redrawERP();
    end


%-------------------------- Save selected ERPsets-------------------------------------------
    function savechecked(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Save');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        
        try
            for Numoferpset = 1:length(Selected_erpset)
                if Selected_erpset(Numoferpset) > length(observe_ERPDAT.ALLERP)
                    beep;
                    disp(['Index of selected ERP is lager than the length of ALLERP!!!']);
                    return;
                end
                ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
                FileName = ERP.filename;
                
                if isempty(FileName)
                    FileName =ERP.erpname;
                end
                [pathx, filename, ext] = fileparts(FileName);
                filename = [filename '.erp'];
                [observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset)), issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', filename, 'filepath',pathName);
                [~, ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset)), ALLERPCOM, ERPCOM);
            end
            observe_ERPDAT.Process_messg =2;
        catch
            beep;
            observe_ERPDAT.Process_messg =3;
            disp(['ERPsets>Save: Cannot save the selected ERPsets.']);
            return;
        end
    end


%------------------------- Save as-----------------------------------------
    function savecheckedas(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Save As');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset = length(observe_ERPDAT.ALLERP);
            estudioworkingmemory('selectederpstudio',Selected_erpset);
        end
        try
            ALLERPCOM = evalin('base','ALLERPCOM');
        catch
            ALLERPCOM = [];
            assignin('base','ALLERPCOM',ALLERPCOM);
        end
        for Numoferpset = 1:length(Selected_erpset)
            if Selected_erpset(Numoferpset) > length(observe_ERPDAT.ALLERP)
                beep;
                disp('Index of selected ERP is lager than the length of ALLERP!!!');
                return;
            end
            ERP = observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset));
            [pathstr, namedef, ext] = fileparts(char(ERP.filename));
            [erpfilename, erppathname, indxs] = uiputfile({'*.erp','ERP (*.erp)';...
                '*.mat','ERP (*.erp)'}, ...
                ['Save "',ERP.erpname,'" as'],...
                fullfile(pathName,namedef));
            
            if isequal(erpfilename,0)
                disp('User selected Cancel')
                return
            end
            [pathx, filename, ext] = fileparts(erpfilename);
            [pathstr, erpfilename, ext] = fileparts(erpfilename) ;
            
            if indxs==1
                ext = '.erp';
            elseif indxs==2
                ext = '.mat';
            else
                ext = '.erp';
            end
            erpFilename = char(strcat(erpfilename,ext));
            [observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset)), issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', erpFilename,...
                'filepath',erppathname);
            [~, ALLERPCOM] = erphistory(observe_ERPDAT.ALLERP(Selected_erpset(Numoferpset)), ALLERPCOM, ERPCOM);
        end
        observe_ERPDAT.Process_messg =2;
        
    end


%---------------- Enable/Disable dot structure-----------------------------
    function toggledots(~,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        pathName =  erpworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =cd;
        end
        title = 'Select one forlder for saving files in following procedures';
        sel_path = uigetdir(pathName,title);
        
        if isequal(sel_path,0)
            sel_path = cd;
        end
        userpath(sel_path);
        cd(sel_path);
        erpworkingmemory('ERP_save_folder',sel_path);
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        if isempty(observe_ERPDAT.ERP)
            observe_ERPDAT.Count_currentERP=1;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_erptab_panelchanges();
        if ~isempty(messgStr)
            observe_ERPDAT.erp_two_panels = observe_ERPDAT.erp_two_panels+1;%%call the functions from the other panel
        end
        
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets-select ERPset(s)');
        observe_ERPDAT.Process_messg =1;
        
        Selected_ERPsetlabel = source.Value;
        estudioworkingmemory('selectederpstudio',Selected_ERPsetlabel);
        
        Current_ERP_selected=Selected_ERPsetlabel(1);
        observe_ERPDAT.CURRENTERP = Current_ERP_selected;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_ERP_selected);
        
        checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_ERPsetlabel);
        
        msgboxText = {};
        if checked_ERPset_Index_bin_chan(1) ==1
            msgboxText =  ['Number of bins across ERPsets is different!'];
        elseif checked_ERPset_Index_bin_chan(2)==2
            msgboxText =  ['Number of channels across ERPsets is different!'];
        elseif checked_ERPset_Index_bin_chan(3) ==3
            msgboxText =  ['Type of data across ERPsets is different!'];
        elseif checked_ERPset_Index_bin_chan(4)==4
            msgboxText =  ['Number of samples across ERPsets is different!'];
        elseif checked_ERPset_Index_bin_chan(5)==5
            msgboxText =  ['Start time of epoch across ERPsets is different!'];
        end
        if ischar(msgboxText)
            if checked_ERPset_Index_bin_chan(1) ==1 && checked_ERPset_Index_bin_chan(2) ==0
                question = [  '%s\n See details at command window.\n\n',...
                    ' (a). "Bins" will be deactive on "Bins and Channel Selection".\n\n',...
                    ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
                    ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
                    ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
                    ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
                    ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
                    ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
                    ' (h). "Average across ERPsets" will be deactive.\n\n'];
            elseif checked_ERPset_Index_bin_chan(1) ==0 && checked_ERPset_Index_bin_chan(2) ==2
                
                question = [  '%s\n See details at command window.\n\n',...
                    ' (a). "Channels" will be deactive on "Bins and Channel Selection".\n\n',...
                    ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
                    ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
                    ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
                    ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
                    ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
                    ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
                    ' (h). "Average across ERPsets" will be deactive.\n\n'];
            elseif checked_ERPset_Index_bin_chan(1) ==1 && checked_ERPset_Index_bin_chan(2) ==2
                msgboxText =  ['Both the number of channels and the number of bins vary across ERPsets!'];
                question = [  '%s\n See details at command window.\n\n',...
                    ' (a). "Channels" and "Bins" will be deactive on "Bins and Channel Selection".\n\n',...
                    ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
                    ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
                    ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
                    ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
                    ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
                    ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
                    ' (h). "Average across ERPsets" will be deactive.\n\n'];
            else
                msgboxText =  [];
                question = [  ];
            end
            if ~isempty(question)
                BackERPLABcolor = [1 0.9 0.3];
                title       = 'EStudio: ERPsets';
                oldcolor = get(0,'DefaultUicontrolBackgroundColor');
                set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
                button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
                set(0,'DefaultUicontrolBackgroundColor',oldcolor);
            end
        end
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = 2;
        f_redrawERP();
    end

% Gets [ind, erp] for input ds where ds is a dataset structure, ind is the
% index of the corresponding ERP, and ERP is the corresponding ERP
% structure.
    function varargout = ds2erp(ds)
        [~,cvtc] = size(observe_ERPDAT.ALLERP);
        for z = 1:cvtc
            fp1 = observe_ERPDAT.ALLERP(1,z).filepath;
            fp2 = cell2mat(ds(5));
            fp1(regexp(fp1,'[/]')) = [];
            fp2(regexp(fp2,'[/]')) = [];
            if strcmp(observe_ERPDAT.ALLERP(1,z).erpname,cell2mat(ds(1)))&&strcmp(fp1,fp2)
                varargout{1} = z;
                varargout{2} = observe_ERPDAT.ALLERP(1,z);
            end
            
        end
    end


%%%--------------Up this panel--------------------------------------
    function Count_currentERPChanged(~,~)
        if observe_ERPDAT.Count_currentERP~=1
            return;
        end
        if ~isempty(observe_ERPDAT.ALLERP) && ~isempty(observe_ERPDAT.ERP)
            Selected_ERP= estudioworkingmemory('selectederpstudio');
            if isempty(Selected_ERP)
                Selected_ERP = length(observe_ERPDAT.ALLERP);
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                observe_ERPDAT.CURRENTERP = Selected_ERP;
                estudioworkingmemory('selectederpstudio',Selected_ERP);
            end
            ERPlistName =  getERPsets();
            ERPsetops.butttons_datasets.String = ERPlistName;
            ERPsetops.butttons_datasets.Value = Selected_ERP;
            
            ERPsetops.butttons_datasets.Min=1;
            ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            ERPsetops.butttons_datasets.Value = Selected_ERP;
            ERPsetops.butttons_datasets.Enable = 'on';
            Edit_label = 'on';
        else
            ERPlistName =  getERPsets();
            Selected_ERP =1;
            ERPsetops.butttons_datasets.String = ERPlistName;
            ERPsetops.butttons_datasets.Value = Selected_ERP;
            ERPsetops.butttons_datasets.Min=1;
            ERPsetops.butttons_datasets.Max=length(ERPlistName)+1;
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            Edit_label = 'off';
        end
        ViewerFlag=erpworkingmemory('ViewerFlag');
        if ViewerFlag==1
            Edit_label = 'off';
            ERPsetops.importexport.Enable=Edit_label;
            ERPsetops.loadbutton.Enable=Edit_label;
        else
            ERPsetops.importexport.Enable='on';
            ERPsetops.loadbutton.Enable='on';
        end
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.dotstoggle.Enable=Edit_label;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        observe_ERPDAT.Count_ERP = observe_ERPDAT.Count_ERP+1;
        observe_ERPDAT.Count_currentERP = 2;
        f_redrawERP();
    end

%%------------------get the names of erpsets-------------------------------
    function ERPlistName =  getERPsets(ALLERP)
        if nargin<1
            ALLERP= observe_ERPDAT.ALLERP;
        end
        ERPlistName = {};
        if ~isempty(ALLERP)
            for ii = 1:length(ALLERP)
                ERPlistName{ii,1} =    char(strcat(num2str(ii),'.',32, ALLERP(ii).erpname));
            end
        else
            ERPlistName{1} = 'No erpset is available' ;
        end
    end


    function Reset_erp_panel_change(~,~)
        if observe_ERPDAT.Reset_erp_paras_panel~=1
          return;  
        end
        observe_ERPDAT.Reset_erp_paras_panel=2;
    end

end