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
        if isempty(EEGArray) || any(EEGArray(:)>length(dsnames))
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
        EStduio_eegtab_EEG_set.refresh_eegset = uicontrol('Parent', EStduio_eegtab_EEG_set.buttons2, 'Style', 'pushbutton', 'String', 'Refresh',...
            'Callback', @refresh_eegset,'Enable',Edit_label,'FontSize',FonsizeDefault,'BackgroundColor',[1 1 1]);
        
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
    function continuous_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
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
        whichpanel = [19:23];
        EEGTab_close_open_Panels(whichpanel);
        EStudio_gui_erp_totl.EEG_transf = 1;
    end

%%--------------------------epoched EEG--------------------------------------
    function epoch_eeg(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
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
        whichpanel = [13:18];
        EEGTab_close_open_Panels(whichpanel);
        EStudio_gui_erp_totl.EEG_transf= 1;
    end


%------------------duplicate the selected EEGsets--------------------------
    function duplicateSelected(Source,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Duplicate');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if isempty(EEGArray)
            EEGArray = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = EEGArray;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            EStduio_eegtab_EEG_set.butttons_datasets.Value=EEGArray;
        end
        ChanArray=estudioworkingmemory('EEG_ChanArray');
        ChanArray = f_EEG_duplicate_GUI(observe_EEGDAT.EEG,ChanArray);
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            
            if isempty(ChanArray) || any(ChanArray(:)>EEG.nbchan) || any(ChanArray(:)<=0)
                ChanArray = [1:EEG.nbchan];
                estudioworkingmemory('EEG_ChanArray',ChanArray);
            end
            [EEG, LASTCOM] = pop_duplicateeg( EEG, 'ChanArray',ChanArray,...
                'Saveas', 'off', 'History', 'gui');
            if isempty(LASTCOM)
                return;
            end
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            [ALLEEG_out,~,~] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
        end
        
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray),'_duplicated');
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
            if Save_file_label
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
            [ALLEEG,~,~] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        
        try
            Selected_ERP_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
        catch
            Selected_ERP_afd = length(observe_EEGDAT.ALLEEG);
        end
        EStduio_eegtab_EEG_set.butttons_datasets.Value = Selected_ERP_afd;
        observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        observe_EEGDAT.EEG  = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        estudioworkingmemory('EEGArray',Selected_ERP_afd);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        
        observe_EEGDAT.count_current_eeg=1;%%to channel & IC panel
        observe_EEGDAT.eeg_panel_message =2;
    end

