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
global observe_ERPDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'eeg_message_panel_change',@eeg_message_panel_change);
% addlistener(observe_EEGDAT,'eeg_message_panel_change',@EEG_Messg_change);
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
            'Callback', @imp_eeg,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.loadbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Load', ...
            'Callback', @load,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.appendbutton = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Append', ...
            'Callback', @append_eeg,'FontSize',FonsizeDefault,'Enable',Edit_label);
        
        EStduio_gui_EEG_set.clearselected = uicontrol('Parent', buttons3, 'Style', 'pushbutton', 'String', 'Clear', ...
            'Callback', @cleardata,'Enable',Edit_label,'FontSize',FonsizeDefault);
        buttons4 = uiextras.HBox('Parent', vBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_set.savebutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save', 'Callback', @savechecked,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.saveasbutton = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Save As...', 'Callback', @savecheckedas,'Enable',Edit_label,'FontSize',FonsizeDefault);
        EStduio_gui_EEG_set.dotstoggle = uicontrol('Parent', buttons4, 'Style', 'pushbutton', 'String', 'Current Folder', ...
            'Callback', @curr_folder,'Enable',Edit_label,'FontSize',FonsizeDefault);
        set(buttons4,'Sizes',[70 70 115]);
        set(vBox, 'Sizes', [20 170 25 25 25]);
        estudioworkingmemory('EEGTab_eegset',0);
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
        %         box_eegset_gui.TitleColor= [0.0500    0.2500    0.5000];%% the default is [0.0500    0.2500    0.5000]
        MessageViewer= char(strcat('EEGsets > Continuous EEG'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_message_panel=1;
        
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
        EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            %             return;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            EStduio_gui_EEG_set.eeg_contns.Value=0;
            EStduio_gui_EEG_set.eeg_epoch.Value = 1;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
        end
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            %             EStduio_gui_EEG_set.butttons_datasets.String = EEgNamelist;
            [xpos, ypos] =  find(EEGtypeFlag==1);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
                observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
                observe_EEGDAT.CURRENTSET = CURRENTSET;
                %%save to workspace
                %         assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
                assignin('base','EEG',observe_EEGDAT.EEG);
                assignin('base','CURRENTSET',CURRENTSET);
            end
        end
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_message_panel=2;
    end

%%--------------------------epoched EEG--------------------------------------
    function epoch_eeg(~,~)
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=100 && eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        estudioworkingmemory('EEGTab_eegset',0);
        MessageViewer= char(strcat('EEGsets > Epoched EEG'));
        erpworkingmemory('f_EEG_proces_messg',MessageViewer);
        observe_EEGDAT.eeg_message_panel=1;
        
        
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
        EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        %%Only continuous EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==0
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.eeg_contns.Value=1;
            EStduio_gui_EEG_set.eeg_epoch.Value = 0;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            %             return;
        end
        %%Only epoched EEG
        if EEGConts_epoch_Flag(1)==0 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        end
        
        %%contains the both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            [xpos, ypos] =  find(EEGtypeFlag==0);
            Diffnum = setdiff(EEGArray,ypos);
            if ~isempty(Diffnum)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end); %%May recall the plotting function
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
                observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
                observe_EEGDAT.CURRENTSET = CURRENTSET;
                assignin('base','EEG',observe_EEGDAT.EEG);
                assignin('base','CURRENTSET',CURRENTSET);
            end
        end
        observe_EEGDAT.count_current_eeg=2;
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_message_panel=2;
    end


%------------------duplicate the selected EEGsets--------------------------
    function duplicateSelected(~,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Duplicate');
        observe_EEGDAT.eeg_message_panel =1;
        
        SelectedERP= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedERP)
            SelectedERP = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = SelectedERP;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(end);
            EStduio_gui_EEG_set.butttons_datasets.Value=SelectedERP;
            if isempty(SelectedERP)
                msgboxText =  'No ERPset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
        end
        
        try
            for Numofselecterp = 1:numel(SelectedERP)
                New_EEG = observe_EEGDAT.ALLEEG(SelectedERP(Numofselecterp));
                
                New_EEG.filename = '';
                New_EEG.setname = char(strcat(New_EEG.setname, '_Duplicated'));
                ChanArray = observe_EEGDAT.EEG_chan;
                if isempty(ChanArray)
                    ChanArray = [1:New_EEG.nbchan];
                end
                New_EEG = f_EEG_duplicate_GUI(New_EEG,length(observe_EEGDAT.ALLEEG),ChanArray);
                if isempty(New_EEG)
                    beep;
                    disp('User selected cancal!');
                    return;
                end
                
                observe_EEGDAT.ALLEEG(length(observe_EEGDAT.ALLEEG)+1) = New_EEG;
                
                EEGlistName =  getDatasets(observe_EEGDAT.ALLEEG);
                %%Reset the display in ERPset panel
                EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
            end
            try
                Selected_ERP_afd =  [length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1:length(observe_EEGDAT.ALLEEG)];
            catch
                Selected_ERP_afd = length(observe_EEGDAT.ALLEEG);
            end
            EStduio_gui_EEG_set.butttons_datasets.Value = Selected_ERP_afd;
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(SelectedERP)+1;
            observe_EEGDAT.EEG  = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            observe_EEGDAT.count_current_eeg=2;%%to channel & IC panel
            observe_EEGDAT.eeg_message_panel =2;
            %             observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        catch
            
            observe_EEGDAT.eeg_message_panel =3;
            return;
        end
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end



%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Rename');
        observe_EEGDAT.eeg_message_panel =1;
        
        SelectedEEG= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedEEG)
            SelectedEEG =observe_EEGDAT.CURRENTSET;
            if isempty(SelectedEEG)
                msgboxText =  'No EEGset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
        end
        for Numofselecterp = 1:length(SelectedEEG)
            try
                ndsns = SelectedEEG(Numofselecterp);
                erpName = char(observe_EEGDAT.ALLEEG(1,ndsns).setname);
                new = f_EEG_rename_gui(erpName,SelectedEEG(Numofselecterp));
                if isempty(new)
                    beep;
                    disp(['User selected cancel']);
                    return;
                end
                observe_EEGDAT.ALLEEG(1,ndsns).setname = cell2mat(new);
                EEGlistName =  getDatasets();
                EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
                assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            catch
                observe_EEGDAT.eeg_message_panel =3;
            end
        end
        observe_EEGDAT.eeg_message_panel =2;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Add Suffix');
        observe_EEGDAT.eeg_message_panel =1;
        
        SelectedEEG= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(SelectedEEG)
            SelectedEEG =observe_EEGDAT.CURRENTSET;
            if isempty(SelectedEEG)
                msgboxText =  'No EEGset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
        end
        if isempty(SelectedEEG)
            msgboxText =  'No EEGset was selected!!!';
            title = 'EStudio: EEGsets';
            errorfound(msgboxText, title);
            return;
        end
        new = f_EEG_suffix_gui('Suffix');
        if ~isempty(new)
            for Numofselecterp = SelectedEEG
                observe_EEGDAT.ALLEEG(1,Numofselecterp).setname = char(strcat(observe_EEGDAT.ALLEEG(1,Numofselecterp).setname,new{1}));
                EEGlistName =  getDatasets();
                EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
                EStduio_gui_EEG_set.butttons_datasets.Min = 1;
                EStduio_gui_EEG_set.butttons_datasets.Max = length(EEGlistName)+1;
            end
            observe_EEGDAT.eeg_message_panel =2;
        else
            beep;
            disp('User selected Cancel');
            return;
        end
    end



