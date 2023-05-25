% ERPset selector panel
%
% Author: Carter Luck and Guanghui ZHANG
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2018 & 2022

% ERPLAB Toolbox
%

%
% Initial setup
%
function varargout = f_ERP_erpsetsGUI(varargin)
global observe_ERPDAT;
% addlistener(observe_ERPDAT,'ALLERP_change',@allErpChanged);
% addlistener(observe_ERPDAT,'ERP_change',@drawui_CB);
% addlistener(observe_ERPDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_ERPDAT,'Count_currentERP_change',@Count_currentERPChanged);

ERPsetops = struct();
%---------Setting the parameter which will be used in the other panels-----------

CurrentERPSet = evalin('base','CURRENTERP');

if isempty(CurrentERPSet) || (CurrentERPSet> length(observe_ERPDAT.ALLERP))
    CurrentERPSet =1;
end


estudioworkingmemory('selectederpstudio',CurrentERPSet);

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end
datasets = []; % Local data structure
% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_erpset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_erpset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'ERPsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end


getDatasets() % Get datasets from ALLERP

datasets = sortdata(datasets);
datasets = sortdata(datasets);
% global selectedData;
try
    cerp = observe_ERPDAT.CURRENTERP;
    i = observe_ERPDAT.ALLERP(1,cerp);
    [r,~] = size(datasets);
    for j = 1:r
        if strcmp(i.erpname,cell2mat(datasets(j,1)))&&strcmp(i.filename,cell2mat(datasets(j,4)))&&strcmp(i.filepath,cell2mat(datasets(j,5)))
            selectedData = j;
        end
    end
catch
    selectedData = 0;
end


sel_path = cd;
estudioworkingmemory('ERP_save_folder',sel_path);
% datasets = {'name', 1, 0, 'Users/***/Documents/Matlab/Test_data/', 'S1.erp';'name2', 2, 1;'name3', 3, 2;'name4', 4, 1;'name5', 5, 4}; % Create datasets. {'Name', datasetNumber, parentNumber, 'filename', 'filepath'}
% Test erpname/filepath/filename against ALLERP to correlate
% No duplicate dataset numbers. If a dataset's parent number is not a valid
% dataset, the dataset will be cleared when dataset = sortdata(datasets) is
% called. erpsetname must contain at least one non-numeric character.
datasets = sortdata(datasets);


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


% Grab local structure from global ERP (update local structure instead of
% replacing it)

