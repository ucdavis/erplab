% EEG sets selector panel
%
% Author: Guanghui ZHANG  & Steve Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023 && 2024

% ERPLAB Studio Toolbox
%



function varargout = f_EEG_eeg_sets_GUI(varargin)
global observe_EEGDAT;
global EStudio_gui_erp_totl;
% global observe_ERPDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);


EStduio_eegtab_EEG_set = struct();
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

estudioworkingmemory('Startimes',0);%%set default value

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
        EStduio_eegtab_EEG_set.datatype_title = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_set.eeg_contns = uicontrol('Parent',EStduio_eegtab_EEG_set.datatype_title, 'Style', 'radiobutton', 'String', 'Continuous EEG',...
            'Callback', @continuous_eeg,'FontSize',FonsizeDefault,'BackgroundColor',ColorB_def,'Enable','off','Value',1);
        
        EStduio_eegtab_EEG_set.eeg_epoch = uicontrol('Parent',EStduio_eegtab_EEG_set.datatype_title, 'Style', 'radiobutton', 'String', 'Epoched EEG',...
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
        EStduio_eegtab_EEG_set.butttons_datasets = uicontrol('Parent', panelsv2box, 'Style', 'listbox', 'min', 1,'max',...
            length(dsnames)+1,'String', dsnames,'Callback',@selectdata,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        if isempty(EEGArray) || min(EEGArray(:))>length(dsnames) || max(EEGArray(:))>length(dsnames)
            EEGArray=1;
            estudioworkingmemory('EEGArray',EEGArray);
        end
        try
            EStduio_eegtab_EEG_set.butttons_datasets.Value = EEGArray;
        catch
        end
        %%---------------------Options for EEGsets-----------------------------------------------------
        EStduio_eegtab_EEG_set.buttons2 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_set.dupeselected = uicontrol('Parent', EStduio_eegtab_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Duplicate', ...
            'Callback', @duplicateSelected,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.renameselected = uicontrol('Parent', EStduio_eegtab_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Rename',...
            'Callback', @renamedata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.suffix = uicontrol('Parent', EStduio_eegtab_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Add Suffix',...
            'Callback', @add_suffix,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
        
        buttons3 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_set.importexport = uicontrol('Parent',buttons3, 'Style', 'pushbutton', 'String', 'Import',...
            'Callback', @imp_eeg,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.appendbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Append', ...
            'Callback', @append_eeg,'FontSize',FonsizeDefault,'Enable',Edit_label,'BackgroundColor',[1 1 1]);
        
        EStduio_eegtab_EEG_set.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_set.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton',...
            'String', 'Save', 'Callback', @eegset_save,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton',...
            'String', 'Save As...', 'Callback', @eegset_saveas,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_set.curr_folder = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder', ...
            'Callback', @curr_folder,'Enable','on','FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        set(buttons4,'Sizes',[70 70 115]);
        set(vBox, 'Sizes', [20 150 25 25 25]);
        estudioworkingmemory('EEGTab_eegset',0);
        EStudio_gui_erp_totl.EEG_transf = 0;%%reveaal if transfter continous EEG to epoched EEG or from epoched to continous EEG
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------------------------------    Subfunctions    --------------------------------------------%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%-----------------------continuous EEG------------------------------------
    function continuous_eeg(~,~)
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_eegset',0);
        EStduio_eegtab_EEG_set.eeg_contns.Value=1;
        EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        if isempty(EEGtypeFlag)
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            return;
        end
        EEGArray = EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if any(EEGArray(:) > length(EEGlistName)) || any(EEGArray(:) <1)
            EEGArray = length(EEGlistName);
            estudioworkingmemory('EEGArray',EEGArray);%%May replot the waves wiht addtionl codes Aug. 8 2023
        end
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.butttons_datasets.Value = EEGArray;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
            EStduio_eegtab_EEG_set.butttons_datasets.Value = EEGArray;
        end
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            %             EStduio_eegtab_EEG_set.butttons_datasets.String = EEgNamelist;
            [xpos, ypos] =  find(EEGtypeFlag==1);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_eegtab_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
                observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
                observe_EEGDAT.CURRENTSET = CURRENTSET;
                %%save to workspace
                assignin('base','EEG',observe_EEGDAT.EEG);
                assignin('base','CURRENTSET',CURRENTSET);
            end
        end
        estudioworkingmemory('Startimes',0);
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        whichpanel = [20:24];
        EEGTab_close_open_Panels(whichpanel);
        EStudio_gui_erp_totl.EEG_transf = 1;
    end

%%--------------------------epoched EEG--------------------------------------
    function epoch_eeg(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_eegset',0);
        EStduio_eegtab_EEG_set.eeg_contns.Value=0;
        EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        if isempty(EEGtypeFlag)
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            return;
        end
        EEGArray = EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if any(EEGArray(:) > length(EEGlistName))
            EEGArray = length(EEGlistName);
        end
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
            EStduio_eegtab_EEG_set.butttons_datasets.Value = EEGArray;
            %             return;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        end
        
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            [xpos, ypos] =  find(EEGtypeFlag==0);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_eegtab_EEG_set.butttons_datasets.Value =ypos(end); %%May recall the plotting function
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
                observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
                observe_EEGDAT.CURRENTSET = CURRENTSET;
                assignin('base','EEG',observe_EEGDAT.EEG);
                assignin('base','CURRENTSET',CURRENTSET);
            end
        end
        estudioworkingmemory('Startimes',1);
        observe_EEGDAT.count_current_eeg=2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        whichpanel = [13:19];
        EEGTab_close_open_Panels(whichpanel);
        EStudio_gui_erp_totl.EEG_transf= 1;
    end


%------------------duplicate the selected EEGsets--------------------------
    function duplicateSelected(~,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Duplicate');
        observe_EEGDAT.eeg_panel_message =1;
        
        SelectedERP= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = SelectedERP;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            EStduio_eegtab_EEG_set.butttons_datasets.Value=SelectedERP;
        end
        ChanArray=estudioworkingmemory('EEG_ChanArray');
        
        for Numofselecterp = 1:numel(SelectedERP)
            New_EEG = observe_EEGDAT.ALLEEG(SelectedERP(Numofselecterp));
            
            New_EEG.filename = '';
            New_EEG.setname = char(strcat(New_EEG.setname, '_Duplicated'));
            if isempty(ChanArray) || any(ChanArray(:)>New_EEG.nbchan) || any(ChanArray(:)<=0)
                ChanArray = [1:New_EEG.nbchan];
                estudioworkingmemory('EEG_ChanArray',ChanArray);
            end
            New_EEG = f_EEG_duplicate_GUI(New_EEG,length(observe_EEGDAT.ALLEEG),ChanArray);
            if isempty(New_EEG)
                return;
            end
            
            observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) = New_EEG;
            EEGlistName =  getDatasets(observe_EEGDAT.ALLEEG);
            %%Reset the display in ERPset panel
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
            EStduio_eegtab_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
        end
        try
            Selected_ERP_afd =  [length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1:length(observe_EEGDAT.ALLEEG)];
        catch
            Selected_ERP_afd = length(observe_EEGDAT.ALLEEG);
        end
        EStduio_eegtab_EEG_set.butttons_datasets.Value = Selected_ERP_afd;
        observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1;
        observe_EEGDAT.EEG  = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.count_current_eeg=2;%%to channel & IC panel
        observe_EEGDAT.eeg_panel_message =2;
    end

%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Rename');
        observe_EEGDAT.eeg_panel_message =1;
        
        SelectedEEG= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        
        app = feval('EEG_Tab_rename_gui',observe_EEGDAT.ALLEEG(SelectedEEG),SelectedEEG);
        waitfor(app,'Finishbutton',1);
        try
            ALLEEG = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(ALLEEG)
            return;
        end
        
        observe_EEGDAT.ALLEEG(SelectedEEG) = ALLEEG;
        EEGlistName =  getDatasets();
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
        EStduio_eegtab_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.count_current_eeg=2;%%to channel & IC panel
        observe_EEGDAT.eeg_panel_message =2;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Add Suffix');
        observe_EEGDAT.eeg_panel_message =1;
        SelectedEEG= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        new = f_EEG_suffix_gui('Suffix');
        if ~isempty(new)
            for Numofselecterp = SelectedEEG
                observe_EEGDAT.ALLEEG(1,Numofselecterp).setname = char(strcat(observe_EEGDAT.ALLEEG(1,Numofselecterp).setname,new{1}));
                EEGlistName =  getDatasets();
                EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
                EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
                EStduio_eegtab_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
            end
            if EStudio_gui_erp_totl.EEG_autoplot==1
                f_redrawEEG_Wave_Viewer();
            end
            observe_EEGDAT.eeg_panel_message =2;
        else
            return;
        end
    end



%----------------------- Import-----------------------------------
    function imp_eeg( ~, ~ )
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Import');
        observe_EEGDAT.eeg_panel_message =1;
        %-----------Setting for import-------------------------------------
        ALLEEG =   f_EEG_import_GUI(observe_EEGDAT.ALLEEG);
        if isempty(ALLEEG)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        [~,EEGConts_epoch_Flag,~] =  getDatasets(ALLEEG);%%all EEGset
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
        end
        %%contains both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
        end
        CURRENTSET = length(ALLEEG);
        EEG = ALLEEG(CURRENTSET);
        if EEG.trials==1
            if EStduio_eegtab_EEG_set.eeg_contns.Value==0
                EStudio_gui_erp_totl.EEG_transf=1;
            end
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
        else
            if EStduio_eegtab_EEG_set.eeg_contns.Value==1
                EStudio_gui_erp_totl.EEG_transf=1;
            end
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
        end
        [EEGlistName,~,~] =  getDatasets(ALLEEG);
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        
        observe_EEGDAT.ALLEEG = ALLEEG;
        EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
        EStduio_eegtab_EEG_set.butttons_datasets.Max = length(observe_EEGDAT.ALLEEG)+1;
        EStduio_eegtab_EEG_set.butttons_datasets.Value = CURRENTSET;
        estudioworkingmemory('EEGArray',CURRENTSET);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        
        Edit_label = 'on';
        EStduio_eegtab_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.renameselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.suffix.Enable= Edit_label;
        EStduio_eegtab_EEG_set.clearselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.savebutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_eegtab_EEG_set.curr_folder.Enable='on';
        EStduio_eegtab_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_eegtab_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.eeg_panel_message=2;
        
        if  EStduio_eegtab_EEG_set.eeg_contns.Value==1
            whichpanel = [20:24];
        else
            whichpanel = [13:19];
        end
        EEGTab_close_open_Panels(whichpanel);
    end


%%---------------------Load EEG--------------------------------------------
    function load(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('EEGTab_eegset',0);
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Load');
        observe_EEGDAT.eeg_panel_message =1;
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        
        [filename, filepath] = uigetfile({'*.set','EEG (*.set)'}, ...
            'Load EEG', ...
            'MultiSelect', 'on');
        if isequal(filename,0)
            return;
        end
        
        [EEG,  Lastcom]= pop_loadset('filename',filename,'filepath',filepath);
        EEG = eegh(Lastcom, EEG);
        eegh(Lastcom);%%ALLCOM
        if isempty(observe_EEGDAT.EEG)
            OLDSET  =0;
        else
            OLDSET = length(ALLEEG);
        end
        [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, OLDSET,'study',0,'gui','off');
        
        eegh(LASTCOM);
        [~,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets(ALLEEG);%%all EEGset
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
        end
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
        end
        
        CURRENTSET = length(ALLEEG);
        EEG = ALLEEG(CURRENTSET);
        if EEG.trials==1
            if EStduio_eegtab_EEG_set.eeg_contns.Value==0
                EStudio_gui_erp_totl.EEG_transf=1;
            end
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
        else
            if EStduio_eegtab_EEG_set.eeg_contns.Value==1
                EStudio_gui_erp_totl.EEG_transf=1;
            end
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
            EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
        end
        [EEGlistName,~,~] =  getDatasets(ALLEEG);
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        %%contains the both continuous and epoched EEG
        observe_EEGDAT.ALLEEG = ALLEEG;
        EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
        EStduio_eegtab_EEG_set.butttons_datasets.Max = length(observe_EEGDAT.ALLEEG)+1;
        EStduio_eegtab_EEG_set.butttons_datasets.Value = CURRENTSET;
        estudioworkingmemory('EEGArray',CURRENTSET);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        
        Edit_label = 'on';
        EStduio_eegtab_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.renameselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.suffix.Enable= Edit_label;
        EStduio_eegtab_EEG_set.clearselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.savebutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_eegtab_EEG_set.curr_folder.Enable='on';
        EStduio_eegtab_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_eegtab_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.eeg_panel_message=2;
        if  EStduio_eegtab_EEG_set.eeg_contns.Value==1
            whichpanel = [20:24];
        else
            whichpanel = [13:19];
        end
        EEGTab_close_open_Panels(whichpanel);
    end

%%----------------------------Append two or more files---------------------
    function append_eeg(~,~)
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.ALLEEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Append');
        EEGArray= estudioworkingmemory('EEGArray');
        if isempty(EEGArray)
            EEGArray = '';
        end
        %%Popup the selection
        uilist    = { { 'style' 'text' 'string' 'Dataset indices to merge' } ...
            { 'style' 'edit' 'string' num2str(EEGArray) } ...
            { 'style' 'text' 'string' 'Preserve ICA weights of the first dataset ?' } ...
            { 'style' 'checkbox' 'string' '' } };
        res = inputgui( 'uilist', uilist, 'geometry', { [3 1] [3 1] }, 'helpcom', 'pophelp(''pop_mergeset'')');
        
        if isempty(res)
            return;
        end
        INEEG2  = eval( [ '[' res{1} ']' ] );
        keepall = res{2};
        [EEG,LASTCOM]= pop_mergeset( observe_EEGDAT.ALLEEG,INEEG2,keepall);
        if isempty(LASTCOM)
            return;
        end
        
        if ~isempty(LASTCOM)
            EEG = eegh(LASTCOM, EEG);
            eegh(LASTCOM);
            if isempty(observe_EEGDAT.ALLEEG)
                OLDSET=1;
            else
                OLDSET = length(observe_EEGDAT.ALLEEG);
            end
            
            Answer = f_EEG_save_single_file('Merged_datasets',EEG.filename,OLDSET);
            if isempty(Answer)
                return;
            end
            
            if ~isempty(Answer)
                EEGName = Answer{1};
                if ~isempty(EEGName)
                    EEG.setname = EEGName;
                end
                fileName_full = Answer{2};
                if isempty(fileName_full)
                    EEG.filename = '';
                    EEG.saved = 'no';
                elseif ~isempty(fileName_full)
                    [pathstr, file_name, ext] = fileparts(fileName_full);
                    if strcmp(pathstr,'')
                        pathstr = cd;
                    end
                    EEG.filename = [file_name,ext];
                    EEG.filepath = pathstr;
                    EEG.saved = 'yes';
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                    eegh(LASTCOM);
                end
            end
            
            [observe_EEGDAT.ALLEEG, EEG,~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG,OLDSET, 'gui', 'off');
            eegh(LASTCOM);
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_eegtab_EEG_set.butttons_datasets.Value =observe_EEGDAT.CURRENTSET ;
            EStduio_eegtab_EEG_set.butttons_datasets.Max =length(EEGlistName)+1;
            EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
            estudioworkingmemory('EEGArray',EEGArray);
            
            observe_EEGDAT.count_current_eeg =2;
            if EStudio_gui_erp_totl.EEG_autoplot==1
                f_redrawEEG_Wave_Viewer();
            end
            observe_EEGDAT.eeg_panel_message=2;
        end
    end


%%----------------------Clear the selected EEGsets-------------------------
    function cleardata(source,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Clear');
        observe_EEGDAT.eeg_panel_message =1;
        
        SelectedERP = EStduio_eegtab_EEG_set.butttons_datasets.Value;
        ERPset_remained = setdiff(1:length(EStduio_eegtab_EEG_set.butttons_datasets.String),SelectedERP);
        
        if isempty(ERPset_remained)
            observe_EEGDAT.ALLEEG = [];
            observe_EEGDAT.EEG = [];
            observe_EEGDAT.CURRENTSET  = 0;
            Edit_label = 'off';
            CURRENTSET=1;
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'off';
        else
            observe_EEGDAT.ALLEEG = observe_EEGDAT.ALLEEG(ERPset_remained);
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();%%all EEGset
            %%Only continuous EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
                if EStduio_eegtab_EEG_set.eeg_contns.Value==0
                    EStudio_gui_erp_totl.EEG_transf=1;
                end
                EStduio_eegtab_EEG_set.eeg_contns.Value=1;
                EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
            end
            %%Only epoched EEG
            if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
                if EStduio_eegtab_EEG_set.eeg_contns.Value==1
                    EStudio_gui_erp_totl.EEG_transf=1;
                end
                EStduio_eegtab_EEG_set.eeg_contns.Value=0;
                EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
            end
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            CURRENTSET = length(observe_EEGDAT.ALLEEG);
            
            %%contains the both continuous and epoched EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
                if  EStduio_eegtab_EEG_set.eeg_contns.Value==1%%continuous EEG
                    [~, ypos] =  find(EEGtypeFlag==1);
                else
                    [~, ypos] =  find(EEGtypeFlag==0);
                end
                CURRENTSET = ypos(end);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
            observe_EEGDAT.CURRENTSET  = CURRENTSET;
            Edit_label = 'on';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'on';
        end
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        EStduio_eegtab_EEG_set.butttons_datasets.Value =CURRENTSET;
        EStduio_eegtab_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.renameselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.suffix.Enable= Edit_label;
        EStduio_eegtab_EEG_set.clearselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.savebutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_eegtab_EEG_set.curr_folder.Enable='on';
        EStduio_eegtab_EEG_set.butttons_datasets.Min =1;
        EStduio_eegtab_EEG_set.butttons_datasets.Max =length(EEGlistName)+1;
        EStduio_eegtab_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_eegtab_EEG_set.appendbutton.Enable = Edit_label;
        
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        estudioworkingmemory('EEGArray',EEGArray);
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Clear EEG');
        observe_EEGDAT.eeg_panel_message=2;
    end


%-------------------------- Save selected EEGsets-------------------------------------------
    function eegset_save(source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Save');
        observe_EEGDAT.eeg_panel_message =1;
        pathName =  estudioworkingmemory('EEG_save_folder');%% the forlder to save the data.
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if isempty(EEGArray) || any(EEGArray>length(observe_EEGDAT.ALLEEG))
            EEGArray =observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:length(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Save EEG dataset*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
            
            
            FileName = EEG.filename;
            if isempty(FileName)
              FileName =EEG.setname;  
            end
%                 FileName =EEG.setname;
%                 [pathstr, namedef, ext] = fileparts(FileName);
%                 [FileName, pathName, indxs] = uiputfile({'*.set'}, ...
%                     ['Save "',EEG.setname,'" as'],...
%                     fullfile(pathName,namedef));
%                 if isequal(FileName,0)
%                     fprintf( ['\n',repmat('-',1,100) '\n']);
%                     return
%                 end
%                 if isempty(FileName)
%                     FileName =EEG.setname;
%                 end
%             end
            [pathx, filename, ext] = fileparts(FileName);
            filename = [filename '.set'];
            checkfileindex = checkfilexists([pathName,filename]);
            if checkfileindex==1
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',pathName);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                eegh(LASTCOM);
                disp(['Saved to',32,pathName,filename]);
                fprintf(['\n',LASTCOM,'\n']);
            else
                disp(['User selected Cancel for saving',32,filename]);
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        observe_EEGDAT.eeg_panel_message =2;
    end


%------------------------- Save as-----------------------------------------
    function eegset_saveas(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Save As');
        observe_EEGDAT.eeg_panel_message =1;
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if isempty(EEGArray) || any(EEGArray>length(observe_EEGDAT.ALLEEG))
            EEGArray =observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:length(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Save EEG dataset as *',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
            if ~isempty(EEG.filename)
                filename=  EEG.filename;
            else
                filename = [EEG.setname,'.set'];
            end
            [pathstr, namedef, ext] = fileparts(filename);
            [erpfilename, erppathname, indxs] = uiputfile({'*.set'}, ...
                ['Save "',EEG.setname,'" as'],...
                fullfile(pathName,namedef));
            if isequal(erpfilename,0)
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return
            end
            if isempty(erpfilename)
                erpfilename =EEG.setname;
            end
            [pathx, filename, ext] = fileparts(erpfilename);
            filename = [filename '.set'];
            checkfileindex = checkfilexists([erppathname,filename]);
            if checkfileindex==1
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',erppathname);
                eegh(LASTCOM);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                disp(['Saved to',32,erppathname,filename]);
                fprintf(['\n',LASTCOM,'\n']);
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg =1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%---------------- Enable/Disable dot structure-----------------------------
    function curr_folder(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =cd;
        end
        title = 'Select one forlder for saving files in following procedures';
        select_path = uigetdir(pathName,title);
        
        if isequal(select_path,0)
            select_path = cd;
        end
        userpath(select_path);
        cd(select_path);
        estudioworkingmemory('EEG_save_folder',select_path);
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
%         erpworkingmemory('f_EEG_proces_messg','EEGsets-select EEGset(s)');
%         observe_EEGDAT.eeg_panel_message =1;
        EEGArraylabel = sort(source.Value);
        [~,~,EEGtypeFlag] =  getDatasets();
        EEGArraydef =  estudioworkingmemory('EEGArray');
        if  EStduio_eegtab_EEG_set.eeg_contns.Value==1 %%continuous EEG
            EEGtypeFlag1 = 1;
        else%%epoched EEG
            EEGtypeFlag1 = 0;
        end
        
        [xpos, ypos] =  find(EEGtypeFlag==EEGtypeFlag1);
        Diffnum = setdiff(EEGArraylabel,ypos);
        if ~isempty(Diffnum)
            if isempty(EEGArraydef)
                EStduio_eegtab_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
            else
                %%insert Warning message to message panel
                Diffnum1 = setdiff(EEGArraydef,ypos);
                if ~isempty(Diffnum1)
                    EStduio_eegtab_EEG_set.butttons_datasets.Value =ypos(end);
                    estudioworkingmemory('EEGArray',ypos(end));
                    CURRENTSET = ypos(end);
                else
                    EStduio_eegtab_EEG_set.butttons_datasets.Value =EEGArraydef;
                    CURRENTSET = EEGArraydef(1);
                end
            end
        else%%included in the continuous EEG
            estudioworkingmemory('EEGArray',EEGArraylabel);
            CURRENTSET = EEGArraylabel(1);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        estudioworkingmemory('Startimes',0);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
%         observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
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

%%%--------------Update this panel--------------------------------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=1
            return;
        end
        Change2epocheeg= erpworkingmemory('Change2epocheeg');
        if isempty(Change2epocheeg) || Change2epocheeg==0
        else
            EStduio_eegtab_EEG_set.eeg_epoch.Value =1;
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
        end
        erpworkingmemory('Change2epocheeg',0);
        if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG)
            ALLEEG = observe_EEGDAT.ALLEEG;
            EEGArray=   estudioworkingmemory('EEGArray');
            CURRENTSET = observe_EEGDAT.CURRENTSET;
            ALLEEGArray = [1:length(ALLEEG)];
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();%%all EEGset
            %%Only continuous EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
                EStduio_eegtab_EEG_set.eeg_contns.Value=1;
                EStduio_eegtab_EEG_set.eeg_epoch.Value = 0;
            end
            %%Only epoched EEG
            if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
                EStduio_eegtab_EEG_set.eeg_contns.Value=0;
                EStduio_eegtab_EEG_set.eeg_epoch.Value = 1;
            end
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            if (EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0) || (EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1)
                if isempty(setdiff(EEGArray,ALLEEGArray)) %%
                    if isempty(setdiff(CURRENTSET,EEGArray)) %%
                        CURRENTSET = EEGArray(1);
                    end
                else
                    CURRENTSET = length(ALLEEG);
                    EEGArray = CURRENTSET;
                    estudioworkingmemory('EEGArray',CURRENTSET);
                end
            end
            
            %%contains the both continuous and epoched EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
                if  EStduio_eegtab_EEG_set.eeg_contns.Value==1%%continuous EEG
                    [~, ypos] =  find(EEGtypeFlag==1);
                else
                    [~, ypos] =  find(EEGtypeFlag==0);
                end
                if isempty(setdiff(EEGArray,ypos)) %%
                    if isempty(setdiff(CURRENTSET,EEGArray)) %%
                        CURRENTSET = EEGArray(1);
                    end
                else
                    CURRENTSET = ypos(end);
                    EEGArray = CURRENTSET;
                    estudioworkingmemory('EEGArray',CURRENTSET);
                end
            end
            EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
            EStduio_eegtab_EEG_set.butttons_datasets.Max = length(observe_EEGDAT.ALLEEG)+1;
            EStduio_eegtab_EEG_set.butttons_datasets.Value = EEGArray;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
            observe_EEGDAT.CURRENTSET = CURRENTSET;
            Edit_label = 'on';
        else
            observe_EEGDAT.ALLEEG = [];
            observe_EEGDAT.EEG = [];
            observe_EEGDAT.CURRENTSET  = 0;
            Edit_label = 'off';
            CURRENTSET=1;
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'off';
            EStduio_eegtab_EEG_set.butttons_datasets.Value=1;
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        end
        %%save to workspace
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        
        EStduio_eegtab_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.renameselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.suffix.Enable= Edit_label;
        EStduio_eegtab_EEG_set.clearselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.savebutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_eegtab_EEG_set.curr_folder.Enable='on';
        EStduio_eegtab_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_eegtab_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
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
            [xpos,ypos1] = find(EEGtypeFlag==1);
            if isempty(ypos1)
                EEGConts_epoch_Flag(1) = 0;
            else
                EEGConts_epoch_Flag(1) = 1;
            end
            [~,ypos2] = find(EEGtypeFlag==0);
            if isempty(ypos2)
                EEGConts_epoch_Flag(2) = 0;
            else
                EEGConts_epoch_Flag(2) = 1;
            end
            
            ERP_markdisable = [];
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
                if EStduio_eegtab_EEG_set.eeg_contns.Value==1
                    ERP_markdisable = setdiff([1:length(ALLEEG)],ypos1);
                else
                    ERP_markdisable = setdiff([1:length(ALLEEG)],ypos2);
                end
                if ~isempty(ERP_markdisable)
                    for ii = ERP_markdisable
                        EEGlistName{ii,1} = str2html( char(strcat(num2str(ii),'.',32, ALLEEG(ii).setname)),'italic', 1, 'colour', '#A0A0A0');
                    end
                end
            end
        else
            EEGlistName{1} = 'No EEG is available' ;
            EEGConts_epoch_Flag = [0,0];%%continuous EEG, epoch EEG
            EEGtypeFlag = [];
        end
    end

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=1
            return;
        end
        observe_EEGDAT.Reset_eeg_paras_panel=2;
    end

end

%%----Oct 2023---GH
%%---automatically close right panels if select continuous/epoched EEG-----
function EEGTab_close_open_Panels(whichpanel)
global EStudio_gui_erp_totl
if any(whichpanel(:)>24) || any(whichpanel(:)<1)%%check the labels for the right panels
    return;
end

for Numofpanel = 1:length(whichpanel)
    minned = EStudio_gui_erp_totl.eegpanel{whichpanel(Numofpanel)}.IsMinimized;
    if ~minned
        szs = get( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes');
        set( EStudio_gui_erp_totl.eegpanel{whichpanel(Numofpanel)}, 'IsMinimized', true);
        szs(whichpanel(Numofpanel)) = 25;
        set( EStudio_gui_erp_totl.eegsettingLayout, 'Sizes', szs );
        EStudio_gui_erp_totl.eegpanelscroll.Heights = sum(szs);
    end
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
