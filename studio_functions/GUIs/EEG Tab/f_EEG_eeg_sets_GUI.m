% EEG sets selector panel
%
% Author: Guanghui ZHANG  & Steve Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023

% ERPLAB Studio Toolbox
%



function varargout = f_EEG_eeg_sets_GUI(varargin)
global observe_EEGDAT;
% addlistener(observe_EEGDAT,'ALLEEG_change',@ALLEEGChanged);
% addlistener(observe_EEGDAT,'ERP_change',@drawui_CB);
% addlistener(observe_EEGDAT,'CURRENTERP_change',@cerpchange);
addlistener(observe_EEGDAT,'Count_currentEEG_change',@Count_currentERPChanged);

EStduio_gui_EEG_set = struct();
%---------Setting the parameter which will be used in the other panels-----------

try
    [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
catch
    ColorB_def = [0.95 0.95 0.95];
end

% global box;
if nargin == 0
    fig = figure(); % Parent figure
    box_eegset_gui = uiextras.BoxPanel('Parent', fig, 'Title', 'EEGsets', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    box_eegset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGsets', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    box_eegset_gui = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEGsets', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
end




% global selectedData;
sel_path = cd;
estudioworkingmemory('EEG_save_folder',sel_path);
try
    FonsizeDefault = varargin{2};
catch
    FonsizeDefault = [];
end
if isempty(FonsizeDefault)
    FonsizeDefault = f_get_default_fontsize();
end
drawui_EEGset(FonsizeDefault);

varargout{1} = box_eegset_gui;


% Grab local structure from global ERP (update local structure instead of
% replacing it)

% Draw the ui
    function drawui_EEGset(FonsizeDefault)
        try
            [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        catch
            ColorB_def = [0.7020 0.77 0.85];
        end
        
        vBox = uiextras.VBox('Parent', box_eegset_gui, 'Spacing', 5,'BackgroundColor',ColorB_def); % VBox for everything
        
        %%continuous or epoch
        EStduio_gui_EEG_set.datatype_title = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_set.eeg_contns = uicontrol('Parent',EStduio_gui_EEG_set.datatype_title, 'Style', 'radiobutton', 'String', 'Continuous EEG',...
            'Callback', @continuous_eeg,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        
        EStduio_gui_EEG_set.eeg_epoch = uicontrol('Parent',EStduio_gui_EEG_set.datatype_title, 'Style', 'radiobutton', 'String', 'Epoched EEG',...
            'Callback', @epoch_eeg,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',0);
        
        
        %%-----------------------ERPset display---------------------------------------
        panelshbox = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        panelsv2box = uiextras.VBox('Parent',panelshbox,'Spacing',5,'BackgroundColor',ColorB_def);
        dsnames  =  getDatasets();
        if isempty(observe_EEGDAT.ALLEEG)
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        EEGArray = estudioworkingmemory('EEGArray');
        EStduio_gui_EEG_set.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            length(dsnames)+1,'String', dsnames,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label);
        if isempty(EEGArray) || min(EEGArray(:))>length(dsnames) || max(EEGArray(:))>length(dsnames)
            EEGArray=1;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
        
        
        %%---------------------Options for EEGsets-----------------------------------------------------
        EStduio_gui_EEG_set.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_set.dupeselected = uicontrol('Parent', EStduio_gui_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.renameselected = uicontrol('Parent', EStduio_gui_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.suffix = uicontrol('Parent', EStduio_gui_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault);
        
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_set.importexport = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @imp_erp,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.export = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Export', 'Callback', @exp_erp,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', 'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault);
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_set.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save', 'Callback', @savechecked,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save As...', 'Callback', @savecheckedas,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder', 'Callback', @toggledots,'Enable',Edit_label,'FontSize',FonsizeDefault);
        set(buttons4,'Sizes',[70 70 115]);
        set(vBox, 'Sizes', [20 170 25 25 25]);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%-----------------------continuous EEG------------------------------------
    function continuous_eeg(~,~)
        EStduio_gui_EEG_set.eeg_contns.Value=1;
        EStduio_gui_EEG_set.eeg_epoch.Value = 0;
        
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        if isempty(EEGtypeFlag);
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            return;
        end
        EEGArray = EStduio_gui_EEG_set.butttons_datasets.Value;
        if min(EEGArray(:)) > length(EEGlistName) || max(EEGArray(:)) > length(EEGlistName)
            EEGArray = length(EEGlistName);
            estudioworkingmemory('EEGArray',EEGArray);%%May replot the waves wiht addtionl codes Aug. 8 2023
        end
        
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            return;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            EStduio_gui_EEG_set.eeg_contns.Value=0;
            EStduio_gui_EEG_set.eeg_epoch.Value = 1;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            return;
        end
        
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            for ii = 1:length(observe_EEGDAT.ALLEEG)
                if observe_EEGDAT.ALLEEG(ii).trials>1
                    EEgNamelist{ii,1} = str2html( char(strcat(num2str(ii),'.',32, observe_EEGDAT.ALLEEG(ii).setname)),'italic', 1, 'colour', '#A0A0A0');
                else
                    EEgNamelist{ii,1} =  char(strcat(num2str(ii),'.',32, observe_EEGDAT.ALLEEG(ii).setname));
                end
            end
            EStduio_gui_EEG_set.butttons_datasets.String = EEgNamelist;
            [xpos, ypos] =  find(EEGtypeFlag==1);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
            end
        end
        
    end

%%--------------------------epoched EEG--------------------------------------
    function epoch_eeg(~,~)
        EStduio_gui_EEG_set.eeg_contns.Value=0;
        EStduio_gui_EEG_set.eeg_epoch.Value = 1;
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        if isempty(EEGtypeFlag);
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            return;
        end
        EEGArray = EStduio_gui_EEG_set.butttons_datasets.Value;
        if min(EEGArray(:)) > length(EEGlistName) || max(EEGArray(:)) > length(EEGlistName)
            EEGArray = length(EEGlistName);
        end
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.eeg_contns.Value=1;
            EStduio_gui_EEG_set.eeg_epoch.Value = 0;
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            return;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            return;
        end
        
        
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            for ii = 1:length(observe_EEGDAT.ALLEEG)
                if observe_EEGDAT.ALLEEG(ii).trials==1
                    EEgNamelist{ii,1} = str2html( char(strcat(num2str(ii),'.',32, observe_EEGDAT.ALLEEG(ii).setname)),'italic', 1, 'colour', '#A0A0A0');
                else
                    EEgNamelist{ii,1} =  char(strcat(num2str(ii),'.',32, observe_EEGDAT.ALLEEG(ii).setname));
                end
            end
            EStduio_gui_EEG_set.butttons_datasets.String = EEgNamelist;
            [xpos, ypos] =  find(EEGtypeFlag==0);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end); %%May recall the plotting function
                estudioworkingmemory('EEGArray',ypos(end));
            end
        end
        
        
    end


%------------------duplicate the selected EEGsets--------------------------
    function duplicateSelected(source,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Duplicate');
        observe_EEGDAT.Process_messg =1;
        
        SelectedERP= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP =observe_EEGDAT.CURRENTSET;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        checked_ERPset_Index_bin_chan = [0 0 0 0 0 0 0];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            checked_ERPset_Index_bin_chan = S_geterpbinchan.checked_ERPset_Index;
        catch
            checked_ERPset_Index_bin_chan = f_checkerpsets(observe_EEGDAT.ALLEEG,SelectedERP);
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
                New_ERP = observe_EEGDAT.ALLEEG(SelectedERP(Numofselecterp));
                
                New_ERP.filename = '';
                New_ERP.erpname = char(strcat(New_ERP.erpname, '_Duplicated'));
                if checked_ERPset_Index_bin_chan(1)==1 || checked_ERPset_Index_bin_chan(2) ==2
                    BinArray = [1:New_ERP.nbin];
                    ChanArray  = [1:New_ERP.nchan];
                end
                New_ERP = f_ERP_duplicate(New_ERP,length(observe_EEGDAT.ALLEEG),BinArray,ChanArray);
                if isempty(New_ERP)
                    beep;
                    disp('User selected cancal!');
                    return;
                end
                
                observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) = New_ERP;
                
                datasets = {};
                getDatasets()
                datasets = sortdata(datasets);
                
                
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(cell2mat(datasets(Numofsub,2))),'.',32,datasets{Numofsub,1}));
                end
                %%Reset the display in ERPset panel
                EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(datasets);
                % EStduio_gui_EEG_set.butttons_datasets.Value =observe_EEGDAT.CURRENTSET;
            end
            try
                Selected_ERP_afd =  [length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1:length(observe_EEGDAT.ALLEEG)];
                EStduio_gui_EEG_set.butttons_datasets.Value = Selected_ERP_afd;
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1;
            catch
                Selected_ERP_afd = length(observe_EEGDAT.ALLEEG);
                EStduio_gui_EEG_set.butttons_datasets.Value =  Selected_ERP_afd;
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTERP);
            SelectedERP =Selected_ERP_afd;
            estudioworkingmemory('selectederpstudio',SelectedERP);
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_ERP_afd);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            observe_EEGDAT.Process_messg =2;
            observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        catch
            EStduio_gui_EEG_set.butttons_datasets.Value = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            SelectedERP =observe_EEGDAT.CURRENTERP;
            estudioworkingmemory('selectederpstudio',SelectedERP);
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_ERP_afd);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            observe_EEGDAT.Process_messg =3;
            observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
            return;
        end
        observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end