%----------------------- Import-----------------------------------
    function imp_eeg( ~, ~ )
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Import');
        observe_EEGDAT.eeg_message_panel =1;
        %-----------Setting for import-------------------------------------
        
        ALLEEG =   f_EEG_import_GUI(observe_EEGDAT.ALLEEG);
        if isempty(ALLEEG)
            observe_EEGDAT.eeg_message_panel =4;
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
        %%contains both continuous and epoched EEG
        if EEGConts_epoch_Flag(1)==1 && EEGConts_epoch_Flag(2)==1
            EStduio_gui_EEG_set.eeg_contns.Enable='on';
            EStduio_gui_EEG_set.eeg_epoch.Enable='on';
            for ii = 1:length(ALLEEG)
                if  EStduio_gui_EEG_set.eeg_contns.Value==1%%continuous EEG
                    [~, ypos] =  find(EEGtypeFlag==1);
                else
                    [~, ypos] =  find(EEGtypeFlag==0);
                end
            end
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
        EStduio_gui_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
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
        observe_EEGDAT.eeg_message_panel =1;
        
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
            if  EStduio_gui_EEG_set.eeg_contns.Value==1%%continuous EEG
                [~, ypos] =  find(EEGtypeFlag==1);
            else
                [~, ypos] =  find(EEGtypeFlag==0);
            end
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
        EStduio_gui_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_message_panel=2;
        
    end