%%-------------------Rename the selcted files------------------------------
    function renamedata(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Rename');
        observe_EEGDAT.eeg_panel_message =1;
        
        SelectedEEG= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        
        app = feval('EEG_Tab_rename_gui',observe_EEGDAT.ALLEEG(SelectedEEG),SelectedEEG);
        waitfor(app,'Finishbutton',1);
        try
            setnames = app.Output; %NO you don't want to output EEG with edited channel locations, you want to output the parameters to run decoding
            app.delete; %delete app from view
            pause(0.1); %wait for app to leave
        catch
            return;
        end
        if isempty(setnames)
            return;
        end
        ALLEEG = observe_EEGDAT.ALLEEG(SelectedEEG);
        [ALLEEG, LASTCOM] = pop_renameeg( ALLEEG, 'eegnames',setnames,...
            'Saveas', 'off', 'History', 'gui');
        if isempty(LASTCOM)
            return;
        end
        for Numofeeg = 1:numel(SelectedEEG)
            
            ALLEEG(Numofeeg) = eegh(LASTCOM, ALLEEG(Numofeeg));
            if Numofeeg ==numel(SelectedEEG)
                eegh(LASTCOM);
            end
            
        end
        observe_EEGDAT.ALLEEG(SelectedEEG) = ALLEEG;
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
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
    function add_suffix(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Add Suffix');
        observe_EEGDAT.eeg_panel_message =1;
        SelectedEEG= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        suffixstr = f_EEG_suffix_gui('Suffix');
        if ~isempty(suffixstr)
            ALLEEG =  observe_EEGDAT.ALLEEG(SelectedEEG);
            [ALLEEG, LASTCOM] = pop_suffixeeg( ALLEEG, 'suffixstr',suffixstr,...
                'Saveas', 'off', 'History', 'gui');
            for Numofeeg = 1:length(SelectedEEG)
                ALLEEG(Numofeeg)=eegh(LASTCOM, ALLEEG(Numofeeg));
                if Numofeeg ==length(SelectedEEG)
                    eegh(LASTCOM);
                end
            end
            observe_EEGDAT.ALLEEG(SelectedEEG) =ALLEEG;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            
            EEGlistName =  getDatasets();
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_eegtab_EEG_set.butttons_datasets.Min = 1;
            EStduio_eegtab_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
            if EStudio_gui_erp_totl.EEG_autoplot==1
                f_redrawEEG_Wave_Viewer();
            end
            observe_EEGDAT.count_current_eeg=26;%%to channel & IC panel
            observe_EEGDAT.eeg_panel_message =2;
        else
            return;
        end
    end

%%----------------------Refresh alleeg and eeg-----------------------------
    function refresh_eegset(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Refresh');
        try
            ALLEEG = evalin('base', 'ALLEEG');
        catch
            ALLEEG = [];
        end
        try
            EEG = evalin('base', 'EEG');
        catch
            EEG = [];
        end
        try
            CURRENTSET = evalin('base', 'CURRENTSET');
        catch
            CURRENTSET = 1;
        end
        if isempty(ALLEEG) && ~isempty(EEG)
            ALLEEG = EEG;
            CURRENTSET =1;
        end
        if ~isempty(ALLEEG) && isempty(EEG)
            if isempty(CURRENTSET) || numel(CURRENTSET)~=1 || any(CURRENTSET(:)>length(ALLEEG))
                CURRENTSET = length(ALLEEG);
            end
            EEG = ALLEEG(CURRENTSET);
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        observe_EEGDAT.EEG =EEG;
        observe_EEGDAT.CURRENTSET  =CURRENTSET ;
        observe_EEGDAT.ALLEEG(CURRENTSET) = observe_EEGDAT.EEG;
        if isempty(observe_EEGDAT.ALLEEG) && isempty(observe_EEGDAT.EEG)
            observe_EEGDAT.ALLEEG = [];
            observe_EEGDAT.EEG = [];
            observe_EEGDAT.CURRENTSET  = 1;
            Edit_label = 'off';
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'off';
        else
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();%%all EEGset
            %%Only continuous EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
                if EStduio_eegtab_EEG_set.eeg_contns.Value==0
                    EStudio_gui_erp_totl.EEG_transf=1;
                end
            end
            %%Only epoched EEG
            if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
                if EStduio_eegtab_EEG_set.eeg_contns.Value==1
                    EStudio_gui_erp_totl.EEG_transf=1;
                end
            end
            EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
            
            %%contains the both continuous and epoched EEG
            if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
                EStduio_eegtab_EEG_set.eeg_contns.Enable='on';
                EStduio_eegtab_EEG_set.eeg_epoch.Enable='on';
            end
            Edit_label = 'on';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'on';
            
        end
        if ~isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials>1
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
        else
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
        end
        [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        
        EStduio_eegtab_EEG_set.butttons_datasets.String = EEGlistName;
        
        EStduio_eegtab_EEG_set.butttons_datasets.Value =observe_EEGDAT.CURRENTSET;
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
        EStduio_eegtab_EEG_set.refresh_eegset.Enable= Edit_label;
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        estudioworkingmemory('EEGArray',EEGArray);
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets > Refresh');
        observe_EEGDAT.eeg_panel_message=2;
    end

%----------------------- Import--------------------------------------------
    function imp_eeg( ~, ~ )
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Import');
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
        EStduio_eegtab_EEG_set.refresh_eegset.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.eeg_panel_message=2;
        
        if  EStduio_eegtab_EEG_set.eeg_contns.Value==1
            whichpanel = [19:23];
        else
            whichpanel = [13:18];
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
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Load');
        observe_EEGDAT.eeg_panel_message =1;
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        
        [filename, filepath] = uigetfile({'*.set','EEG (*.set)'}, ...
            'Load EEG', ...
            'MultiSelect', 'on');
        if isequal(filename,0)
            return;
        end
        if ischar(filename)
            [EEG,  Lastcom]= pop_loadset('filename',filename,'filepath',filepath);
            try
                EEG.history = [ EEG.history 10 Lastcom ];
            catch
                EEG.history = strvcat(EEG.history, Lastcom);
            end
            eegh(Lastcom);%%ALLCOM
            if isempty(observe_EEGDAT.EEG)
                OLDSET  =0;
            else
                OLDSET = length(ALLEEG);
            end
            [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, OLDSET,'study',0,'gui','off');
        elseif iscell(filename)
            for Numofeeg = 1:length(filename)
                
                [EEG,  Lastcom]= pop_loadset('filename',filename{Numofeeg},'filepath',filepath);
                try
                    EEG.history = [ EEG.history 10 Lastcom ];
                catch
                    EEG.history = strvcat(EEG.history, Lastcom);
                end
                eegh(Lastcom);%%ALLCOM
                if isempty(observe_EEGDAT.EEG)
                    OLDSET  =0;
                else
                    OLDSET = length(ALLEEG);
                end
                [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, OLDSET,'study',0,'gui','off');
            end
        else
            return;
        end
        
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
        EStduio_eegtab_EEG_set.refresh_eegset.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        observe_EEGDAT.eeg_panel_message=2;
        if  EStduio_eegtab_EEG_set.eeg_contns.Value==1
            whichpanel = [19:23];
        else
            whichpanel = [13:18];
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
        estudioworkingmemory('f_EEG_proces_messg','EEGsets > Append');
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
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Clear');
        observe_EEGDAT.eeg_panel_message =1;
        EEGArray = EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if length(observe_EEGDAT.ALLEEG)==1 && numel(EEGArray) == length(observe_EEGDAT.ALLEEG)
            ALLEEG = [];
            LASTCOM = 'ALLEEG = []; EEG=[]; CURRENTSET=[];';
        else
            [ALLEEG,LASTCOM] = pop_delset( observe_EEGDAT.ALLEEG , EEGArray);
            if  isempty(LASTCOM)
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            ERPset_remained = setdiff([1:length(observe_EEGDAT.ALLEEG)],EEGArray);
            if isempty(ERPset_remained)
                ALLEEG = [];
            end
        end
        eegh(LASTCOM);
        if isempty(ALLEEG)
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
        EStduio_eegtab_EEG_set.refresh_eegset.Enable= Edit_label;
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        estudioworkingmemory('EEGArray',EEGArray);
        observe_EEGDAT.count_current_eeg =2;
        if EStudio_gui_erp_totl.EEG_autoplot==1
            f_redrawEEG_Wave_Viewer();
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets > Clear EEG');
        observe_EEGDAT.eeg_panel_message=2;
    end


%-------------------------- Save selected EEGsets-------------------------------------------
    function eegset_save(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('f_EEG_proces_messg','EEGsets > Save');
        observe_EEGDAT.eeg_panel_message =1;
        pathNamedef =  estudioworkingmemory('EEG_save_folder');%% the forlder to save the data.
        if isempty(pathNamedef)
            pathNamedef =  [cd,filesep];
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
            pathName = EEG.filepath;
            if isempty(pathName)
                pathName = pathNamedef;
            end
            [pathName, ~, ~] = fileparts(pathName);
            FileName = EEG.filename;
            if isempty(FileName)
                FileName =EEG.setname;
            end
            [pathx, filename, ext] = fileparts(FileName);
            filename = [filename '.set'];
            checkfileindex = checkfilexists([pathName,filename]);
            if checkfileindex==1
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',pathName);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                if Numofeeg ==length(EEGArray)
                    eegh(LASTCOM);
                end
                disp(['Saved to',32,pathName,filesep,filename]);
                fprintf(['\n',LASTCOM,'\n']);
            else
                disp(['User selected Cancel for saving',32,filename]);
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg =26;
        observe_EEGDAT.eeg_panel_message =2;
    end


%------------------------- Save as-----------------------------------------
    function eegset_saveas(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','EEGsets>Save As');
        observe_EEGDAT.eeg_panel_message =1;
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        EEGArray= EStduio_eegtab_EEG_set.butttons_datasets.Value;
        if isempty(EEGArray) || any(EEGArray>length(observe_EEGDAT.ALLEEG))
            EEGArray =observe_EEGDAT.CURRENTSET;
        end
        
        Answer =  f_EEG_saveas_multi_file(observe_EEGDAT.ALLEEG,EEGArray,'',pathName);
        if isempty(Answer)
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
        end
        
        for Numofeeg = 1:length(EEGArray)
            EEG = ALLEEG_out(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Save EEG dataset as *',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
            if ~isempty(EEG.filename)
                filename=  EEG.filename;
            else
                filename = [EEG.setname,'.set'];
            end
            [pathstr, filename, ext] = fileparts(filename);
            filename = [filename '.set'];
            checkfileindex = checkfilexists([EEG.filepath,filename]);
            if checkfileindex==1
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',[EEG.filepath,filesep]);
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
                if Numofeeg ==length(EEGArray)
                    eegh(LASTCOM);
                end
                disp(['Saved as to',32,EEG.filepath,filesep,filename]);
                fprintf(['\n',LASTCOM,'\n']);
            end
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
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
        
        cd(select_path);
        erpcom  = sprintf('cd(%s',select_path);
        erpcom = [erpcom,');'];
        eegh(erpcom);
        estudioworkingmemory('EEG_save_folder',select_path);
        observe_EEGDAT.count_current_eeg=26;
    end


%-----------------select the ERPset of interest--------------------------
    function selectdata(source,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
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
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        Change2epocheeg= estudioworkingmemory('Change2epocheeg');
        if isempty(Change2epocheeg) || Change2epocheeg==0
            
        elseif Change2epocheeg==1
            EStduio_eegtab_EEG_set.eeg_epoch.Value =1;
            EStduio_eegtab_EEG_set.eeg_contns.Value=0;
        elseif Change2epocheeg==2
            EStduio_eegtab_EEG_set.eeg_epoch.Value =0;
            EStduio_eegtab_EEG_set.eeg_contns.Value=1;
        end
        estudioworkingmemory('Change2epocheeg',0);
        if ~isempty(observe_EEGDAT.ALLEEG) && ~isempty(observe_EEGDAT.EEG)
            ALLEEG = observe_EEGDAT.ALLEEG;
            EEGArray=   estudioworkingmemory('EEGArray');
            if isempty(EEGArray) || any(EEGArray(:)>length(observe_EEGDAT.ALLEEG))
                EEGArray =  length(observe_EEGDAT.ALLEEG);estudioworkingmemory('EEGArray',EEGArray);
                observe_EEGDAT.CURRENTSET = EEGArray;
            end
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
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'off';
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
        if EEGUpdate==1
            Edit_label = 'off';
            EStduio_eegtab_EEG_set.eeg_contns.Enable='off';
            EStduio_eegtab_EEG_set.eeg_epoch.Enable='off';
            EStduio_eegtab_EEG_set.butttons_datasets.Enable = 'off';
        end
        EStduio_eegtab_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.renameselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.suffix.Enable= Edit_label;
        EStduio_eegtab_EEG_set.clearselected.Enable=Edit_label;
        EStduio_eegtab_EEG_set.savebutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_eegtab_EEG_set.curr_folder.Enable='on';
        EStduio_eegtab_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_eegtab_EEG_set.appendbutton.Enable= Edit_label;
        EStduio_eegtab_EEG_set.refresh_eegset.Enable= Edit_label;
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
        
        if ~isempty(observe_EEGDAT.ALLEEG)
            
            CURRENTSET = length(observe_EEGDAT.ALLEEG);
            EEGArray = CURRENTSET;
            estudioworkingmemory('EEGArray',EEGArray);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(EEGArray);
            if observe_EEGDAT.EEG.trials>1
                EStduio_eegtab_EEG_set.eeg_epoch.Value =1;
                EStduio_eegtab_EEG_set.eeg_contns.Value=0;
            else
                EStduio_eegtab_EEG_set.eeg_epoch.Value =0;
                EStduio_eegtab_EEG_set.eeg_contns.Value=1;
            end
            EStduio_eegtab_EEG_set.butttons_datasets.Value = CURRENTSET;
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',CURRENTSET);
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
