%%This function is operation for EEG events

% *** This function is part of ERPLAB Studio Toolbox ***
% Author: Guanghui Zhang & Steven Luck
% Center for Mind and Brain
% University of California, Davis,
% Davis, CA
% 2023


function varargout = f_EEG_events_GUI(varargin)

global observe_EEGDAT;
addlistener(observe_EEGDAT,'count_current_eeg_change',@count_current_eeg_change);
% addlistener(observe_EEGDAT,'eeg_panel_change_message',@eeg_panel_change_message);
addlistener(observe_EEGDAT,'eeg_two_panels_change',@eeg_two_panels_change);
%---------------------------Initialize parameters------------------------------------

EStduio_eegtab_EEG_events = struct();

%-----------------------------Name the title----------------------------------------------
% global EStudio_eeg_events_box;
[version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
if nargin == 0
    fig = figure(); % Parent figure
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', fig, 'Title', 'EEG Events', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @event_help); % Create boxpanel
elseif nargin == 1
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Events', 'Padding', 5,...
        'BackgroundColor',ColorB_def, 'HelpFcn', @event_help);
else
    EStudio_eeg_events_box = uiextras.BoxPanel('Parent', varargin{1}, 'Title', 'EEG Events', 'Padding', 5,...
        'FontSize', varargin{2},'BackgroundColor',ColorB_def, 'HelpFcn', @event_help);
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

