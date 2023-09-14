%%This function is to assin eventlist to one specific bin


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_event2bin_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_message_panel_change',@eeg_message_panel_change);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

EStduio_gui_EEG_event2bin = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_EEG_event2bin;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', fig, 'Title', 'Assign Events to Bins', 'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins', 'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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

drawui_event2bin_eeg(FonsizeDefault)
varargout{1} = EStudio_box_EEG_event2bin;

    function drawui_event2bin_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_gui_EEG_event2bin.DataSelBox = uiextras.VBox('Parent', EStudio_box_EEG_event2bin,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%display original data?
        EStduio_gui_EEG_event2bin.BDF_title = uiextras.HBox('Parent', EStduio_gui_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',EStduio_gui_EEG_event2bin.BDF_title,...
            'String','BDF File','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_gui_EEG_event2bin.BDF_edit = uicontrol('Style', 'edit','Parent',EStduio_gui_EEG_event2bin.BDF_title,...
            'String','','callback',@BDF_edit,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        EStduio_gui_EEG_event2bin.BDF_edit.KeyPressFcn=  @eeg_event2bin_presskey;
        def  = erpworkingmemory('pop_binlister');
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        try bdfileName = def{1}; catch  bdfileName = ''; end
        if ~ischar(bdfileName) || isfile(bdfileName)
            bdfileName = '';
        end
        EStduio_gui_EEG_event2bin.BDF_edit.String = bdfileName;
        EStduio_gui_EEG_event2bin.BDF_browse = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.BDF_title,...
            'String','Browse','callback',@BDF_browse,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        set( EStduio_gui_EEG_event2bin.BDF_title, 'Sizes',[60 -1 60]);
        
        %%----------------cancel and apply---------------------------------
        EStduio_gui_EEG_event2bin.reset_apply = uiextras.HBox('Parent',EStduio_gui_EEG_event2bin.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        
        EStduio_gui_EEG_event2bin.bdf_cancel = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.reset_apply,...
            'String','Cancel','callback',@BDF_eeg_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        
        EStduio_gui_EEG_event2bin.event2bin_advanced = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.reset_apply,...
            'String','Advanced','callback',@event2bin_advanced,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        EStduio_gui_EEG_event2bin.event2bin_advanced.KeyPressFcn=  @eeg_event2bin_presskey;
        
        EStduio_gui_EEG_event2bin.bdf_apply = uicontrol('Style', 'pushbutton','Parent',EStduio_gui_EEG_event2bin.reset_apply,...
            'String','Apply','callback',@eeg_bdf_apply,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        EStduio_gui_EEG_event2bin.bdf_apply.KeyPressFcn=  @eeg_event2bin_presskey;
        
        
        set(EStduio_gui_EEG_event2bin.DataSelBox,'Sizes',[30 30]);
        estudioworkingmemory('EEGTab_event2bin',0);
    end



%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%


%%-------------------------Edit the BDF file-------------------------------
    function BDF_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%change color for cancel and apply
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_event2bin.TitleColor= [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [1 1 1];
        
        BDFileName = EStduio_gui_EEG_event2bin.BDF_edit.String;
        if ~ischar(BDFileName) || isempty(BDFileName)
            MessageViewer =  ['Assign Events to Bins - bdfile should be a string.'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            EStduio_gui_EEG_event2bin.BDF_edit.String = '';
        end
        estudioworkingmemory('EEGTab_event2bin',1);
    end

%%--------------------------------Browse the BDF file----------------------
    function BDF_browse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and apply
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [1 1 1];
        EStudio_box_EEG_event2bin.TitleColor= [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [1 1 1];
        
        try
            pre_patha = EStduio_gui_EEG_event2bin.BDF_edit.String;
            [pre_pathb, nameq, extq] = fileparts(pre_patha);
            [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)', pre_pathb);
        catch
            [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)');
        end
        if isequal(bdfilename,0)
            disp('User selected Cancel')
            return;
        end
        EStduio_gui_EEG_event2bin.BDF_edit.String = fullfile(bdfpathname, bdfilename);
        estudioworkingmemory('EEGTab_event2bin',1);
    end


%%---------------------------Cancel----------------------------------------
    function BDF_eeg_cancel(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        def =  erpworkingmemory('pop_binlister');
        bdfilename = def{1};
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        try bdfileName = def{1}; catch  bdfileName = ''; end
        if ~ischar(bdfileName) || isfile(bdfileName)
            bdfileName = '';
        end
        EStduio_gui_EEG_event2bin.BDF_edit.String = bdfileName;
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if ~isempty(EEGArray) && numel(EEGArray)>1
            EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'off';
        else
            EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'on';
        end
        
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
    end


%%--------------------------Advanced options-------------------------------
    function event2bin_advanced(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','Assign Events to Bins > Advanced');
        observe_EEGDAT.eeg_message_panel =1; %%Marking for the procedure has been started.
        
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if numel(EEGArray)>1
            EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'off';
            erpworkingmemory('f_EEG_proces_messg','Assign Events to Bins > Advanced:doesnot support for multi-eegsets,please select one');
            observe_EEGDAT.eeg_message_panel =4; %%Marking for the procedure has been started.
            return;
        end
        bdfileName =  EStduio_gui_EEG_event2bin.BDF_edit.String;
        %%check is the file name is a string
        if isempty(bdfileName) || ~ischar(bdfileName)
            bdfileName = '';
        end
        %%check if the specified file exists
        if ~isfile(bdfileName)
            bdfileName ='';
            erpworkingmemory('f_EEG_proces_messg','Assign Events to Bins > Advanced:Such bdfile doesnot exist');
            observe_EEGDAT.eeg_message_panel =4;
        end
        def  = erpworkingmemory('pop_binlister');
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        def{1} = bdfileName;
        erpworkingmemory('pop_binlister',def);
        
        EEG = observe_EEGDAT.ALLEEG(EEGArray);
        [EEG, LASTCOM] = pop_binlister(EEG);
        if isempty(LASTCOM)
            return;
        end
        EEG = eegh(LASTCOM, EEG);
        [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        estudioworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_message_panel =2;
    end

%%---------------------------Apply-----------------------------------------
    function eeg_bdf_apply(~,~)
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','Assign Events to Bins > Apply');
        observe_EEGDAT.eeg_message_panel =1; %%Marking for the procedure has been started.
        
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        
        bdfileName =  EStduio_gui_EEG_event2bin.BDF_edit.String;
        %%check is the file name is a string
        if isempty(bdfileName) || ~ischar(bdfileName)
            MessageViewer =  ['Assign Events to Bins - bdfile should be a string'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            EStduio_gui_EEG_event2bin.BDF_edit.String = '';
            return;
        end
        %%check if the specified file exists
        if ~isfile(bdfileName)
            MessageViewer =  ['Assign Events to Bins - Cannot find the specified bdfile'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            EStduio_gui_EEG_event2bin.BDF_edit.String = '';
            return;
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        eventlistFlag = check_evetlist(observe_EEGDAT.ALLEEG,EEGArray);
        if eventlistFlag==1
            MessageViewer =  ['Assign Events to Bins - No Eventlist or it is empty for some eegsets'];
            erpworkingmemory('f_EEG_proces_messg',MessageViewer);
            observe_EEGDAT.eeg_message_panel =4;
            return;
        end
        
        if numel(EEGArray)>1
            Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_bins');
            if isempty(Answer)
                beep;
                disp('User selected Cancel');
                return;
            end
            if ~isempty(Answer{1})
                ALLEEG_advance = Answer{1};
                Save_file_label = Answer{2};
            end
        elseif numel(EEGArray)==1
            Save_file_label =0;
            ALLEEG_advance = observe_EEGDAT.ALLEEG;
        end
        def  = erpworkingmemory('pop_binlister');
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        def{1} = bdfileName;
        erpworkingmemory('pop_binlister',def);
        
        try
            for Numofeeg = 1:numel(EEGArray)
                EEG = ALLEEG_advance(EEGArray(Numofeeg));
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset:',32,EEG.setname,'\n\n']);
                
                %% Run pop_ command again with the inputs from the GUI
                [EEG, LASTCOM]   = pop_binlister( EEG , 'BDF',bdfileName, 'IndexEL',  1, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG', 'History', 'gui' );
                EEG = eegh(LASTCOM, EEG);
                
                
                if numel(EEGArray) ==1
                    Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_bins')),EEG.filename,EEGArray(Numofeeg));
                    if isempty(Answer)
                        disp('User selected cancel.');
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
                            %%----------save the current sdata as--------------------
                            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                            EEG = eegh(LASTCOM, EEG);
                        end
                    end
                end
                
                if Save_file_label
                    [pathstr, file_name, ext] = fileparts(EEG.filename);
                    EEG.filename = [file_name,'.set'];
                    [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                    EEG = eegh(LASTCOM, EEG);
                else
                    EEG.filename = '';
                    EEG.saved = 'no';
                    EEG.filepath = '';
                end
                [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            end
            
            try
                Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
            catch
                Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
                observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            end
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_message_panel =2;
        catch
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
            Selected_EEG_afd =observe_EEGDAT.CURRENTSET;
            estudioworkingmemory('EEGArray',Selected_EEG_afd);
            assignin('base','EEG',observe_EEGDAT.EEG);
            assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
            assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
            observe_EEGDAT.count_current_eeg=1;
            observe_EEGDAT.eeg_message_panel =3;%%There is errros in processing procedure
            return;
        end
    end



%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if  isempty(observe_EEGDAT.EEG)
            EStduio_gui_EEG_event2bin.BDF_edit.Enable = 'off';
            EStduio_gui_EEG_event2bin.BDF_browse.Enable = 'off';
            EStduio_gui_EEG_event2bin.bdf_cancel.Enable = 'off';
            EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'off';
            EStduio_gui_EEG_event2bin.bdf_apply.Enable = 'off';
            return;
        end
        
        if observe_EEGDAT.count_current_eeg ~=7
            return;
        end
        EStduio_gui_EEG_event2bin.BDF_edit.Enable = 'on';
        EStduio_gui_EEG_event2bin.BDF_browse.Enable = 'on';
        EStduio_gui_EEG_event2bin.bdf_cancel.Enable = 'on';
        EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'on';
        EStduio_gui_EEG_event2bin.bdf_apply.Enable = 'on';
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if ~isempty(EEGArray) && numel(EEGArray)>1
            EStduio_gui_EEG_event2bin.event2bin_advanced.Enable = 'off';
        end
        observe_EEGDAT.count_current_eeg=8;
    end

%%-------------------------------------------------------------------------
%%Automatically saving the changed parameters for the current panel if the
%%user change parameters for the other panels.
%%-------------------------------------------------------------------------
    function eeg_two_panels_change(~,~)
        if observe_EEGDAT.eeg_two_panels==0
            return;
        end
        ChangeFlag =  estudioworkingmemory('EEGTab_event2bin');
        if ChangeFlag~=1
            return;
        end
        eeg_bdf_apply();
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
    end


%%--------------press return to execute "Apply"----------------------------
    function eeg_event2bin_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_event2bin');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            eeg_bdf_apply();
            estudioworkingmemory('EEGTab_event2bin',0);
            EStduio_gui_EEG_event2bin.bdf_apply.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_event2bin.bdf_apply.ForegroundColor = [0 0 0];
            EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_gui_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
            EStduio_gui_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        else
            return;
        end
    end




%%----check if eventlist can be found for each of the selected eegsets-----
    function eventlistFlag = check_evetlist(ALLEEG,EEGArray)
        eventlistFlag = 0;
        count = 0;
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            if ~isfield(EEG, 'EVENTLIST') || isempty(EEG.EVENTLIST)
                count = count+1;
                eventlistFlag = 1;
                if count==1
                    fprintf( ['\n\n',repmat('-',1,100) '\n']);
                    fprintf('For following eegset(s), we didnot find eventlist or found the eventlist is empty,please create one.\n')
                    fprintf(2,['\n',EEG.setname,'\n']);
                end
            end
        end
        if count~=0
            fprintf(['\n',repmat('-',1,100) '\n\n\n']);
        end
    end

end