% Draw the ui
    function drawui_erpset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.95 0.95 0.95];
        end
        [r, ~] = size(datasets); % Get size of array of datasets. r is # of datasets
        % Sort the datasets!!!
        datasets = sortdata(datasets);
        vBox = uiextras.VBox('Parent', box_erpset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        %         panelshbox = uix.ScrollingPanel('Parent', vBox);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        
        
        %%-----------------------ERPset display---------------------------------------
        dsnames = {};
        if size(datasets,1)==1
            if strcmp(datasets{1},'No ERPset loaded')
                dsnames = {''};
                Edit_label = 'off';
            else
                dsnames{1} =    strcat(num2str(cell2mat(datasets(1,2))),'.',32,datasets{1,1});
                Edit_label = 'on';
            end
        else
            for Numofsub = 1:size(datasets,1)
                dsnames{Numofsub} =    char(strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1}));
            end
            Edit_label = 'on';
        end
        SelectedERP= estudioworkingmemory('selectederpstudio');
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        ds_length = length(datasets);
        if selectedData == 0
            ERPsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
                ds_length,'String', dsnames,'Value',1,'Callback',@selectdata,'FontSize',FonsizeDefault);
        else
            ERPsetops.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
                ds_length,'String', dsnames,'Value', SelectedERP,'Callback',@selectdata,'FontSize',FonsizeDefault);
        end
        set(vBox, 'Sizes', 150);
        
        %%---------------------Options for ERPsets-----------------------------------------------------
        ERPsetops.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.dupeselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault);
        ERPsetops.renameselected = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault);
        ERPsetops.suffix = uicontrol('Parent', ERPsetops.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault);
        
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.importexport = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @imp_erp,'FontSize',FonsizeDefault);
        ERPsetops.export = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Export', 'Callback', @exp_erp,'Enable',Edit_label,'FontSize',FonsizeDefault);
        ERPsetops.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault);
        ERPsetops.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', 'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault);
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        ERPsetops.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save', 'Callback', @savechecked,'Enable',Edit_label,'FontSize',FonsizeDefault);
        ERPsetops.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save As...', 'Callback', @savecheckedas,'Enable',Edit_label,'FontSize',FonsizeDefault);
        ERPsetops.dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder', 'Callback', @toggledots,'Enable',Edit_label,'FontSize',FonsizeDefault);
        set(buttons4,'Sizes',[70 70 115])
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------------duplicate the selected ERPsets-----------------------------
    function duplicateSelected(source,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Duplicate');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        checked_ERPset_Index_bin_chan = [0 0 0 0 0 0 0];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            checked_ERPset_Index_bin_chan = S_geterpbinchan.checked_ERPset_Index;
        catch
            checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,SelectedERP);
        end
        
        BinArray = [];
        ChanArray = [];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            BinArray = S_geterpbinchan.bins{1};
            ChanArray = S_geterpbinchan.elecs_shown{1};
        catch
            BinArray = [];
            ChanArray = [];
        end
        
        
        try
            for Numofselecterp = 1:numel(SelectedERP)
                New_ERP = observe_ERPDAT.ALLERP(SelectedERP(Numofselecterp));
                
                New_ERP.filename = '';
                New_ERP.erpname = char(strcat(New_ERP.erpname, '_Duplicated'));
                if checked_ERPset_Index_bin_chan(1)==1 || checked_ERPset_Index_bin_chan(2) ==2
                    BinArray = [1:New_ERP.nbin];
                    ChanArray  = [1:New_ERP.nchan];
                end
                New_ERP = f_ERP_duplicate(New_ERP,length(observe_ERPDAT.ALLERP),BinArray,ChanArray);
                if isempty(New_ERP)
                    beep;
                    disp('User selected cancal!');
                    return;
                end
                
                observe_ERPDAT.ALLERP(length(observe_ERPDAT.ALLERP)+1) = New_ERP;
                
                datasets = {};
                getDatasets()
                datasets = sortdata(datasets);
                
                
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1}));
                end
                %%Reset the display in ERPset panel
                ERPsetops.butttons_datasets.String = dsnames;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(datasets);
                % ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
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
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERP_afd);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            observe_ERPDAT.Process_messg =2;
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        catch
            ERPsetops.butttons_datasets.Value = length(observe_ERPDAT.ALLERP);
            observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
            SelectedERP =observe_ERPDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',SelectedERP);
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERP_afd);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            observe_ERPDAT.Process_messg =3;
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            return;
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end



%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Rename');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        for Numofselecterp = 1:length(SelectedERP)
            try
                ndsns = SelectedERP(Numofselecterp);
                [r,~] = size(datasets);
                for Numofsub = 1:r
                    if ismember(datasets{Numofsub,2},ndsns)
                        
                        erpName = char(datasets{Numofsub,1});
                        new = f_ERP_rename_gui(erpName,SelectedERP(Numofselecterp));
                        if isempty(new)
                            beep;
                            disp(['User selected cancel']);
                            return;
                        end
                        
                        datasets{Numofsub,1} = new{1,1};
                        clear k
                        [~,cerp] = size(observe_ERPDAT.ALLERP);
                        for k = 1:cerp
                            if strcmp(observe_ERPDAT.ALLERP(1,k).filepath,datasets{Numofsub,5}) && strcmp(observe_ERPDAT.ALLERP(1,k).filename,datasets{Numofsub,4})
                                observe_ERPDAT.ALLERP(1,k).erpname = cell2mat(new);
                            end
                        end
                    end
                end
                datasets = sortdata(datasets);
                
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(datasets{Numofsub,2}),'.',32,datasets{Numofsub,1}));
                    
                end
                ERPsetops.butttons_datasets.String = dsnames;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(datasets);
                observe_ERPDAT.Process_messg =2;
            catch
                datasets = sortdata(datasets);
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(datasets{Numofsub,2}),'.',32,char(datasets{Numofsub,1})));
                end
                ERPsetops.butttons_datasets.String = dsnames;
                ERPsetops.butttons_datasets.Min = 1;
                ERPsetops.butttons_datasets.Max = length(datasets);
                observe_ERPDAT.Process_messg =3;
            end
        end
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Add Suffix');
        observe_ERPDAT.Process_messg =1;
        
        SelectedERP= ERPsetops.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = observe_ERPDAT.CURRENTERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        if isempty(SelectedERP)
            msgboxText =  'No ERPset was selected!!!';
            title = 'EStudio: ERPsets';
            errorfound(msgboxText, title);
            return;
        end
        new = f_ERP_suffix_gui('Suffix');
        if ~isempty(new)
            for Numofselecterp = 1:length(SelectedERP)
                datasets{SelectedERP(Numofselecterp),1} = char(strcat(datasets{SelectedERP(Numofselecterp),1},'_',new{1}));
                
                [~,cerp] = size(observe_ERPDAT.ALLERP);
                for Numoferp = 1:cerp
                    if strcmp(observe_ERPDAT.ALLERP(1,Numoferp).filepath,char(datasets{SelectedERP(Numofselecterp),5})) && strcmp(observe_ERPDAT.ALLERP(1,Numoferp).filename,char(datasets{SelectedERP(Numofselecterp),4}))
                        observe_ERPDAT.ALLERP(1,Numoferp).erpname = char(datasets{SelectedERP(Numofselecterp),1});
                    end
                end
            end
            observe_ERPDAT.Process_messg =2;
        else
            beep;
            disp('User cancelled');
            observe_ERPDAT.Process_messg =4;
            return;
        end
        datasets = sortdata(datasets);
        dsnames = {};
        for Numofsub = 1:size(datasets,1)
            dsnames{Numofsub} =    char(strcat(num2str((datasets{Numofsub,2})),'.',32,char(datasets{Numofsub,1})));
        end
        ERPsetops.butttons_datasets.String = dsnames;
        ERPsetops.butttons_datasets.Min = 1;
        ERPsetops.butttons_datasets.Max = size(datasets,1);
    end