%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Rename');
        observe_EEGDAT.Process_messg =1;
        
        SelectedERP= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP =observe_EEGDAT.CURRENTSET;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,SelectedERP);
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
                        [~,cerp] = size(observe_EEGDAT.ALLEEG);
                        for k = 1:cerp
                            if strcmp(observe_EEGDAT.ALLEEG(1,k).filepath,datasets{Numofsub,5}) && strcmp(observe_EEGDAT.ALLEEG(1,k).filename,datasets{Numofsub,4})
                                observe_EEGDAT.ALLEEG(1,k).erpname = cell2mat(new);
                            end
                        end
                    end
                end
                datasets = sortdata(datasets);
                
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(datasets{Numofsub,2}),'.',32,datasets{Numofsub,1}));
                    
                end
                EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(datasets);
                observe_EEGDAT.Process_messg =2;
            catch
                datasets = sortdata(datasets);
                dsnames = {};
                for Numofsub = 1:size(datasets,1)
                    dsnames{Numofsub} =    char(strcat(num2str(datasets{Numofsub,2}),'.',32,char(datasets{Numofsub,1})));
                end
                EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(datasets);
                observe_EEGDAT.Process_messg =3;
            end
        end
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Add Suffix');
        observe_EEGDAT.Process_messg =1;
        
        SelectedERP= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP =observe_EEGDAT.CURRENTSET;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,SelectedERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        if isempty(SelectedERP)
            msgboxText =  'No ERPset was selected!!!';
            title = 'EStudio: EEGsets';
            errorfound(msgboxText, title);
            return;
        end
        new = f_ERP_suffix_gui('Suffix');
        if ~isempty(new)
            for Numofselecterp = 1:length(SelectedERP)
                datasets{SelectedERP(Numofselecterp),1} = char(strcat(datasets{SelectedERP(Numofselecterp),1},'_',new{1}));
                
                [~,cerp] = size(observe_EEGDAT.ALLEEG);
                for Numoferp = 1:cerp
                    if strcmp(observe_EEGDAT.ALLEEG(1,Numoferp).filepath,char(datasets{SelectedERP(Numofselecterp),5})) && strcmp(observe_EEGDAT.ALLEEG(1,Numoferp).filename,char(datasets{SelectedERP(Numofselecterp),4}))
                        observe_EEGDAT.ALLEEG(1,Numoferp).erpname = char(datasets{SelectedERP(Numofselecterp),1});
                    end
                end
            end
            observe_EEGDAT.Process_messg =2;
        else
            beep;
            disp('User cancelled');
            observe_EEGDAT.Process_messg =4;
            return;
        end
        datasets = sortdata(datasets);
        dsnames = {};
        for Numofsub = 1:size(datasets,1)
            dsnames{Numofsub} =    char(strcat(num2str((datasets{Numofsub,2})),'.',32,char(datasets{Numofsub,1})));
        end
        EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
        EStduio_gui_EEG_set.butttons_datasets.Min = 1;
        EStduio_gui_EEG_set.butttons_datasets.Max = size(datasets,1);
    end



