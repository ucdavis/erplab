%%This function is to assin eventlist to one specific bin


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_eeglabtool_GUI(varargin) 

global observe_EEGDAT;
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
% addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);

%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_eeglab_tool = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_eeglab_tool;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_eeglab_tool = uiextras.BoxPanel('Parent', fig, 'Title',...
        'EEGLAB Tools (only for one selected dataset)', 'Padding', 5,'BackgroundColor',ColorB_def); % , 'HelpFcn', @eeglabtool_help
elseif nargin == 1
    EStudio_box_eeglab_tool = uiextras.BoxPanel('Parent', varargin{1}, 'Title',...
        'EEGLAB Tools (only for one selected dataset)', 'Padding ', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_eeglab_tool = uiextras.BoxPanel('Parent', varargin{1}, 'Title',...
        'EEGLAB Tools (only for one selected dataset)', 'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);
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
varargout{1} = EStudio_box_eeglab_tool;

    function drawui_event2bin_eeg(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_eegtab_eeglab_tool.DataSelBox = uiextras.VBox('Parent', EStudio_box_eeglab_tool,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%About this dataset and Edit Dataset Info
        EStduio_eegtab_eeglab_tool.datainfo_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        
        EStduio_eegtab_eeglab_tool.about_eegdata = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.datainfo_title,...
            'String','About this dataset','callback',@about_eegdata,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_tool.edit_eeginfor = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.datainfo_title,...
            'String','Edit Dataset Info','callback',@edit_eeginfor,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        
        %%Edit eeg events and channel locations
        EStduio_eegtab_eeglab_tool.event_chanlocs_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_tool.edit_eegevent = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.event_chanlocs_title,...
            'String','Event values','callback',@edit_eegevent,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_tool.edit_eegchanlocs = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.event_chanlocs_title,...
            'String','Chan locations','callback',@edit_eegchanlocs,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        
        %%Reject data using Clean Rawdata and ASR
        EStduio_eegtab_eeglab_tool.eeg_ASR_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_tool.eeg_asr = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.eeg_ASR_title,...
            'String','Reject data using clean rawdata and ASR','callback',@eeg_asr,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%adjust event latencies
        EStduio_eegtab_eeglab_tool.eeg_adjustlatency_title = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_tool.adjust_latency = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_eeglab_tool.eeg_adjustlatency_title,...
            'String','Adjust event latencies','callback',@adjust_latency,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',EStduio_eegtab_eeglab_tool.eeg_adjustlatency_title);
        set(EStduio_eegtab_eeglab_tool.eeg_adjustlatency_title,'Sizes',[130 -1])
        
        
        %%Plot channel function
        EStduio_eegtab_eeglab_tool.plotchan_title1 = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent', EStduio_eegtab_eeglab_tool.plotchan_title1,...
            'String','Plot channel function:','FontWeight','bold','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_tool.plotchan_title2 = uiextras.HBox('Parent', EStduio_eegtab_eeglab_tool.DataSelBox, 'BackgroundColor',ColorB_def);
        EStduio_eegtab_eeglab_tool.eeg_spcetra_map = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.plotchan_title2,...
            'String','Spectra & maps','callback',@eeg_spcetra_map,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_eeglab_tool.eeg_chanprop = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.plotchan_title2,...
            'String','Chan prop.','callback',@eeg_chanprop,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        EStduio_eegtab_eeglab_tool.eeg_tfr = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_eeglab_tool.plotchan_title2,...
            'String','Time-frequency','callback',@eeg_tfr,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set(EStduio_eegtab_eeglab_tool.DataSelBox,'Sizes',[30 30 30 30 20 30])
    end


%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-----------------------About the current EEG-----------------------------
    function about_eegdata(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > About this dataset');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        if numel(EEGArray)~=1
            msgboxText = 'EEGLAB Tools > About this dataset: Only works for one selected dataset';
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        
        for Numofeeg = 1:numel(EEGArray)%%loop for subjects
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            if ~isempty(EEG.comments)
                titleName = ['EEGset',32,num2str(EEGArray(Numofeeg)),':',EEG.setname];
                [EEG.comments,LASTCOM] = pop_comments(EEG.comments,titleName);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
            else
                msgboxText = ['EEGLAB Tools > EEG.comments is empty for',32,EEG.setname];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > About this dataset');
        observe_EEGDAT.eeg_panel_message =2; %%Marking for the procedure has been started.
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        observe_EEGDAT.count_current_eeg=26;
    end


%%---------------------EEG datasets information----------------------------
    function edit_eeginfor(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Edit Dataset Info');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Edit Dataset Info: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        EEG = observe_EEGDAT.ALLEEG(EEGArray);
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['Your current EEGset(No.',num2str(EEGArray(1)),'):',32,EEG.setname,'\n\n']);
        
        %%Only the slected bin and chan were selected to remove baseline and detrending and others are remiained.
        [EEG, LASTCOM] = pop_editset(EEG);
        fprintf(LASTCOM,'\n');
        if isempty(LASTCOM)
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            rerurn;
        end
        EEG = eegh(LASTCOM, EEG);
        eegh(LASTCOM);
        Answer = f_EEG_save_multi_file(EEG,1,'_eeginfo');
        if isempty(Answer)
            return;
        end
        Save_file_label =0;
        if ~isempty(Answer{1})
            EEG = Answer{1};
            Save_file_label = Answer{2};
        end
        
        checkfileindex = checkfilexists([EEG.filepath,filesep, EEG.filename]);
        if Save_file_label==1 && checkfileindex==1
            [pathstr, file_name, ext] = fileparts(EEG.filename);
            EEG.filename = [file_name,'.set'];
            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
            EEG = eegh(LASTCOM, EEG);
            eegh(LASTCOM);
            fprintf(LASTCOM,'\n');
        else
            EEG.filename = '';
            EEG.saved = 'no';
            EEG.filepath = '';
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        fprintf(LASTCOM,'\n');
        fprintf( ['\n',repmat('-',1,100) '\n']);
        eegh(LASTCOM);
        
        observe_EEGDAT.ALLEEG = ALLEEG;
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        erpworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end

%%--------------------Event values-----------------------------------------
    function edit_eegevent(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Event values');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET; erpworkingmemory('EEGArray',EEGArray);
        end
        
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Event value: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        
        EEG = observe_EEGDAT.ALLEEG(EEGArray);
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*Event values*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(['Your current data',32,num2str(EEGArray),':',EEG.setname,'\n']);
        
        %%Edit events contained in EEG dataset structure
        [EEG, LASTCOM] =  pop_editeventvals(EEG);
        if isempty(LASTCOM)
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
        fprintf(LASTCOM,'\n');
        EEG = eegh(LASTCOM, EEG);
        eegh(LASTCOM);
        
        Answer = f_EEG_save_multi_file(EEG,1,'_evetvalue');
        if isempty(Answer)
            return;
        end
        Save_file_label =0;
        if ~isempty(Answer{1})
            EEG = Answer{1};
            Save_file_label = Answer{2};
        end
        
        checkfileindex = checkfilexists([EEG.filepath,filesep, EEG.filename]);
        if Save_file_label && checkfileindex==1
            [pathstr, file_name, ext] = fileparts(EEG.filename);
            EEG.filename = [file_name,'.set'];
            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
            EEG = eegh(LASTCOM, EEG);
            fprintf(LASTCOM,'\n');
            eegh(LASTCOM);
        else
            EEG.filename = '';
            EEG.saved = 'no';
            EEG.filepath = '';
        end
        [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        fprintf(LASTCOM,'\n');
        fprintf( ['\n',repmat('-',1,100) '\n']);
        eegh(LASTCOM);
        observe_EEGDAT.ALLEEG = ALLEEG;
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        erpworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------------------Edit channel location--------------------------------
    function edit_eegchanlocs(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Chan locations');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Chan locations: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        %%Edit the channel locations
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['Edit the channel locations for eegset(s):',32,num2str(EEGArray),'\n']);
        [EEG, chaninfo, urchans, LASTCOM] =pop_chanedit(ALLEEG(EEGArray));
        LASTCOM = ['EEG',LASTCOM];
        if isempty(LASTCOM)
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
        fprintf(LASTCOM,'\n');
        EEG = eegh(LASTCOM, EEG);
        eegh(LASTCOM);
        
        Answer = f_EEG_save_multi_file(EEG,1,'_chanlos');
        if isempty(Answer)
            return;
        end
        Save_file_label =0;
        if ~isempty(Answer{1})
            EEG = Answer{1};
            Save_file_label = Answer{2};
        end
        if Save_file_label
            [pathstr, file_name, ext] = fileparts(EEG.filename);
            EEG.filename = [file_name,'.set'];
            checkfileindex = checkfilexists([EEG.filepath,filesep, EEG.filename]);
            if checkfileindex==1
                [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                EEG = eegh(LASTCOM, EEG);
                fprintf(LASTCOM,'\n');
            end
        else
            EEG.filename = '';
            EEG.saved = 'no';
            EEG.filepath = '';
        end
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        fprintf(LASTCOM,'\n');
        fprintf( ['\n',repmat('-',1,100) '\n']);
        eegh(LASTCOM);
        observe_EEGDAT.ALLEEG = ALLEEG;
        
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        erpworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end


%%----------------Reject data using clean rawdata and ASR------------------
    function eeg_asr(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Reject data using clean rawdata and ASR');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG)) ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET; erpworkingmemory('EEGArray',EEGArray);
        end
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Reject data using clean rawdata and ASR: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        ALLEEG = observe_EEGDAT.ALLEEG;
        %%Edit the channel locations
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['**Reject data using clean rawdata and ASR**\n']);
        fprintf(['Your current eegset(s):',32,num2str(EEGArray),'\n']);
        try
            [EEG,LASTCOM] =pop_clean_rawdata(ALLEEG(EEGArray));
        catch
            msgboxText = ['EEGLAB Tools > Reject data using clean rawdata and ASR: Clean Rawdata tool was not included in EEGLAB plugin'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        if isempty(LASTCOM)
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            return;
        end
        fprintf(LASTCOM,'\n');
        EEG = eegh(LASTCOM, EEG);
        eegh(LASTCOM);
        
        Answer = f_EEG_save_multi_file(EEG,1,'_asr');
        if isempty(Answer)
            return;
        end
        Save_file_label =0;
        if ~isempty(Answer{1})
            EEG = Answer{1};
            Save_file_label = Answer{2};
        end
        checkfileindex = checkfilexists([EEG.filepath,filesep, EEG.filename]);
        if Save_file_label && checkfileindex==1
            [pathstr, file_name, ext] = fileparts(EEG.filename);
            EEG.filename = [file_name,'.set'];
            [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
            EEG = eegh(LASTCOM, EEG);
            eegh(LASTCOM);
        else
            EEG.filename = '';
            EEG.saved = 'no';
            EEG.filepath = '';
        end
        [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        fprintf( ['\n',repmat('-',1,100) '\n']);
        eegh(LASTCOM);
        observe_EEGDAT.ALLEEG = ALLEEG;
        try
            Selected_EEG_afd =  [length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1:length(observe_EEGDAT.ALLEEG)];
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG)-numel(EEGArray)+1;
        catch
            Selected_EEG_afd = length(observe_EEGDAT.ALLEEG);
            observe_EEGDAT.CURRENTSET = length(observe_EEGDAT.ALLEEG);
        end
        observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(observe_EEGDAT.CURRENTSET);
        erpworkingmemory('EEGArray',Selected_EEG_afd);
        assignin('base','EEG',observe_EEGDAT.EEG);
        assignin('base','CURRENTSET',observe_EEGDAT.CURRENTSET);
        assignin('base','ALLEEG',observe_EEGDAT.ALLEEG);
        observe_EEGDAT.count_current_eeg=1;
        observe_EEGDAT.eeg_panel_message =2;
    end

%%----------------adjust event latencies-----------------------------------
    function adjust_latency(~,~)
        BackERPLABcolor = [1 0.9 0.3];    % yellow
        question = ["We do not support this EEGLAB function. We recommend that you instead use ERPLAB's function: Shift Event Codes for Continuous EEG.\nAlternatively, you can quite from ERPLAB Studio, launch EEGLAB, and run the EEGLAB function."];
        title = 'EEGLAB Tool > Adjust event latencies';
        oldcolor = get(0,'DefaultUicontrolBackgroundColor');
        set(0,'DefaultUicontrolBackgroundColor',BackERPLABcolor)
        button = questdlg(sprintf(question), title,'Yes','Yes');
        set(0,'DefaultUicontrolBackgroundColor',oldcolor);
    end


%%----------------------Spectra and maps-----------------------------------
    function eeg_spcetra_map(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Spectra and maps');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Spectra and maps: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['*Channel spectra and maps*',32,32,32,32,datestr(datetime('now')),'\n']);
            fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
            chanlocs_present = 0;
            if ~isempty(EEG.chanlocs)
                if isfield(EEG.chanlocs, 'theta')
                    tmpchanlocs = EEG.chanlocs;
                    if any(~cellfun(@isempty, { tmpchanlocs.theta }))
                        chanlocs_present = 1;
                    end
                end
            end
            dataflag = 1;
            geometry = { [2 1] [2 1] [2 1] [2 1] [2 1] [2 1]};
            scalp_freq = fastif(chanlocs_present, { '6 10 22' }, { '' 'enable' 'off' });
            promptstr    = { { 'style' 'text' 'string' 'Epoch time range to analyze [min_ms max_ms]:' }, ...
                { 'style' 'edit' 'string' [num2str( EEG.xmin*1000) ' ' num2str(EEG.xmax*1000)] }, ...
                { 'style' 'text' 'string' 'Percent data to sample (1 to 100):'}, ...
                { 'style' 'edit' 'string' '100' }, ...
                { 'style' 'text' 'string' 'Frequencies to plot as scalp maps (Hz):'}, ...
                { 'style' 'edit' 'string'  scalp_freq{:} }, ...
                { 'style' 'text' 'string' 'Apply to EEG|ERP|BOTH:'}, ...
                { 'style' 'edit' 'string' 'EEG' }, ...
                { 'style' 'text' 'string' 'Plotting frequency range [lo_Hz hi_Hz]:'}, ...
                { 'style' 'edit' 'string' '2 25' }, ...
                { 'style' 'text' 'string' 'Spectral and scalp map options (see topoplot):' } ...
                { 'style' 'edit' 'string' '''electrodes'',''off''' } };
            if EEG.trials == 1
                geometry(3) = [];
                promptstr(7:8) = [];
            end
            result       = inputgui( geometry, promptstr, 'pophelp(''pop_spectopo'')', ['Channel spectra and maps for eegset:',num2str(EEGArray(Numofeeg))]);
            if size(result,1) == 0
                erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > EEGLAB Tools > Spectra and maps:User selected cancel');
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                return;
            end
            timerange    = eval( [ '[' result{1} ']' ] );
            options = [];
            if isempty(EEG.chanlocs)
                disp('Topographic plot options ignored. First import a channel location file');
                disp('To plot a single channel, use channel property menu or the following call');
                disp('  >> figure; chan = 1; spectopo(EEG.data(chan,:,:), EEG.pnts, EEG.srate);');
            end
            if EEG.trials ~= 1
                Electrodelabel = result{6};
                frerange = str2num(result{5});
            else
                Electrodelabel = result{5};
                frerange = str2num(result{4});
            end
            Newfile = split(Electrodelabel,',');
            if strcmpi( Newfile{2},'on')
                Electrodelabel = 'on';
            elseif strcmpi( Newfile{2},'off')
                Electrodelabel = 'off';
            elseif strcmpi( Newfile{2},'labels')
                Electrodelabel = 'labels';
            elseif strcmpi( Newfile{2},'numbers')
                Electrodelabel = 'numbers';
            elseif strcmpi( Newfile{2},'ptslabels')
                Electrodelabel = 'ptslabels';
            elseif strcmpi( Newfile{2},'ptsnumbers')
                Electrodelabel = 'ptsnumbers';
            else
                Electrodelabel = 'off';
            end
            figspec= figure('tag', 'spectopo');
            set(figspec,'Name',['eegset',32,num2str(EEGArray(Numofeeg)),': Channel spectra and maps for',32,EEG.setname],'NumberTitle', 'off');
            pop_spectopo(EEG, 1, str2num(result{1}), 'EEG' ,'percent',str2num(result{2}),...
                'freq', str2num(result{3}), 'freqrange',frerange,'electrodes',Electrodelabel);
            if eval(result{2}) ~= 100, options = [ options ', ''percent'', '  result{2} ]; end
            if ~isempty(result{3}) && ~isempty(EEG.chanlocs), options = [ options ', ''freq'', ['  result{3} ']' ]; end
            if EEG.trials ~= 1
                processflag = result{4};
                if ~isempty(result{5}),    options = [ options ', ''freqrange'',[' result{5} ']' ]; end
                if ~isempty(result{6}),    options = [ options ',' result{6} ]; end
            else
                processflag = 'EEG';
                if ~isempty(result{4}),    options = [ options ', ''freqrange'',[' result{4} ']' ]; end
                if ~isempty(result{5}),    options = [ options ',' result{5} ]; end
            end
            
            %%History
            LASTCOM = sprintf('pop_spectopo(EEG, %d, [%s], ''%s'' %s);', 1, num2str(timerange), processflag, options);
            observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = eegh(LASTCOM, EEG);
            eegh(LASTCOM);
            observe_EEGDAT.EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf(LASTCOM,'\n');
            fprintf( ['\n',repmat('-',1,100) '\n']);
        end%%end loop for subject
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=26;
    end


%%---------------------Channel properties----------------------------------
    function eeg_chanprop(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Chan properties');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Chan properties: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        EEG = observe_EEGDAT.EEG;
        typecomp = 1;    % defaults
        chanorcomp = 1;
        commandchan = 'tmpchanlocs = EEG(1).chanlocs; [tmp tmpval] = pop_chansel({tmpchanlocs.labels}, ''withindex'', ''on'', ''selectionmode'', ''single''); set(findobj(gcbf, ''tag'', ''chan''), ''string'',tmpval); clear tmp tmpchanlocs tmpval';
        uitext = { { 'style' 'text' 'string' fastif(typecomp,'Channel index(ices) to plot:','Component index(ices) to plot:') } ...
            { 'style' 'edit' 'string' '1', 'tag', 'chan' } ...
            { 'style' 'pushbutton' 'string'  '...', 'enable' fastif(~isempty(EEG(1).chanlocs) && typecomp, 'on', 'off') 'callback' commandchan } ...
            { 'style' 'text' 'string' 'Spectral options (see spectopo() help):' } ...
            { 'style' 'edit' 'string' '''freqrange'', [2 50]' } {} };
        uigeom = { [2 1 0.5 ] [2 1 0.5] };
        result = inputgui('geometry', uigeom, 'uilist', uitext, 'helpcom', 'pophelp(''pop_prop'');', ...
            'title', fastif( typecomp, 'Channel properties - pop_prop()', 'Component properties - pop_prop()'));
        if size( result, 1 ) == 0
            erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Chan properties:User selected cancel');
            observe_EEGDAT.eeg_panel_message =4;
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            return;
        end
        
        chanoristr = result{1};
        try
            chanorcomp   = eeg_decodechan(EEG.chanlocs, result{1} );
        catch
            fprintf(2, ['\nEEGLAB Tools > Chan properties: Channel index out of range, we therefore set it to 1\n']);
            titlNamerro = 'Warning for EEG Tab';
            msgboxText =   ['EEGLAB Tools > Chan properties: Channel index out of range, we therefore set it to 1'];
            estudio_warning(msgboxText,titlNamerro);
            chanorcomp = 1;
        end
        spec_opt     = eval( [ '{' result{2} '}' ] );
        if isempty(chanorcomp)
            msgboxText = ['EEGLAB Tools > Chan properties:Please define Channel index(ices)'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =4;
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            return;
        end
        
        
        EEG = observe_EEGDAT.ALLEEG(EEGArray);
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*Chan properties*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(['Your current data',32,num2str(EEGArray(Numofeeg)),':',EEG.setname,'\n']);
        for Numofchan = 1:numel(chanorcomp)
            LASTCOM =  pop_prop( EEG, 1, chanorcomp(Numofchan), NaN, spec_opt);
            set(gcf,'Name',['eegset',32,num2str(EEGArray),': Channel properties for',32,EEG.setname],'NumberTitle', 'off');
        end
        LASTCOM = sprintf('pop_prop( EEG, %d, %s, NaN, %s);', typecomp, ['[',num2str(chanorcomp),']'], vararg2str( { spec_opt } ) );
        observe_EEGDAT.ALLEEG(EEGArray) = eegh(LASTCOM, EEG);
        fprintf(LASTCOM,'\n');
        eegh(LASTCOM);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        observe_EEGDAT.EEG=observe_EEGDAT.ALLEEG(EEGArray);
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Chan properties');
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=26;
    end


%%------------------------Time-frequency-----------------------------------
    function eeg_tfr(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) &&  eegpanelIndex~=0
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Time-frequency');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:)<1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        if numel(EEGArray)~=1
            msgboxText = ['EEGLAB Tools > Time-frequency: Only works for one selected dataset'];
            Source.Enable = 'off';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            return;
        end
        
        EEG = observe_EEGDAT.ALLEEG(EEGArray);
        fprintf( ['\n\n',repmat('-',1,100) '\n']);
        fprintf(['*Chan time-frequency*',32,32,32,32,datestr(datetime('now')),'\n']);
        fprintf(['Your current data',32,num2str(EEGArray),':',EEG.setname,'\n']);
        LASTCOM =  pop_newtimef(EEG,1);
        if isempty(LASTCOM)
            observe_EEGDAT.eeg_panel_message =1;
            fprintf( ['\n',repmat('-',1,100) '\n']);
            return;
        end
        set(gcf,'Name',['eegset',32,num2str(EEGArray),': Time-frequency for',32,EEG.setname],'NumberTitle', 'off');
        LASTCOM =LASTCOM(8:end);
        observe_EEGDAT.ALLEEG(EEGArray) = eegh(LASTCOM, EEG);
        fprintf(LASTCOM,'\n');
        eegh(LASTCOM);
        fprintf( ['\n',repmat('-',1,100) '\n']);
        erpworkingmemory('f_EEG_proces_messg','EEGLAB Tools > Time-frequency');
        
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.EEG =  observe_EEGDAT.ALLEEG(EEGArray);
        observe_EEGDAT.count_current_eeg=26;
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=11
            return;
        end
        EEGUpdate = erpworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  erpworkingmemory('EEGUpdate',0);
        end
        if  isempty(observe_EEGDAT.EEG) || EEGUpdate==1
            EStduio_eegtab_eeglab_tool.about_eegdata.Enable =  'off';
            EStduio_eegtab_eeglab_tool.edit_eeginfor.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_eegevent.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_eegchanlocs.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_samplerate.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_asr.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_spcetra_map.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_chanprop.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_tfr.Enable=  'off';
            EStduio_eegtab_eeglab_tool.adjust_latency.Enable=  'off';
            observe_EEGDAT.count_current_eeg=12;
            return;
        end
        
        EEGArray =  erpworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;erpworkingmemory('EEGArray',EEGArray);
        end
        
        if numel(EEGArray)~=1
            EStduio_eegtab_eeglab_tool.about_eegdata.Enable =  'off';
            EStduio_eegtab_eeglab_tool.edit_eeginfor.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_eegevent.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_eegchanlocs.Enable=  'off';
            EStduio_eegtab_eeglab_tool.edit_samplerate.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_asr.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_spcetra_map.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_chanprop.Enable=  'off';
            EStduio_eegtab_eeglab_tool.eeg_tfr.Enable=  'off';
            EStduio_eegtab_eeglab_tool.adjust_latency.Enable=  'off';
            observe_EEGDAT.count_current_eeg=12;
            return;
        end
        EStduio_eegtab_eeglab_tool.about_eegdata.Enable =  'on';
        EStduio_eegtab_eeglab_tool.edit_eeginfor.Enable=  'on';
        EStduio_eegtab_eeglab_tool.edit_eegevent.Enable=  'on';
        EStduio_eegtab_eeglab_tool.edit_eegchanlocs.Enable=  'on';
        EStduio_eegtab_eeglab_tool.edit_samplerate.Enable=  'on';
        if observe_EEGDAT.EEG.trials~=1
            EStduio_eegtab_eeglab_tool.eeg_asr.Enable=  'off';
        else
            EStduio_eegtab_eeglab_tool.eeg_asr.Enable=  'on';
        end
        EStduio_eegtab_eeglab_tool.eeg_spcetra_map.Enable=  'on';
        EStduio_eegtab_eeglab_tool.eeg_chanprop.Enable=  'on';
        EStduio_eegtab_eeglab_tool.eeg_tfr.Enable=  'on';
        EStduio_eegtab_eeglab_tool.adjust_latency.Enable=  'on';
        observe_EEGDAT.count_current_eeg=12;
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
