%%This function is to assin eventlist to one specific bin


% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% Sep. 2023


function varargout = f_EEG_event2bin_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
addlistener(observe_EEGDAT,'Reset_eeg_panel_change',@Reset_eeg_panel_change);

%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_EEG_event2bin = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_box_EEG_event2bin;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', fig, 'Title', 'Assign Events to Bins (BINLISTER)', ...
        'Padding', 5,'BackgroundColor',ColorB_def); % Create boxpanel
elseif nargin == 1
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins (BINLISTER)',...
        'Padding', 5,'BackgroundColor',ColorB_def);
else
    EStudio_box_EEG_event2bin = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'Assign Events to Bins (BINLISTER)',...
        'Padding', 5, 'FontSize', varargin{2},'BackgroundColor',ColorB_def);%, 'HelpFcn', @event2bin_help
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
        EStduio_eegtab_EEG_event2bin.DataSelBox = uiextras.VBox('Parent', EStudio_box_EEG_event2bin,'BackgroundColor',ColorB_def);
        
        if isempty(observe_EEGDAT.EEG)
            EnableFlag = 'off';
        else
            EnableFlag = 'on';
        end
        %%display original data?
        EStduio_eegtab_EEG_event2bin.BDF_title = uiextras.HBox('Parent', EStduio_eegtab_EEG_event2bin.DataSelBox, 'Spacing', 5,'BackgroundColor',ColorB_def);
        uicontrol('Style', 'text','Parent',EStduio_eegtab_EEG_event2bin.BDF_title,...
            'String','Bin Descriptor File','FontSize',FonsizeDefault,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_event2bin.BDF_edit = uicontrol('Style', 'edit','Parent',EStduio_eegtab_EEG_event2bin.BDF_title,...
            'String','','callback',@BDF_edit,'FontSize',FonsizeDefault,'Enable',EnableFlag);
        EStduio_eegtab_EEG_event2bin.BDF_edit.KeyPressFcn=  @eeg_event2bin_presskey;
        def  = estudioworkingmemory('pop_binlister');
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        try bdfileName = def{1}; catch  bdfileName = ''; end
        if ~ischar(bdfileName) || isfile(bdfileName)
            bdfileName = '';
        end
        EStduio_eegtab_EEG_event2bin.BDF_edit.String = bdfileName;
        EStduio_eegtab_EEG_event2bin.BDF_browse = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_event2bin.BDF_title,...
            'String','Browse','callback',@BDF_browse,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        set( EStduio_eegtab_EEG_event2bin.BDF_title, 'Sizes',[100 -1 60]);
        
        %%---------------------Table---------------------------------------
        EStduio_eegtab_EEG_event2bin.table_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_event2bin.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        for ii = 1:100
            dsnames{ii,1} = '';
            dsnames{ii,2} = '';
            dsnames{ii,3} = '';
        end
        EStduio_eegtab_EEG_event2bin.table_event = uitable(  ...
            'Parent'        , EStduio_eegtab_EEG_event2bin.table_title,...
            'Data'          , dsnames, ...
            'ColumnWidth'   , {50,100,100}, ...
            'ColumnName'    , {'Bin','Description','#Occurrences'}, ...
            'RowName'       , [],...
            'ColumnEditable',[false, false, false]);
        
        %%----------------cancel and Run---------------------------------
        EStduio_eegtab_EEG_event2bin.reset_Run = uiextras.HBox('Parent',EStduio_eegtab_EEG_event2bin.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_event2bin.bdf_cancel = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_event2bin.reset_Run,...
            'String','Cancel','callback',@BDF_eeg_cancel,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_event2bin.event2bin_advanced = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_event2bin.reset_Run,...
            'String','Advanced','callback',@event2bin_advanced,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_event2bin.event2bin_advanced.KeyPressFcn=  @eeg_event2bin_presskey;
        EStduio_eegtab_EEG_event2bin.bdf_Run = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_event2bin.reset_Run,...
            'String','Run','callback',@eeg_bdf_Run,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        EStduio_eegtab_EEG_event2bin.bdf_Run.KeyPressFcn=  @eeg_event2bin_presskey;
        
        set(EStduio_eegtab_EEG_event2bin.DataSelBox,'Sizes',[30 100 30]);
        estudioworkingmemory('EEGTab_event2bin',0);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-------------------------Edit the Bin Descriptor File-------------------------------
    function BDF_edit(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        %%change color for cancel and Run
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [1 1 1];
        EStudio_box_EEG_event2bin.TitleColor= [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [1 1 1];
        
        BDFileName = EStduio_eegtab_EEG_event2bin.BDF_edit.String;
        if ~ischar(BDFileName) || isempty(BDFileName)
            msgboxText =  ['Assign Events to Bins (BINLISTER) - bdfile should be a string.'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            EStduio_eegtab_EEG_event2bin.BDF_edit.String = '';
        end
        estudioworkingmemory('EEGTab_event2bin',1);
    end

%%--------------------------------Browse the Bin Descriptor File----------------------
    function BDF_browse(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        %%change color for cancel and Run
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [1 1 1];
        EStudio_box_EEG_event2bin.TitleColor= [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [0.5137    0.7569    0.9176];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [1 1 1];
        try
            pre_patha = EStduio_eegtab_EEG_event2bin.BDF_edit.String;
            [pre_pathb, nameq, extq] = fileparts(pre_patha);
            [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)', pre_pathb);
        catch
            [bdfilename,bdfpathname] = uigetfile({'*.txt';'*.*'},'Select a Bin Descriptor File (BDF)');
        end
        if isequal(bdfilename,0)
            return;
        end
        EStduio_eegtab_EEG_event2bin.BDF_edit.String = fullfile(bdfpathname, bdfilename);
        estudioworkingmemory('EEGTab_event2bin',1);
    end

%%---------------------------Cancel----------------------------------------
    function BDF_eeg_cancel(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        def =  estudioworkingmemory('pop_binlister');
        bdfilename = def{1};
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        try bdfileName = def{1}; catch  bdfileName = ''; end
        if ~ischar(bdfileName) || isfile(bdfileName)
            bdfileName = '';
        end
        EStduio_eegtab_EEG_event2bin.BDF_edit.String = bdfileName;
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        if ~isempty(EEGArray) && numel(EEGArray)>1
            EStduio_eegtab_EEG_event2bin.event2bin_advanced.Enable = 'off';
        else
            EStduio_eegtab_EEG_event2bin.event2bin_advanced.Enable = 'on';
        end
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
    end


%%--------------------------Advanced options-------------------------------
    function event2bin_advanced(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Assign Events to Bins (BINLISTER) > Advanced');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  any(EEGArray(:) > length(observe_EEGDAT.ALLEEG))  ||  any(EEGArray(:) <1)
            EEGArray = observe_EEGDAT.CURRENTSET;estudioworkingmemory('EEGArray',EEGArray);
        end
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            def  = estudioworkingmemory('pop_binlister');
            if isempty(def)
                def = {'' '' '' 0 [] [] 0 0 0 1 0};
            end
            
            %%get defined BDfile
            bdfileName =  EStduio_eegtab_EEG_event2bin.BDF_edit.String;
            %%check is the file name is a string
            if isempty(bdfileName) || ~ischar(bdfileName)
                bdfileName = '';
            end
            %%check if the specified file exists
            if ~isfile(bdfileName)
                bdfileName ='';
                msgboxText = ['Assign Events to Bins (BINLISTER) > Advanced:Such bdfile doesnot exist'];
                titlNamerro = 'Warning for EEG Tab';
                estudio_warning(msgboxText,titlNamerro);
            end
            def{1} = bdfileName;
            
            packarray = menuBinListGUI(EEG, [], def);
            
            if isempty(packarray)
                observe_EEGDAT.eeg_panel_message =2;
                return
            end
            
            file1      = packarray{1};         % bin descriptor file
            file2      = packarray{2};         % external eventlist (read event list from)
            file3      = packarray{3};         % text file containing the updated EVENTLIST (Write resulting eventlist to)
            flagrst    = packarray{4};         % 1 means reset flags
            forbiddenCodeArray = packarray{5};
            ignoreCodeArray    = packarray{6};
            updevent   = packarray{7};
            option2do  = packarray{8};         % See  option2do below
            reportable = packarray{9};         % 1 means create a report about binlister work.
            iswarning  = packarray{10};        % 1 means create a report about binlister work.
            getfromerp = 0;
            indexEL    = packarray{12};
            EStduio_eegtab_EEG_event2bin.BDF_edit.String = file1;
            if isempty(file2) || strcmpi(file2,'no') || strcmpi(file2,'none')
                
                if isfield(EEG, 'EVENTLIST')
                    if isfield(EEG.EVENTLIST, 'eventinfo')
                        if isempty(EEG.EVENTLIST(indexEL).eventinfo)
                            msgboxText = ['Assign Events to Bins (BINLISTER) > Advanced: EVENTLIST.eventinfo structure is empty!\n'...
                                'Use Create EVENTLIST before BINLISTER'];
                            titlNamerro = 'Warning for EEG Tab';
                            estudio_warning(msgboxText,titlNamerro);
                            observe_EEGDAT.eeg_panel_message =2;
                            return
                        end
                    else
                        msgboxText =  ['Assign Events to Bins (BINLISTER) > Advanced: EVENTLIST.eventinfo structure was not found, please Create EVENTLIST before BINLISTER'];
                        titlNamerro = 'Warning for EEG Tab';
                        estudio_warning(msgboxText,titlNamerro);
                        observe_EEGDAT.eeg_panel_message =2;
                        return
                    end
                else
                    msgboxText =  ['Assign Events to Bins (BINLISTER) > Advanced: EVENTLIST structure was not found, Please Create EVENTLIST before BINLISTER'];
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_EEGDAT.eeg_panel_message =2;
                    return
                end
                logfilename = 'no';
                logpathname = '';
                file2 = [logpathname logfilename];
                disp('For LOGFILE, user selected INTERNAL')
            end
            estudioworkingmemory('pop_binlister', {file1, file2, file3, flagrst, forbiddenCodeArray, ignoreCodeArray,...
                updevent, option2do, reportable, iswarning, getfromerp, indexEL});
            
            
            if flagrst==1
                strflagrst = 'on';
            else
                strflagrst = 'off';
            end
            if updevent==1
                strupdevent = 'on';
            else
                strupdevent = 'off';
            end
            switch option2do
                case 0
                    msgboxText = 'Assign Events to Bins (BINLISTER) > Advanced: Where should I send the update EVENTLIST??? Pick an option.';
                    titlNamerro = 'Warning for EEG Tab';
                    estudio_warning(msgboxText,titlNamerro);
                    observe_EEGDAT.eeg_panel_message =2;
                    return
                case 1
                    stroption2do = 'Text';
                case 2
                    stroption2do = 'EEG';
                case 3
                    stroption2do = 'EEG&Text';
                case 4
                    stroption2do = 'Workspace';
                case 5
                    stroption2do = 'Workspace&Text';
                case 6
                    stroption2do = 'Workspace&EEG';
                case 7
                    stroption2do = 'All';
            end
            if reportable==1
                strreportable = 'on';
            else
                strreportable = 'off';
            end
            if iswarning==1
                striswarning = 'on';
            else
                striswarning = 'off';
            end
            if ~getfromerp
                EEG.setname = [EEG.setname '_bins']; %suggest a new name
            end
            
            %% Run pop_ command again with the inputs from the GUI
            [EEG, LASTCOM]   = pop_binlister(EEG, 'BDF', file1, 'ImportEL', file2, 'ExportEL', file3, 'Resetflag', strflagrst, 'Forbidden', forbiddenCodeArray,...
                'Ignore', ignoreCodeArray, 'UpdateEEG', strupdevent, 'SendEL2', stroption2do,'Report', strreportable, 'Warning', striswarning,...
                'Saveas', 'off', 'IndexEL', indexEL, 'History', 'gui');
            if isempty(LASTCOM)
                return;
            end
            if Numofeeg==1
                eegh(LASTCOM);
            end
            EEG = eegh(LASTCOM, EEG);
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_bins');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
            checkfileindex = checkfilexists([EEG.filepath,filesep,EEG.filename]);
            if Save_file_label && checkfileindex==1
                [pathstr, file_name, ext] = fileparts(EEG.filename);
                EEG.filename = [file_name,'.set'];
                [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                EEG = eegh(LASTCOM, EEG);
            else
                EEG.filename = '';
                EEG.saved = 'no';
                EEG.filepath = '';
            end
            [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
        
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
        observe_EEGDAT.eeg_panel_message =2;
    end

%%---------------------------Run-----------------------------------------
    function eeg_bdf_Run(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr) && eegpanelIndex~=5
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        estudioworkingmemory('f_EEG_proces_messg','Assign Events to Bins (BINLISTER) > Run');
        observe_EEGDAT.eeg_panel_message =1; %%Marking for the procedure has been started.
        
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [0 0 0];
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        
        bdfileName =  EStduio_eegtab_EEG_event2bin.BDF_edit.String;
        %%check is the file name is a string
        if isempty(bdfileName) || ~ischar(bdfileName)
            msgboxText =  ['Assign Events to Bins (BINLISTER) - bdfile should be a string'];
            EStduio_eegtab_EEG_event2bin.BDF_edit.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        %%check if the specified file exists
        if ~isfile(bdfileName)
            msgboxText =  ['Assign Events to Bins (BINLISTER) - Cannot find the specified bdfile'];
            EStduio_eegtab_EEG_event2bin.BDF_edit.String = '';
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        eventlistFlag = check_evetlist(observe_EEGDAT.ALLEEG,EEGArray);
        if eventlistFlag==1
            msgboxText =  ['Assign Events to Bins (BINLISTER) - No Eventlist or it is empty for some eegsets'];
            titlNamerro = 'Warning for EEG Tab';
            estudio_warning(msgboxText,titlNamerro);
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        ALLEEG = observe_EEGDAT.ALLEEG;
        
        def  = estudioworkingmemory('pop_binlister');
        if isempty(def)
            def = {'' '' '' 0 [] [] 0 0 0 1 0};
        end
        def{1} = bdfileName;
        estudioworkingmemory('pop_binlister',def);
        ALLEEG_out = [];
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run pop_ command again with the inputs from the GUI
            [EEG, LASTCOM]   = pop_binlister( EEG , 'BDF',bdfileName, 'IndexEL',  1, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG', 'History', 'gui' );
            if isempty(LASTCOM)
                disp('Process failed. Please check your data or you selected cancel')
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                observe_EEGDAT.eeg_panel_message =2;
                return;
            end
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            
            [ALLEEG_out,~,~,LASTCOM] = pop_newset(ALLEEG_out, EEG, length(ALLEEG_out), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
            fprintf( ['\n',repmat('-',1,100) '\n\n']);
        end
        Save_file_label = 0;
        Answer = f_EEG_save_multi_file(ALLEEG_out,1:numel(EEGArray), '_bins');
        if isempty(Answer)
            observe_EEGDAT.eeg_panel_message =2;
            return;
        end
        if ~isempty(Answer{1})
            ALLEEG_out = Answer{1};
            Save_file_label = Answer{2};
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_out(Numofeeg);
            checkfileindex = checkfilexists([EEG.filepath,filesep,EEG.filename]);
            if Save_file_label && checkfileindex==1
                [pathstr, file_name, ext] = fileparts(EEG.filename);
                EEG.filename = [file_name,'.set'];
                [EEG, LASTCOM] = pop_saveset(EEG,'filename', EEG.filename, 'filepath',EEG.filepath,'check','on');
                EEG = eegh(LASTCOM, EEG);
            else
                EEG.filename = '';
                EEG.saved = 'no';
                EEG.filepath = '';
            end
            [ALLEEG,~,~,LASTCOM] = pop_newset(ALLEEG, EEG, length(ALLEEG), 'gui', 'off');
        end
        observe_EEGDAT.ALLEEG = ALLEEG;
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
        observe_EEGDAT.eeg_panel_message =2;
    end

%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=13
            return;
        end
        EEGUpdate = estudioworkingmemory('EEGUpdate');
        if isempty(EEGUpdate) || numel(EEGUpdate)~=1 || (EEGUpdate~=0 && EEGUpdate~=1)
            EEGUpdate = 0;  estudioworkingmemory('EEGUpdate',0);
        end
        for ii = 1:100
            dsnamesdef{ii,1} = '';
            dsnamesdef{ii,2} = '';
            dsnamesdef{ii,3} = '';
        end
        if  isempty(observe_EEGDAT.EEG) || observe_EEGDAT.EEG.trials~=1 || EEGUpdate==1
            if ~isempty(observe_EEGDAT.EEG) && observe_EEGDAT.EEG.trials~=1
                EStudio_box_EEG_event2bin.TitleColor= [0.7500    0.7500    0.75000];
            else
                EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
            end
            EStduio_eegtab_EEG_event2bin.BDF_edit.Enable = 'off';
            EStduio_eegtab_EEG_event2bin.BDF_browse.Enable = 'off';
            EStduio_eegtab_EEG_event2bin.bdf_cancel.Enable = 'off';
            EStduio_eegtab_EEG_event2bin.event2bin_advanced.Enable = 'off';
            EStduio_eegtab_EEG_event2bin.bdf_Run.Enable = 'off';
            
            if ~isempty(observe_EEGDAT.EEG)  && observe_EEGDAT.EEG.trials~=1 &&  isfield(observe_EEGDAT.EEG,'EVENTLIST') && ~isempty(observe_EEGDAT.EEG.EVENTLIST) && ~isempty(observe_EEGDAT.EEG.EVENTLIST.trialsperbin)
                EEG = observe_EEGDAT.EEG;
                
                for jjj = 1:length(EEG.EVENTLIST.eventinfo)
                     bini = EEG.EVENTLIST.eventinfo(jjj).bini;
                    eventbini(jjj,1) = bini(1);
                end
                xpos = find(eventbini>0);
                for ii = 1:length(observe_EEGDAT.EEG.EVENTLIST.trialsperbin)
                    try
                        dsnames{ii,1} = num2str(ii);
                        dsnames{ii,2} = EEG.EVENTLIST.bdf(ii).description;
                        dsnames{ii,3} = num2str(EEG.EVENTLIST.trialsperbin(ii));
                    catch
                        dsnames{ii,1} = '';
                        dsnames{ii,2} = '';
                        dsnames{ii,3} ='';
                    end
                end
            else
                dsnames = dsnamesdef;
            end
            EStduio_eegtab_EEG_event2bin.table_event.Data = dsnames;
            
            observe_EEGDAT.count_current_eeg=14;
            return;
        end
        
        if ~isempty(observe_EEGDAT.EEG) &&  isfield(observe_EEGDAT.EEG,'EVENTLIST') && ~isempty(observe_EEGDAT.EEG.EVENTLIST) && (~isempty(observe_EEGDAT.EEG.EVENTLIST.trialsperbin))
            EEG = observe_EEGDAT.EEG;
            for jjj = 1:length(EEG.EVENTLIST.eventinfo)
                bini = EEG.EVENTLIST.eventinfo(jjj).bini;
                eventbini(jjj,1) = bini(1);
            end
            xpos = find(eventbini>0);
            if ~isempty(xpos)
                for ii = 1:length(observe_EEGDAT.EEG.EVENTLIST.trialsperbin)
                    try
                        dsnames{ii,1} = num2str(ii);
                        dsnames{ii,2} = EEG.EVENTLIST.bdf(ii).description;
                        dsnames{ii,3} = num2str(EEG.EVENTLIST.trialsperbin(ii));
                    catch
                        dsnames{ii,1} = '';
                        dsnames{ii,2} = '';
                        dsnames{ii,3} ='';
                    end
                end
            else
                dsnames = dsnamesdef;
            end
        else
            dsnames = dsnamesdef;
        end
        try
            EStduio_eegtab_EEG_event2bin.table_event.Data = dsnames;
        catch
            EStduio_eegtab_EEG_event2bin.table_event.Data = dsnamesdef;
        end
        EStduio_eegtab_EEG_event2bin.BDF_edit.Enable = 'on';
        EStduio_eegtab_EEG_event2bin.BDF_browse.Enable = 'on';
        EStduio_eegtab_EEG_event2bin.bdf_cancel.Enable = 'on';
        EStduio_eegtab_EEG_event2bin.event2bin_advanced.Enable = 'on';
        EStduio_eegtab_EEG_event2bin.bdf_Run.Enable = 'on';
        EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        observe_EEGDAT.count_current_eeg=14;
    end


%%--------------press return to execute "Run"----------------------------
    function eeg_event2bin_presskey(hObject, eventdata)
        keypress = eventdata.Key;
        ChangeFlag =  estudioworkingmemory('EEGTab_event2bin');
        if ChangeFlag~=1
            return;
        end
        if strcmp (keypress, 'return') || strcmp (keypress , 'enter')
            eeg_bdf_Run();
            estudioworkingmemory('EEGTab_event2bin',0);
            EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [1 1 1];
            EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [0 0 0];
            EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
            EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
            EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
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

%%--------------Reset this panel with the default parameters---------------
    function Reset_eeg_panel_change(~,~)
        if observe_EEGDAT.Reset_eeg_paras_panel~=10
            return;
        end
        estudioworkingmemory('EEGTab_event2bin',0);
        EStduio_eegtab_EEG_event2bin.bdf_Run.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_Run.ForegroundColor = [0 0 0];
        %         EStudio_box_EEG_event2bin.TitleColor= [0.0500    0.2500    0.5000];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.BackgroundColor =  [1 1 1];
        EStduio_eegtab_EEG_event2bin.bdf_cancel.ForegroundColor = [0 0 0];
        EStduio_eegtab_EEG_event2bin.BDF_edit.String= '';
        def = {'' '' '' 0 [] [] 0 0 0 1 0};
        estudioworkingmemory('pop_binlister',def);
        observe_EEGDAT.Reset_eeg_paras_panel=11;
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