%----------------------- Import-----------------------------------
    function imp_erp( ~, ~ )
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Import');
        observe_EEGDAT.Process_messg =1;
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
        ALLCOM = evalin('base','ALLCOM');
        
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
                    
                    [ERP, ALLEEG, ERPCOM] = pop_importerpss('Filename', fname, 'Format', dformatstr, 'Pointat', orienpoint, 'History', 'script');
                    ERP = erphistory(ERP, [], ERPCOM,1);
                    
                    try
                        Selected_erpset = [length(ALLEEG)-length(fname)+1:length(ALLEEG)];
                    catch
                        beep;
                        disp('Fail to import the EEGsets, please try again or restart EStudio!');
                        return
                    end
                    ALLEEG = f_erp_remv_Calibrate(ALLEEG, Selected_erpset);
                    Answer = f_ERP_save_multi_file(ALLEEG,Selected_erpset,'_erpss');
                    if isempty(Answer)
                        beep;
                        disp('User selected Cancel');
                        return;
                    end
                    Save_file_label = 0;
                    if ~isempty(Answer{1})
                        ALLEEG_advance = Answer{1};
                        Save_file_label = Answer{2};
                    end
                    if Save_file_label==1
                        for Numoferpset = 1:length(Selected_erpset)
                            ERP = ALLEEG_advance(Selected_erpset(Numoferpset));
                            [ERP, issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ERP.filename, 'filepath',ERP.filepath);
                            ERP = erphistory(ERP, [], ERPCOM,1);
                        end
                    end
                    observe_EEGDAT.ALLEEG=ALLEEG_advance; clear ALLEEG_advance;clear ALLEEG
                    
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
                        if  length(observe_EEGDAT.ALLEEG)==1 && strcmp(observe_EEGDAT.ALLEEG(1).erpname,'No ERPset loaded')
                            Selected_erpset_indx = 1;
                        else
                            Selected_erpset_indx = length(observe_EEGDAT.ALLEEG)+1;
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
                        if  length(observe_EEGDAT.ALLEEG)==1 && strcmp(observe_EEGDAT.ALLEEG(1).erpname,'No ERPset loaded')
                            Selected_erpset_indx = 1;
                        else
                            Selected_erpset_indx = length(observe_EEGDAT.ALLEEG)+1;
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
                    observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) =ERP;
                end
            end
            
            [~, ALLCOM] = erphistory(ERP, ALLCOM, ERPCOM);
            assignin('base','ALLCOM',ALLCOM);
            assignin('base','ERPCOM',ERPCOM);
            
            ERPset_default_label = [];
            count = 0;
            for Numoferpset = 1:size(observe_EEGDAT.ALLEEG,2)
                if strcmp(observe_EEGDAT.ALLEEG(Numoferpset).erpname,'No ERPset loaded')
                    count = count +1;
                    ERPset_default_label(count) = Numoferpset;
                end
            end
            
            if ~isempty(ERPset_default_label)
                observe_EEGDAT.ALLEEG(ERPset_default_label)=[];
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            observe_EEGDAT.Process_messg =2;
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        catch
            observe_EEGDAT.Process_messg =3;
            disp(['User selected cancel']);
            return;
        end
        EStduio_gui_EEG_set.butttons_datasets.Value = length(observe_EEGDAT.ALLEEG);
        EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
        if strcmp(datasets{1},'No ERPset loaded')
            Edit_label = 'off';
        else
            Edit_label = 'on';
        end
        EStduio_gui_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_gui_EEG_set.renameselected.Enable=Edit_label;
        EStduio_gui_EEG_set.suffix.Enable= Edit_label;
        EStduio_gui_EEG_set.clearselected.Enable=Edit_label;
        EStduio_gui_EEG_set.savebutton.Enable= Edit_label;
        EStduio_gui_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_gui_EEG_set.dotstoggle.Enable=Edit_label;
        EStduio_gui_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_gui_EEG_set.export.Enable = Edit_label;
        
        SelectedERP =observe_EEGDAT.CURRENTSET;
        estudioworkingmemory('selectederpstudio',SelectedERP);
        S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,SelectedERP);
        estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
        estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        EStduio_gui_EEG_set.butttons_datasets.Min=1;
        if size(datasets,1)<=2
            EStduio_gui_EEG_set.butttons_datasets.Max=size(datasets,1)+1;
        else
            EStduio_gui_EEG_set.butttons_datasets.Max=size(datasets,1);
        end
        observe_EEGDAT.Process_messg =2;
        observe_EEGDAT.Count_ERP = observe_EEGDAT.Count_ERP+1;
        observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end