%%----------------------------Append two or more files---------------------
    function append_eeg(~,~)
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.ALLEEG)
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Append');
        
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
            disp('User selected Cancel');
            return;
        end
        INEEG2  = eval( [ '[' res{1} ']' ] );
        keepall = res{2};
        [EEG,LASTCOM]= pop_mergeset( observe_EEGDAT.ALLEEG,INEEG2,keepall);
        if isempty(LASTCOM)
            beep;
            disp('User selected Cancel');
            return;
        end
        
        if ~isempty(LASTCOM)
            EEG = eegh(LASTCOM, EEG);
            if isempty(observe_EEGDAT.ALLEEG)
                OLDSET=1;
            else
                OLDSET = length(observe_EEGDAT.ALLEEG);
            end
            [observe_EEGDAT.ALLEEG, EEG] = pop_newset( observe_EEGDAT.ALLEEG, EEG,OLDSET);
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG( observe_EEGDAT.CURRENTSET);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
            EStduio_gui_EEG_set.butttons_datasets.Value =observe_EEGDAT.CURRENTSET ;
            EStduio_gui_EEG_set.butttons_datasets.Max =length(EEGlistName)+1;
            EEGArray= EStduio_gui_EEG_set.butttons_datasets.Value;
            estudioworkingmemory('EEGArray',EEGArray);
            
            observe_EEGDAT.count_current_eeg =2;
            f_redrawEEG_Wave_Viewer();
            observe_EEGDAT.eeg_message_panel=2;
        end
    end



%%----------------------Clear the selected EEGsets-------------------------
    function cleardata(source,~)
        if isempty(observe_EEGDAT.EEG)
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Clear');
        observe_EEGDAT.eeg_message_panel =1;
        
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
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
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
        EStduio_gui_EEG_set.appendbutton.Enable = Edit_label;
        
        EEGArray= EStduio_gui_EEG_set.butttons_datasets.Value;
        estudioworkingmemory('EEGArray',EEGArray);
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_message_panel=2;
    end


%-------------------------- Save selected EEGsets-------------------------------------------
    function savechecked(source,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Save');
        observe_EEGDAT.eeg_message_panel =1;
        pathName =  estudioworkingmemory('EEG_save_folder');%% the forlder to save the data.
        pathName =  [pathName,filesep];
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        Selected_eegset= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(Selected_eegset)
            Selected_eegset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_eegset)
                msgboxText =  'No EEGset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
        end
        try
            ALLCOM = evalin('base','ALLCOM');
        catch
            ALLCOM = [];
            assignin('base','ALLCOM',ALLCOM);
        end
        
        try
            for Numoferpset = 1:length(Selected_eegset)
                if Selected_eegset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                    beep;
                    disp(['Index of selected ERP is lager than the length of ALLEEG!!!']);
                    return;
                end
                EEG = observe_EEGDAT.ALLEEG(Selected_eegset(Numoferpset));
                FileName = EEG.filename;
                
                if isempty(FileName)
                    FileName =EEG.setname;
                end
                [pathx, filename, ext] = fileparts(FileName);
                filename = [filename '.set'];
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',pathName);
                observe_EEGDAT.ALLEEG(Selected_eegset(Numoferpset)) = eegh(LASTCOM, EEG);
                disp(['Saved to',32,pathName,filename]);
                assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.eeg_message_panel =2;
        catch
            beep;
            observe_EEGDAT.eeg_message_panel =3;
            disp(['EEGsets > Save: Cannot save the selected EEGsets.']);
            return;
            
        end
    end