%----------------------- Import-----------------------------------
    function imp_erp( ~, ~ )
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
            
            ERPset_default_label = [];
            count = 0;
            for Numoferpset = 1:size(observe_ERPDAT.ALLERP,2)
                if strcmp(observe_ERPDAT.ALLERP(Numoferpset).erpname,'No ERPset loaded')
                    count = count +1;
                    ERPset_default_label(count) = Numoferpset;
                end
            end
            
            if ~isempty(ERPset_default_label)
                observe_ERPDAT.ALLERP(ERPset_default_label)=[];
            end
            
            datasets = {};
            getDatasets()
            datasets = sortdata(datasets);
            
            dsnames = {};
            if size(datasets,1)==1
                if strcmp(datasets{1},'No ERPset loaded')
                    dsnames = {''};
                    Edit_label = 'off';
                else
                    dsnames{1} =    strcat(num2str(cell2mat(datasets(1,2))),'.',32,datasets{1,1});
                    Edit_label = 'on';
                end
            else
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1});
                end
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
        ERPsetops.butttons_datasets.String = dsnames;
        if strcmp(datasets{1},'No ERPset loaded')
            Edit_label = 'off';
        else
            Edit_label = 'on';
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
        
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
        estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
        estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        ERPsetops.butttons_datasets.Min=1;
        if size(datasets,1)<=2
            ERPsetops.butttons_datasets.Max=size(datasets,1)+1;
        else
            ERPsetops.butttons_datasets.Max=size(datasets,1);
        end
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_ERP = observe_ERPDAT.Count_ERP+1;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end



%-----------------------Export-----------------------------------
    function exp_erp( ~, ~ )
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Export');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        Selected_erpset= ERPsetops.butttons_datasets.Value;
        if isempty(Selected_erpset)
            Selected_erpset = observe_ERPDAT.CURRENTERP;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        checked_ERPset_Index_bin_chan = [0 0 0 0 0 0 0];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            checked_ERPset_Index_bin_chan = S_geterpbinchan.checked_ERPset_Index;
        catch
            checked_ERPset_Index_bin_chan = f_checkerpsets(observe_ERPDAT.ALLERP,Selected_erpset);
        end
        BinArray = [];
        ChanArray = [];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            BinArray = S_geterpbinchan.bins{1};
            ChanArray = S_geterpbinchan.elecs_shown{1};
        catch
            BinArray = [];
            ChanArray = [];
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
        %%%Export data end
    end