%-----------------------Export-----------------------------------
    function exp_erp( ~, ~ )
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Export');
        observe_EEGDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        Selected_erpset= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(Selected_erpset)
            Selected_erpset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        checked_ERPset_Index_bin_chan = [0 0 0 0 0 0 0];
        try
            S_geterpbinchan = estudioworkingmemory('geterpbinchan');
            checked_ERPset_Index_bin_chan = S_geterpbinchan.checked_ERPset_Index;
        catch
            checked_ERPset_Index_bin_chan = f_checkerpsets(observe_EEGDAT.ALLEEG,Selected_erpset);
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
        
        ALLCOM = evalin('base','ALLCOM');
        for Numoferpset = 1:length(Selected_erpset)
            
            if Selected_erpset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                beep;
                msgboxText =  ['EEGsets>Export: Index of selected ERP is lager than the length of ALLEEG'];
                fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.Process_messg =4;
                return;
            end
            ERP_export_erp = observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset));
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
                    
                    [observe_EEGDAT.EEG, ERPCOM] = pop_erp2asc(ERP,FileName,'History', 'gui');
                    [observe_EEGDAT.EEG, ALLCOM] = erphistory(ERP, ALLCOM, ERPCOM);
                    assignin('base','ALLCOM',ALLCOM);
                    assignin('base','ERPCOM',ERPCOM);
                    observe_EEGDAT.Process_messg =2;
                catch
                    beep;
                    msgboxText =  ['EEGsets>Export: cannot be saved as ERPs'];
                    fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.Process_messg =4;
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
                        [observe_EEGDAT.EEG, ALLCOM] = erphistory(ERP_export_erp, ALLCOM, ERPCOM);
                        assignin('base','ALLCOM',ALLCOM);
                        assignin('base','ERPCOM',ERPCOM);
                        observe_EEGDAT.Process_messg =2;
                    catch
                        beep;
                        msgboxText =  ['EEGsets>Export: Failed to save selected EEGsets'];
                        fprintf(2,['\n Warning: ',msgboxText,'.\n']);
                        erpworkingmemory('f_EEG_proces_messg',msgboxText);
                        observe_EEGDAT.Process_messg =4;
                        return;
                    end
                catch
                    observe_EEGDAT.Process_messg =3;
                    return;
                end
            end
        end
        %%%Export data end
    end