%------------------------- Save as-----------------------------------------
    function savecheckedas(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Save As');
        observe_EEGDAT.eeg_message_panel =1;
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        Selected_eegset= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(Selected_eegset)
            Selected_eegset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_eegset)
                msgboxText =  'No EEGset was selected!!!';
                title = 'EStudio: EEGsets';
                errorfound(msgboxText, title);
                return;
            end
        end
        
        try
            ALLCOM = evalin('base','ALLCOM');
        catch
            ALLCOM = [];
            assignin('base','ALLCOM',ALLCOM);
        end
        
        for Numoferpset = 1:length(Selected_eegset)
            if Selected_eegset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                beep;
                disp('Index of selected ERP is lager than the length of ALLEEG!!!');
                return;
            end
            
            EEG = observe_EEGDAT.ALLEEG(Selected_eegset(Numoferpset));
            [pathstr, namedef, ext] = fileparts(char(EEG.filename));
            [erpfilename, erppathname, indxs] = uiputfile({'*.set'}, ...
                ['Save "',EEG.setname,'" as'],...
                fullfile(pathName,namedef));
            if isequal(erpfilename,0)
                disp('User selected Cancel')
                return
            end
            if isempty(erpfilename)
                erpfilename =EEG.setname;
            end
            [pathx, filename, ext] = fileparts(erpfilename);
            filename = [filename '.set'];
            [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',erppathname);
            observe_EEGDAT.ALLEEG(Selected_eegset(Numoferpset)) = eegh(LASTCOM, EEG);
            disp(['Saved to',32,erppathname,filename]);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.eeg_message_panel =2;
        
    end


%---------------- Enable/Disable dot structure-----------------------------
    function curr_folder(~,~)
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
        erpworkingmemory('f_EEG_proces_messg','EEGsets-select EEGset(s)');
        observe_EEGDAT.eeg_message_panel =1;
        Selected_eegsetlabel = source.Value;
        [~,~,EEGtypeFlag] =  getDatasets();
        EEGArraydef =  estudioworkingmemory('EEGArray');
        if  EStduio_gui_EEG_set.eeg_contns.Value==1 %%continuous EEG
            EEGtypeFlag1 = 1;
        else%%epoched EEG
            EEGtypeFlag1 = 0;
        end
        
        [xpos, ypos] =  find(EEGtypeFlag==EEGtypeFlag1);
        Diffnum = setdiff(Selected_eegsetlabel,ypos);
        if ~isempty(Diffnum)
            if isempty(EEGArraydef)
                EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                estudioworkingmemory('EEGArray',ypos(end));
                CURRENTSET = ypos(end);
            else
                %%insert Warning message to message panel
                Diffnum1 = setdiff(EEGArraydef,ypos);
                if ~isempty(Diffnum1)
                    EStduio_gui_EEG_set.butttons_datasets.Value =ypos(end);
                    estudioworkingmemory('EEGArray',ypos(end));
                    CURRENTSET = ypos(end);
                else
                    EStduio_gui_EEG_set.butttons_datasets.Value =EEGArraydef;
                    CURRENTSET = EEGArraydef(1);
                end
            end
        else%%included in the continuous EEG
            estudioworkingmemory('EEGArray',Selected_eegsetlabel);
            CURRENTSET = Selected_eegsetlabel(1);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
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
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=1
            return;
        end
        Change2epocheeg= erpworkingmemory('Change2epocheeg');
        if isempty(Change2epocheeg) || Change2epocheeg==0
           
        else
           EStduio_gui_EEG_set.eeg_epoch.Value =1;  
           EStduio_gui_EEG_set.eeg_contns.Value=0;
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
                EStduio_gui_EEG_set.eeg_contns.Enable='on';
                EStduio_gui_EEG_set.eeg_epoch.Enable='on';
                if  EStduio_gui_EEG_set.eeg_contns.Value==1%%continuous EEG
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
            EStduio_gui_EEG_set.butttons_datasets.Min = 1;
            EStduio_gui_EEG_set.butttons_datasets.Max = length(observe_EEGDAT.ALLEEG)+1;
            EStduio_gui_EEG_set.butttons_datasets.Value = EEGArray;
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
            observe_EEGDAT.CURRENTSET = CURRENTSET;
            Edit_label = 'on';
        else
            observe_EEGDAT.ALLEEG = [];
            observe_EEGDAT.EEG = [];
            observe_EEGDAT.CURRENTSET  = 0;
            Edit_label = 'off';
            CURRENTSET=1;
            EStduio_gui_EEG_set.eeg_contns.Enable='off';
            EStduio_gui_EEG_set.eeg_epoch.Enable='off';
            EStduio_gui_EEG_set.butttons_datasets.Enable = 'off';
            [EEGlistName,EEGConts_epoch_Flag,EEGtypeFlag] =  getDatasets();
            EStduio_gui_EEG_set.butttons_datasets.String = EEGlistName;
        end
        %%save to workspace
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);

        EStduio_gui_EEG_set.dupeselected.Enable=Edit_label;
        EStduio_gui_EEG_set.renameselected.Enable=Edit_label;
        EStduio_gui_EEG_set.suffix.Enable= Edit_label;
        EStduio_gui_EEG_set.clearselected.Enable=Edit_label;
        EStduio_gui_EEG_set.savebutton.Enable= Edit_label;
        EStduio_gui_EEG_set.saveasbutton.Enable=Edit_label;
        EStduio_gui_EEG_set.dotstoggle.Enable=Edit_label;
        EStduio_gui_EEG_set.butttons_datasets.Enable = Edit_label;
        EStduio_gui_EEG_set.appendbutton.Enable= Edit_label;
        observe_EEGDAT.count_current_eeg =2;
        f_redrawEEG_Wave_Viewer();
        observe_EEGDAT.eeg_message_panel=2;
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
                if EStduio_gui_EEG_set.eeg_contns.Value==1
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

end