%%---------------------Load ERP--------------------------------------------
    function load(~,~)
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Load');
        observe_ERPDAT.Process_messg =1;
        
        ALLERPCOM = evalin('base','ALLERPCOM');
        [~,bc] = size(observe_ERPDAT.ALLERP);
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
                [ERP, ALLERP, ERPCOM] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'on', 'multiload', 'off',...
                    'History', 'gui');
            else
                [ERP, ALLERP, ERPCOM] = pop_loaderp('filename', filename, 'filepath', filepath, 'Warning', 'on', 'UpdateMainGui', 'off', 'multiload', 'off',...
                    'History', 'gui'); %If eeglab is not open, don't update
                [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM,1);
            end
        catch
            return;
        end
        
        [ERP, ALLERPCOM] = erphistory(ERP, ALLERPCOM, ERPCOM);
        assignin('base','ALLERPCOM',ALLERPCOM);
        assignin('base','ERPCOM',ERPCOM);
        observe_ERPDAT.ALLERP = ALLERP;
        observe_ERPDAT.ERP = ERP;
        ERPset_default_label = [];
        if ~isequal([1,bc], size(observe_ERPDAT.ALLERP))
            count = 0;
            for Numoferpset = 1:size(observe_ERPDAT.ALLERP,2)
                if strcmp(observe_ERPDAT.ALLERP(Numoferpset).erpname,'No ERPset loaded')
                    count = count +1;
                    ERPset_default_label(count) = Numoferpset;
                end
            end
            if ~isempty(ERPset_default_label)
                observe_ERPDAT.ALLERP(ERPset_default_label)=[];
                observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
                observe_ERPDAT.CURRENTERP = size(observe_ERPDAT.ALLERP,2);
            end
        end
        datasets = {};
        getDatasets()
        datasets = sortdata(datasets);
        %         drawui_erpset();
        
        dsnames = {};
        if size(datasets,1)==1
            if strcmp(datasets{1},'No ERPset loaded')
                dsnames = {''};
                Edit_label = 'off';
            else
                
                dsnames{1} =    strcat(num2str(cell2mat(datasets(1,2))),'.',32,datasets{1,1});
                
                Edit_label = 'on';
            end
        else
            for Numofsub = 1:size(datasets,1)
                dsnames{Numofsub} =    strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1});
            end
            Edit_label = 'on';
        end
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
        observe_ERPDAT.CURRENTERP = length(observe_ERPDAT.ALLERP);
        
        ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        ERPsetops.butttons_datasets.String = dsnames;
        
        if strcmp(datasets{1},'No ERPset loaded')
            Edit_label = 'off';
        else
            Edit_label = 'on';
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
        
        
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        
        S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
        estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
        estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        
        ERPsetops.butttons_datasets.Min=1;
        if size(datasets,1)<=2
            ERPsetops.butttons_datasets.Max=size(datasets,1)+1;
        else
            ERPsetops.butttons_datasets.Max=size(datasets,1);
        end
        
        observe_ERPDAT.Process_messg =2;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end