%%---------------------Load ERP--------------------------------------------
    function load(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Load');
        observe_EEGDAT.Process_messg_EEG =1;
        %         ALLCOM = evalin('base','ALLCOM');
        ALLEEG = observe_EEGDAT.ALLEEG;
        try
            [filename, filepath] = uigetfile({'*.set','ERP (*.set)'}, ...
                'Load ERP', ...
                'MultiSelect', 'on');
            if isequal(filename,0)
                disp('User selected Cancel');
                return;
            end
            EEG = pop_loadset('filename',filename,'filepath',filepath);
            [ALLEEG,~,~] = pop_newset(ALLEEG, EEG, 0,'study',0);
        catch
            %%insert warning message here.
            return;
        end
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets(ALLEEG);%%all EEGset
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.eeg_contns.Value=1;
            EStduio_gui_EEG_set.eeg_epoch.Value = 0;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            EStduio_gui_EEG_set.eeg_contns.Value=0;
            EStduio_gui_EEG_set.eeg_epoch.Value = 1;
        end
        EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        CURRENTSET = length(ALLEEG);
        
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            
            for ii = 1:length(ALLEEG)
                if  EStduio_gui_EEG_set.eeg_contns.Value==1%%continuous EEG
                    if ALLEEG(ii).trials>1
                        EEgNamelist{ii,1} = str2html( char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname)),'italic', 1, 'colour', '#A0A0A0');
                    else
                        EEgNamelist{ii,1} =  char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname));
                    end
                    [~, ypos] =  find(EEGtypeFlag==1);
                else
                    if ALLEEG(ii).trials==1
                        EEgNamelist{ii,1} = str2html( char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname)),'italic', 1, 'colour', '#A0A0A0');
                    else
                        EEgNamelist{ii,1} =  char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname));
                    end
                    [~, ypos] =  find(EEGtypeFlag==0);
                end
                
            end
            EStduio_gui_EEG_set.butttons_datasets.String = EEgNamelist;
            CURRENTSET = ypos(end);
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        EStduio_gui_EEG_set.butttons_datasets.Min = 1;
        EStduio_gui_EEG_set.butttons_datasets.Max = length(observe_EEGDAT.ALLEEG)+1;
        EStduio_gui_EEG_set.butttons_datasets.Value = CURRENTSET;
        estudioworkingmemory('EEGArray',CURRENTSET);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        
        Edit_label = 'on';
        EStduio_gui_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_gui_EEG_set.renameselected.Enable=Edit_label;
        EStduio_gui_EEG_set.suffix.Enable= Edit_label;
        EStduio_gui_EEG_set.clearselected.Enable=Edit_label;
        EStduio_gui_EEG_set.savebutton.Enable= Edit_label;
        EStduio_gui_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_gui_EEG_set.dotstoggle.Enable=Edit_label;
        EStduio_gui_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_gui_EEG_set.export.Enable = Edit_label;
        
        
        %         observe_EEGDAT.Process_messg =2;
        %         observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end