drawui_eeg_events(FonsizeDefault)
varargout{1} = EStudio_eeg_events_box;

    function drawui_eeg_events(FonsizeDefault)
        [version reldate,ColorB_def,ColorF_def,errorColorF_def] = geterplabstudiodef;
        %%--------------------channel and bin setting----------------------
        EStduio_eegtab_EEG_events.DataSelBox = uiextras.VBox('Parent', EStudio_eeg_events_box,'BackgroundColor',ColorB_def);
        if isempty(observe_EEGDAT.EEG)
            EnableFlag= 'off';
        else
            EnableFlag= 'on';
        end
        %%Summarize EEG event codes
        EStduio_eegtab_EEG_events.summarize_code_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.summarize_code = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.summarize_code_title,...
            'String','Summarize event code','callback',@summarize_code,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        %%Shift EEG event codes
        EStduio_eegtab_EEG_events.shift_code = uicontrol('Style', 'pushbutton','Parent', EStduio_eegtab_EEG_events.summarize_code_title,...
            'String','Shift event code','callback',@shift_code,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%Create and RTs
        EStduio_eegtab_EEG_events.create_rt_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.create_eventlist = uicontrol('Style', 'pushbutton','Parent',   EStduio_eegtab_EEG_events.create_rt_title ,...
            'String','Create eventlist','callback',@create_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        %%export reaction times
        EStduio_eegtab_EEG_events.exp_rt = uicontrol('Style', 'pushbutton','Parent',   EStduio_eegtab_EEG_events.create_rt_title ,...
            'String','Export RTs','callback',@exp_rt,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%Import and export eventlist
        EStduio_eegtab_EEG_events.imp_exp_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.imp_eventlist = uicontrol('Style', 'pushbutton','Parent',  EStduio_eegtab_EEG_events.imp_exp_title ,...
            'String','Import eventlist','callback',@imp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        %%export evetnlist to text file
        EStduio_eegtab_EEG_events.exp_eventlist = uicontrol('Style', 'pushbutton','Parent',  EStduio_eegtab_EEG_events.imp_exp_title ,...
            'String','Export eventlist','callback',@exp_eventlist,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        
        %%Shuffle events/bins/samples/
        EStduio_eegtab_EEG_events.shuffle_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.eeg_shuffle = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_events.shuffle_title ,...
            'String','Shuffle events/bins/samples','callback',@eeg_shuffle,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',EStduio_eegtab_EEG_events.shuffle_title); % 1A
        set(EStduio_eegtab_EEG_events.shuffle_title,'Sizes',[190 30]);
        
        %%transfer event info to EEG.event
        EStduio_eegtab_EEG_events.transfer_event_title = uiextras.HBox('Parent',EStduio_eegtab_EEG_events.DataSelBox,'Spacing',1,'BackgroundColor',ColorB_def);
        EStduio_eegtab_EEG_events.transfer_event = uicontrol('Style', 'pushbutton','Parent',EStduio_eegtab_EEG_events.transfer_event_title ,...
            'String','Transfer event info to EEG.event','callback',@transfer_event,'FontSize',FonsizeDefault,'Enable',EnableFlag,'BackgroundColor',[1 1 1]);
        uiextras.Empty('Parent',EStduio_eegtab_EEG_events.transfer_event_title); % 1A
        set(EStduio_eegtab_EEG_events.transfer_event_title,'Sizes',[190 30]);
        
        set(EStduio_eegtab_EEG_events.DataSelBox,'Sizes',[30 30 30 30 30]);
    end

%%**************************************************************************%%
%%--------------------------Sub function------------------------------------%%
%%**************************************************************************%%

%%-----------------------event help----------------------------------------
    function event_help(~,~)
        web('https://github.com/ucdavis/erplab/wiki/Manual/','-browser');
    end


%%----------Summarize the event codes for the selected EEG-----------------
    function summarize_code(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EEG Events >  Summarize event code:EEG.event is empty for the current EEG'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Summarize event code');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        for Numofeeg = 1:numel(EEGArray)
            EEG =   observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            
            if isempty(EEG.event)
                CheckFlag = 0;
                msgboxText = ['EEG Events >  Summarize event code:EEG.event is empty for',32,EEG.setname];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
            elseif isempty([EEG(1).event.type])
                CheckFlag = 0;
                msgboxText = ['EEG Events >  Summarize event code:EEG.event.type is empty for',32,EEG.setname];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
            else
                CheckFlag=1;
            end
            if CheckFlag==1
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n']);
                [EEG, LASTCOM] = pop_squeezevents(EEG,'History','gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) = EEG;
            end
        end
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Summarize event code');
        observe_EEGDAT.eeg_panel_message =2;
    end



%%--------------Shift the event codes for the selected EEG-----------------
    function shift_code(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EEG Events >  Shift event code: EEG.event is empty for the current EEG'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Shift event code');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        if numel(EEGArray)>1
            Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_shift');
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
        
        %% Get previous input parameters
        def  = erpworkingmemory('pop_erplabShiftEventCodes');
        if isempty(def)
            def = {};
        end
        
        EEG = observe_EEGDAT.EEG;
        %% Detected if prior Eventlist exists in the EEG
        if(isfield(EEG, 'EVENTLIST'))
            if(~isempty(EEG.EVENTLIST))
                eventlist_detected = true;
            else
                eventlist_detected = false;
            end
        else
            eventlist_detected = false;
        end
        
        def = [def, eventlist_detected];
        def{4} = false;
        %% Call GUI
        inputstrMat = gui_erplabShiftEventCodes(def);  % GUI
        
        % Exit when CANCEL button is pressed
        if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
            beep;
            disp('User selected Cancel');
            return;
        end
        eventcodes          = inputstrMat{1};
        timeshift           = inputstrMat{2};
        rounding            = inputstrMat{3};
        displayEEG          = false;
        displayFeedback     = 'both';
        
        % Save GUI input to working memory
        erpworkingmemory('pop_erplabShiftEventCodes', ...
            {eventcodes, timeshift, rounding, displayEEG, displayFeedback});
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if(isfield(EEG, 'EVENTLIST') && ~isempty(EEG.EVENTLIST))
                WanMessage = ['\n EEG Events >  Shift event code for EEGset:',32,EEG.setname...
                    '\n Previously Created ERPLAB EVENTLIST Detected.\n Running this function changes your event codes, and so your prior Eventlist will be deleted.\n Re-create a new ERPLAB Eventlist afterwards.\n'];
                fprintf(2,WanMessage);
            end
            
            %% Run pop_ command again with the inputs from the GUI
            [EEG, LASTCOM] = pop_erplabShiftEventCodes(EEG,'Eventcodes',eventcodes,'Timeshift',timeshift,'Rounding',rounding,'DisplayEEG', displayEEG,'DisplayFeedback', displayFeedback,'History', 'gui');
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            if numel(EEGArray) ==1
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_shift')),EEG.filename,EEGArray(Numofeeg));
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
                        if Numofeeg==1
                            eegh(LASTCOM);
                        end
                    end
                end
            end
            
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
            [observe_EEGDAT.ALLEEG, EEG,~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
        observe_EEGDAT.eeg_panel_message =2;
    end

%%------------------------Create EEG eventlist-----------------------------
    function create_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EEG Events >  Create eventlist: EEG.event is empty for the current EEG'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Create eventlist');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        if numel(EEGArray)>1
            Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_elist');
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
        
        
        %% Get previous input parameters
        def  = erpworkingmemory('pop_creabasiceventlist');
        if isempty(def)
            def = {'' 'boundary' -99 1 1};
        end
        multieeg =1;
        
        %% Call GUI
        inputstrMat = creabasiceventlistGUI(def, multieeg);  % GUI
        
        if isempty(inputstrMat) && ~strcmp(inputstrMat,'')
            disp('User selected Cancel')
            return
            
        end
        elname   = inputstrMat{1};
        boundarystrcode    = inputstrMat{2};
        newboundarynumcode = inputstrMat{3};
        rwwarn   = inputstrMat{4};
        alphanum = inputstrMat{5};
        
        erpworkingmemory('pop_creabasiceventlist', {elname, boundarystrcode, newboundarynumcode, rwwarn, alphanum});
        
        if rwwarn==1
            striswarning = 'on';
        else
            striswarning = 'off';
        end
        if alphanum==1
            stralphanum = 'on';
        else
            stralphanum = 'off';
        end
        
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            
            %% Run pop_ command again with the inputs from the GUI
            [EEG, LASTCOM] = pop_creabasiceventlist(EEG, 'Eventlist', elname, 'BoundaryString', boundarystrcode,...
                'BoundaryNumeric', newboundarynumcode,'Warning', striswarning, 'AlphanumericCleaning', stralphanum, 'History', 'gui');
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            if numel(EEGArray) ==1
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_elist')),EEG.filename,EEGArray(Numofeeg));
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
                        if Numofeeg==1
                            eegh(LASTCOM);
                        end
                    end
                end
            end
            
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
            %                 [observe_EEGDAT.ALLEEG EEG CURRENTSET] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            [observe_EEGDAT.ALLEEG, EEG, ~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
        observe_EEGDAT.eeg_panel_message =2;
    end


%%----------------Export reaction times to text file-----------------------
    function exp_rt(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export RTs');
        observe_EEGDAT.eeg_panel_message =1;
        
        if ~isfield(observe_EEGDAT.EEG,'EVENTLIST')
            erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export RTs: No EVETLIST, please create one first');
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        def  = erpworkingmemory('pop_rt2text');
        
        if isempty(def)
            def = {'' 'basic' 'on' 'off' 1};
        end
        
        e2 = length(observe_EEGDAT.EEG.EVENTLIST);
        
        %
        % Call Gui
        %
        param  = saveRTGUI(def, e2);
        
        if isempty(param)
            disp('User selected Cancel')
            return
        end
        filenamei  = param{1};
        listformat = param{2};
        header     = param{3};  % 1 means include header (name of variables)
        arfilt     = param{4};  % 1 means filter out RTs with marked flags
        indexel    = param{5};  % index for eventlist
        [pathx, filename, ext] = fileparts(filenamei);
        if header==1
            headstr = 'on';
        else
            headstr = 'off';
        end
        if arfilt==1
            arfilter = 'on';
        else
            arfilter = 'off';
        end
        erpworkingmemory('pop_rt2text', {fullfile(pathx, filename), listformat, headstr, arfilter, indexel});
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        for Numofeeg = 1:numel(EEGArray)
            
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            if ~isfield(EEG, 'EVENTLIST')
                erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export RTs:EVENTLIST structure is empty');
                observe_EEGDAT.eeg_panel_message =4;
            else
                filenameeeg = EEG.filename;
                [pathxeeg, filenameeeg, ext] = fileparts(filenameeeg);
                if isempty(filenameeeg)
                    filename = [num2str(EEGArray(Numofeeg)),'_',filename,'.txt'];
                else
                    filename = strcat(filenameeeg,'_',filename,'.txt');
                end
                filename = fullfile(pathx, filename);
                fprintf( ['\n\n',repmat('-',1,100) '\n']);
                fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
                fprintf(['The exported file name:',32,filename,'\n\n']);
                
                [EEG,values, LASTCOM] = pop_rt2text(EEG, 'filename', filename, 'listformat', listformat, 'header', headstr,...
                    'arfilter', arfilter, 'eventlist', indexel, 'History', 'gui');
                if ~isempty( values)
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                    observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) =EEG;
                else
                    fprintf(2,['Cannot export reaction times for:',32,EEG.setname,'\n']);
                    fprintf( [repmat('-',1,100) '\n']);
                end
            end
        end
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export RTs');
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=1;
    end



%%--------------------import EEG eventlist to text file--------------------
    function imp_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        if observe_EEGDAT.EEG.trials>1
            beep;
            msgboxText =  '\n Import eventlist:pop_importeegeventlist() has been tested for continuous data only.\n';
            fprintf(2,[msgboxText]);
            Source.Enable= 'off';
            return;
        end
        
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Import eventlist');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            %%check current eeg data
            
            %% Run pop_ command again with the inputs from the GUI
            [filename,pathname] = uigetfile({'*.*';'*.txt'},['Select a EVENTLIST file for eegset:',32,num2str(EEGArray(Numofeeg))]);
            ELfullname = fullfile(pathname, filename);
            
            if isequal(filename,0)
                disp('User selected Cancel');
                fprintf( ['\n',repmat('-',1,100) '\n']);
                return
            else
                disp(['For read an EVENTLIST, user selected ', ELfullname])
            end
            
            [EEG, LASTCOM] = pop_importeegeventlist( EEG, ELfullname , 'ReplaceEventList', 'on' );
            EEG = eegh(LASTCOM, EEG);
            if Numofeeg==1
                eegh(LASTCOM);
            end
            Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_impel')),EEG.filename,EEGArray(Numofeeg));
            if isempty(Answer)
                disp('User selected cancel.');
                fprintf( ['\n',repmat('-',1,100) '\n']);
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
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                end
            end
            [observe_EEGDAT.ALLEEG, ~,~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
        observe_EEGDAT.eeg_panel_message =2;
        
    end


%%--------------------export EEG eventlist to text file--------------------
    function exp_eventlist(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export eventlist');
        observe_EEGDAT.eeg_panel_message =1;
        
        if ~isfield(observe_EEGDAT.EEG,'EVENLIST') || isempty(observe_EEGDAT.EEG)
            msgboxText =  ['EEG Events >Export eventlist: Please check the current EEG.EVENTLIST'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        [fname, pathname] = uiputfile({'*.*'},'Save EVENTLIST file as (This will be suffix when using EStudio)');
        
        if isequal(fname,0)
            disp('User selected Cancel')
            return
        end
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        [xpath, suffixstr, ext] = fileparts(fname);
        
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = observe_EEGDAT.ALLEEG(EEGArray(Numofeeg));
            msgboxText = '';
            if isfield(EEG, 'EVENTLIST')
                if isempty(EEG.EVENTLIST)
                    msgboxText =  ['EEG.EVENTLIST structure is empty'];
                end
                if isfield(EEG.EVENTLIST, 'eventinfo')
                    if isempty(EEG.EVENTLIST.eventinfo)
                        msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty'];
                    end
                else
                    msgboxText =  ['EEG.EVENTLIST.eventinfo structure is empty'];
                end
            else
                msgboxText =  ['EEG.EVENTLIST structure is empty'];
            end
            
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset(No.',num2str(EEGArray(Numofeeg)),'):',32,EEG.setname,'\n\n']);
            if isempty(msgboxText)
                filenameeg = EEG.filename;
                [xpatheeg, filenameeg, exteeg] = fileparts(filenameeg);
                if isempty(filenameeg)
                    filenameeg = strcat(num2str(EEGArray(Numofeeg)),'_',suffixstr,'.txt');
                else
                    filenameeg = strcat(filenameeg,'_',suffixstr,'.txt');
                end
                filenameeg = fullfile(pathname, filenameeg);
                
                disp(['For EVENTLIST output user selected ', filenameeg])
                [EEG, LASTCOM] = pop_exporteegeventlist( EEG , 'Filename', filenameeg,'History','gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
                observe_EEGDAT.ALLEEG(EEGArray(Numofeeg)) =EEG;
            else
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                fprintf(2,['Cannot export eventlist for:',32,EEG.setname,'\n']);
                fprintf( [repmat('-',1,100) '\n']);
            end
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Export eventlist');
        observe_EEGDAT.eeg_panel_message =2;
        observe_EEGDAT.count_current_eeg=1;
    end


%%-----------------Shuffle events/bins/samples-----------------------------
    function eeg_shuffle(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Shuffle events/bins/samples');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        if numel(EEGArray)>1
            Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_shuffled');
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
        
        %% Get previous input parameters
        def = erpworkingmemory('pop_eventshuffler');
        
        if isempty(def)
            def = {[] 0};
        end
        %% Call GUI
        answer = shuffleGUI(def);
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        valueatfield = answer{1};
        specfield    = answer{2};
        
        if specfield==0
            specfieldstr = 'code';
        elseif specfield==1
            specfieldstr = 'bini';
        elseif specfield==2
            specfieldstr = 'data';
            valueatfield = 'off';
        else
            erpworkingmemory('f_EEG_proces_messg','EEG Events >  Shuffle events/bins/samples: invalid field');
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        if ~isnumeric(valueatfield) && ~strcmpi(valueatfield, 'all') && ~strcmpi(valueatfield, 'off')
            valueatfield = str2num(valueatfield);
            if isempty(valueatfield)
                msgboxText =  'EEG Events >  Shuffle events/bins/samples:Invalid value for "codes to shuffle"';
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                return;
            end
        end
        erpworkingmemory('pop_eventshuffler', {valueatfield specfield});
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset:',32,EEG.setname,'\n\n']);
            
            if ~isnumeric(valueatfield) && strcmpi(valueatfield, 'all')
                fprintf('User selected all %s\n', specfieldstr )
            elseif isnumeric(valueatfield)
                fprintf('User specified %s = %s \n', specfieldstr, vect2colon(valueatfield))
            end
            %%check current eeg data
            msgboxText ='';
            if ~isfield(EEG, 'event')
                msgboxText =  ['pop_eventshuffler did not find EEG.event field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ~isfield(EEG.event, 'type')
                msgboxText =  ['pop_eventshuffler did not find EEG.event.type field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ~isfield(EEG.event, 'latency')
                msgboxText =  ['pop_eventshuffler did not find EEG.event.latency field at dataset',32,num2str(EEGArray(Numofeeg))];
            end
            if ischar(EEG.event(1).type) && ~isfield(EEG, 'EVENTLIST')
                msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset',32,num2str(EEGArray(Numofeeg)),...
                    'We recommend to use Create EEG Eventlist to convert them into numeric ones.'];
            elseif ischar(EEG.event(1).type) && isfield(EEG, 'EVENTLIST')
                msgboxText =  ['pop_eventshuffler found alphanumeric codes at dataset',32,num2str(EEGArray(Numofeeg)),...
                    'We recommend to use Create EEG Eventlist Advance first.'];
            end
            if isempty(msgboxText)
                %% Run pop_ command again with the inputs from the GUI
                [EEG, LASTCOM] = pop_eventshuffler(EEG, 'Values', valueatfield, 'Field', specfieldstr, 'History', 'gui');
                EEG = eegh(LASTCOM, EEG);
                if Numofeeg==1
                    eegh(LASTCOM);
                end
            else
                msgboxText =  ['EEG Events >  Shuffle events/bins/samples:', msgboxText];
                erpworkingmemory('f_EEG_proces_messg',msgboxText);
                observe_EEGDAT.eeg_panel_message =4;
                fprintf( ['\n',repmat('-',1,100) '\n\n']);
                break;
            end
            
            if numel(EEGArray) ==1
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_shuffled')),EEG.filename,EEGArray(Numofeeg));
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
                        if Numofeeg==1
                            eegh(LASTCOM);
                        end
                    end
                end
            end
            
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
            [observe_EEGDAT.ALLEEG,~,~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
        observe_EEGDAT.eeg_panel_message =2;
    end


%%--------------Transfer event info to EEG.event---------------------------
    function transfer_event(Source,~)
        if isempty(observe_EEGDAT.EEG)
            Source.Enable= 'off';
            return;
        end
        %%first checking if the changes on the other panels have been applied
        [messgStr,eegpanelIndex] = f_check_eegtab_panelchanges();
        if ~isempty(messgStr)
            observe_EEGDAT.eeg_two_panels = observe_EEGDAT.eeg_two_panels+1;%%call the functions from the other panel
        end
        
        if isempty(observe_EEGDAT.EEG.event)
            Source.Enable= 'off';
            msgboxText = ['EEG Events >  Transfer event to EEG.event: EEG.event is empty for the current EEG'];
            erpworkingmemory('f_EEG_proces_messg',msgboxText);
            Source.Enable= 'off';
            observe_EEGDAT.eeg_panel_message =4;
            return;
        end
        
        if observe_EEGDAT.EEG.trials>1
            Source.Enable= 'off';
            return;
        end
        erpworkingmemory('f_EEG_proces_messg','EEG Events >  Transfer event to EEG.event');
        observe_EEGDAT.eeg_panel_message =1;
        
        EEGArray =  estudioworkingmemory('EEGArray');
        if isempty(EEGArray) ||  min(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  max(EEGArray(:)) > length(observe_EEGDAT.ALLEEG) ||  min(EEGArray(:)) <1
            EEGArray = observe_EEGDAT.CURRENTSET;
        end
        
        if numel(EEGArray)>1
            Answer = f_EEG_save_multi_file(observe_EEGDAT.ALLEEG,EEGArray, '_transf');
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
        
        %% Call GUI
        answer = overwriteventGUI;
        
        if isempty(answer)
            disp('User selected Cancel')
            return
        end
        mainfield    = answer{1};
        removenctype = answer{2}; % remove remaining event codes
        if removenctype==1
            rrcstr = 'on';
        else
            rrcstr = 'off';
        end
        iserrorf   = 0;
        
        
        for Numofeeg = 1:numel(EEGArray)
            EEG = ALLEEG_advance(EEGArray(Numofeeg));
            fprintf( ['\n\n',repmat('-',1,100) '\n']);
            fprintf(['Your current EEGset:',32,EEG.setname,'\n\n']);
            serror = erplab_eegscanner(EEG, 'pop_overwritevent', 0, 0, 0, 2, 1);
            msgboxText ='';
            if serror
                return;
            end
            %%check current eeg data
            if ~serror
                testfield1 = unique_bc2([EEG.EVENTLIST.eventinfo.(mainfield)]);
                if isempty(testfield1)
                    iserrorf = 1;
                end
                if isnumeric(testfield1)
                    testfield1 = num2str(testfield1);
                end
                if strcmp(testfield1,'"')
                    iserrorf = 1;
                end
                if iserrorf
                    msgboxText =  ['Sorry, EEG.EVENTLIST.eventinfo.'  mainfield ' field is empty!\n\n'...
                        'You should assign values to this field before overwriting EEG.event'];
                end
                
                if isempty(msgboxText)
                    [EEG, LASTCOM] = pop_overwritevent(EEG, mainfield, 'RemoveRemCodes', rrcstr,'History', 'gui');
                    if  isempty(LASTCOM)
                        fprintf( ['\n',repmat('-',1,100) '\n\n']);
                        break;
                    end
                    EEG = eegh(LASTCOM, EEG);
                    if Numofeeg==1
                        eegh(LASTCOM);
                    end
                else
                    msgboxText =  ['EEG Events >  Transfer event to EEG.event:', msgboxText];
                    erpworkingmemory('f_EEG_proces_messg',msgboxText);
                    observe_EEGDAT.eeg_panel_message =4;
                    fprintf( ['\n',repmat('-',1,100) '\n\n']);
                    break;
                end
            end
            if numel(EEGArray) ==1
                Answer = f_EEG_save_single_file(char(strcat(EEG.setname,'_transf')),EEG.filename,EEGArray(Numofeeg));
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
                        if Numofeeg==1
                            eegh(LASTCOM);
                        end
                    end
                end
            end
            
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
            [observe_EEGDAT.ALLEEG,~,~,LASTCOM] = pop_newset(observe_EEGDAT.ALLEEG, EEG, length(observe_EEGDAT.ALLEEG), 'gui', 'off');
            if Numofeeg==1
                eegh(LASTCOM);
            end
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
        observe_EEGDAT.eeg_panel_message =2;
        
    end


%%--------Settting will be modified if the selected was changed------------
    function count_current_eeg_change(~,~)
        if observe_EEGDAT.count_current_eeg ~=8
            return;
        end
        if isempty(observe_EEGDAT.EEG) || isempty(observe_EEGDAT.EEG.event)
            EnableFlag = 'off';
            EStduio_eegtab_EEG_events.summarize_code.Enable=EnableFlag;
            %%Shift EEG event codes
            EStduio_eegtab_EEG_events.shift_code.Enable=EnableFlag;%%continous eeg
            %%Create and RTs
            EStduio_eegtab_EEG_events.create_eventlist.Enable=EnableFlag;
            %%export reaction times
            EStduio_eegtab_EEG_events.exp_rt.Enable=EnableFlag;
            %%Import and export eventlist
            EStduio_eegtab_EEG_events.imp_eventlist.Enable=EnableFlag;
            %%export evetnlist to text file
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='off';
            EStduio_eegtab_EEG_events.eeg_shuffle.Enable=EnableFlag;
            EStduio_eegtab_EEG_events.transfer_event.Enable=EnableFlag;
            %             if  ~isempty(observe_EEGDAT.EEG) && isempty(observe_EEGDAT.EEG.event)
            %                 EStudio_eeg_events_box.Title = 'No events were found for  the current EEG';
            %                 EStudio_eeg_events_box.ForegroundColor= [1 0 0];
            %             end
            observe_EEGDAT.count_current_eeg=9;
            return;
        end
        
        EStudio_eeg_events_box.Title = 'EEG Events';
        EStudio_eeg_events_box.ForegroundColor= [1 1 1];
        
        
        if ~isempty(observe_EEGDAT.EEG)
            if ndims(observe_EEGDAT.EEG.data) ==3%%Epoched EEG
                EnableFlag ='off';
            else %%Continuous EEG
                EnableFlag ='on';
            end
        end
        %%Summarize EEG event codes
        EStduio_eegtab_EEG_events.summarize_code.Enable=EnableFlag;
        %%Shift EEG event codes
        EStduio_eegtab_EEG_events.shift_code.Enable=EnableFlag;%%continous eeg
        %%Create and RTs
        EStduio_eegtab_EEG_events.create_eventlist.Enable=EnableFlag;
        %%export reaction times
        EStduio_eegtab_EEG_events.exp_rt.Enable=EnableFlag;
        %%Import and export eventlist
        EStduio_eegtab_EEG_events.imp_eventlist.Enable=EnableFlag;
        %%export evetnlist to text file
        if ~isempty(observe_EEGDAT.EEG)
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='on';
        else
            EStduio_eegtab_EEG_events.exp_eventlist.Enable='off';
        end
        EStduio_eegtab_EEG_events.eeg_shuffle.Enable=EnableFlag;
        EStduio_eegtab_EEG_events.transfer_event.Enable=EnableFlag;
        observe_EEGDAT.count_current_eeg=9;
    end

end