%%----------------------Clear the selected ERPsets-------------------------
    function cleardata(source,~)
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Clear');
        observe_ERPDAT.Process_messg =1;
        
        %         global ERPCOM;
        SelectedERP = ERPsetops.butttons_datasets.Value;
        ERPset_remained = setdiff(1:size(datasets,1),SelectedERP);
        
        if isempty(ERPset_remained)
            if numel(findobj('tag', 'erpsets')) > 0
                [observe_ERPDAT.ERP, observe_ERPDAT.ALLERP, ERPCOM] = pop_loaderp('filename', 'dummy.erp', 'Warning', 'on','multiload', 'off',...
                    'History', 'implicit');
            else
                [observe_ERPDAT.ERP, observe_ERPDAT.ALLERP, ERPCOM] = pop_loaderp('filename', 'dummy.erp', 'Warning', 'on','multiload', 'off',...
                    'History', 'implicit'); %If eeglab is not open, don't update
            end
            %Reset the datasets%%%%%
            
            datasets = {};
            datasets{1} =  observe_ERPDAT.ALLERP(end).erpname;
            datasets{2} =  1;
            datasets{3} =  0;
            datasets{4} =  observe_ERPDAT.ALLERP(end).filename;
            datasets{5} =  observe_ERPDAT.ALLERP(end).filepath;
            
            observe_ERPDAT.ALLERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP  = 1;
            assignin('base','ERP',observe_ERPDAT.ERP)
        else
            observe_ERPDAT.ALLERP = observe_ERPDAT.ALLERP(ERPset_remained);
            observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(end);
            observe_ERPDAT.CURRENTERP  = length(observe_ERPDAT.ALLERP);
            datasets = {};
            getDatasets();
        end
        
        datasets = sortdata(datasets);
        
        dsnames = {};
        for Numofsub = 1:size(datasets,1)
            dsnames{Numofsub} =    strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1});
        end
        
        if strcmp(datasets{1},'No ERPset loaded') && length(observe_ERPDAT.ALLERP)==1
            dsnames = {''};
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        
        ERPsetops.butttons_datasets.String = dsnames;
        ERPsetops.butttons_datasets.Value = observe_ERPDAT.CURRENTERP;
        ERPsetops.dupeselected.Enable=Edit_label;
        ERPsetops.renameselected.Enable=Edit_label;
        ERPsetops.suffix.Enable= Edit_label;
        ERPsetops.clearselected.Enable=Edit_label;
        ERPsetops.savebutton.Enable= Edit_label;
        ERPsetops.saveasbutton.Enable=Edit_label;
        ERPsetops.dotstoggle.Enable=Edit_label;
        ERPsetops.butttons_datasets.Min =1;
        ERPsetops.butttons_datasets.Max =length(dsnames)+1;
        ERPsetops.butttons_datasets.Enable = Edit_label;
        ERPsetops.export.Enable = Edit_label;
        
        SelectedERP = observe_ERPDAT.CURRENTERP;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,SelectedERP);
        estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
        estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        observe_ERPDAT.Process_messg =2;
        
        observe_ERPDAT.Count_ERP = observe_ERPDAT.Count_ERP+1;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end


%-------------------------- Save selected ERPsets-------------------------------------------
    function savechecked(source,~)
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Save');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset = observe_ERPDAT.CURRENTERP;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
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
        erpworkingmemory('f_ERP_proces_messg','ERPsets>Save As');
        observe_ERPDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset = observe_ERPDAT.CURRENTERP;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
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
        erpworkingmemory('f_ERP_proces_messg','ERPsets-select ERPset(s)');
        observe_ERPDAT.Process_messg =1;
        
        Selected_ERPsetlabel = source.Value;
        estudioworkingmemory('selectederpstudio',Selected_ERPsetlabel);
        
        S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERPsetlabel);
        estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
        estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        
        Current_ERP_selected=Selected_ERPsetlabel(1);
        observe_ERPDAT.CURRENTERP = Current_ERP_selected;
        observe_ERPDAT.ERP = observe_ERPDAT.ALLERP(Current_ERP_selected);
        
        checked_ERPset_Index_bin_chan = S_erpplot.geterpbinchan.checked_ERPset_Index;
        
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
        observe_ERPDAT.Count_ERP = observe_ERPDAT.Count_ERP+1;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
        if numel(source.Value)==1
            observe_ERPDAT.ERP_chan = [1:observe_ERPDAT.ERP.nchan];
            observe_ERPDAT.ERP_bin = [1:observe_ERPDAT.ERP.nbin];
        end
        observe_ERPDAT.Two_GUI = observe_ERPDAT.Two_GUI+1;
    end