%%----------------------Clear the selected EEGsets-------------------------
    function cleardata(source,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Clear');
        observe_EEGDAT.Process_messg_EEG =1;
        
        %         global ERPCOM;
        SelectedERP = EStduio_gui_EEG_set.butttons_datasets.Value;
        ERPset_remained = setdiff(1:length(EStduio_gui_EEG_set.butttons_datasets.String),SelectedERP);
        
        if isempty(ERPset_remained)
            observe_EEGDAT.ALLEEG = [];
            observe_EEGDAT.EEG = [];
            observe_EEGDAT.CURRENTSET  = 0;
            Edit_label = 'off';
            CURRENTSET=1;
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.butttons_datasets.Enable = 'off';
        else
            observe_EEGDAT.ALLEEG = observe_EEGDAT.ALLEEG(ERPset_remained);
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();%%all EEGset
            %%Only continuous EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
                EStduio_gui_EEG_set.eeg_contns.Enable='on';
                EStduio_gui_EEG_set.eeg_epoch.Enable='off';
                EStduio_gui_EEG_set.eeg_contns.Value=1;
                EStduio_gui_EEG_set.eeg_epoch.Value = 0;
            end
            %%Only epoched EEG
            if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
                EStduio_gui_EEG_set.eeg_contns.Enable='off';
                EStduio_gui_EEG_set.eeg_epoch.Enable='on';
                EStduio_gui_EEG_set.eeg_contns.Value=0;
                EStduio_gui_EEG_set.eeg_epoch.Value = 1;
            end
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            CURRENTSET = length(observe_EEGDAT.ALLEEG);
            
            %%contains the both continuous and epoched EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
                EStduio_gui_EEG_set.eeg_contns.Enable='on';
                EStduio_gui_EEG_set.eeg_epoch.Enable='on';
                if  EStduio_gui_EEG_set.eeg_contns.Value==1%%continuous EEG
                    [~, ypos] =  find(EEGtypeFlag==1);
                else
                    [~, ypos] =  find(EEGtypeFlag==0);
                end
                CURRENTSET = ypos(end);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            observe_EEGDAT.CURRENTSET  = CURRENTSET;
            Edit_label = 'on';
            EStduio_gui_EEG_set.butttons_datasets.Enable = 'on';
        end
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        
        EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        EStduio_gui_EEG_set.butttons_datasets.Value =CURRENTSET;
        EStduio_gui_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_gui_EEG_set.renameselected.Enable=Edit_label;
        EStduio_gui_EEG_set.suffix.Enable= Edit_label;
        EStduio_gui_EEG_set.clearselected.Enable=Edit_label;
        EStduio_gui_EEG_set.savebutton.Enable= Edit_label;
        EStduio_gui_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_gui_EEG_set.dotstoggle.Enable=Edit_label;
        EStduio_gui_EEG_set.butttons_datasets.Min =1;
        EStduio_gui_EEG_set.butttons_datasets.Max =length(EEGlistName)+1;
        EStduio_gui_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_gui_EEG_set.export.Enable = Edit_label;
        
        %         observe_EEGDAT.Process_messg_EEG =2;
        %         observe_EEGDAT.Count_ERP = observe_EEGDAT.Count_ERP+1;
        %         observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end


%-------------------------- Save selected EEGsets-------------------------------------------
    function savechecked(source,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Save');
        observe_EEGDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        try
            ALLCOM = evalin('base','ALLCOM');
        catch
            ALLCOM = [];
            assignin('base','ALLCOM',ALLCOM);
        end
        
        try
            for Numoferpset = 1:length(Selected_erpset)
                if Selected_erpset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                    beep;
                    disp(['Index of selected ERP is lager than the length of ALLEEG!!!']);
                    return;
                end
                ERP = observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset));
                FileName = ERP.filename;
                
                if isempty(FileName)
                    FileName =ERP.erpname;
                end
                [pathx, filename, ext] = fileparts(FileName);
                filename = [filename '.erp'];
                [observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)), issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', filename, 'filepath',pathName);
                [~, ALLCOM] = erphistory(observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)), ALLCOM, ERPCOM);
                
            end
            
            observe_EEGDAT.Process_messg =2;
        catch
            beep;
            observe_EEGDAT.Process_messg =3;
            disp(['EEGsets>Save: Cannot save the selected EEGsets.']);
            return;
            
        end
    end


