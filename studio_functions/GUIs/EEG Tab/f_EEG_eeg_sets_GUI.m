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
addlistener(observe_EEGDAT,'Count_currentEEG_change',@Count_currentERPChanged);
addlistener(observe_EEGDAT,'EEG_Process_messg_change',@EEG_Messg_change);
% addlistener(observe_EEGDAT,'EEG_Process_messg_change',@EEG_Messg_change);
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
        observe_EEGDAT.Count_currentEEG =2;
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
            %             return;
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
                %%save to workspace
                %         assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
                assignin('base','EEG',observe_EEGDAT.EEG);
                assignin('base','CURRENTSET',CURRENTSET);
            end
        end
        observe_EEGDAT.Count_currentEEG=2;
    end


%------------------duplicate the selected EEGsets--------------------------
    function duplicateSelected(~,~)%%The defualt channels and bins that come from "bin and channel" panel but user can select bins and channels.
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Duplicate');
        observe_EEGDAT.EEG_messg =1;
        
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
            observe_EEGDAT.Count_currentEEG=2;%%to channel & IC panel
            observe_EEGDAT.EEG_messg =2;
            %             observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
        catch
            
            observe_EEGDAT.EEG_messg =3;
            %             observe_EEGDAT.Count_currentERP = observe_EEGDAT.Count_currentERP+1;
            return;
        end
        %         observe_EEGDAT.Two_GUI = observe_EEGDAT.Two_GUI+1;
    end



%%-------------------Rename the selcted files------------------------------
    function renamedata(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Rename');
        observe_EEGDAT.EEG_messg =1;
        
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
                observe_EEGDAT.EEG_messg =3;
            end
        end
        observe_EEGDAT.EEG_messg =2;
    end

%%--------------------------------Add Suffix---------------------------------
    function add_suffix(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Add Suffix');
        observe_EEGDAT.EEG_messg =1;
        
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
            observe_EEGDAT.EEG_messg =2;
        else
            beep;
            disp('User selected Cancel');
            return;
        end
    end



%----------------------- Import-----------------------------------
    function imp_eeg( ~, ~ )
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Import');
        observe_EEGDAT.EEG_messg =1;
        %-----------Setting for import-------------------------------------
        
        ALLEEG =   f_EEG_import_GUI(observe_EEGDAT.ALLEEG);
        if isempty(ALLEEG)
            observe_EEGDAT.EEG_messg =4;
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
        observe_EEGDAT.Count_currentEEG =2;
    end




%%---------------------Load EEG--------------------------------------------
    function load(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Load');
        observe_EEGDAT.EEG_messg =1;
       
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
        observe_EEGDAT.Count_currentEEG =2;
        
    end


    function append_eeg(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Append');
        
        if isempty(observe_EEGDAT.ALLEEG)
            
            return;
        end
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
            observe_EEGDAT.Count_currentEEG =2;
        end
    end



%%----------------------Clear the selected EEGsets-------------------------
    function cleardata(source,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Clear');
        observe_EEGDAT.EEG_messg =1;
        
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
        EStduio_gui_EEG_set.appendbutton.Enable = Edit_label;
        observe_EEGDAT.Count_currentEEG =2;
    end


%-------------------------- Save selected EEGsets-------------------------------------------
    function savechecked(source,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets > Save');
        observe_EEGDAT.EEG_messg =1;
        pathName =  estudioworkingmemory('EEG_save_folder');%% the forlder to save the data.
        pathName =  [pathName,filesep];
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        Selected_erpset= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(Selected_erpset)
            Selected_erpset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_erpset)
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
            for Numoferpset = 1:length(Selected_erpset)
                if Selected_erpset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                    beep;
                    disp(['Index of selected ERP is lager than the length of ALLEEG!!!']);
                    return;
                end
                EEG = observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset));
                FileName = EEG.filename;
                
                if isempty(FileName)
                    FileName =EEG.setname;
                end
                [pathx, filename, ext] = fileparts(FileName);
                filename = [filename '.set'];
                [EEG, LASTCOM] = pop_saveset( EEG, 'filename',filename,'filepath',pathName);
                observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)) = eegh(LASTCOM, EEG);
                disp(['Saved to',32,pathName,filename]);
                assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.EEG_messg =2;
        catch
            beep;
            observe_EEGDAT.EEG_messg =3;
            disp(['EEGsets > Save: Cannot save the selected EEGsets.']);
            return;
            
        end
    end


%------------------------- Save as-----------------------------------------
    function savecheckedas(~,~)
        erpworkingmemory('f_EEG_proces_messg','EEGsets>Save As');
        observe_EEGDAT.EEG_messg =1;
        
        pathName =  estudioworkingmemory('EEG_save_folder');
        if isempty(pathName)
            pathName =  [cd,filesep];
        end
        
        
        Selected_erpset= EStduio_gui_EEG_set.butttons_datasets.Value;
        if isempty(Selected_erpset)
            Selected_erpset =observe_EEGDAT.CURRENTSET;
            if isempty(Selected_erpset)
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
        
        for Numoferpset = 1:length(Selected_erpset)
            if Selected_erpset(Numoferpset) > length(observe_EEGDAT.ALLEEG)
                beep;
                disp('Index of selected ERP is lager than the length of ALLEEG!!!');
                return;
            end
            
            EEG = observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset));
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
            observe_EEGDAT.ALLEEG(Selected_erpset(Numoferpset)) = eegh(LASTCOM, EEG);
            disp(['Saved to',32,erppathname,filename]);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG_messg =2;
        
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
        observe_EEGDAT.EEG_messg =1;
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
                    %                     return;
                end
            end
        else%%included in the continuous EEG
            estudioworkingmemory('EEGArray',Selected_ERPsetlabel);
            CURRENTSET = Selected_ERPsetlabel(1);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(CURRENTSET);
        observe_EEGDAT.CURRENTSET = CURRENTSET;
        %%save to workspace
        %         assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',CURRENTSET);
        observe_EEGDAT.Count_currentEEG =2;
        f_redrawEEG_Wave_Viewer();
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
        
        %         observe_EEGDAT.EEG_messg =2;
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
        if observe_EEGDAT.Count_currentEEG ~=1
            return;
        end
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
            %             EStduio_gui_EEG_set.export.Enable = Edit_label;
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