% called datasets = sortdata(datasets), sorts datasets in order based on
% parents
    function varargout = sortdata(data)
        cinds = [];
        ndata = {}; % Sorted data
        it = 1; % Iterator for row
        for i = data' % Iterate thru all datasets
            if cell2mat(i(3)) == 0 % Find base datasets (child of 0 means it's not reliant on another dataset)
                [~, ic] = size(cinds);
                cinds(1, ic+1) = cell2mat(i(2)); % Append dataset number to list of current indexes
                ndata(it,:) = i'; % Put it in
                it = it + 1;
            end
        end
        
        cond = true;
        while cond
            ninds = []; % Reset new indexes
            for i = data' % Iterate thru all data
                for j = cinds % Iterate thru all parents
                    if cell2mat(i(3)) == j % Check to see if every datapoint is a child of the current layer
                        [~, nic] = size(ninds);
                        ninds(1, nic+1) = cell2mat(i(2)); % Append dataset number to the next round of parents
                        [ndr, ~] = size(ndata);
                        for v = 1:ndr
                            if cell2mat(ndata(v, 2)) == j
                                ndata(v+2:end+1,:) = ndata(v+1:end,:);
                                ndata(v+1,:) = i';
                            end
                        end
                    end
                end
            end
            [~, nic] = size(ninds);
            if nic == 0 % If we've gone thru all of them, there should be no new indexes
                cond = false;
            end
            clear cinds
            cinds = ninds; % Start again with ninds
        end
        varargout{1} = ndata;
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
        
        Selected_ERP= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_ERP)
            Selected_ERP = observe_ERPDAT.CURRENTERP;
            if isempty(Selected_ERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: ERPsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        [chk, msgboxText] = f_ERP_chckerpindex(observe_ERPDAT.ALLERP, Selected_ERP);
        if chk==1
            Selected_ERP = observe_ERPDAT.CURRENTERP;
            if isempty(Selected_ERP)
                msgboxText =  'No ERPset was imported!!!';
                title = 'EStudio: f_ERP_binoperation_GUI error.';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
            return;
        end
        ERPfilter_label =  erpworkingmemory('ERPfilter');
        def_baseline =  erpworkingmemory('f_ERP_BLS_Detrend');
        ERP_bin_opertion =  erpworkingmemory('f_ERP_bin_opt');
        ERP_simulation = erpworkingmemory('ERP_simulation');
        if isempty(ERPfilter_label)
            ERPfilter_label =1;
        end
        if isempty(def_baseline)
            def_baseline{3} =1;
        end
        if isempty(ERP_bin_opertion)
            ERP_bin_opertion =1;
        end
        if isempty(ERP_simulation)
            ERP_simulation =1;
        end
        if ERPfilter_label ==1 || def_baseline{3}==1 || ERP_bin_opertion==1 || ERP_simulation==1
            erpworkingmemory('ERPfilter',0);
            def_baseline{3} = 0;
            erpworkingmemory('f_ERP_BLS_Detrend',def_baseline);
            erpworkingmemory('f_ERP_bin_opt',0);
            erpworkingmemory('ERP_simulation',0);
            datasets = {};
            getDatasets()
            datasets = sortdata(datasets);
            dsnames = {};
            if size(datasets,1)==1
                if strcmp(datasets{1},'No ERPset loaded')
                    dsnames = {''};
                    Edit_label = 'off';
                else
                    dsnames{1} =    strcat(num2str(cell2mat(datasets(1,2))),'.',32,datasets{1,1});
                    Edit_label = 'on';
                end
            else
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1});
                end
                Edit_label = 'on';
            end
            ERPsetops.butttons_datasets.String = dsnames;
            ERPsetops.butttons_datasets.Value = Selected_ERP;
            if strcmp(datasets{1},'No ERPset loaded')
                Edit_label = 'off';
            else
                Edit_label = 'on';
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
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            S_erpplot = f_ERPplot_Parameter(observe_ERPDAT.ALLERP,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            ERPsetops.butttons_datasets.Min=1;
            ERPsetops.butttons_datasets.Max=size(datasets,1)+1;
        end
        ERPsetops.butttons_datasets.Value = Selected_ERP;
        observe_ERPDAT.Count_ERP = observe_ERPDAT.Count_ERP+1;
        observe_ERPDAT.Count_currentERP = observe_ERPDAT.Count_currentERP+1;
    end

%----------------------Get the information of the updated ERPsets----------
    function getDatasets()
        if isempty(datasets)
            datasets = {};
        end
        [s,~] = size(datasets);
        del = [];
        for i = 1:s
            cond = false;
            for j = observe_ERPDAT.ALLERP
                if strcmp(j.filename, datasets{i,4}) && strcmp(j.filepath, datasets{i,5}) && strcmp(i.erpname, datasets{j,1})
                    cond = true;
                end
            end
            if ~cond
                del(end+1) = i;
            end
        end
        for i = del
            datasets(del,:) = [];
        end
        for i = observe_ERPDAT.ALLERP
            cond = false;
            [s,~] = size(datasets);
            for j = 1:s
                if strcmp(i.filename, datasets{j,4}) && strcmp(i.filepath, datasets{j,5}) && strcmp(i.erpname, datasets{j,1});
                    cond = true;
                end
            end
            if ~cond
                datasets{end+1,1} = i.erpname;
                [r,~] = size(datasets);
                datasets{end,2} = r;
                datasets{end,3} = 0;
                datasets{end,4} = i.filename;
                datasets{end,5} = i.filepath;
            end
        end
    end

%     function onErpChanged(~,~)
%         assignin('base','ERP',observe_ERPDAT.ERP);
%     end


end