%------------------------- Save as-----------------------------------------
    function savecheckedas(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Save As');
        observe_EEGDAT.Process_messg =1;
        
        pathName =  estudioworkingmemory('ERP_save_folder');
        if isempty(pathName)
            pathName =  cd;
        end
        
        Selected_erpset= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_erpset)
            Selected_erpset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_erpset)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_erpset);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        
        try
            ALLCOM = evalin('base','ALLCOM');
        catch
            ALLCOM = [];
            assignin('base','ALLCOM',ALLCOM);
        end
        
        for Numoferpset = 1:length(Selected_erpset)
            if Selected_erpset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                beep;
                disp('Index of selected ERP is lager than the length of ALLEEG!!!');
                return;
            end
            
            ERP = observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset));
            
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
            [observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)), issave, ERPCOM] = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', erpFilename,...
                'filepath',erppathname);
            [~, ALLCOM] = erphistory(observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)), ALLCOM, ERPCOM);
            
        end
        observe_EEGDAT.Process_messg =2;
        
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
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets-select ERPset(s)');
        observe_EEGDAT.Process_messg_EEG =1;
        Selected_ERPsetlabel = source.Value;
        [~,~,EEGtypeFlag] =  getDatasets();
        EEGArraydef =  estudioworkingmemory('EEGArray');
        if  EStduio_gui_EEG_set.eeg_contns.Value==1 %%continuous EEG
            EEGtypeFlag1 = 1;
        else%%epoched EEG
            EEGtypeFlag1 = 0;
        end
        
        [xpos, ypos] =  find(EEGtypeFlag==EEGtypeFlag1);
        Diffnum = setdiff(Selected_ERPsetlabel,ypos);
        if ~isempty(Diffnum)
            if isempty(EEGArraydef)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
            else
                %%insert Warning message to message panel
                Diffnum1 = setdiff(EEGArraydef,ypos);
                if ~isempty(Diffnum1)
                    EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                    estudioworkingmemory('EEGArray',ypos(end));
                else
                    EStduio_gui_EEG_set.butttons_datasets.Value =EEGArraydef;
                    return;
                end
            end
        else%%included in the continuous EEG
            estudioworkingmemory('EEGArray',Selected_ERPsetlabel);
        end
        
        
        
        %        Current_ERP_selected=Selected_ERPsetlabel(1);
        %        observe_EEGDAT.CURRENTSET = Current_ERP_selected;
        %         observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(Current_ERP_selected);
        
        %         checked_ERPset_Index_bin_chan = S_erpplot.geterpbinchan.checked_ERPset_Index;
        %
        %         msgboxText = {};
        %         if checked_ERPset_Index_bin_chan(1) ==1
        %             msgboxText =  ['Number of bins across EEGsets is different!'];
        %         elseif checked_ERPset_Index_bin_chan(2)==2
        %             msgboxText =  ['Number of channels across EEGsets is different!'];
        %         elseif checked_ERPset_Index_bin_chan(3) ==3
        %             msgboxText =  ['Type of data across EEGsets is different!'];
        %         elseif checked_ERPset_Index_bin_chan(4)==4
        %             msgboxText =  ['Number of samples across EEGsets is different!'];
        %         elseif checked_ERPset_Index_bin_chan(5)==5
        %             msgboxText =  ['Start time of epoch across EEGsets is different!'];
        %         end
        %         if ischar(msgboxText)
        %             if checked_ERPset_Index_bin_chan(1) ==1 && checked_ERPset_Index_bin_chan(2) ==0
        %                 question = [  '%s\n See details at command window.\n\n',...
        %                     ' (a). "Bins" will be deactive on "Bins and Channel Selection".\n\n',...
        %                     ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
        %                     ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
        %                     ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
        %                     ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
        %                     ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
        %                     ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
        %                     ' (h). "Average across EEGsets" will be deactive.\n\n'];
        %             elseif checked_ERPset_Index_bin_chan(1) ==0 && checked_ERPset_Index_bin_chan(2) ==2
        %
        %                 question = [  '%s\n See details at command window.\n\n',...
        %                     ' (a). "Channels" will be deactive on "Bins and Channel Selection".\n\n',...
        %                     ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
        %                     ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
        %                     ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
        %                     ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
        %                     ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
        %                     ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
        %                     ' (h). "Average across EEGsets" will be deactive.\n\n'];
        %             elseif checked_ERPset_Index_bin_chan(1) ==1 && checked_ERPset_Index_bin_chan(2) ==2
        %                 msgboxText =  ['Both the number of channels and the number of bins vary across EEGsets!'];
        %                 question = [  '%s\n See details at command window.\n\n',...
        %                     ' (a). "Channels" and "Bins" will be deactive on "Bins and Channel Selection".\n\n',...
        %                     ' (b). "Plot Scalp Maps" panel will be deactive.\n\n',...
        %                     ' (c). "Selected bin and chan" will be deactive on "Baseline correction & Linear detrend".\n\n',...
        %                     ' (d). "ERP Channel Operations" panel will be deactive.\n\n',...
        %                     ' (e). "ERP Bin Operations" panel will be deactive.\n\n',...
        %                     ' (f). "Covert Voltage to CSD" panel will be deactive.\n\n',...
        %                     ' (g). "Save values" will be deactive on "ERP Measurement Tool".\n\n',...
        %                     ' (h). "Average across EEGsets" will be deactive.\n\n'];
        %             else
        %                 msgboxText =  [];
        %                 question = [  ];
        %
        %             end
        %             if ~isempty(question)
        %                 BackERPLABcolor = [1 0.9 0.3];
        %                 title       = 'EStudio: EEGsets';
        %                 oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        %                 set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        %                 button      = questdlg(sprintf(question, msgboxText), title,'OK','OK');
        %                 set(0,'DefaultUicontrolBackgroundColor',oldcolor);
        %             end
        %         end
        
        %         observe_EEGDAT.Process_messg_EEG =2;
        %         observe_EEGDAT.Count_ERP = observe_EEGDAT.Count_ERP+1;
        %         observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        %         if numel(source.Value)==1
        %             observe_EEGDAT.EEG_chan = [1:observe_EEGDAT.EEG.nchan];
        %             observe_EEGDAT.EEG_IC = [1:observe_EEGDAT.EEG.nbin];
        %         end
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end





% Gets [ind, erp] for input ds where ds is a dataset structure, ind is the
% index of the corresponding ERP, and ERP is the corresponding ERP
% structure.
    function varargout = ds2erp(ds)
        [~,cvtc] = size(observe_EEGDAT.ALLEEG);
        for z = 1:cvtc
            fp1 = observe_EEGDAT.ALLEEG(1,z).filepath;
            fp2 = cell2mat(ds(5));
            fp1(regexp(fp1,'[/]')) = [];
            fp2(regexp(fp2,'[/]')) = [];
            if strcmp(observe_EEGDAT.ALLEEG(1,z).erpname,cell2mat(ds(1)))&&strcmp(fp1,fp2)
                varargout{1} = z;
                varargout{2} = observe_EEGDAT.ALLEEG(1,z);
            end
            
        end
        
    end



%%%--------------Up this panel--------------------------------------
    function Count_currentERPChanged(~,~)
        
        Selected_ERP= estudioworkingmemory('selectederpstudio');
        if isempty(Selected_ERP)
            Selected_ERP =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_ERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
        end
        
        [chk, msgboxText] = f_ERP_chckerpindex(observe_EEGDAT.ALLEEG, Selected_ERP);
        if chk==1
            Selected_ERP =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_ERP)
                msgboxText =  'No ERPset was imported!!!';
                title = 'EStudio: f_ERP_binoperation_GUI error.';
                errorfound(msgboxText, title);
                return;
            end
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
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
            EStduio_gui_EEG_set.butttons_datasets.String = dsnames;
            EStduio_gui_EEG_set.butttons_datasets.Value = Selected_ERP;
            if strcmp(datasets{1},'No ERPset loaded')
                Edit_label = 'off';
            else
                Edit_label = 'on';
            end
            EStduio_gui_EEG_set.dupeselected.Enable=Edit_label;
            EStduio_gui_EEG_set.renameselected.Enable=Edit_label;
            EStduio_gui_EEG_set.suffix.Enable= Edit_label;
            EStduio_gui_EEG_set.clearselected.Enable=Edit_label;
            EStduio_gui_EEG_set.savebutton.Enable= Edit_label;
            EStduio_gui_EEG_set.saveasbutton.Enable=Edit_label;
            EStduio_gui_EEG_set.dotstoggle.Enable=Edit_label;
            EStduio_gui_EEG_set.butttons_datasets.Enable = Edit_label;
            EStduio_gui_EEG_set.export.Enable = Edit_label;
            estudioworkingmemory('selectederpstudio',Selected_ERP);
            S_erpplot = f_ERPplot_Parameter(observe_EEGDAT.ALLEEG,Selected_ERP);
            estudioworkingmemory('geterpbinchan',S_erpplot.geterpbinchan);
            estudioworkingmemory('geterpplot',S_erpplot.geterpplot);
            EStduio_gui_EEG_set.butttons_datasets.Min=1;
            EStduio_gui_EEG_set.butttons_datasets.Max=size(datasets,1)+1;
        end
        EStduio_gui_EEG_set.butttons_datasets.Value = Selected_ERP;
        observe_EEGDAT.Count_ERP = observe_EEGDAT.Count_ERP+1;
        observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
    end

%----------------------Get the information of the updated EEGsets----------
    function [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets(ALLEEG)
        if nargin<1
            ALLEEG= observe_EEGDAT.ALLEEG;
        end
        EEGlistName = {};
        EEGConts_epoch_Flag = [0 0];
        if ~isempty(ALLEEG)
            for ii = 1:length(ALLEEG)
                EEGlistName{ii,1} =    char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname));
                if ALLEEG(ii).trials>1
                    EEGtypeFlag(1,ii) = 0;%%epoched EEG
                else
                    EEGtypeFlag(1,ii) = 1;%%Continuous EEG
                end
            end
            [xpos,ypos] = find(EEGtypeFlag==1);
            if isempty(ypos)
                EEGConts_epoch_Flag(1) = 0;
            else
                EEGConts_epoch_Flag(1) = 1;
            end
            [~,ypos] = find(EEGtypeFlag==0);
            if isempty(ypos)
                EEGConts_epoch_Flag(2) = 0;
            else
                EEGConts_epoch_Flag(2) = 1;
            end
        else
            EEGlistName{1} = 'No EEG is available' ;
            EEGConts_epoch_Flag = [0,0];%%continuous EEG, epoch EEG
            EEGtypeFlag = [];
        end
    end

end